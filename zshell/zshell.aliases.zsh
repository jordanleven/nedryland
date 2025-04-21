#!/bin/zsh

. "$(dirname "$0")/zshell.nedryland.zsh"
. "$(dirname "$0")/zshell.temp-directory.zsh"

alias nedryland="nedryland_message_show_large"
alias nedryland_loaded="nedryland_message_show_small"
alias tempdir="nedryland_create_temp_directory"
alias persistdir="nedryland_persist_temp_directory"
alias vsc="code . && exit"

alias gpp="git pull"
alias gppr="git pull --rebase"
alias gfu="git commit --fixup=HEAD~0"
