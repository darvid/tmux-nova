#!/usr/bin/env bash
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
segments_dir="$(readlink -f "${current_dir}/../segments")"

source $current_dir/utils.sh

# 🐈‍⬛ Catpuccin Mocha color palette
white="#cdd6f4"
gray="#313244"
dark_gray="#181825"
light_purple="#cba6f7"
dark_purple="#b4befe"
cyan="#94e2d5"
green="#a6e3a1"
orange="#fab387"
red="#f38ba8"
pink="#f2cdcd"
dark_pink="##f5c2e7"
yellow="#f9e2af"
dark_yellow="#313244"

divider=$(get_option "@nova-pane-divider" "")
padding=$(get_option "@nova-padding" 1)
margin=$(get_option "@nova-margin" 1)
rows=$(get_option "@nova-rows" 1)

pane_copy_mode="#{?#{==:#{pane_mode},copy-mode}, ,}"
pane_view_mode="#{?#{==:#{pane_mode},view-mode}, ,}"

tmux set -g "@nova-pane-name-colors" "fg:${pink}"
tmux set -g "@nova-pane-divider" ""
tmux set -g "@nova-pane-divider-colors" "fg:${pink}"
tmux set -g "@nova-pane-divider-active-colors" "fg:${pink}"

tmux set -g "@nova-segment-mode" "#{?client_prefix,#[fg=${white}]󰐂,󱩜} ${divider}"
tmux set -g "@nova-segment-mode-colors" "#{?client_prefix,${cyan},${red}} #{?client_prefix,default,default}"
tmux set -g "@nova-segment-whoami" "${divider} #[italics]#(whoami)@#h"
tmux set -g "@nova-segment-whoami-colors" "${white} ${dark_pink}"

tmux set -g "@nova-segment-spotify" "#(${segments_dir}/spotify.sh)"
tmux set -g "@nova-segment-spotify-roll" true
tmux set -g "@nova-segment-spotify-prefix" " ${divider}"
tmux set -g "@nova-segment-spotify-colors" "${pink} ${green}"

tmux set -g "@nova-segment-mode-colors" "#{?client_prefix,${green},${dark_gray}} #{?client_prefix,default,default}"

add_margin() {
  local option=${1:-status-left}
  local cmd
  if [ "$option" = "${option#window-}" ]; then
    cmd=set-window-option
  else
    cmd=set-option
  fi
  if [ $margin -gt 0 ]; then
    tmux $cmd -ga $option "$(padding $margin)"
  fi
}

get_pane_fmt() {
  local active=${1:-false}
  local pane_zoomed="#{?window_zoomed_flag, ,}"
  local pane_mode="#{?pane_in_mode,${pane_copy_mode}${pane_view_mode},}"
  local pane_window_name="#(${segments_dir}/window-name.sh #{pane_current_command} ${active})"
  local pane=$(get_option "@nova-pane" "${pane_mode}${pane_window_name}${pane_zoomed}")
  echo " $pane"
}

get_status_style_fmt() {
  local activity_color=$1
  if [ -z "$activity_color" ]; then
    activity_color=$(get_option "@nova-status-style-activity-bg" "$white")
  fi
  local normal_color=${2:-default}
  local type=${3:-bg}
  echo "#{?window_activity_flag,#[${type}=${activity_color}],#[${type}=${normal_color}]}"
}

main() {
  if [ "$rows" -eq 0 ]; then
    tmux set-option -g status on
  else
    tmux set-option -g status $(expr $rows + 1)
  fi

  interval=$(get_option "@nova-interval" 1)
  tmux set-option -g status-interval $interval
  status_style_fg=$(get_option "@nova-status-style-fg" "${gray}")
  status_style_active_fg=$(get_option "@nova-status-style-active-fg" "${white}")
  status_style_activity_fg=$(get_option "@nova-status-style-activity-fg" "${pink}")

  tmux set-option -g status-style "fg=$status_style_fg"

  pane_border_style=$(get_option "@nova-pane-border-style" "${dark_gray}")
  pane_active_border_style=$(get_option "@nova-pane-active-border-style" "${gray}")
  tmux set-option -g pane-border-style "fg=${pane_border_style}"
  tmux set-option -g pane-active-border-style "fg=${pane_active_border_style}"

  # segments-0-left
  segments_left=$(get_option "@nova-segments-0-left" "mode")
  IFS=' ' read -r -a segments_left <<<$segments_left

  tmux set-option -g status-left ""

  for segment in "${segments_left[@]}"; do
    segment_content=$(get_option "@nova-segment-${segment}" "mode")
    segment_colors=$(get_option "@nova-segment-${segment}-colors" "${dark_gray} ${gray}")
    IFS=' ' read -r -a segment_colors <<<${segment_colors}
    if [ "$segment_content" != "" ]; then
      # condition everything on the non emptiness of the evaluated segment
      tmux set-option -ga status-left "#{?#{w:#{E:@nova-segment-${segment}}},"

      tmux set-option -ga status-left "#[fg=${segment_colors[1]}]"
      tmux set-option -ga status-left "$(padding ${padding})"
      tmux set-option -ga status-left "$segment_content"
      tmux set-option -ga status-left "$(padding ${padding})"

      # condition end
      tmux set-option -ga status-left ',}'
    fi
  done

  # status-format
  pane_justify=$(get_option "@nova-pane-justify" "left")
  tmux set-option -g status-justify ${pane_justify}
  tmux set-window-option -g window-status-format ""
  tmux set-option -g window-status-activity-style fg=default

  tmux set-window-option -ga window-status-format "$(get_status_style_fmt $status_style_activity_fg $status_style_fg fg)"
  tmux set-window-option -ga window-status-format "$(get_pane_fmt)"

  tmux set-window-option -g window-status-current-format "#[fg=${status_style_active_fg}]"
  tmux set-window-option -ga window-status-current-format "$(get_pane_fmt true)"

  # segments-0-right
  segments_right=$(get_option "@nova-segments-0-right" "")
  IFS=' ' read -r -a segments_right <<<$segments_right

  tmux set-option -g status-right ""

  for segment in "${segments_right[@]}"; do
    segment_content=$(get_option "@nova-segment-${segment}" "")
    segment_colors=$(get_option "@nova-segment-${segment}-colors" "${gray} ${white}")
    IFS=' ' read -r -a segment_colors <<<$segment_colors
    if [ "$segment_content" != "" ] && [ "$segment_colors" != "" ]; then
      # condition everything on the non emptiness of the evaluated segment
      tmux set-option -ga status-right "#{?#{w:#{E:@nova-segment-$segment}},"
      tmux set-option -ga status-right "#[fg=${segment_colors[1]}]"
      tmux set-option -ga status-right "$segment_content"
      tmux set-option -ga status-right ',}'
    fi
  done

  for ((row = 1; row <= rows; row++)); do
    # segments-n-left
    segments_bottom_left=$(get_option "@nova-segments-$row-left" "")
    IFS=' ' read -r -a segments_bottom_left <<<$segments_bottom_left

    tmux set-option -g status-format[$row] "#[align=left]"

    for segment in "${segments_bottom_left[@]}"; do
      segment_content=$(get_option "@nova-segment-${segment}" "")
      segment_colors=$(get_option "@nova-segment-${segment}-colors" "$dark_gray $gray")
      IFS=' ' read -r -a segment_colors <<<$segment_colors
      if [ "$segment_content" != "" ]; then
        tmux set-option -ga status-format[$row] "#[fg=${segment_colors[1]}]"
        tmux set-option -ga status-format[$row] "$(padding $padding)"
        tmux set-option -ga status-format[$row] "$segment_content"
        tmux set-option -ga status-format[$row] "$(padding $padding)"
      fi
    done

    # segments-n-center
    segments_bottom_center=$(get_option "@nova-segments-$row-center" "")
    IFS=' ' read -r -a segments_bottom_center <<<$segments_bottom_center

    tmux set-option -ga status-format[$row] "#[align=centre]"

    for segment in "${segments_bottom_center[@]}"; do
      segment_content=$(get_option "@nova-segment-${segment}")
      segment_colors=$(get_option "@nova-segment-${segment}-colors" "$dark_gray $gray")
      IFS=' ' read -r -a segment_colors <<<$segment_colors

      if [ "$segment_content" != "" ]; then
        tmux set-option -ga status-format[$row] "#[fg=${segment_colors[1]}]"
        tmux set-option -ga status-format[$row] "$(padding $padding)"
        tmux set-option -ga status-format[$row] "$segment_content"
        tmux set-option -ga status-format[$row] "$(padding $padding)"
      fi
    done

    # segments-n-right
    segments_bottom_right=$(get_option "@nova-segments-$row-right" "")
    IFS=' ' read -r -a segments_bottom_right <<<$segments_bottom_right

    tmux set-option -ga status-format[$row] "#[align=right]"

    for segment in "${segments_bottom_right[@]}"; do
      segment_content=$(get_option "@nova-segment-${segment}")
      segment_colors=$(get_option "@nova-segment-${segment}-colors" "$dark_gray $gray")
      IFS=' ' read -r -a segment_colors <<<$segment_colors

      if [ "$segment_content" != "" ]; then
        # condition everything on the non emptiness of the evaluated segment
        tmux set-option -ga status-right "#{?#{w:#{E:@nova-segment-${segment}}},"

        tmux set-option -ga status-format[$row] "#[fg=${segment_colors[1]}]"
        tmux set-option -ga status-format[$row] "$(padding $padding)"
        tmux set-option -ga status-format[$row] "$segment_content"
        tmux set-option -ga status-format[$row] "$(padding $padding)"

        # condition end
        tmux set-option -ga status-right ',}'
      fi
    done
  done
}

main "$@"
