#!/usr/bin/env python3

"""mc-backup.py: automate backups of my Minecraft servers, using the
minecraft-control wrapper.

Usage: mc-backup.py -c minecraft_control.ini -s /path/to/server

The `minecraft-control` password is obtained from the settings.ini for
minecraft-control. Backups are placed in the `backups/` directory under the
Minecraft server root, named with datetime stamps.

See `mc-backup.py --help` for command usage."""

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

        # Fin
        sys.exit(0)

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
    args = parser.parse_args()
    if args.debug:
        log.setLevel(logging.DEBUG)

    Application(args).run()

