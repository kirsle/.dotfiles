###
# Common shell functions/aliases between bash and zsh.
###

################################################################################
## Functions
################################################################################

# Recursively traverse directory tree for git repositories, run git command
# e.g.
#  rgit status
#  rgit diff
#
# Credit:
# http://chr4.org/blog/2014/09/10/gittree-bash-slash-zsh-function-to-run-git-commands-recursively/
rgit() {
	if [ $# -lt 1 ]; then
		echo "Usage: rgit <command>"
		return 1
	fi

	for gitdir in $(find . -type d -name .git); do
		# Display repository name in bold orange text.
		repo=$(dirname $gitdir)
		echo -e "\e[1;38;5;208m$repo\e[0m"

		# Run git command in the repository's directory
		cd $repo && git $@
		ret=$?

		# Return to calling directory (ignore output)
		cd - >/dev/null

		# Abort if cd or git command fails
		if [ $ret -ne 0 ]; then
			return 1
		fi

		echo
	done
}
