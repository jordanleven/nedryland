---
name: dependabot-rebase
description: Trigger a rebase on all open Dependabot pull requests
disable-model-invocation: true
---

Trigger a rebase on all open Dependabot pull requests by posting a comment.

## Steps

1. **Find open Dependabot PRs** using:
   ```
   gh pr list --author "app/dependabot" --state open --json number,title
   ```
   If there are none, report that and stop.

2. **Post a rebase comment on every PR** without pausing or producing any output between them. Commenting is fast — outputting status after each one takes longer than just firing them all and reporting at the end:
   ```
   gh pr comment <number> --body "@dependabot rebase"
   ```

3. **Output a consolidated checklist** after all comments have been posted:
   ```
   - [x] #<number>: <title>
   - [x] #<number>: <title>
   ...
   ```
   Mark every PR that was successfully commented on as `[x]`. If any comment failed, mark it `[ ]` and note the error.
