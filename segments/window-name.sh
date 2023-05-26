#!/bin/bash
# https://github.com/joshmedeski/tmux-nerd-font-window-name

name=$1
active=${2:false}
show_name="$(tmux show -gqv '@nova-pane-show-window-name')"
name_colors="$(tmux show -gqv '@nova-pane-name-colors')"
icon_colors="$(tmux show -gqv '@nova-pane-icon-colors')"
show_inactive_divider="$(tmux show -gqv '@nova-pane-show-inactive-divider')"
divider="$(tmux show -gqv '@nova-pane-divider')"
divider_colors="$(tmux show -gqv '@nova-pane-divider-colors')"
divider_colors_active="$(tmux show -gqv '@nova-pane-divider-active-colors')"

function get_shell_icon() {
	local default_shell_icon=""
	local shell_icon="$(tmux show -gqv '@nova-pane-window-name-shell-icon')"
	if [ -n "$shell_icon" ]; then
		echo "$shell_icon"
	else
		echo "$default_shell_icon"
	fi
}

get_icon() {
	case $name in
	tmux)
		echo ""
		;;
	htop | top)
		echo ""
		;;
	fish | zsh | bash | tcsh)
		echo "$(get_shell_icon)"
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
		echo ""
		;;
	esac
}

main() {
  local icon=$(get_icon)
  local _divider

  if [ "${show_name:-true}" = true ]; then
    if [ "$active" = true ] || [ "${show_inactive_divider:-true}" = true ]; then
      _divider="$divider"
      local divider_colors="$divider_colors_active"
    else
      _divider=" "
      local divider_colors="$divider_colors"
    fi
    echo "#[$icon_colors]$icon" "#[$divider_colors]$_divider" "#[$name_colors]$name"
  else
    echo "#[$icon_colors]$icon"
  fi
}

main "$@"
