# Color grepping!
set -gx GREP_COLOR 31
function grep
	/bin/grep --exclude=min.js --color=auto $argv
end

