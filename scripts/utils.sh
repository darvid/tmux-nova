#!/usr/bin/env bash
export LC_ALL=en_US.UTF-8

# https://github.com/erikw/tmux-powerline/blob/main/config/shell.sh
export SHELL_PLATFORM='unknown'

ostype() { echo $OSTYPE | tr '[A-Z]' '[a-z]'; }

case "$(ostype)" in
	*'linux'*  ) SHELL_PLATFORM='linux' ;;
	*'darwin'* ) SHELL_PLATFORM='osx'   ;;
	*'bsd'*    ) SHELL_PLATFORM='bsd'   ;;
esac

shell_is_linux() { [[ $SHELL_PLATFORM == 'linux' || $SHELL_PLATFORM == 'bsd' ]]; }
shell_is_osx()   { [[ $SHELL_PLATFORM == 'osx' ]]; }
shell_is_bsd()   { [[ $SHELL_PLATFORM == 'bsd' || $SHELL_PLATFORM == 'osx' ]]; }

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

get_segment_content() {
  local segment_name=$1
  local segment_content=${2:-$(get_option "@nova-segment-$segment_name" "mode")}
  if [ -z "$segment_content" ]; then
    return
  fi

  local segment_roll=$(get_option "@nova-segment-$segment_name-roll" false)
  local segment_roll_speed=$(get_option "@nova-segment-$segment_name-roll-speed" 1)
  local segment_max_length=$(get_option "@nova-segment-$segment_name-max-length" 15)
  local segment_prefix=$(get_option "@nova-segment-$segment_name-prefix" "")

  if [ "$segment_roll" = "true" ]; then
    echo "$segment_prefix $(roll_text "${segment_content}" $segment_max_length $segment_roll_speed)"
  else
    echo "$segment_prefix $segment_content"
  fi
}

# https://github.com/erikw/tmux-powerline/blob/main/lib/text_roll.sh
# Rolling anything what you want.
# arg1: text to roll.
# arg2: max length to display.
# arg3: roll speed in characters per second.
roll_text() {
	local text="$1"  # Text to print

	if [ -z "$text" ]; then
		return;
	fi

	local max_len="10"	# Default max length.

	if [ -n "$2" ]; then
		max_len="$2"
	fi

	local speed="1"  # Default roll speed in chars per second.

	if [ -n "$3" ]; then
		speed="$3"
	fi

	# Skip rolling if the output is less than max_len.
	if [ "${#text}" -le "$max_len" ]; then
		echo "$text"
		return
	fi

	# Anything starting with 0 is an Octal number in Shell,C or Perl,
	# so we must explicitly state the base of a number using base#number
	local offset=$((10#$(date +%s) * ${speed} % ${#text}))

	# Truncate text.
	text=${text:offset}

	local char	# Character.
	local bytes # The bytes of one character.
	local index

	for ((index=0; index < max_len; index++)); do
		char=${text:index:1}
		bytes=$(echo -n $char | wc -c)
		# The character will takes twice space
		# of an alphabet if (bytes > 1).
		if ((bytes > 1)); then
			max_len=$((max_len - 1))
		fi
	done

	text=${text:0:max_len}

	#echo "index=${index} max=${max_len} len=${#text}"
	# How many spaces we need to fill to keep
	# the length of text that will be shown?
	local fill_count=$((${index} - ${#text}))

	for ((index=0; index < fill_count; index++)); do
		text="${text} "
	done

	echo "${text}"
}

export -f get_option
export -f get_ple_end
export -f get_segment_content
export -f padding
export -f roll_text
export -f set_option
export -f shell_is_linux
export -f shell_is_osx
export -f shell_is_bsd
export -f upsert_option
