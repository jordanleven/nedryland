#!/usr/bin/env bash
set -euo pipefail

# Detect the main branch (main, trunk, mainline, default, or master).
main_branch=""
for ref in refs/heads/main refs/heads/trunk refs/heads/mainline refs/heads/default \
           refs/remotes/origin/main refs/remotes/origin/trunk \
           refs/remotes/origin/mainline refs/remotes/origin/default; do
  if git show-ref -q --verify "$ref" 2>/dev/null; then
    main_branch="${ref##*/}"
    break
  fi
done
main_branch="${main_branch:-master}"

echo "Main branch: ${main_branch}"
echo ""
git log "${main_branch}..HEAD" --oneline
echo ""
git diff "${main_branch}...HEAD" --stat
