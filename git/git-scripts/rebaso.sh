#!/bin/zsh

source $(dirname "$0")/get-branch.sh

branch=$(get_branch)
if [[ $(current_branch) == $(git_main_branch) ]]
then
  git rebase -i --root
else
  git rebase -i $(get_branch $1)
fi
