#!/bin/zsh

nedryland_current_directory=$(dirname "$0")

nedryland_message_show() {
  nedryland_ascii_art=$(<"$nedryland_current_directory/../assets/$1")
  echo "$nedryland_ascii_art\n"
}

nedryland_message_show_large() {
  nedryland_message_show "nedryland_large.txt"
}

nedryland_message_show_small() {
  nedryland_message_show "nedryland_small.txt";
}

nedryland_message_show_auto() {
  local terminal_columns="${COLUMNS:-0}"
  local terminal_lines="${LINES:-0}"
  local large_min_columns="${NEDRYLAND_LARGE_MIN_COLUMNS:-100}"
  local large_min_lines="${NEDRYLAND_LARGE_MIN_LINES:-14}"

  if (( terminal_columns <= 0 || terminal_lines <= 0 )) && command -v tput > /dev/null
  then
    terminal_columns="$(tput cols 2>/dev/null || echo 0)"
    terminal_lines="$(tput lines 2>/dev/null || echo 0)"
  fi

  if (( terminal_columns >= large_min_columns && terminal_lines >= large_min_lines ))
  then
    nedryland_message_show_large
  else
    nedryland_message_show_small
  fi
}
