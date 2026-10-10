#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <headRefName>" >&2
  exit 1
fi

head_ref=$1

git fetch origin "$head_ref"
git cherry-pick "origin/${head_ref}"

echo "Cherry-picked origin/${head_ref}."
