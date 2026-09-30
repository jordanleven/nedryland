---
name: force-refresh-support
description: Review open Force Refresh support requests, assess their status, and draft replies
---

## 1. Fetch open support requests

Fetch `https://wordpress.org/support/plugin/force-refresh/unresolved/` and retrieve each open thread.

## 2. Assess each thread

For each thread, fetch its full content and determine its status:

- **Needs a first reply**: Jordan hasn't responded yet. Proceed to diagnose and draft a reply (steps 3-5).
- **Waiting on the reporter**: Jordan replied and the reporter hasn't responded. Note how long it's been since Jordan's last reply and ask the user if they'd like to send a reminder (see section 7).
- **Looks resolved**: The reporter confirmed the issue is fixed, the conversation has concluded, or the root cause is outside Force Refresh's scope (e.g. a hosting or PHP configuration issue) and the cause has been explained. Draft a closing message with a review request (see section 8).

**When resolved status is ambiguous**, ask Jordan before deciding — don't make that call independently.

Present a summary of all open threads and their statuses before diving into any one of them. Then work through them one at a time, asking the user how to proceed for each.

**Always include the direct URL to each thread** in the summary and when presenting draft replies, so the user can click through to post directly.

## 3. Research the codebase

For all threads, work in the Force Refresh codebase at `~/Developer/Personal/force-refresh` before drafting any reply. Use the path directly rather than `z force-refresh`, which prints an animated shell banner when run from a subshell. This is required any time you reference UI navigation paths, feature behavior, or plugin settings — do not assume locations from memory. Look at:
- The specific feature or behavior being reported.
- Any recent changes in git history related to the area (`git log --oneline` is fine).
- Known limitations or edge cases in the code.

## 4. Diagnose

Based on the support request and code, determine:
- Whether this is a known bug, expected behavior, a configuration issue, or something else.
- The root cause if it is a bug.
- Whether the issue exists in the current codebase or has already been fixed.

## 5. Draft a support reply

Write a reply that matches Jordan's actual support tone:
- Direct and efficient. Answer the question, give steps, done. No padding.
- A brief warm touch at the opener is fine ("thanks for following up!") but don't overdo it. No "no worries!", "that's really helpful!", "glad you circled back!", or multi-sentence pleasantries.
- opener: use "Hey @username," or just "@username," — not a full sentence of acknowledgment.
- Closing lines are simple: "Let me know if you have any other issues." or "I'll close out this request for now." Nothing more.
- Think out loud briefly when uncertain: "Hmm, I'm wondering if..." is fine.
- Never over-explain. If the answer is one sentence, keep it one sentence.
- Do not use em dashes or en dashes. Use plain punctuation or reword.
- Do not use arrows (→) for navigation paths. Write them out in words, e.g. "the Force Refresh page in the Tools menu" instead of "Tools → Force Refresh".
- Answer the literal question they asked first, then explain. Work out what they think the feature does, since a question is often built on a mistaken model of it (e.g. assuming the refresh interval reloads the page every time).
- Explains the cause or answers their question.
- Provides concrete debugging steps or a workaround if applicable.
- Mentions if a fix is planned or already released.

**Deciding how to respond:**
- If the thread is a question about how a feature works, answer it directly based on your knowledge of the codebase.
- If the user is describing unusual or unexpected behavior, ask for screenshots: one of what they're seeing, and one from the Force Refresh Troubleshooting screen (go to the Force Refresh page in the Tools menu and click the "Troubleshooting" button). That screen shows the PHP and WordPress versions Force Refresh is actually detecting.
- If you're unsure how to respond, stop and ask Jordan before drafting a reply.

**Common questions:** Verify these against the codebase each time, since behavior may change.
- **Stale content for visitors:** Force Refresh only reloads browsers that already have the site open, and only after a refresh is triggered ("Force Refresh Site" or a scheduled refresh). Publishing content doesn't trigger one. Stale content on a fresh visit comes from caching (a caching plugin, the host, or a CDN), which Force Refresh doesn't handle.
- **Refresh interval, bandwidth, or server load:** The interval is only how often open tabs send a small version check. The page reloads only when a refresh has been triggered, so a longer interval is fine for most sites. For server load concerns, point them to the "Update method" setting set to "Static file" (off by default, and unavailable when a CDN is detected).

**Audience:** Assume non-technical users who may have minor technical expertise. Keep instructions simple and step-by-step.

**Beta builds:** Jordan provides these manually. Only reference a beta if Jordan supplies one. Never proactively suggest one.

Present the draft reply to the user for review before they post it. **Always include the direct URL to the thread** so the user can click through to post the reply. Present the reply text in a plain code block (no markdown formatting inside), and automatically copy it to the clipboard using `pbcopy`.

## 5a. Posting the reply

WordPress.org forums have no API for posting replies. If Jordan asks you to post it, use Claude in Chrome:

1. Open the thread in a new tab and confirm Jordan is logged in (the toolbar shows "Howdy, jordanleven" and a reply form is present). If not, ask Jordan to log in. Never enter credentials yourself. The 1Password for Claude integration only works in the Claude desktop app, not Claude Code.
2. Fill the reply textarea with the approved text.
3. Submit only once Jordan has explicitly approved posting.
4. Confirm the reply appears in the thread, then set reminders immediately (see section 7).

## 6. If a beta fix is available

When a bug has been identified and a beta release exists (or needs to be referenced), use the standardized message below. Fill in:
- `{release_title}`: the release name as it appears on GitHub, e.g. `Force Refresh 2.16.1-6C88A3.0`
- `{download_url}`: direct link to the `.zip`, format: `https://github.com/jordanleven/force-refresh/releases/download/{tag}/Force_Refresh_{version}.zip`
- `{compare_url}`: GitHub compare link, format: `https://github.com/jordanleven/force-refresh/compare/{base_tag}...{beta_tag}`

---

> Hey @{username}, the first beta build for this issue is available here: **[{release_title}]({download_url})**
>
> You may notice it's marked as a beta release, but since we're working through this together it's safe to install. Download the `.zip` file and upload it in your WordPress admin by going to **Plugins**, clicking **Add New**, then **Upload Plugin**. WordPress will detect that Force Refresh is already installed and prompt you to replace it.
>
> As a quick note, every release I publish, including betas, is signed with my GPG key. You can verify this by viewing the release on GitHub and hovering over the green checkmark next to the commit. If you'd like to see exactly what's changed in this build, you can [view the diff here]({compare_url}).
>
> Once you've had a chance to install it, let me know if it resolves the issue. You'll also notice a message in the plugin letting you know you're on a pre-release version. That's expected and will go away once the fix is included in a public release and you update.

---

## 7. Reminder messages

When Jordan has replied and the reporter hasn't responded, the follow-up timeline is:

- **2 days** since Jordan's last reply: send a short nudge.
- **5 days** since Jordan's last reply: send a closing message.

Draft the appropriate message based on how long it's been:

- **2 or more days but fewer than 5**: draft a short, friendly nudge:

  > Hey @{username}, just following up to see if you had a chance to try those steps. Happy to help if you run into anything!

- **5 or more days**: draft a friendly closing message:

  > Hey @{username}, just following up since I haven't heard back. I'll go ahead and close this out for now, but feel free to reach out again if you run into any other issues!

**Resetting the clock:** If the reporter replies at any point, the 2-day and 5-day timers reset from Jordan's next reply after that.

**Setting reminders after any Jordan reply:** Whenever Jordan posts a reply and is now waiting on the reporter, automatically run the bundled script without asking — it deletes any existing reminders for these threads and creates both new ones (2-day nudge, 5-day close-out), computing dates and weekday/weekend times itself:

```bash
~/.claude/skills/force-refresh-support/set-reminders.sh "{thread_url}" "{last_reply_date}"
```

- `{thread_url}`: the full URL of the support thread.
- `{last_reply_date}`: Jordan's most recent reply date, as `YYYY-MM-DD`.

Print the script's output (it reports the nudge and close-out dates it set) as confirmation that both reminders are set.

**When to delete and recreate:** Each time the skill runs and a thread is still in "Waiting on the reporter" status, always delete any existing reminders for that thread and recreate both based on Jordan's current most-recent reply date. This keeps the dates accurate if Jordan sent a follow-up since the last run.

## 8. If the issue is resolved

If the thread looks resolved, draft a closing message that includes a review request. The ask should feel natural and low-pressure, not transactional. Include a brief rationale for why reviews matter (they help other users discover and trust the plugin, and they help the developer continue maintaining it as a free tool). Example closing:

**Never use em dashes, en dashes, or arrows in replies. Use plain punctuation instead (commas, periods, or reword the sentence).**

> If you're enjoying Force Refresh, I'd really appreciate it if you took a moment to [leave a review on the WordPress plugin directory](https://wordpress.org/support/plugin/force-refresh/reviews/#new-post). Reviews help other users find the plugin and go a long way in supporting its continued development. It's free to use and every bit helps. Thanks!
