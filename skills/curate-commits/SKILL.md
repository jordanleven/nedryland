---
name: curate-commits
description: Curate the commit history of the current branch — either as a reviewer-friendly narrative or collapsed into clean atomic commits ready for main
disable-model-invocation: true
---

Start by asking the user which mode to use:

> **How would you like to curate the commits?**
> 1. **Regular curation** — reorganize into a reviewer-friendly narrative (best for PR review)
> 2. **Curate for main** — collapse into clean, atomic commits ready to land on main

Wait for the user's answer, then follow the instructions for that mode below.

---

## Mode 1: Regular curation

Reorganize commits on the current branch so the history reads like a story for a reviewer — not a chronological record of how the work was done, but a logical narrative that guides the reviewer through the thought process and evolution of the change.

### Philosophy

A reviewer cannot fully understand a large PR by jumping straight to the end and viewing all file changes at once. They need to be onboarded through the commits in an order that progressively builds context. The commit history should make the thought process behind the PR immediately clear.

The order commits were *made* is rarely the order they should be *reviewed*. Like an essay — readers don't see it in the order it was written. Reorder, reshape, and rename commits so the history serves the reader.

### Steps

#### 1. Survey the current branch

```
git log main..HEAD --oneline
git diff main...HEAD --stat
```

Review all commits on the branch relative to main. Identify:
- Commits that cover multiple ideas and should be split
- Commits that cover the same idea and should be squashed or fixed up
- Commits that are out of logical order
- WIP, temp, or debug commits that are candidates for dropping
- Commits with poor messages that should be reworded
- Unrelated housekeeping (dep updates, chore, docs) that should be grouped and repositioned

#### 2. Present the curation plan

**Do not begin the interactive rebase yet.** Present a plan to the user first and wait for explicit approval before proceeding.

The plan must list every commit currently on the branch and the proposed action for each one, in the proposed final order. Present it as a table:

| # | SHA | Action | Current message | New message | Notes |
|---|-----|--------|-----------------|-------------|-------|
| 1 | `abc1234` | pick | chore: Update dependencies | — | Moving to front; foundation for the rest |
| 2 | `def5678` | reword | feat: Add data service | feat: Add UserDataService for fetching profile data | Subject was too vague |
| 3 | `ghi9012` + `jkl3456` | fixup | feat: Wire data service into profile page | — | Folding in "forgot to stage this" commit |
| 4 | `mno7890` | edit (split) | feat: Add profile page and fix unrelated bug | feat: Add profile page / fix: ... | Two ideas in one commit |

- Use `—` in the "New message" column when the message is unchanged.
- For drops, add a row with action `drop` and explain in the Notes column.
- End with: **Proceed with this plan?**

**Never drop a commit without listing it explicitly in the plan and explaining why.** Always wait for the user to approve before executing any drops.

#### 3. Execute after approval

Once the user approves the plan, run:

```
git rebase -i main
```

Apply the approved operations. When resolving merge conflicts during rebase, ask: *"How would I have made this change had the preceding commits already been in place?"*

#### 4. Design the narrative order

Plan the commit sequence that best onboards a reviewer. A good ordering usually follows this pattern:

1. **Foundation first** — chores, dependency updates, infrastructure changes, or scaffolding that the rest of the work builds on
2. **Core logic** — the primary feature or fix in a logical build-up, where each commit makes sense given the previous one
3. **Integration** — wiring things together, consuming the new code
4. **Polish** — tests, documentation, style, cleanup

Ask: *"If a reviewer read these commits one by one, would each commit make sense given what came before it?"* If not, reorder.

Ask: *"If a reviewer checked out any individual commit, would the code make sense?"* If not, a commit may need to be split or reordered.

#### 5. Available operations

| Operation | When to use |
|-----------|-------------|
| **reorder** (pick) | Related commits are not grouped together; commits that depend on each other are out of order |
| **squash (s)** | Two commits express the same idea; preserve both commit messages |
| **fixup (f)** | A commit is a trivial addendum to the previous one (forgot a file, minor fix); discard the extra message. Also use fixup when a later commit only tunes or adjusts something introduced by an earlier commit (e.g. changing a delay value, expanding a pool size, tweaking a parameter) — these belong in the original commit even if they aren't adjacent |

**When combining commits with fixup or squash:** always place the earlier commit first. Reordering so that a later commit precedes the one it's being folded into causes merge conflicts, because git applies patches in sequence — if a later commit touching file A comes before the earlier commit that also touched file A, the patch won't apply cleanly.

Example: commits 1 (file A), 2 (file B), 3 (file A) — to fold 3 into 1, order them `1, 3, 2` (fixup), not `3, 1, 2`.

**`package-lock.json` is especially conflict-prone.** Lock files are large and auto-generated, so any reordering that moves a dep-related commit across other commits that also touch `package-lock.json` will almost always produce a conflict that cannot be cleanly resolved. If a fixup candidate sits chronologically between other commits that also modified the lock file, leave it in its natural position as a standalone pick rather than trying to move it into a dep group elsewhere in the sequence.
| **edit (e)** | A single commit encompasses too many ideas and needs to be split |
| **reword (r)** | The message is vague, has a typo, or lacks context |
| **drop (d)** | WIP commits, debug/temp commits, or accidental commits — **requires explicit user approval** |

#### 6. Write commit messages that explain *why*

Use the Conventional Commits format:

```
<type>: <subject> (50 chars or less)

<body — explain why, not what. Git already shows what changed.>

<footer — ticket references, breaking change notices>
```

- **Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`
- **No scopes** — never use `type(scope):` format (e.g. `chore(deps):` is wrong; use `chore:`)
- **Subject:** imperative mood, sentence case, no trailing period, **50 characters or less** (count them)
- **Body lines:** 72 characters or less
- **Body:** the *why* and the *context* — what would be valuable to know when reading this commit 6 months from now? What problem does this solve? What was the reasoning behind this approach?
- **`fix:` vs `chore:`** — use `fix:` only for bugs in application behavior. Use `chore:` for anything in the build, tooling, or transpilation pipeline — even if it resolves a warning or error. Suppressing a Sass deprecation warning is `chore:`, not `fix:`.

#### 7. Push the rewritten history

**Do not push unless the user explicitly asks you to.** When asked, use:

```
git push --force-with-lease --force-if-includes
```

**Never use `--force` alone.** `--force-with-lease --force-if-includes` is the only acceptable option: it rejects the push if someone else has pushed commits to your branch that you don't have locally, preventing you from silently overwriting their work.

#### 8. Summarize the result

After curating, output a summary of the final commit list (one line per commit) and a brief explanation of what was changed and why the resulting order best serves a reviewer.

---

## Mode 2: Curate for main

Collapse the commit history of the current branch into a small set of clean, stable, atomic commits that represent complete ideas — not the step-by-step record of how the work was done.

### Philosophy

A PR review values narrative: many commits that build context incrementally. Main's history values clarity: a compact record where each commit represents one complete, self-contained idea that can be understood, bisected, or reverted in isolation.

The bar here is higher than for PR curation. If multiple commits all belong to the same feature, fix, or theme, they become one commit. Dependency updates across multiple packages become one commit. Housekeeping and chore work gets consolidated. When in doubt, squash.

**The only reason to keep two commits separate is if they represent genuinely distinct, independently revertable ideas.**

### Steps

#### 1. Survey the branch

```
git log main..HEAD --oneline
git diff main...HEAD --stat
```

Group every commit by idea. Common groupings:
- All commits for a single feature or fix → one commit
- All dependency updates → one commit, always titled exactly `chore: Update dependencies`
- All chore/housekeeping (config, docs, style) → one commit, unless unrelated

#### 2. Present the consolidation plan

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

#### 3. Execute after approval

Once the user approves, run:

```
git rebase -i main
```

Apply the approved operations. When resolving merge conflicts during rebase, ask: *"How would I have made this change had the preceding commits already been in place?"*

**When combining commits with squash or fixup:** always place the earlier commit first. If a later commit touching file A needs to come before an earlier commit also touching file A, the patch won't apply cleanly.

Example: commits 1 (file A), 2 (file B), 3 (file A) — to fold 3 into 1, order them `1, 3, 2` (fixup), not `3, 1, 2`.

**`package-lock.json` is especially conflict-prone.** Lock files are large and auto-generated, so any reordering that moves a dep-related commit across other commits that also touch `package-lock.json` will almost always produce a conflict that cannot be cleanly resolved. If a fixup candidate (e.g. "restore a dependency that was accidentally pruned") sits chronologically between other commits that also modified the lock file, it is safer to leave it in its natural position as a standalone pick rather than trying to move it into a dep group earlier in the sequence.

#### 4. Write commit messages that explain *why*

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

**Dependency updates always use a fixed subject.** If two or more commits are dependency updates (e.g. individual Dependabot bumps), squash them all into a single commit with the subject `chore: Update dependencies` — no package names, no version numbers in the subject. The individual packages updated are already visible in the diff.

#### 5. Push the rewritten history

**Do not push unless the user explicitly asks you to.** When asked, use:

```
git push --force-with-lease --force-if-includes
```

**Never use `--force` alone.** `--force-with-lease --force-if-includes` is the only acceptable option: it rejects the push if someone else has pushed commits to your branch that you don't have locally, preventing you from silently overwriting their work.

#### 6. Summarize the result

After curating, output a summary of the final commit list (one line per commit) and a brief explanation of what was consolidated and why the resulting history is the right shape for main.
