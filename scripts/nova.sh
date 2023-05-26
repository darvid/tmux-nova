#!/usr/bin/env bash
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
segments_dir="$(readlink -f "$current_dir/../segments")"

source $current_dir/utils.sh

#
# dracula color palette
#
white="#f8f8f2"
gray="#44475a"
dark_gray="#282a36"
light_purple="#bd93f9"
dark_purple="#6272a4"
cyan="#8be9fd"
green="#50fa7b"
orange="#ffb86c"
red="#ff5555"
pink="#ff79c6"
dark_pink="##803b62"
yellow="#f1fa8c"
dark_yellow="##879306"

#
# global options
#

padding=$(get_option "@nova-padding" 0)
margin=$(get_option "@nova-margin" 1)
nerdfonts=$(get_option "@nova-nerdfonts" true)
pills=$(get_option "@nova-pills" true)
nerdfonts_right=$(get_option "@nova-nerdfonts-right" )
nerdfonts_left=$(get_option "@nova-nerdfonts-left" )
rows=$(get_option "@nova-rows" 1)

set_option "@nova-pane-name-colors" "fg:$gray"
set_option "@nova-pane-icon-colors" "fg:magenta"
set_option "@nova-pane-divider-colors" "fg:$pink"
set_option "@nova-pane-divider-active-colors" "fg:$pink"

pane_copy_mode="#{?#{==:#{pane_mode},copy-mode},,}"
pane_view_mode="#{?#{==:#{pane_mode},view-mode},,}"

#
# default segments
#

upsert_option "@nova-segment-mode" "#{?client_prefix,🦄,💊}"
upsert_option "@nova-segment-mode-colors" "#{?client_prefix,$green,$dark_gray} #{?client_prefix,default,default}"
upsert_option "@nova-segment-whoami" "🧛 #[italics]#(whoami)@#h"
upsert_option "@nova-segment-whoami-colors" "$pink $dark_pink"
upsert_option "@nova-segment-mode-colors" "$pink $dark_gray"

upsert_option "@nova-segment-spotify" "#($segments_dir/spotify.sh)"
upsert_option "@nova-segment-spotify-roll" true
upsert_option "@nova-segment-spotify-prefix" " "
upsert_option "@nova-segment-spotify-colors" "$dark_purple $light_purple"

upsert_option "@nova-segment-mode-colors" "#{?client_prefix,$green,$dark_gray} #{?client_prefix,default,default}"

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
  local divider=${2:-}
  local pane_zoomed="#{?window_zoomed_flag,$divider ,}"
  local pane_mode="#{?pane_in_mode,$pane_copy_mode$pane_view_mode $divider ,}"
  local pane_window_name="#($segments_dir/window-name.sh #{pane_current_command} ${active})"
  local pane=$(get_option "@nova-pane" "#I$divider $pane_mode$pane_window_name$pane_zoomed_flag")
  echo "$pane"
}

get_status_style_fmt() {
  local activity_color=$1
  if [ -z "$activity_color" ]; then
    activity_color=$(get_option "@nova-status-style-activity-bg" "$white")
  fi
  local normal_color=${2:-default}
  local type=${3:-bg}
  echo "#{?window_activity_flag,#[$type=$activity_color],#[$type=$normal_color]}"
}

main() {
  #
  # double
  #
  if [ "$rows" -eq 0 ]; then
    tmux set-option -g status on
  else
    tmux set-option -g status $(expr $rows + 1)
  fi

  #
  # interval
  #
  interval=$(get_option "@nova-interval" 1)
  tmux set-option -g status-interval $interval

  #
  # status-style
  #
  if [ $pills = true ]; then
    status_style_bg=$(get_option "@nova-status-style-bg" "default")
    status_style_pill_bg=$(get_option "@nova-status-style-pill-bg" "$gray")
    status_style_pill_fg=$(get_option "@nova-status-style-pill-fg" "$dark_gray")
  else
    status_style_bg=$(get_option "@nova-status-style-bg" "$gray")
  fi
  status_style_fg=$(get_option "@nova-status-style-fg" "$gray")
  status_style_active_bg=$(get_option "@nova-status-style-active-bg" "$yellow")
  status_style_active_fg=$(get_option "@nova-status-style-active-fg" "$dark_yellow")
  status_style_activity_bg=$(get_option "@nova-status-style-activity-bg" "$red")
  status_style_activity_fg=$(get_option "@nova-status-style-activity-fg" "$gray")

  tmux set-option -g status-style "bg=$status_style_bg,fg=$status_style_fg"

  #
  # pane
  #
  pane_border_style=$(get_option "@nova-pane-border-style" "$dark_gray")
  pane_active_border_style=$(get_option "@nova-pane-active-border-style" "$gray")
  tmux set-option -g pane-border-style "fg=${pane_border_style}"
  tmux set-option -g pane-active-border-style "fg=${pane_active_border_style}"

  #
  # segments-0-left
  #
  segments_left=$(get_option "@nova-segments-0-left" "mode")
  IFS=' ' read -r -a segments_left <<< $segments_left

  tmux set-option -g status-left ""

  first_left_segment=true
  for segment in "${segments_left[@]}"; do
    segment_content=$(get_option "@nova-segment-$segment" "mode")
    segment_colors=$(get_option "@nova-segment-$segment-colors" "$dark_gray $gray")
    IFS=' ' read -r -a segment_colors <<< $segment_colors
    if [ "$segment_content" != "" ]; then
      # condition everything on the non emptiness of the evaluated segment
      tmux set-option -ga status-left "#{?#{w:#{E:@nova-segment-$segment}},"

      if [ $nerdfonts = true ]; then
        if [ $first_left_segment != true ] || [ $first_left_segment = true ] && [ $pills = true ]; then
          if [ $pills = true ]; then
            tmux set-option -ga status-left "#[bg=default]#[fg=${segment_colors[0]}]"
          else
            tmux set-option -ga status-left "#[bg=${segment_colors[0]}]"
          fi

          tmux set-option -ga status-left "$(get_ple_end right)"
        fi
      fi

      tmux set-option -ga status-left "#[fg=${segment_colors[1]}#,bg=${segment_colors[0]}]"
      tmux set-option -ga status-left "$(padding $padding)"
      tmux set-option -ga status-left "$segment_content"
      tmux set-option -ga status-left "$(padding $padding)"

      # set the fg color for the next nerdfonts seperator
      tmux set-option -ga status-left "#[fg=${segment_colors[0]}]"

      # condition end
      tmux set-option -ga status-left ',}'

      first_left_segment=false
    fi
  done

  if [ $nerdfonts = true ]; then
    tmux set-option -ga status-left "#[bg=${status_style_bg}]"
    tmux set-option -ga status-left "$(get_ple_end left)"
  fi

  #
  # status-format
  #
  pane_justify=$(get_option "@nova-pane-justify" "left")
  tmux set-option -g status-justify ${pane_justify}
  tmux set-window-option -g window-status-format "$(padding $margin)"

  if [ $nerdfonts = true ]; then
    if [ $pills = true ]; then
      tmux set-window-option -ga window-status-format "$(get_status_style_fmt $status_style_activity_bg $status_style_bg fg)#[bg=default]"
      tmux set-window-option -g window-status-current-format "$(padding $margin)$(get_status_style_fmt $status_style_activity_bg $status_style_active_bg fg)#[bg=default]"
    else
      tmux set-window-option -g window-status-current-format "$(padding $margin)#[fg=${status_style_bg}]$(get_status_style_fmt $status_style_activity_bg $status_style_active_bg bg)"
    fi
    tmux set-window-option -ga window-status-format "$(get_ple_end right)"
    tmux set-window-option -ga window-status-current-format "$(get_ple_end right)"
  fi

  tmux set-window-option -ga window-status-format "$(get_status_style_fmt $status_style_activity_fg $status_style_pill_fg fg)"
  tmux set-window-option -ga window-status-format "$(get_status_style_fmt $status_style_activity_bg $status_style_pill_bg bg)"
  tmux set-window-option -ga window-status-format "$(padding $padding)"
  tmux set-window-option -ga window-status-format "$(get_pane_fmt)"
  tmux set-window-option -ga window-status-format "$(padding $padding)"

  if [ $nerdfonts = true ]; then
    tmux set-window-option -ga window-status-current-format "#[fg=${status_style_active_fg}]#[bg=${status_style_active_bg}]"
  else
    tmux set-window-option -g window-status-current-format "#[fg=${status_style_active_fg}]#[bg=${status_style_active_bg}]"
  fi

  tmux set-window-option -ga window-status-current-format "$(padding $padding)"
  tmux set-window-option -ga window-status-current-format "$(get_pane_fmt true)"
  tmux set-window-option -ga window-status-current-format "$(padding $padding)"

  if [ $nerdfonts = true ]; then
    tmux set-window-option -ga window-status-current-format "#[fg=${status_style_active_bg},bg=${status_style_bg}]"
    tmux set-window-option -ga window-status-current-format "$(get_ple_end left)"
    tmux set-window-option -ga window-status-format "$(get_status_style_fmt $status_style_activity_bg $status_style_bg fg)#[bg=default]"
    tmux set-window-option -ga window-status-format "$(get_ple_end left)"
  fi

  add_margin window-status-current-format

  #
  # segments-0-right
  #
  segments_right=$(get_option "@nova-segments-0-right" "")
  IFS=' ' read -r -a segments_right <<< $segments_right

  tmux set-option -g status-right ""

  for segment in "${segments_right[@]}"; do
    segment_content=$(get_option "@nova-segment-$segment" "")
    segment_colors=$(get_option "@nova-segment-$segment-colors" "$dark_gray $gray")
    IFS=' ' read -r -a segment_colors <<< $segment_colors
    if [ "$segment_content" != "" ] && [ "$segment_colors" != "" ]; then
      if [ $nerdfonts = true ] && [ ! -n "$(tmux show-option -gqv status-right)" ]; then
        tmux set-option -ga status-right "#[bg=#${status_style_bg}]"
      fi

      # condition everything on the non emptiness of the evaluated segment
      tmux set-option -ga status-right "#{?#{w:#{E:@nova-segment-$segment}},"

      if [ $nerdfonts = true ]; then
        tmux set-option -ga status-right "#[fg=${segment_colors[0]}]"
        tmux set-option -ga status-right "$nerdfonts_right"
      fi

      tmux set-option -ga status-right "#[fg=${segment_colors[1]}#,bg=${segment_colors[0]}]"
      tmux set-option -ga status-right "$(padding $padding)"
      tmux set-option -ga status-right "$segment_content"
      tmux set-option -ga status-right "$(padding $padding)"

      # set the bg color for the next nerdfonts seperator
      if [ $pills = true ]; then
        tmux set-option -ga status-right "#[fg=${segment_colors[0]}]#[bg=default]$(get_ple_end left)"
      elif [ $nerdfonts = true ]; then
        tmux set-option -ga status-right "#[bg=${segment_colors[0]}]"
      fi

      # condition end
      tmux set-option -ga status-right ',}'
    fi
  done

  for ((row=1; row <= rows; row++)); do
    #
    # segments-n-left
    #
    if [ $pills = true ]; then
      status_style_double_bg=$(get_option "@nova-status-style-double-bg" "default")
    else
      status_style_double_bg=$(get_option "@nova-status-style-double-bg" "$dark_gray")
    fi
    segments_bottom_left=$(get_option "@nova-segments-$row-left" "")
    IFS=' ' read -r -a segments_bottom_left <<< $segments_bottom_left

    tmux set-option -g status-format[$row] "#[fill=$status_style_double_bg]#[align=left]"
    nerdfonts_color="$status_style_double_bg"

    for segment in "${segments_bottom_left[@]}"; do
      segment_content=$(get_option "@nova-segment-$segment" "")
      segment_colors=$(get_option "@nova-segment-$segment-colors" "$dark_gray $gray")
      IFS=' ' read -r -a segment_colors <<< $segment_colors
      if [ "$segment_content" != "" ]; then
        if [ $pills = true ]; then
          tmux set-option -ga status-format[$row] "#[fg=${segment_colors[0]}]"
          tmux set-option -ga status-format[$row] "$(get_ple_end right)"
        elif [ $nerdfonts = true ] && [ "$(tmux show-option -gqv status-format[$row])" != "#[align=left]"]; then
          tmux set-option -ga status-format[$row] "#[fg=${nerdfonts_color},bg=#${segment_colors[0]}]"
          tmux set-option -ga status-format[$row] "$nerdfonts_left"
        fi

        tmux set-option -ga status-format[$row] "#[fg=${segment_colors[1]},bg=${segment_colors[0]}]"
        tmux set-option -ga status-format[$row] "$(padding $padding)"
        tmux set-option -ga status-format[$row] "$segment_content"
        tmux set-option -ga status-format[$row] "$(padding $padding)"

        [ $nerdfonts = true ] && nerdfonts_color="${segment_colors[0]}"
      fi
    done

    if [ $nerdfonts = true ] && [ ! -z $nerdfonts_color ]; then
      tmux set-option -ga status-format[$row] "#[fg=${nerdfonts_color},bg=${status_style_double_bg}]"
      tmux set-option -ga status-format[$row] "$(get_ple_end left)"
    fi

    #
    # segments-n-center
    #
    nerdfonts_color="$status_style_double_bg"

    segments_bottom_center=$(get_option "@nova-segments-$row-center" "")
    IFS=' ' read -r -a segments_bottom_center <<< $segments_bottom_center

    tmux set-option -ga status-format[$row] "#[align=centre]"

    for segment in "${segments_bottom_center[@]}"; do
      segment_content=$(get_option "@nova-segment-$segment")
      segment_colors=$(get_option "@nova-segment-$segment-colors" "$dark_gray $gray")
      IFS=' ' read -r -a segment_colors <<< $segment_colors

      if [ "$segment_content" != "" ]; then
        if [ $nerdfonts = true ]; then
          tmux set-option -ga status-format[$row] "#[fg=${nerdfonts_color}]#[bg=#${segment_colors[0]}]"
          tmux set-option -ga status-format[$row] "$nerdfonts_left"
        fi

        tmux set-option -ga status-format[$row] "#[fg=${segment_colors[1]}]#[bg=${segment_colors[0]}]"
        tmux set-option -ga status-format[$row] "$(padding $padding)"
        tmux set-option -ga status-format[$row] "$segment_content"
        tmux set-option -ga status-format[$row] "$(padding $padding)"

        if [ $nerdfonts = true ]; then
          tmux set-option -ga status-format[$row] "#[fg=${nerdfonts_color}]#[bg=#${segment_colors[0]}]"
          tmux set-option -ga status-format[$row] "$nerdfonts_right"
        fi
      fi
    done

    #
    # segments-n-right
    #
    nerdfonts_color="$status_style_double_bg"

    segments_bottom_right=$(get_option "@nova-segments-$row-right" "")
    IFS=' ' read -r -a segments_bottom_right <<< $segments_bottom_right

    tmux set-option -ga status-format[$row] "#[align=right]"

    for segment in "${segments_bottom_right[@]}"; do
      segment_content=$(get_option "@nova-segment-$segment")
      segment_colors=$(get_option "@nova-segment-$segment-colors" "$dark_gray $gray")
      IFS=' ' read -r -a segment_colors <<< $segment_colors

      if [ "$segment_content" != "" ]; then
        # condition everything on the non emptiness of the evaluated segment
        tmux set-option -ga status-right "#{?#{w:#{E:@nova-segment-$segment}},"

        if [ $nerdfonts = true ]; then
          tmux set-option -ga status-format[$row] "#[fg=${segment_colors[0]}]#[bg=#${nerdfonts_color}]"
          tmux set-option -ga status-format[$row] "$(get_ple_end right)"
        fi

        tmux set-option -ga status-format[$row] "#[fg=${segment_colors[1]}]#[bg=${segment_colors[0]}]"
        tmux set-option -ga status-format[$row] "$(padding $padding)"
        tmux set-option -ga status-format[$row] "$segment_content"
        tmux set-option -ga status-format[$row] "#[bg=${segment_colors[0]}]$(padding $padding)"

        if [ $pills = true ]; then
          tmux set-option -ga status-format[$row] "#[fg=${segment_colors[0]}]#[bg=${nerdfonts_color}]$(get_ple_end left)"
        fi

        # condition end
        tmux set-option -ga status-right ',}'
      fi
    done
  done
}

main "$@"
