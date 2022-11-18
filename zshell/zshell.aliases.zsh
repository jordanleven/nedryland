#!/bin/zsh

. "$(dirname "$0")/zshell.nedryland.zsh"
. "$(dirname "$0")/zshell.temp-directory.zsh"

alias nedryland="welcome_to_nedryland"
alias tempdir="nedryland_create_temp_directory"
alias persistdir="nedryland_persist_temp_directory"

alias gpp="git pull"
alias gppr="git pull --rebase"
alias gfu="git commit --fixup=HEAD~0"
alias toggleheat="shortcuts run 'Space Heater'"

function brightness() {
  # Default to 50%
  shortcuts run 'Set Brightness' <<< ${1-50}
}
