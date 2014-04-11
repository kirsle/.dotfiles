# A DOS-like title command
function title
	set -gx FISH_CUSTOM_TITLE "$argv"
end
