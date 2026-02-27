---
name: commit
description: Stage and commit changes using project conventions
disable-model-invocation: true
---

Stage and commit changes following these conventions:

## Commit message format

```
type: Subject line (50 chars or less)

- Body line one (72 chars or less)
- Body line two (72 chars or less)
```

- **Types:** `feat`, `fix`, `chore`, `style`, `refactor`, `test`
- **CI/build changes use `chore`** — `ci` is not a valid type; workflow, pipeline, and build config changes should use `chore`
- **`fix:` is strictly for application code bugs** — test infrastructure, CI, and tooling changes use `chore:` even if they "fix" something; commit subjects drive semantic versioning, so a `fix:` on a test retry loop would incorrectly bump the patch version
- **No scopes** — never use `type(scope):` format
- **Sentence case** — capitalize the first word only
- **Imperative mood** — "Add", "Fix", "Update", not "Added", "Fixes", "Updated"
- **No trailing period on the subject line**
- **Body lines must be complete sentences ending with a period**
- Use **backticks** for specific file or script names (e.g., `fix: Update \`prepare-commit-msg\` hook`)
- **Subject line must be 50 characters or less** — GitHub truncates beyond this
- **Body lines must be 72 characters or less** — if a point needs more, wrap it onto the next line, but only the first line of each point gets a hyphen prefix
- **Every body line must start with a bullet (`-`)** — no bare prose paragraphs
- **Don't split one idea into multiple bullets** — if two points are part of the same cause-and-effect or tell one continuous story, combine them into a single bullet

## Commit body

**Always write a body. The body must explain *why*, not *what*.** Git already shows exactly what changed — a reviewer can run `git diff` and see every line. What they cannot see is your reasoning: why this approach, why now, what problem it solves, what you considered and rejected.

Ask yourself: *"What would I want to know about this change if I were reading it six months from now with no context?"* Write that.

Bad body (describes what, git already shows this):
```
- Added error handling to fetchUser
- Updated return type to include null
```

Good body (explains why):
```
- fetchUser was silently swallowing 404s and returning an empty object,
  causing downstream components to render as if the user existed
- Returning null on 404 lets callers handle the missing-user case explicitly
```

## Commit strategy

**Commit by idea, not by file.** Group changes by logical unit — a feature, a bug fix, a refactor — so each commit can be reverted independently without breaking unrelated work.

**Order commits so the build passes at every step.** If changes are being committed from unstaged files, sequence them so that checking out any individual commit leaves the project in a working, buildable state. Never commit a dependency before the thing it depends on.

## Steps

1. Run `git status` and `git diff` to understand all pending changes
2. Group the changes into logical commits — one idea per commit
3. Plan the commit order so each one leaves the build passing
4. For each commit:
   - Stage only the files relevant to that idea with `git add`
   - Write a message following the format above
   - Commit with `git commit -m "<message>"`
5. Repeat until all changes are committed
