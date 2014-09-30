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

# Source local system-specific config.
if test -e ~/.local.fish
	. ~/.local.fish
end

# 256 colors
if test $TERM = "xterm"
	set -x TERM "xterm-256color"
end

# VirtualEnv
set -g VIRTUALFISH_HOME $HOME/.virtualenv
set -g VIRTUALFISH_COMPAT_ALIASES
. ~/.config/fish/virtual.fish

# Shell prompt
function fish_prompt
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
	set_color 0099FF
	echo -n "]\$ "
	set_color normal
end

# Title bar
function fish_title
	if set -q FISH_CUSTOM_TITLE
		echo -n $FISH_CUSTOM_TITLE
	else
		echo -n -s (whoami) "@" (hostname) ":" (prompt_pwd)
	end
end

