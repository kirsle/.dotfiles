#!/usr/bin/env python3

# Cron script to renew LetsEncrypt certificates.
#
# --Kirsle
# https://sh.kirsle.net/

import os
import subprocess
import time

################################################################################
# Configuration Section Begins                                                 #
################################################################################

# Let's Encrypt directories
LE_APPDIR = "/opt/letsencrypt"       # Where `letsencrypt-auto` lives
LE_CERTS  = "/etc/letsencrypt/live"  # Where live certificates go

# Common arguments to letsencrypt-auto
COMMON = ["./letsencrypt-auto", "certonly", "--renew",
          "--webroot", "-w", "/var/www/html"]

# Domains and their subdomains; one array element per certificate, with each
# array element being a list of domains to include in the same cert.
CERTS = [
    [ "www.kirsle.net", "kirsle.net", "www.kirsle.com", "kirsle.com",
      "www.kirsle.org", "kirsle.org", "sh.kirsle.net", "rpm.kirsle.net",
      "minecraft.kirsle.net", "mc.kirsle.net", "rophako.kirsle.net" ],
    [ "noah.is", "www.noah.is", "petherbridge.org", "www.petherbridge.org",
      "noah.petherbridge.org", "noahpetherbridge.com",
      "www.noahpetherbridge.com" ],
    [ "rivescript.com", "www.rivescript.com", "static.rivescript.com" ],
    [ "siikir.com", "www.siikir.com" ],
    [ "collegegent.com", "www.collegegent.com" ],
]

# Minimum lifetime for certificate before renewing it?
LIFETIME = 60*60*24*30  # Once a month.

# Command to run after finishing if certs were renewed.
RESTART_COMMAND = ["service", "nginx", "reload"]

################################################################################
# End Configuration Section                                                    #
################################################################################

def main():
    os.chdir(LE_APPDIR)

    # If any certs were renewed, we'll schedule the restart command at the end.
    any_renewed = False

    # See which certificates are ready to be renewed.
    print("Checking SSL certificates for renewal")
    for cert in CERTS:
        ready = False  # Ready to renew this one
        primary = cert[0]

        # Find its existing live certificate file.
        home = os.path.join(LE_CERTS, primary)
        chain = os.path.join(home, "cert.pem")

        # When was it last modified?
        if not os.path.isfile(chain):
            print("NOTE: No existing cert file found for {} ({})".format(
                primary,
                chain,
            ))
            ready = True
        else:
            mtime = os.stat(chain).st_mtime
            if time.time() - mtime > LIFETIME:
                print("Cert for {} is old; scheduling it for renewal!"\
                    .format(primary))
                ready = True

        # Proceed?
        if ready:
            print("Renewing certificate for {}...".format(primary))
            command = []
            command.extend(COMMON)

            # Add all the domains.
            for domain in cert:
                command.extend(["-d", domain])

            print("Exec: {}".format(" ".join(command)))
            subprocess.call(command)
            any_renewed = True

    # If any certs were changed, restart the web server.
    if any_renewed:
        print("Restarting the web server: {}".format(" ".join(RESTART_COMMAND)))
        subprocess.call(RESTART_COMMAND)

if __name__ == "__main__":
    main()

