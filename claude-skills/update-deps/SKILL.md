---
name: update-deps
description: Update dependencies for the project in the current working directory
disable-model-invocation: true
---

Update dependencies for the project in the current working directory based on open Dependabot pull requests. Dependencies are applied in batches of 3 and tested together as a fast path — if the batch passes, move on. If it fails, reset the batch and fall back to one at a time to isolate the culprit. Each dependency ends up as its own commit so any single update can be reverted without affecting the others.

## Steps

1. **Prepare the local repository:**
   - Pull the latest main branch: `git checkout main && git pull`
   - Prune remote-tracking references and delete local branches already merged into main:
     ```
     git fetch --prune
     git branch --merged main | grep -v '^\* \|^  main$' | xargs -r git branch -d
     ```
   - Create and check out a new branch for this work:
     ```
     git checkout -b chore--update-dependencies-<YYYY-MM-DD>
     ```
     where `<YYYY-MM-DD>` is today's date (e.g. `chore--update-dependencies-2026-02-28`).

2. **Find open Dependabot PRs** using `gh pr list --author "app/dependabot" --state open --json number,title,headRefName`. If there are none, report that and stop.

2. **Extract the packages to update** from the PR titles. Dependabot PR titles follow patterns like:
   - `Bump <package> from <old> to <new>`
   - `Bump <package> and <package> from <old> to <new>`
   - `Update <package> requirement from <old> to <new>`

3. **Present a confirmation checklist** listing every package that will be updated, showing the old and new version for each:
   ```
   The following dependencies will be updated in batches of 3:

   - [ ] <package>: <old-version> → <new-version>  (#<pr-number>)
   - [ ] <package>: <old-version> → <new-version>  (#<pr-number>)
   ...

   Proceed with updates? (yes/no)
   ```
   **Stop if the user says no.**

   When reprinting the checklist during updates, mark the current batch with a `→` arrow so it's clear which 3 are actively being worked on:
   ```
   - [x] <package>: <old> → <new>  (#<pr-number>)   ✓ done
   - [ ] <package>: <old> → <new>  (#<pr-number>)   ← current batch
   - [ ] <package>: <old> → <new>  (#<pr-number>)   ← current batch
   - [ ] <package>: <old> → <new>  (#<pr-number>)   ← current batch
   - [ ] <package>: <old> → <new>  (#<pr-number>)
   ...
   ```

4. **Detect the package manager** by checking for lockfiles/config files:
   - `package-lock.json` → npm
   - `yarn.lock` → yarn
   - `pnpm-lock.yaml` → pnpm
   - `Pipfile` or `Pipfile.lock` → pipenv
   - `requirements.txt` → pip
   - `go.mod` → go
   - `Gemfile` → bundler

5. **Process dependencies in batches of 3**, using a fast path with a one-at-a-time fallback:

   ### Fast path (batch of 3)

   For each batch of up to 3 PRs:

   a. **Cherry-pick all PRs in the batch**, one after the other without testing between them:
      ```
      git fetch origin <headRefName>
      git cherry-pick origin/<headRefName>
      ```
      For each cherry-pick, if there are merge conflicts resolve them before continuing:
      - **`package.json` conflict** — resolve manually, keeping the new version from the Dependabot branch
      - **Lockfile conflict** (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`) — unstage and regenerate:
        - npm: `git checkout HEAD -- package-lock.json && npm install --package-lock-only`
        - yarn: `git checkout HEAD -- yarn.lock && yarn install --frozen-lockfile=false`
        - pnpm: `git checkout HEAD -- pnpm-lock.yaml && pnpm install --lockfile-only`
      - Stage all resolved files and run `git cherry-pick --continue`

   b. **Verify the batch with a clean install and full check:**
      1. Sync the lockfile: `npm install --package-lock-only` — `npm ci` requires `package.json` and `package-lock.json` to be in sync
      2. Clean install: `rm -rf node_modules && npm ci`
      3. Run the application or build to confirm it starts
      4. Run the test suite
      5. Run the linter

   c. **If the batch passes:** check off all items in the batch with `[x]`, reprint the full checklist showing their completed status and highlighting the next batch with `→`, then move on.

   d. **If the batch fails:** reset all commits in the batch:
      ```
      git reset --hard HEAD~<number of commits in batch>
      ```
      Then fall back to the **one-at-a-time path** (below) for each PR in this batch individually.

   ### One-at-a-time fallback

   Apply each PR individually, running the full verification after each one:

   a. Cherry-pick and resolve conflicts (same as fast path step a above).

   b. **Verify** (same clean install + full check as fast path step b above).

   c. **If verification passes:**
      - If any additional files were modified to make the update work (e.g. fixing a changed API, updating a config), amend them into the cherry-pick commit:
        ```
        git add <modified-files>
        git commit --amend --no-edit
        ```
        Never create a separate follow-up commit — a single revert must undo everything.
      - Check off the item in the checklist with `[x]` and continue.

   d. **If verification fails**, first check whether this is a **major version bump** (major version number changed, e.g. `1.4.2 → 2.0.0`):

      - **Major version bump:** do not attempt debugging. Immediately run `git reset --hard HEAD~1` and ask:
        > "`<package>` was bumped from `<old>` to `<new>` (major version). Major bumps often include breaking changes that require migration work. Would you like to skip this one?"
        Check off as skipped with a note if they confirm, then continue.

      - **Minor or patch bump:** pause and ask:
        > "`<package>` update caused a failure in `<step>`. Would you like me to try to fix the issue, or undo and move on?"
        - If fix: attempt to resolve, then re-run the full check. **Spend no more than 3 minutes debugging.** If unresolved, ask: "I wasn't able to fix this within 3 minutes. Should I keep trying or would you like to take over?"
        - If skip: run `git reset --hard HEAD~1`, check off as skipped with a note, and continue.

   **Do not comment on or close the Dependabot PR.** Leave it untouched until the work is merged.

6. **Ask the user** if they would like to open a pull request for these changes. If yes, use the `create-pr` skill. The PR title must be **"Dependency Updates"** (always, regardless of what was updated). The body should include:
   - The full list of dependency updates (package name, old version → new version, Dependabot PR reference)
   - Any other commits on the branch that are unrelated to dependency updates, listed separately so reviewers are aware of them

7. **Summarize** what was updated and, if a PR was opened, link to it.
