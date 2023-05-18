#!/bin/bash
# https://github.com/joshmedeski/tmux-nerd-font-window-name

NAME=$1
SHOW_NAME="$(tmux show -gqv '@nova-pane-show-window-name')"
DIVIDER="$(tmux show -gqv '@nova-pane-divider')"

function get_shell_icon() {
	local default_shell_icon=""
	local shell_icon
	shell_icon="$(tmux show -gqv '@nova-pane-window-name-shell-icon')"
	if [ -n "$shell_icon" ]; then
		echo "$shell_icon"
	else
		echo "$default_shell_icon"
	fi
}

SHELL_ICON=$(get_shell_icon)

get_icon() {
	case $NAME in
	tmux)
		echo ""
		;;
	htop | top)
		echo ""
		;;
	fish | zsh | bash | tcsh)
		echo "$SHELL_ICON"
		;;
	vi | vim | nvim | lvim)
		echo ""
		;;
	lazygit | git | tig)
		echo ""
		;;
	node)
		echo ""
		;;
	ruby)
		echo ""
		;;
	go)
		echo "ﳑ"
		;;
	lf | lfcd)
		echo ""
		;;
	beam | beam.smp) # Erlang runtime
		echo ""
		;;
	rustc | rustup)
		echo ""
		;;
	python)
		echo ""
		;;
	*)
		if [ "$SHOW_NAME" = true ]; then
			echo ""
		else
			echo "$NAME"
		fi
		;;
	esac
}

ICON=$(get_icon)

if [ "${SHOW_NAME:-true}" = true ]; then
	echo "$ICON" "$DIVIDER" "$NAME"
else
	echo "$ICON"
fi
