---
name: update-deps
description: Update dependencies for the project in the current working directory
disable-model-invocation: true
---

Update dependencies for the project in the current working directory based on open Dependabot pull requests. This skill has two separate tracks:

- **Patch and minor updates** — cherry-picked onto a new dated branch in batches of 3, each ending up as its own commit so any single update can be reverted independently.
- **Major version updates** — handled separately by checking out the existing Dependabot branch directly (no new branch). Major bumps are presented as a ranked plan and tackled one at a time at the user's direction.

## Steps

1. **Prepare the local repository:**
   - Fetch all remotes: `git fetch --all`
   - Pull the latest main branch: `git checkout <main-branch> && git pull` — check `git remote show origin` or recent commits to confirm whether it's `master` or `main`
   - Switch to the correct Node version: `source ~/.nvm/nvm.sh && nvm use` — background bash commands run in a fresh shell and do not inherit nvm shell state, so nvm must be sourced explicitly every time, not just once
   - Prune remote-tracking references and delete local branches already merged into main:
     ```
     git fetch --prune
     git branch --merged <main-branch> | grep -v '^\* \|^  <main-branch>$' | xargs -r git branch -d
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

   **Separate into two tracks:**
   - **Patch and minor** (e.g. `1.2.3 → 1.2.4` or `1.2.3 → 1.3.0`) — queue for the batch flow in step 5, patches before minors
   - **Major** (e.g. `1.x → 2.0.0`) — set aside for the dedicated major update flow in step 7; do **not** include in the batch

3. **Present a confirmation checklist** for the patch/minor updates only (majors are handled separately in step 7). Show the old and new version for each:
   ```
   The following patch/minor dependencies will be updated in batches of 3:

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
      After cherry-picking each PR, confirm the actual new version by reading the relevant entry in `package.json` — PR titles and branch names are frequently stale and may not reflect what was actually committed. Use the `package.json` value as ground truth when reporting what changed.
      **Strip the scope from Dependabot commit messages.** Dependabot commits often use `chore(subject): ...` — always rewrite these to `chore: ...` by amending the commit immediately after cherry-picking:
      ```
      git commit --amend -m "chore: <rest of message>"
      ```
      For each cherry-pick, if there are merge conflicts resolve them before continuing:
      - **`package.json` conflict** — resolve manually, keeping the new version from the Dependabot branch
      - **Lockfile conflict** (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`) — unstage and regenerate:
        - npm: `git checkout HEAD -- package-lock.json && npm install --package-lock-only`
        - yarn: `git checkout HEAD -- yarn.lock && yarn install --frozen-lockfile=false`
        - pnpm: `git checkout HEAD -- pnpm-lock.yaml && pnpm install --lockfile-only`
      - Stage all resolved files and run `git -c commit.gpgsign=false cherry-pick --continue --no-edit`
        (The `commit.gpgsign=false` flag is needed on machines where GPG signing is configured — `--continue` creates a merge commit and will fail with a GPG error otherwise.)

   b. **Verify the batch:**
      1. Sync the lockfile and install: `npm install --package-lock-only && npm install` — use `npm install` (not `npm ci`) during batch verification to avoid the cost of a full clean install on every iteration.
         - **If `npm install` fails with ERESOLVE:** do **not** reach for `--legacy-peer-deps`. That flag silently skips peer dependency installation (e.g. `postcss-html`), which can cause downstream failures in lint or build that look unrelated to the update. Treat the ERESOLVE as a real failure and fall back to the one-at-a-time path to isolate which PR caused it.
         - **If `npm install --package-lock-only` fails with a conflict on a package not in this batch:** check whether another open Dependabot PR covers that package. If so, those PRs may need to land together — note it and skip the conflicting one for now.
      2. Run the application/build, test suite, and linter **in parallel** — all three at once to save time. Only report a failure if any of them fail.
         - **Do not trust exit codes alone for the test suite.** Some test runners (e.g. vitest in watch mode) exit 0 when killed, even on a startup crash. Always confirm that the test output contains an explicit passing summary (e.g. "X passed", "All tests passed") — if no such summary appears, treat it as a failure regardless of exit code.

   c. **If the batch passes:** check off all items in the batch with `[x]`, reprint the full checklist showing their completed status and highlighting the next batch with `→`, then move on.

   d. **If the batch fails:** reset all commits in the batch:
      ```
      git reset --hard HEAD~<number of commits in batch>
      ```
      Then fall back to the **one-at-a-time path** (below) for each PR in this batch individually.

   ### One-at-a-time fallback

   Apply each PR individually, running the full verification after each one:

   a. Cherry-pick and resolve conflicts (same as fast path step a above, including stripping `chore(subject):` → `chore:` from the commit message).

   b. **Verify** (same clean install + full check as fast path step b above).

   c. **If verification passes:**
      - If any additional files were modified to make the update work (e.g. fixing a changed API, updating a config), amend them into the cherry-pick commit:
        ```
        git add <modified-files>
        git commit --amend --no-edit
        ```
        Never create a separate follow-up commit — a single revert must undo everything.
      - Check off the item in the checklist with `[x]` and continue.

   d. **If verification fails:** pause and ask:
      > "`<package>` update caused a failure in `<step>`. Would you like me to try to fix the issue, or undo and move on?"
      - If fix: attempt to resolve, then re-run the full check. **Spend no more than 3 minutes debugging.** If unresolved, ask: "I wasn't able to fix this within 3 minutes. Should I keep trying or would you like to take over?"
      - If skip: run `git reset --hard HEAD~1`, check off as skipped with a note, and continue.

   **Do not comment on or close the Dependabot PR.** Leave it untouched until the work is merged.

6. **Final verification with a clean install:** once all dependencies have been updated, do one clean install to catch any peer dependency or resolution issues that `npm install` may have masked:
   ```
   rm -rf node_modules && npm ci
   ```
   Then run the build, tests, and linter in parallel one final time. If this fails, investigate before opening a PR.

7. **Major version updates** (separate track — no new branch):

   Major bumps are not cherry-picked onto the dated branch. Instead, work directly on the existing Dependabot branch so the PR is already there and no branch cleanup is needed.

   a. **Present a ranked plan** of all major Dependabot PRs, organized from least risky to most risky. Assess risk using these signals:
      - **Centrality** — framework-level packages (e.g. React, Next.js, Express, webpack) are highest risk; isolated utility libraries are lowest
      - **Breadth** — how many files in the project import this package
      - **Magnitude** — a jump of 2 major versions is riskier than a jump of 1

      Format the plan as a numbered list, least risky first:
      ```
      Major version updates available (least → most risky):

      1. #<pr>  <package>: <old> → <new>  — <one-line risk rationale>
      2. #<pr>  <package>: <old> → <new>  — <one-line risk rationale>
      ...
      ```

      **Flag interdependencies explicitly.** If two major PRs are likely to require simultaneous updates (e.g. they share a peer dependency or one's types depend on the other), call it out:
      > ⚠️ `<package-A>` and `<package-B>` may need to land together — if so, I can cherry-pick one's commits onto the other's branch.

      End with: **Which would you like to tackle first?**

   b. **Check out the chosen Dependabot branch:**
      ```
      gh pr checkout <number>
      nvm use
      ```
      After checking out, read the relevant entry in `package.json` and use that as the actual version — PR bodies are frequently stale and may not reflect what's on the branch. Report the real version before proceeding.
      **Strip the scope from the branch's commit message(s).** If any commits on the branch use `chore(subject): ...`, rewrite them to `chore: ...`. For the most recent commit this is just:
      ```
      git commit --amend -m "chore: <rest of message>"
      ```

   c. **Verify** using the same process as the patch/minor one-at-a-time flow:
      - `npm install --package-lock-only && npm install`
      - Run build, tests, and linter in parallel

   d. **If verification passes:** note it and ask which major to tackle next, if any remain.

   e. **If verification fails:** pause and report the failure. Ask:
      > "`<package>` major update caused a failure in `<step>`. Would you like me to try to fix it, or move on to a different major update?"
      - If fix: attempt to resolve, committing any additional changes onto the branch (or amending into the existing commit). **Spend no more than 3 minutes debugging.** If unresolved, ask: "I wasn't able to fix this within 3 minutes. Should I keep trying or would you like to take over?"
      - If skip: note it and move on.

   f. **Do not comment on or close the Dependabot PR.** Leave it untouched until merged.

8. **Ask the user** if they would like to open a pull request for these changes.

   - **Patch/minor branch** — use the `pr-create` skill. The PR title must be **"Dependency Updates"** (always, regardless of what was updated). The body should include:
     - The full list of dependency updates (package name, old version → new version, Dependabot PR reference)
     - Any other commits on the branch that are unrelated to dependency updates, listed separately so reviewers are aware of them

   - **Major update (already on a Dependabot branch)** — do **not** use `pr-create`. The Dependabot PR already exists. Instead:
     1. Push the branch: `git push origin HEAD`
     2. Update the existing PR title and body via the GitHub API:
        ```
        gh api repos/{owner}/{repo}/pulls/<number> --method PATCH \
          --field title="<new title>" \
          --field body="<new body>"
        ```
        Note: `gh pr edit` may exit non-zero due to a Projects (classic) deprecation warning even on success — use `gh api` directly to avoid that.
     3. **Strip the scope from the PR title** — if the existing title matches the pattern `chore(<scope>): ...` (e.g. `chore(deps): bump foo from 1 to 2`), rewrite it to `chore: ...`. Only apply this rewrite when the title actually has a scope; leave all other titles untouched.

9. **Summarize** what was updated and, if a PR was opened, link to it.
