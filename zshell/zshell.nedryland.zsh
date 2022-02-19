#!/bin/zsh

nedryland_current_directory=$(dirname "$0")

welcome_to_nedryland() {
  nedryland_ascii_art=$(<"$nedryland_current_directory/../assets/nedryland.txt")
  echo "$nedryland_ascii_art"
}
