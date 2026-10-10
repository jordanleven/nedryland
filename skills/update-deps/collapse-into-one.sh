#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <main-branch>" >&2
  exit 1
fi

main_branch=$1

merge_base=$(git merge-base "$main_branch" HEAD)
commit_count=$(git rev-list --count "${merge_base}..HEAD")

if [ "$commit_count" -le 1 ]; then
  echo "Already a single commit ahead of ${main_branch} — nothing to collapse."
  exit 0
fi

git reset --soft "$merge_base"
git commit -m "chore: Update dependencies"

echo "Collapsed ${commit_count} commits into one: chore: Update dependencies"
