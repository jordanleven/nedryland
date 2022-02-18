#!/bin/zsh

nedryland_directory=$(dirname "$0")

function welcome_to_nedryland {
  nedryland_ascii_art=$(<$nedryland_directory/../assets/nedryland.txt)
  echo -e "\n\033[1;32mWelcome to Nedryland!\033[0m"
  echo -e "$nedryland_ascii_art"
}
