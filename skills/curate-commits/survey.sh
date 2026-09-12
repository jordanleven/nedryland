#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <main-branch>" >&2
  exit 1
fi

main_branch=$1

git log "${main_branch}..HEAD" --oneline
echo ""
git diff "${main_branch}...HEAD" --stat
