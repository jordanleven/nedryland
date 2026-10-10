---
name: dependabot-rebase
description: Trigger a rebase on all open Dependabot pull requests
disable-model-invocation: true
---

Trigger a rebase on all open Dependabot pull requests by posting a comment.

## Steps

1. Run the bundled script and print its output verbatim — it lists open Dependabot PRs, comments `@dependabot rebase` on each, and prints a checklist (`[x]` on success, `[ ]` with an error note on failure):
   ```
   ./skills/dependabot-rebase/rebase.sh
   ```
