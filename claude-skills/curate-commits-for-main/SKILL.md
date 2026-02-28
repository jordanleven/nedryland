---
name: curate-commits-for-main
description: Collapse commits on the current branch into clean, atomic commits ready to land on main
disable-model-invocation: true
---

Collapse the commit history of the current branch into a small set of clean, stable, atomic commits that represent complete ideas — not the step-by-step record of how the work was done.

## Philosophy

A PR review values narrative: many commits that build context incrementally. Main's history values clarity: a compact record where each commit represents one complete, self-contained idea that can be understood, bisected, or reverted in isolation.

The bar here is higher than for PR curation. If multiple commits all belong to the same feature, fix, or theme, they become one commit. Dependency updates across multiple packages become one commit. Housekeeping and chore work gets consolidated. When in doubt, squash.

**The only reason to keep two commits separate is if they represent genuinely distinct, independently revertable ideas.**

## Steps

### 1. Survey the branch

```
git log main..HEAD --oneline
git diff main...HEAD --stat
```

Group every commit by idea. Common groupings:
- All commits for a single feature or fix → one commit
- All dependency updates → one commit
- All chore/housekeeping (config, docs, style) → one commit, unless unrelated

### 2. Present the consolidation plan

**Do not begin the rebase yet.** Present a plan to the user first and wait for explicit approval.

The plan must list every commit currently on the branch, grouped by the proposed final commit, in the proposed final order:

| # | SHAs | Action | Current messages | New message | Notes |
|---|------|--------|------------------|-------------|-------|
| 1 | `abc1234` | pick | chore: Update deps | — | Keeping as-is; one dep update |
| 2 | `def5678` + `ghi9012` + `jkl3456` | squash | feat: Add login page / feat: Add form validation / fix: Fix form submit | feat: Add login page with form validation | Three commits, one idea |
| 3 | `mno7890` | pick | fix: Fix unrelated bug | — | Distinct and independently revertable |

- List **every** current SHA — none may be silently omitted.
- Use `—` in the "New message" column when the message is unchanged.
- For drops, add a row with action `drop` and explain why.
- End with: **Proceed with this plan?**

**Never drop a commit without listing it explicitly in the plan and explaining why.** Always wait for the user to approve.

### 3. Execute after approval

Once the user approves, run:

```
git rebase -i main
```

Apply the approved operations. When resolving merge conflicts during rebase, ask: *"How would I have made this change had the preceding commits already been in place?"*

**When combining commits with squash or fixup:** always place the earlier commit first. If a later commit touching file A needs to come before an earlier commit also touching file A, the patch won't apply cleanly.

Example: commits 1 (file A), 2 (file B), 3 (file A) — to fold 3 into 1, order them `1, 3, 2` (fixup), not `3, 1, 2`.

### 4. Write commit messages that explain *why*

Use the Conventional Commits format:

```
<type>: <subject> (50 chars or less)

<body — explain why, not what. Git already shows what changed.>

<footer — ticket references, breaking change notices>
```

- **Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`
- **No scopes** — never use `type(scope):` format (e.g. `chore(deps):` is wrong; use `chore:`)
- **Subject:** imperative mood, sentence case, no trailing period
- **Body:** the *why* and the *context* — what would be valuable to know when reading this commit 6 months from now?

When squashing multiple commits into one, write a unified message that captures the full scope of the idea — do not just concatenate the original messages.

### 5. Push the rewritten history

**Do not push unless the user explicitly asks you to.** When asked, use:

```
git push --force-with-lease --force-if-includes
```

**Never use `--force` alone.** `--force-with-lease --force-if-includes` is the only acceptable option: it rejects the push if someone else has pushed commits to your branch that you don't have locally, preventing you from silently overwriting their work.

### 6. Summarize the result

After curating, output a summary of the final commit list (one line per commit) and a brief explanation of what was consolidated and why the resulting history is the right shape for main.
