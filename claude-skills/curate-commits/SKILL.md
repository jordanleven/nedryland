---
name: curate-commits
description: Reorganize commits on the current branch into a reviewer-friendly narrative using interactive rebase
disable-model-invocation: true
---

Curate the commit history of the current branch so it reads like a story for a reviewer — not a chronological record of how the work was done, but a logical narrative that guides the reviewer through the thought process and evolution of the change.

## Philosophy

A reviewer cannot fully understand a large PR by jumping straight to the end and viewing all file changes at once. They need to be onboarded through the commits in an order that progressively builds context. The commit history should make the thought process behind the PR immediately clear.

The order commits were *made* is rarely the order they should be *reviewed*. Like an essay — readers don't see it in the order it was written. Reorder, reshape, and rename commits so the history serves the reader.

## Steps

### 1. Survey the current branch

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

### 2. Present the curation plan

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

### 3. Execute after approval

Once the user approves the plan, run:

```
git rebase -i main
```

Apply the approved operations. When resolving merge conflicts during rebase, ask: *"How would I have made this change had the preceding commits already been in place?"*

### 4. Design the narrative order

Plan the commit sequence that best onboards a reviewer. A good ordering usually follows this pattern:

1. **Foundation first** — chores, dependency updates, infrastructure changes, or scaffolding that the rest of the work builds on
2. **Core logic** — the primary feature or fix in a logical build-up, where each commit makes sense given the previous one
3. **Integration** — wiring things together, consuming the new code
4. **Polish** — tests, documentation, style, cleanup

Ask: *"If a reviewer read these commits one by one, would each commit make sense given what came before it?"* If not, reorder.

Ask: *"If a reviewer checked out any individual commit, would the code make sense?"* If not, a commit may need to be split or reordered.

### 5. Available operations

| Operation | When to use |
|-----------|-------------|
| **reorder** (pick) | Related commits are not grouped together; commits that depend on each other are out of order |
| **squash (s)** | Two commits express the same idea; preserve both commit messages |
| **fixup (f)** | A commit is a trivial addendum to the previous one (forgot a file, minor fix); discard the extra message. Also use fixup when a later commit only tunes or adjusts something introduced by an earlier commit (e.g. changing a delay value, expanding a pool size, tweaking a parameter) — these belong in the original commit even if they aren't adjacent |

**When combining commits with fixup or squash:** always place the earlier commit first. Reordering so that a later commit precedes the one it's being folded into causes merge conflicts, because git applies patches in sequence — if a later commit touching file A comes before the earlier commit that also touched file A, the patch won't apply cleanly.

Example: commits 1 (file A), 2 (file B), 3 (file A) — to fold 3 into 1, order them `1, 3, 2` (fixup), not `3, 1, 2`.
| **edit (e)** | A single commit encompasses too many ideas and needs to be split |
| **reword (r)** | The message is vague, has a typo, or lacks context |
| **drop (d)** | WIP commits, debug/temp commits, or accidental commits — **requires explicit user approval** |

### 6. Write commit messages that explain *why*

Use the Conventional Commits format:

```
<type>: <subject> (50 chars or less)

<body — explain why, not what. Git already shows what changed.>

<footer — ticket references, breaking change notices>
```

- **Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`
- **No scopes** — never use `type(scope):` format (e.g. `chore(deps):` is wrong; use `chore:`)
- **Subject:** imperative mood, sentence case, no trailing period
- **Body:** the *why* and the *context* — what would be valuable to know when reading this commit 6 months from now? What problem does this solve? What was the reasoning behind this approach?

### 7. Push the rewritten history

**Do not push unless the user explicitly asks you to.** When asked, use:

```
git push --force-with-lease --force-if-includes
```

**Never use `--force` alone.** `--force-with-lease --force-if-includes` is the only acceptable option: it rejects the push if someone else has pushed commits to your branch that you don't have locally, preventing you from silently overwriting their work.

### 8. Summarize the result

After curating, output a summary of the final commit list (one line per commit) and a brief explanation of what was changed and why the resulting order best serves a reviewer.
