#!/bin/sh

# Used as GIT_SEQUENCE_EDITOR during `git remove-beta`. Rewrites the rebase
# todo list to drop any SHA listed in $GIT_REMOVE_BETA_SHAS.

todo_file="$1"

for sha in $GIT_REMOVE_BETA_SHAS
do
  # Match the short SHA prefix at the start of a pick line and replace with drop.
  sed -i '' "s/^pick $sha/drop $sha/" "$todo_file"
done
