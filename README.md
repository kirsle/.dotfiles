# Kirsle's Dotfiles

This repo is for my own personal use for syncing my Unix config files and
scripts between my various devices. Feel free to look around and learn from
my config scripts.

# Setup

```bash
~$ git clone git@github.com:kirsle/.dotfiles
~$ ./.dotfiles/setup
```

# Dotfiles Manager (dfm)

The dotfiles repo is managed by a `dfm` command, which gets installed into
`~/bin` automatically. (The `.dotfiles/setup` script is just an easy alias
to this command).

See `dfm --help` for documentation. Briefly:

* `dfm setup` creates symlinks to all the files in `./home` into `$HOME`.
* `dfm update` does a `git pull` and installs any new dotfiles.
* `dfm check-update` reminds you every 15 days to run `dfm update` (but
  doesn't remind you more than once per 24 hours).

In case one of the target files already exists (and is not a symlink), it is
copied into `.dotfiles/backup` before being deleted and relinked.

The commands take optional arguments:

* `dfm setup --force`: forcefully re-link all dotfiles, deleting any links
  that already exist.
* `dfm setup --copy`: tell it not to use symlinks but instead make normal
  file copies into `$HOME`.
* `dfm check-update --force`: always show the update reminder.

The `.dotfiles/setup` script passes all options along to `dfm`, so you can
do `.dotfiles/setup --copy` for example.

# Layout

* `./setup`

    Installation script for the dotfiles. Creates symlinks for everything in
    `./home` into `$HOME`.

    This will **not** delete existing files, such as `~/.bashrc`. Use the
    `--install` option to make it do so.

* `./home`

    Everything in this folder will be symlinked to from your `$HOME` folder.
