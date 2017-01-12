#!/usr/bin/env python3

"""mc-backup.py: automate backups of my Minecraft servers, using the
minecraft-control wrapper.

Usage: mc-backup.py -c minecraft_control.ini -s /path/to/server

The `minecraft-control` password is obtained from the settings.ini for
minecraft-control. Backups are placed in the `backups/` directory under the
Minecraft server root, named with datetime stamps.

See `mc-backup.py --help` for command usage.

minecraft-control is available at: https://github.com/kirsle/minecraft-control

Example setting this up in cron:
0 2 * * * ~/cron/mc-backup.py -c ~/mc-control/settings.ini -s ~/mc-server

--Kirsle
https://www.kirsle.net/"""

import argparse
from configparser import RawConfigParser
import datetime
import logging
import os
import subprocess
import sys
import time

# Import the minecraft-control client library.
from mcclient import MinecraftClient

# Threshhold for the number of backups to retain. Modify these variables if you
# don't like them.
DAILY_BACKUPS  = 7  # Retain the 7 most recent daily backups
WEEKLY_BACKUPS = 4  # For backups > DAILY_BACKUPS, keep this many copies around
                    # once per week.
WEEKLY_WEEKDAY = 6  # For weekly backups, base them around Sundays.
                    # 0=Monday .. 6=Sunday

logging.basicConfig()
log = logging.getLogger("mc-backup")
log.setLevel(logging.INFO)

class Application:
    def __init__(self, args):
        """Initialize the application."""
        self.args = args

        # Verify settings.
        self.verify_args()

        self.config   = dict() # minecraft-control configuration
        self.client   = None   # MinecraftClient instance
        self.today    = datetime.datetime.utcnow().strftime("%Y-%m-%d_%H-%M-%S")
        self.world    = self.get_world_name()
        log.info("Today's date/time: {}".format(self.today))

        # Load the minecraft-control configuration.
        self.load_mc_config()

    def verify_args(self):
        """Do some sanity checking on input arguments."""

        # The minecraft-control config file.
        if not os.path.isfile(self.args.config):
            log.error("{}: not a file".format(self.args.config))
            sys.exit(1)

        # The server directory.
        if not os.path.isfile("{}/server.properties".format(self.args.server)):
            log.error("{}: not a Minecraft server directory (no "
                "server.properties file present)".format(self.args.server))
            sys.exit(1)


    def load_mc_config(self):
        """Load the configuration from minecraft-control."""
        log.debug("Loading minecraft-control settings from {}".format(
            args.config
        ))

        parser = RawConfigParser()
        with open(self.args.config, "r") as fh:
            parser.readfp(fh)

        self.config["host"]     = parser.get("tcp-server", "address")
        self.config["port"]     = parser.get("tcp-server", "port")
        self.config["password"] = parser.get("auth", "password")
        self.config["method"]   = parser.get("auth", "method")

    def get_world_name(self):
        """Load the server.properties to find the world name."""

        with open("{}/server.properties".format(self.args.server), "r") as fh:
            for line in fh:
                if not "=" in line: continue
                parts = line.split("=", 1)
                key = parts[0].strip()
                value = parts[1].strip()

                if key == "level-name":
                    return value

        raise ValueError("No level-name found in server.properties!")

    def run(self):
        """Run the main program's logic."""

        # Change into the server's directory.
        os.chdir(self.args.server)

        # If we're only culling backups, do that and exit.
        if self.args.clean:
            return self.cull_backups()

        # Backups directory.
        backups = os.path.join(self.args.server, "backups")
        if not os.path.isdir(backups):
            log.info("Creating backups directory: {}".format(backups))
            os.mkdir(backups)

        # Connect to the Minecraft-Control server.
        log.info("Connecting to Minecraft control server...")
        self.client = MinecraftClient(
            host=self.config["host"],
            port=self.config["port"],
            password=self.config["password"],
            methods=[self.config["method"]],
        )
        self.client.add_handler("auth_ok", self.on_auth_ok)
        self.client.add_handler("auth_error", self.on_auth_error)
        self.client.add_handler("server_message", self.on_message)

        self.client.connect()
        self.client.start()

    def on_auth_ok(self, mc):
        """Handle successful authentication."""
        log.info("Connection to server established and authenticated!")

        # Target file name.
        fname = self.today + ".tar.gz"
        target = os.path.join("backups", fname)

        # Turn off saving and save the world now.
        log.info("Turning off auto-saving and saving the world now!")
        self.client.sendline("save-off")
        self.client.sendline("save-all")
        time.sleep(5)

        # Archive the world.
        log.info("Backing up the world as: {}".format(target))
        subprocess.call(["tar", "czvf", target, self.world])

        # Turn saving back on.
        time.sleep(5)
        log.info("Turning auto-saving back on!")
        self.client.sendline("save-on")

        # Cull old backups.
        self.cull_backups()
        quit()

    def cull_backups(self):
        """Trim the backup copies and remove older backups."""
        log.info("Culling backups...")

        # Date cut-off for daily backups.
        daily_cutoff = (
            datetime.datetime.utcnow() - datetime.timedelta(days=DAILY_BACKUPS)
            ).strftime("%Y-%m-%d")
        log.debug("Daily cutoff date: {}".format(daily_cutoff))

        # Number of weekly backups spared.
        weekly_spared = 0

        # Check all the existing backups.
        for tar in sorted(os.listdir("backups"), reverse=True):
            if not tar.endswith(".tar.gz"):
                continue

            try:
                dt      = datetime.datetime.strptime(tar, "%Y-%m-%d_%H-%M-%S.tar.gz")
                weekday = dt.weekday()
                date    = dt.strftime("%Y-%m-%d")
            except Exception as e:
                log.error("Error parsing datetime from existing backup {}: {}".format(
                    tar, e,
                ))
                continue

            # If this is within the daily cutoff, we keep it.
            if date > daily_cutoff:
                log.debug("DAILY KEEP: {} is within the daily cutoff".format(tar))
                continue

            # Now we're at backups older than our daily threshhold, so we only
            # want to keep one backup per week until we have WEEKLY_BACKUPS
            # copies, and only for backups taken on WEEKLY_WEEKDAY day-of-week.
            if weekday == WEEKLY_WEEKDAY and weekly_spared < WEEKLY_BACKUPS:
                log.debug("WEEKLY KEEP: {} is being kept".format(tar))
                weekly_spared += 1
                continue

            # All other old backups get deleted.
            log.info("Cull old backup: {}".format(tar))
            os.unlink("backups/{}".format(tar))

    def on_auth_error(self, mc, error):
        """Handle unsuccessful authentication."""
        log.error(error)
        sys.exit(1)

    def on_message(self, mc, message):
        """Handle a Minecraft server message."""
        log.info("Minecraft server says: {}".format(message))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Minecraft Backup Taker")
    parser.add_argument("--debug", "-d",
        help="Turn on debug mode.",
        action="store_true",
    )
    parser.add_argument("--config", "-c",
        help="Path to minecraft-control configuration file (settings.ini)",
        type=str,
        required=True,
    )
    parser.add_argument("--server", "-s",
        help="Path to the Minecraft server on disk (should contain "
            "./server.properties file)",
        type=str,
        required=True,
    )
    parser.add_argument("--clean",
        help="Clean up (cull) old backups; do not create a new backup. "
            "This executes the cull backups functionality which trims the "
            "set of stored backups on disk to fit your backup threshholds. "
            "This option does not trigger a *new* backup to be taken.",
        action="store_true",
    )
    args = parser.parse_args()
    if args.debug:
        log.setLevel(logging.DEBUG)

    Application(args).run()

