#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <main-branch> [--new-branch <name>]" >&2
  exit 1
fi

main_branch=$1
new_branch=""

shift
while [[ $# -gt 0 ]]; do
  case $1 in
    --new-branch)
      new_branch=$2
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# Fetch all remotes and pull latest main
git fetch --all
git checkout "$main_branch"
git pull

# Source nvm and use the project's Node version
source ~/.nvm/nvm.sh
nvm use

# Prune remote-tracking refs and delete local merged branches
git fetch --prune
git branch --merged "$main_branch" \
  | grep -v "^\* \|^  ${main_branch}$" \
  | xargs -r git branch -d

# Optionally create and check out a new branch
if [ -n "$new_branch" ]; then
  git checkout -b "$new_branch"
  echo "Checked out new branch: ${new_branch}"
fi

echo "Repository prepared (base: ${main_branch})."
