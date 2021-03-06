###
# .zshrc
#
# Kirsle's Global ZSH Configuration
###

export LANG=en_US.UTF-8           # Unicode
setopt prompt_subst               # Allow for dynamic prompts
autoload -U colors && colors      # Get color aliases
autoload -U compinit && compinit  # Better tab completion
export HISTSIZE=2000              # History settings
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt inc_append_history
setopt nobeep

# Enable 256 colors in my terminal
[[ "$TERM" == "xterm" ]] && export TERM=xterm-256color

# CLI colors under OS X for `ls`
if [[ `uname` == "Darwin" ]]; then
	# Enable colors and set a similar scheme as on Linux (see `man ls`)
	export CLICOLOR=1
	export LSCOLORS="ExGxcxdxcxegedabagecec"
fi

# Normalize the PATH. Under Linux prefer /usr/bin over local paths,
# but on MacOS allow /usr/local and ~/bin to override system paths,
# for Homebrew.
CORE_PATH="/usr/sbin:/sbin:/usr/bin:/bin"
USR_PATH="/usr/local/sbin:/usr/local/bin:${HOME}/bin:${HOME}/go/bin:${HOME}/go/.ext/bin:${HOME}/.cargo/bin:${HOME}/android/sdk/platform-tools"
if [[ `uname` == "Linux" ]] then export PATH="${CORE_PATH}:${USR_PATH}"
else export PATH="${USR_PATH}:${CORE_PATH}"
fi

# Vim as the favorite editor.
export EDITOR="/usr/bin/vim"

# Python settings.
## Prefer Python3 for new environments created by virtualenvwrapper.
export WORKON_HOME=~/.virtualenvs
command -v python3 >/dev/null 2>&1 && export VIRTUALENV_PYTHON=`command -v python3`

# Go settings.
## Separate the GOPATH into external (.ext) and main, to keep my projects
## apart from everyone else's. `go get` installs into the first directory
## of $GOPATH so third party packages end up there.
export GOPATH="$HOME/go/.ext:$HOME/go"

# JavaScript settings.
## Store globally installed npm packages (e.g. `npm install -g babel-cli`)
## in my ~/.npm-global-pkg directory, and add it to my $PATH.
if [[ ! -f "${HOME}/.npmrc" ]]; then
	echo "prefix = ${HOME}/.npm-global-pkg" > $HOME/.npmrc
fi
export NPM_PACKAGES="${HOME}/.npm-global-pkg"
export NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"
export PATH="${NPM_PACKAGES}/bin:$PATH"

# Java settings.
## Make ~/java available on the CLASSPATH.
export CLASSPATH="$CLASSPATH:${HOME}/java"

# Reload zshrc
alias rezsh="source ${HOME}/.zshrc"

# Allow overriding hostname in the prompt from a local config
export PROMPT_HOSTNAME="%m"

# Source local (system specific) configurations
if [[ -f "${HOME}/.zshrc-local" ]]; then
	source "${HOME}/.zshrc-local"
fi

###
# Base shell prompt.
###

# I slowly build the prompt up over multiple places and store it in
# in $base_prompt, so I can modify it before exporting it (for example,
# so the git branch appears before the % at the end of the prompt).

# For the color palette, see: http://www.pixelbeat.org/docs/terminal_colours/
# Use light shades of blue and pink.
local blue="%F{39}"
local pink="%F{213}"
local orange="%F{208}"
local lime="%F{46}"
local cyan="%F{51}"
local base_prompt="%{$blue%}[%{$pink%}%n%{$blue%}@%{$pink%}${PROMPT_HOSTNAME} %{$lime%}%1~"

###
# Include git branch in the prompt
###

git_branch() {
	local res=`git branch 2>/dev/null | grep -v '^[^*]' | perl -pe 's/^\*\s+//g'`
	if [[ "$res" != "" ]]; then
		local res=" ($res)"
	fi
	echo $res
}

local git_prompt='%{$cyan%}$(git_branch)%{$reset_color%}'
local base_prompt="${base_prompt}${git_prompt}"

# End the base prompt
local base_prompt="${base_prompt}%{$blue%}]%# %{%f%}"

###
# Set terminal titles automatically
###

# allow resetting the terminal title like in DOS
function title {
	export PROMPT_DOS_TITLE="$1"
}

precmd() {
	if [ "$PROMPT_DOS_TITLE" != "" ]; then
		print -Pn "\e]0;${PROMPT_DOS_TITLE}\a"
	else
		print -Pn "\e]0;%n@${PROMPT_HOSTNAME}:%~\a"
	fi
}

###############################################################################
# Aliases and things                                                          #
###############################################################################

alias vi="vim"
alias grep="grep --exclude=min.js --color=auto"
alias ll="ls -l"
alias tojson="python -m json.tool"  # JSON pretty print

if [[ `uname` == 'Linux' ]] then
	alias ls="ls --color=auto"
fi

# `h` is a shortcut for `history 1` (show all history) or `history 1 | grep`
# example: `h ls` will do `history 1 | grep ls`
h() {
	if [ -z "$*" ]; then
		history 1;
	else
		history 1 | egrep "$@";
	fi
}

###############################################################################
# zsh plugins                                                                 #
###############################################################################

# Load zgen (plugin manager)
source "${HOME}/.dotfiles/zsh/zgen/zgen.zsh"

# Initialize zgen plugins
if ! zgen saved; then
	echo "Creating a zgen save"

	# Load plugins
	zgen oh-my-zsh plugins/virtualenv
	zgen oh-my-zsh plugins/virtualenvwrapper
	zgen load zsh-users/zsh-syntax-highlighting

	# Save all to the init script
	zgen save
fi

###
# Configure plugin: virtualenvwrapper
###

# Virtualenv prompt. The dynamic part (name of the virtualenv) needs to
# recompute each time so we separate it out into a single-quoted variable.
# See: http://stackoverflow.com/questions/11877551/zsh-not-re-computing-my-shell-prompt
export ZSH_THEME_VIRTUALENV_PREFIX="("
export ZSH_THEME_VIRTUALENV_SUFFIX=")"
local virtualenv_prompt='%{$orange%}$(virtualenv_prompt_info)%{$reset_color%}'
local base_prompt="${virtualenv_prompt}${base_prompt}"

# Trigger any virtualenvs to auto-activate in the current working directory,
# in case we just opened a new terminal inside a project.
command -v workon_cwd >/dev/null && workon_cwd

###
# Configure plugin: zsh-syntax-highlighting
###

typeset -A ZSH_HIGHLIGHT_STYLES

# I like blue instead of green as the base color for most things.
# 39 = light blue, 27 = darker blue
ZSH_HIGHLIGHT_STYLES[alias]=fg=39
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=39,underline
ZSH_HIGHLIGHT_STYLES[builtin]=fg=39
ZSH_HIGHLIGHT_STYLES[function]=fg=39
ZSH_HIGHLIGHT_STYLES[command]=fg=39
ZSH_HIGHLIGHT_STYLES[precommand]=fg=39,underline
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=39
ZSH_HIGHLIGHT_STYLES[globbing]=fg=green

# Highlight command line flags too.
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=27
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=27

# Finalize and export the prompt
export PROMPT=$base_prompt

###
# Import common functions (bash/zsh)
###

. ~/.common.sh

