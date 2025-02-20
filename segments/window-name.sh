#!/bin/bash
# https://github.com/joshmedeski/tmux-nerd-font-window-name

name=$1
active=${2:false}
show_name=true
name_colors="fg:white"
icon_colors="fg:magenta"
show_inactive_divider="false"
divider=""
divider_colors="fg:#f2cdcd"
divider_colors_active="fg:#f2cdcd"
default_shell_icon=""

get_icon() {
  case $name in
  tmux)
    echo ""
    ;;
  htop | top)
    echo ""
    ;;
  fish | zsh | bash | tcsh)
    echo "$default_shell_icon"
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
  local icon="\r#{?window_activity_flag,,$(get_icon)}"
  local _divider

  if [ "${show_name:-true}" = true ]; then
    if [ "$active" = true ] || [ "${show_inactive_divider:-true}" = true ]; then
      _divider="$divider"
      local divider_colors="$divider_colors_active"
    else
      _divider=" "
      local divider_colors="$divider_colors"
    fi
    echo -e "#[$icon_colors]$icon" "#[$divider_colors]$_divider" "#[$name_colors]$name"
  else
    echo -e "#[$icon_colors]$icon"
  fi
}

main "$@"
