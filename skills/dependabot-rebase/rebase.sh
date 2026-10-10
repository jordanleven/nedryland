#!/usr/bin/env bash
set -euo pipefail

prs_json=$(gh pr list --author "app/dependabot" --state open --json number,title)
count=$(echo "$prs_json" | jq 'length')

if [ "$count" -eq 0 ]; then
  echo "No open Dependabot PRs found."
  exit 0
fi

status_lines=()
while IFS=$'\t' read -r number title; do
  if error=$(gh pr comment "$number" --body "@dependabot rebase" 2>&1 >/dev/null); then
    status_lines+=("- [x] #${number}: ${title}")
  else
    status_lines+=("- [ ] #${number}: ${title} (error: ${error})")
  fi
done < <(echo "$prs_json" | jq -r '.[] | [.number, .title] | @tsv')

printf '%s\n' "${status_lines[@]}"
