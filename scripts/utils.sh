#!/usr/bin/env bash
export LC_ALL=en_US.UTF-8

get_option() {
  local option=$(tmux show-option -gqv "$1")
  [ -z "$option" ] && echo $2 || echo "$option"
}

set_option() {
  tmux set-option -g "$1" "$2"
}

upsert_option() {
  local option=$(get_option "$1" "$2")
  tmux set-option -g "$1" "$option"
}

padding() {
  printf '%*s' $1
}

get_ple_end() {
  local direction=${1:-left}
  local pills=$(get_option "@nova-pills" true)
  local nerdfonts_right=$(get_option "@nova-nerdfonts-right" )
  local nerdfonts_left=$(get_option "@nova-nerdfonts-left" )

  if [ $direction = "left" ] && [ $pills = true ]; then
    echo $nerdfonts_left
  else
    echo $nerdfonts_right
  fi
}
