# Kirsle's Dotfiles

This repo is for my own personal use for syncing my Unix config files and
scripts between my various devices. Feel free to look around and learn from
my config scripts.

# Setup

```bash
~$ git clone git@github.com:kirsle/.dotfiles
~$ ./.dotfiles/setup --install
```

# Layout

* `./setup`

    Installation script for the dotfiles. Creates symlinks for everything in
    `./home` into `$HOME`.

    This will **not** delete existing files, such as `~/.bashrc`. Use the
    `--install` option to make it do so.

* `./home`

    Everything in this folder will be symlinked to from your `$HOME` folder.
