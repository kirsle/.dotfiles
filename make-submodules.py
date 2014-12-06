#!/usr/bin/env python

"""Script to generate the .gitmodules file for the vim plugins."""

import re

# Open the files
vimrc = open("home/.vimrc", "r")
outfh = open(".gitmodules", "w")

for line in vimrc.readlines():
    line = line.strip()
    match = re.search(r"Plugin '(\w+?)/([A-Za-z0-9.-]+?)'", line)
    if match:
        username = match.group(1)
        repo     = match.group(2)
        path = "home/.vim/bundle/{}".format(repo)
        url = "https://github.com/{}/{}".format(username, repo)
        print "Submodule:", url

        outfh.write("[submodule \"{}\"]\n".format(path))
        outfh.write("\tpath = {}\n".format(path))
        outfh.write("\turl = {}\n".format(url))

# Clean up.
vimrc.close()
outfh.close()
