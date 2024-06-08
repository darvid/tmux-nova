#!/bin/bash
# https://github.com/joshmedeski/tmux-nerd-font-window-name


tmux_options="$(tmux show -g)"

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value="$(echo "$tmux_options" | grep "^$option " | cut -d " " -f2-)"
  [[ "$option_value" == "''" ]] && [[ -z "$default_value" ]] && echo "" || echo "$default_value"
}

name=$1
active=${2:false}
show_name="$(get_tmux_option '@nova-pane-show-window-name')"
name_colors="$(get_tmux_option '@nova-pane-name-colors')"
icon_colors="$(get_tmux_option '@nova-pane-icon-colors')"
show_inactive_divider="$(get_tmux_option '@nova-pane-show-inactive-divider')"
divider="$(get_tmux_option '@nova-pane-divider' '')"
divider_colors="$(get_tmux_option '@nova-pane-divider-colors')"
divider_colors_active="$(get_tmux_option '@nova-pane-divider-active-colors')"

function get_shell_icon() {
	local default_shell_icon=""
	local shell_icon="$(tget_tmux_option '@nova-pane-window-name-shell-icon')"
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
	docker)
		echo "󰡨"
		;;
	*)
		echo "󰊠"
		;;
	esac
}

main() {
  local icon="#{?window_activity_flag,,$(get_icon)}"
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
