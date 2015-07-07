###
# .zshrc
#
# Kirsle's Global ZSH Configuration
# Updated: 2015-07-07
###

export LANG=en_US.UTF-8       # Unicode
setopt prompt_subst           # Allow for dynamic prompts
autoload -U colors && colors  # Get color aliases

# 256 colors
[[ "$TERM" == "xterm" ]] && export TERM=xterm-256color

# Normalize the PATH
export PATH="/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin:${HOME}/bin:${HOME}/go/bin:${HOME}/android/sdk/platform-tools"
export EDITOR="/usr/bin/vim"

# Virtualenv
export WORKON_HOME=~/.virtualenv

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
	return $res
}

local git_prompt='%{$cyan%}$(git_branch)%{$reset_color%}'
local base_prompt="${base_prompt}${git_prompt}"

# End the base prompt
local base_prompt="${base_prompt}%{$blue%}]%# %{%f%}"

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
	zgen load jimmijj/zsh-syntax-highlighting
	zgen load tarruda/zsh-autosuggestions # depends on syntax-highlighting

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

###
# Configure plugin: zsh-autosuggestions
###
export AUTOSUGGESTION_HIGHLIGHT_COLOR="fg=2"
export AUTOSUGGESTION_ACCEPT_RIGHT_ARROW=1

# Finalize and export the prompt
export PROMPT=$base_prompt
