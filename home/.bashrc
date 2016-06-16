# .bashrc

# Kirsle's Global BashRC
# Updated     2015-05-07

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

platform="unknown"
unamestr=`uname`
if [[ "$unamestr" == "Linux" ]]; then
	platform="linux"
elif [[ "$unamestr" == "Darwin" ]]; then
	platform="darwin"
fi

# PATH settings.
export PATH="/usr/sbin:/sbin:/usr/bin:/bin:$HOME/bin:$HOME/go/bin"
if [[ $platform == "darwin" ]]; then
	# Prefer /usr/local/bin because homebrew
	export PATH="/usr/local/bin:$PATH"

	# Enable colors and set a similar color scheme as Linux (see `man ls`)
	export CLICOLOR=1
	export LSCOLORS="ExGxcxdxcxegedabagecec"
else
	export PATH="$PATH:/usr/local/bin:/usr/local/sbin"
fi

# Perlbrew
export PERLBREW_ROOT="/opt/perl5"
if [ -f /opt/perl5/etc/bashrc ]; then
	source /opt/perl5/etc/bashrc
fi

# Virtualenv
export WORKON_HOME=~/.virtualenvs
if [ -f /usr/bin/virtualenvwrapper.sh ]; then
	source /usr/bin/virtualenvwrapper.sh
fi

# Colors!
BLACK='\e[0;30m'
NAVY='\e[0;34m'
GREEN='\e[0;32m'
TEAL='\e[0;36m'
MAROON='\e[0;31m'
PURPLE='\e[0;35m'
BROWN='\e[0;33m'
SILVER='\e[0;37m'
GRAY='\e[1;30m'
BLUE='\e[1;34m'
LIME='\e[1;32m'
CYAN='\e[1;36m'
RED='\e[1;31m'
MAGENTA='\e[1;35m'
YELLOW='\e[1;33m'
WHITE='\e[1;37m'
BOLD='\e[1m'
NC='\e[0m'              # No Color

# Some 256-colors colors
LBLUE="\e[38;5;39m"
PINK="\e[38;5;213m"

function showcolors() {
	echo -e "$BLACK BLACK $NAVY NAVY $GREEN GREEN $TEAL TEAL"
	echo -e "$MAROON MAROON $PURPLE PURPLE $BROWN BROWN $SILVER SILVER"
	echo -e "$GRAY GRAY $BLUE BLUE $LIME LIME $CYAN CYAN $RED RED"
	echo -e "$MAGENTA MAGENTA $YELLOW YELLOW $WHITE WHITE$NC"
}

# Normalize the terminal.
ENLIGHTENED=0
if [ "$TERM" = 'xterm' ] || [ "$TERM" = 'xterm-256color' ] || [ "$TERM" = 'linux' ]; then
	ENLIGHTENED=1
elif [ "$TERM" = 'screen' ] || [ "$TERM" = 'screen-256color' ]; then
	ENLIGHTENED=1
elif [ "$TERM" = 'cygwin' ]; then
	ENLIGHTENED=1
fi

# Custom bash prompt.
git_branch() {
	branch=`git branch 2> /dev/null | sed -e '/^[^*]/d' | perl -pe 's/^\*\s+//g'`
	if [ "$branch" != '' ]; then
		echo -n " ($branch)"
	fi
}
if [ "$ENLIGHTENED" = '1' ]; then
	export PS1="\[$BOLD$LBLUE\][\[$PINK\]\u\[$LBLUE\]@\[$PINK\]\h \[$LIME\]\W\[$CYAN\]\$(git_branch)\[$LBLUE\]\[$LBLUE\]]\\$ \[$NC\]"
fi

# For non-Fedora environments be sure the PROMPT_COMMAND sets the title bar.
export PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'

#   ___  ____  _  _  ____  ____    __    __
#  / __)( ___)( \( )( ___)(  _ \  /__\  (  )
# ( (_-. )__)  )  (  )__)  )   / /(__)\  )(__
#  \___/(____)(_)\_)(____)(_)\_)(__)(__)(____)
#   -==General Bash Aliases and Functions==-

alias vi='vim'

# reload .bashrc
alias rebash='. ~/.bashrc'

# a DOS-like title command
function title {
	PROMPT_COMMAND="echo -en \"\033]0;$1\007\""
}

# Custom git command that overrides $PATH settings
function git {
	if [ -x "/usr/local/bin/git" ]; then
		/usr/local/bin/git $@
	elif [ -x "/opt/git/bin/git" ]; then
		/opt/git/bin/git $@
	elif [ -x "/usr/bin/git" ]; then
		/usr/bin/git $@
	else
		echo "git isn't installed"
	fi
}

# Case-insensitive searching.
shopt -s nocaseglob

# Save history correctly when using multiple terminals.
# Don't save duplicate lines or blank lines.
export HISTCONTROL="ignoreboth"
export HISTSIZE=1000
shopt -s histappend

export EDITOR="/usr/bin/vim"

# Color grepping! Highlight grep expression in red text.
export GREP_COLOR=31
alias grep='grep --exclude=min.js --color=auto'

# Show proc name with pgrepping.
alias pg='ps aux | grep'
alias pgrep='pgrep -l'

# Allow ASCII color codes to work in less/more.
alias less='less -r'
alias more='less -r' # less is more

# ls aliases (Fedora defaults but here for portability)
if [[ $platform == "darwin" ]]; then
	alias ll='ls -hl'
else
	alias ls='ls --color=auto'
	alias ll='ls --color=auto -hl'
fi

# More aliases!
alias ping='ping -c 10'

# Shortcuts to graphical programs.
alias firefox='nohup firefox 2>/dev/null'
alias gedit='nohup gedit 2>/dev/null'

# Lazy cd commands.
alias ...='cd ../..'
alias ..='cd ..'
alias ~='cd ~'
alias cd..='cd ..'
alias cd...='cd ../..'

# Lazy id commands
alias me='whoami'
alias i='whoami'

# Typos
alias iv='vi'

# Make cp and mv ask before replacing an existing file.
alias cp='cp -i'
alias mv='mv -i'

# 256 Color Terminal! Make sure a .xterm256 file exists in $HOME to enable.
if [ -e ".xterm256" ]; then
	[ "$TERM" = 'xterm' ] && TERM=xterm-256color
	[ "$TERM" = 'screen' ] && TERM=screen-256color
	[ "$TERM" = 'rxvt-unicode' ] && TERM=rxvt-unicode-256color

	if [ ! -z "$TERMCAP" ] && [ "$TERM" = "screen-256color" ]; then
		TERMCAP=$(echo $TERMCAP | sed -e 's/Co#8/Co#256/g')
		export TERMCAP
	fi
fi

# Source local system-specific config.
if [ -f ~/.localbashrc ]; then
	. ~/.localbashrc
fi

###
# Import common functions (bash/zsh)
###

. ~/.common.sh
