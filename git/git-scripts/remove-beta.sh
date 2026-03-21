#!/bin/sh

. "$(dirname "$0")/utilities.sh"

main_branch=$(nedryland_git_main_branch)

# Find beta release commits on this branch that aren't in main/master.
# Beta commits match the pattern: chore(release): X.Y.Z-<hash>
beta_commits=$(git log "$main_branch"..HEAD --oneline | grep -E "chore\(release\): [0-9]+\.[0-9]+\.[0-9]+-[A-Za-z0-9]+")

if [ -z "$beta_commits" ]
then
  printf "\033[1;32mNo beta release commits found.\033[0m\n"
  exit 0
fi

printf "\033[1;33mThe following beta release commits will be dropped:\033[0m\n\n"
echo "$beta_commits"
printf "\n"

printf "\033[1mDrop these commits? [y/n] \033[0m"
read reply
case "$reply" in
  [Yy]*)
    ;;
  *)
    printf "\033[1;31mAborted.\033[0m\n"
    exit 1
    ;;
esac

# Build a grep pattern used to drop matching commits via rebase.
# git rebase --onto cannot drop non-contiguous commits directly, so we use
# filter-branch-style drop via interactive rebase in a script.
beta_shas=$(git log "$main_branch"..HEAD --oneline | grep -E "chore\(release\): [0-9]+\.[0-9]+\.[0-9]+-[A-Za-z0-9]+" | awk '{print $1}')

# Use git rebase with an exec sequence: rewrite the todo list to drop matching SHAs.
GIT_SEQUENCE_EDITOR="$(dirname "$0")/remove-beta-rebase-editor.sh" \
  GIT_REMOVE_BETA_SHAS="$beta_shas" \
  git rebase -i "$main_branch"
