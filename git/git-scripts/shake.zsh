#!/bin/zsh

. "$(dirname "$0")/get-branch.zsh"

branch_target=$(get_branch $1)
git checkout "$branch_target"

branch_current=$(current_branch)
if [ "$(current_branch)" = "$branch_target" ]
then
  git fetch --all
  git pull
  git branch --merged "$branch_current" | grep -v "\* $branch_current" | xargs -n 1 git branch -d
  echo "\033[1;32mBranch $branch_current has been pruned.\033[0m"
else
  echo "\033[1;31mCannot prune while on branch $branch_current \033[0m"
fi
