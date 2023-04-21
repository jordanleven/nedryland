#!/bin/sh

. "$(dirname "$0")/utilities.sh"

if [ "$(nedryland_git_current_branch)" = "$(nedryland_git_main_branch)" ]
then
  git rebase -i --root
else
  git rebase -i "$(nedryland_get_branch "$1")"
fi
