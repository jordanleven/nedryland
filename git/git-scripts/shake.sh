#!/bin/sh

. "$(dirname "$0")/utilities.sh"

branch_target=$(nedryland_get_branch "$1")
git checkout "$branch_target"

branch_current=$(nedryland_git_current_branch)
if [ "$(nedryland_git_current_branch)" = "$branch_target" ]
then
  git fetch --all
  git pull
  git branch --merged "$branch_current" | grep -v "\* $branch_current" | xargs -n 1 git branch -d
  printf "\033[1;32mBranch %s has been pruned.\033[0m\n" "$branch_current"
else
  printf "\033[1;31mCannot prune while on branch %s \033[0m" "$branch_current"
fi
