# config.fish

# Kirsle's config.fish
# Updated: 2014-03-03

function fish_greeting
	echo -s (set_color FF9900) "-== " (fish --version ^&1) " ==-" (set_color normal)
	echo -s (set_color FFFF00) "  Date: " (set_color FFFFFF) (date) (set_color normal)
	echo -s (set_color FFFF00) "Uptime: " (set_color FFFFFF) (uptime) (set_color normal)
end

# Normalize the $PATH.
set -gx PATH /usr/sbin /sbin /usr/bin /bin /usr/local/sbin /usr/local/bin $HOME/bin $HOME/go/bin $HOME/android/sdk/platform-tools

set -gx EDITOR /usr/bin/vim

# 256 colors
if test $TERM = "xterm"
	set -x TERM "xterm-256color"
end

# VirtualEnv
set -g VIRTUALFISH_HOME $HOME/.virtualenvs
set -g VIRTUALFISH_COMPAT_ALIASES
. ~/.config/fish/virtual.fish

# Git repo branches
function git_branch
	git branch 2>/dev/null | grep -v '^[^*]' | perl -pe 's/^\*\s+//g'
end

# Shell prompt
function base_prompt
	# VirtualEnv prefix
	if set -q VIRTUAL_ENV
		echo -n -s (set_color FF9900) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal)
	end

	set_color --bold 0099FF
	echo -n "["
	set_color FF99FF
	echo -n (whoami)
	set_color 0099FF
	echo -n "@"
	set_color FF99FF
	echo -n (hostname)
	echo -n " "
	set_color 00FF00
	echo -n (prompt_pwd)

	# git branch
	set branch (git_branch)
	if test -n "$branch"
		set_color 00FFFF
		echo -n " ($branch)"
	end

	set_color 0099FF
	echo -n "]\$ "
	set_color normal
end
function fish_prompt
	echo -n (base_prompt)
end

# Title bar
function fish_title
	if set -q FISH_CUSTOM_TITLE
		echo -n $FISH_CUSTOM_TITLE
	else
		echo -n -s (whoami) "@" (hostname) ":" (prompt_pwd)
	end
end

# `sudo !!` compat for fish shell
function sudo
	if test "$argv" = !!
		eval command sudo $history[1]
	else
		command sudo $argv
	end
end

# Source local system-specific config.
if test -e ~/.local.fish
	. ~/.local.fish
end

