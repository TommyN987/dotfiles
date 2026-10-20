#!/usr/bin/env bash
# Links dotfiles from this repo into place.
#
#   ./install.sh                     link every tool
#   ./install.sh --tools nvim tmux   link only the listed tools
#   ./install.sh --dry-run           print what would happen, change nothing
#
# For each link: anything real already at the target is moved to
# <target>.bak-<timestamp> first; nothing is ever deleted.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

ALL_TOOLS=(nvim tmux alacritty zsh)

# Prints "<source>|<target>" lines for one tool.
links_for_tool() {
	case "$1" in
	nvim) echo "$DOTFILES_DIR/nvim|$CONFIG_HOME/nvim" ;;
	tmux) echo "$DOTFILES_DIR/tmux|$CONFIG_HOME/tmux" ;;
	alacritty) echo "$DOTFILES_DIR/alacritty|$CONFIG_HOME/alacritty" ;;
	zsh)
		echo "$DOTFILES_DIR/.zshrc|$HOME/.zshrc"
		echo "$DOTFILES_DIR/.p10k.zsh|$HOME/.p10k.zsh"
		;;
	*) return 1 ;;
	esac
}

usage() {
	cat <<EOF
Usage: ./install.sh [--tools TOOL...] [--dry-run]

Tools: ${ALL_TOOLS[*]}
Without --tools, every tool is linked.
EOF
}

dry_run=false

# Runs a command, or only prints it under --dry-run.
run() {
	if $dry_run; then
		echo "    [dry-run] $*"
	else
		"$@"
	fi
}

# Postcondition: $target is a symlink to $source; any previous non-link
# content of $target survives at $target.bak-$TIMESTAMP.
link() {
	local source="$1" target="$2"

	if [[ ! -e "$source" ]]; then
		echo "  ERROR  $source does not exist in the repo" >&2
		return 1
	fi

	if [[ -L "$target" ]]; then
		local current
		current="$(readlink "$target")"
		if [[ "$current" == "$source" ]]; then
			echo "  ok     $target (already linked)"
			return 0
		fi
		echo "  relink $target (was -> $current)"
		run ln -sfn "$source" "$target"
		return 0
	fi

	if [[ -e "$target" ]]; then
		local backup="$target.bak-$TIMESTAMP"
		echo "  backup $target -> $backup"
		run mv "$target" "$backup"
	fi

	echo "  link   $target -> $source"
	run mkdir -p "$(dirname "$target")"
	run ln -sn "$source" "$target"
}

tools=()
while (($# > 0)); do
	case "$1" in
	--tools)
		shift
		while (($# > 0)) && [[ "$1" != --* ]]; do
			tools+=("$1")
			shift
		done
		if ((${#tools[@]} == 0)); then
			echo "--tools needs at least one tool" >&2
			usage >&2
			exit 1
		fi
		;;
	--dry-run)
		dry_run=true
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	esac
done

if ((${#tools[@]} == 0)); then
	tools=("${ALL_TOOLS[@]}")
fi

# Validate every name before touching anything.
for tool in "${tools[@]}"; do
	if ! links_for_tool "$tool" >/dev/null; then
		echo "Unknown tool: $tool" >&2
		echo "Valid tools: ${ALL_TOOLS[*]}" >&2
		exit 1
	fi
done

failed=0
for tool in "${tools[@]}"; do
	echo "$tool"
	while IFS='|' read -r source target; do
		link "$source" "$target" || failed=1
	done < <(links_for_tool "$tool")
done

exit "$failed"
