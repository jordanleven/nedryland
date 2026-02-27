---
name: pr-create
description: Open a pull request for the current branch using the repo's PR template
disable-model-invocation: true
---

Open a pull request for the current branch.

## Steps

1. **Check for a PR template** by looking for:
   - `.github/pull_request_template.md`
   - `.github/PULL_REQUEST_TEMPLATE.md`
   - `.github/PULL_REQUEST_TEMPLATE/*.md` (multiple templates)

2. **Determine the PR title** from the branch's commits:
   - If the branch has a single commit, derive the title from its subject line
   - If the branch has multiple commits, write a title that summarizes the overall change
   - Use **Title Case** — no commit type prefix (no `feat:`, `chore:`, etc.)
   - Be succinct: describe what the PR does, not how it does it

3. **Fill out the PR body:**
   - If a template exists, **fill out every section in full** — do not delete sections, leave placeholders, or write "N/A" without explanation. Read the commits and diff to answer each section with real content.
   - If no template exists, write a body that covers: what changed, why, and how to verify it.

4. **Open the PR** with `gh pr create`:

   ```
   gh pr create --title "<title>" --body "<body>"
   ```

5. **Output the PR URL** so the user can review it.

## Rules

- **Never skip template sections.** If a section asks for a test plan, write one based on what actually changed. If it asks for context, provide it from the commits.
- The body should be written for a reviewer who has no prior context — assume they are coming in cold.
