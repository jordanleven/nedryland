#!/bin/zsh

. ~/.zshrc

get_branch() {
  if [ -n "$1" ]
  then
    echo $1
  else
    git_main_branch
  fi
}
