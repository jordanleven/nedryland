#!/usr/bin/env bash
set -euo pipefail

npm install --package-lock-only
git add package-lock.json
git commit --amend --no-edit

echo "Lockfile synced into HEAD commit."
