#!/bin/sh

. "$(dirname "$0")/utilities.sh"

remote_repo='origin'
branch_current=$(nedryland_git_current_branch)

git push -u $remote_repo "$branch_current" $1
printf "\033[1;32m%s has been set to upstream %s.\033[0m\n" "$branch_current" "$remote_repo"
