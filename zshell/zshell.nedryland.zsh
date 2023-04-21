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
