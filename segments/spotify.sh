#!/bin/bash
export LC_ALL=en_US.UTF-8

SEGMENT_NAME=spotify

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$(readlink -f $current_dir/../scripts/utils.sh)"

# https://github.com/erikw/tmux-powerline/blob/main/segments/now_playing.sh#L297
main() {
  if shell_is_linux; then
    if type pwsh.exe >/dev/null 2>&1; then  # WSL
      np="$(pwsh.exe -NoProfile -C 'Get-Process | Where-Object { ($_.mainWindowTitle -and $_.Name -eq "Spotify") } | Select -Exp MainWindowTitle')"
      if [[ -z "$np" ]]; then
        np="$(tasklist.exe /fo list /v /fi "IMAGENAME eq Spotify.exe" | grep " - "  | cut -d" " -f3-)"
      fi
      np="${np//[$'\t\r\n']}"
    else
      metadata="$(dbus-send --reply-timeout=42 --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null)"
      if [ "$?" -eq 0 ] && [ -n "$metadata" ]; then
        state="$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'|grep -E -A 1 "string"|cut -b 26-|cut -d '"' -f 1|grep -E -v ^$)"
        if [[ $state == "Playing" ]]; then
          artist="$(echo "$metadata" | grep -PA2 "string\s\"xesam:artist\"" | tail -1 | grep -Po "(?<=\").*(?=\")")"
          track="$(echo "$metadata" | grep -PA1 "string\s\"xesam:title\"" | tail -1 | grep -Po "(?<=\").*(?=\")")"
          np="$(echo "${artist} - ${track}")"
        fi
      fi
    fi
  elif shell_is_osx; then
    np="$(${current_dir}/../scripts/np_spotify_mac.script)"
  fi
  if [ -z "$np" ]; then
    np="Not playing"
  fi
  echo "$(get_segment_content $SEGMENT_NAME "$np")"
}

main "$@"
