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
- **Looks resolved**: The reporter confirmed the issue is fixed or the conversation has concluded. Draft a closing message with a review request (see section 8).

Present a summary of all open threads and their statuses before diving into any one of them. Then work through them one at a time, asking the user how to proceed for each.

**Always include the direct URL to each thread** in the summary and when presenting draft replies, so the user can click through to post directly.

## 3. Research the codebase

For all threads, navigate to the Force Refresh codebase by running `z force-refresh` in the terminal before drafting any reply. This is required any time you reference UI navigation paths, feature behavior, or plugin settings — do not assume locations from memory. Look at:
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
- Explains the cause or answers their question.
- Provides concrete debugging steps or a workaround if applicable.
- Mentions if a fix is planned or already released.

**Deciding how to respond:**
- If the thread is a question about how a feature works, answer it directly based on your knowledge of the codebase.
- If the user is describing unusual or unexpected behavior, ask for screenshots: one of what they're seeing, and one from the Force Refresh Troubleshooting screen (Tools → Force Refresh → click the "Troubleshooting" button). That screen shows the PHP and WordPress versions Force Refresh is actually detecting.
- If you're unsure how to respond, stop and ask Jordan before drafting a reply.

**Audience:** Assume non-technical users who may have minor technical expertise. Keep instructions simple and step-by-step.

**Beta builds:** Jordan provides these manually. Only reference a beta if Jordan supplies one. Never proactively suggest one.

Present the draft reply to the user for review before they post it. **Always include the direct URL to the thread** so the user can click through to post the reply. Present the reply text in a plain code block (no markdown formatting inside), and automatically copy it to the clipboard using `pbcopy`.

## 6. If a beta fix is available

When a bug has been identified and a beta release exists (or needs to be referenced), use the standardized message below. Fill in:
- `{release_title}`: the release name as it appears on GitHub, e.g. `Force Refresh 2.16.1-6C88A3.0`
- `{download_url}`: direct link to the `.zip`, format: `https://github.com/jordanleven/force-refresh/releases/download/{tag}/Force_Refresh_{version}.zip`
- `{compare_url}`: GitHub compare link, format: `https://github.com/jordanleven/force-refresh/compare/{base_tag}...{beta_tag}`

---

> Hey @{username}, the first beta build for this issue is available here: **[{release_title}]({download_url})**
>
> You may notice it's marked as a beta release, but since we're working through this together it's safe to install. Download the `.zip` file and upload it via **Plugins → Add New → Upload Plugin** in your WordPress admin. WordPress will detect that Force Refresh is already installed and prompt you to replace it.
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

**Setting reminders after any Jordan reply:** Whenever Jordan posts a reply and is now waiting on the reporter, automatically delete any existing reminders for the thread and create two new reminders without asking: one for the 2-day nudge and one for the 5-day close-out. Both are created from Jordan's reply date.

After presenting the draft message, present a macOS Reminder summary confirming both reminders are set.

**Step 1 — Delete any existing reminders for this thread** (match by title; scanning all reminders by `body` is unreliable and causes AppleScript connection errors):

```bash
osascript -e '
tell application "Reminders"
  set matches to (every reminder whose name is "Follow up on Force Refresh support request" or name is "Close out Force Refresh support request")
  repeat with r in matches
    delete r
  end repeat
end tell'
```

**Step 2 — Create both reminders** (use `body` for notes, not `notes` — that is the correct AppleScript property name):

```bash
# Nudge reminder (2 days after Jordan's last reply)
osascript -e '
tell application "Reminders"
  make new reminder with properties {name:"Follow up on Force Refresh support request", due date:date "{nudge_date}", body:"{thread_url}"}
end tell'

# Close-out reminder (5 days after Jordan's last reply)
osascript -e '
tell application "Reminders"
  make new reminder with properties {name:"Close out Force Refresh support request", due date:date "{close_date}", body:"{thread_url}"}
end tell'
```

- `{thread_url}`: the full URL of the support thread.
- `{nudge_date}`: 2 days after Jordan's most recent reply.
- `{close_date}`: 5 days after Jordan's most recent reply.
- Format dates as `"April 23, 2026 6:00 PM"`. Use **6:00 PM** for weekdays (Mon–Fri), **2:00 PM** for weekends (Sat–Sun).
- Confirm to the user once both reminders are created.

**When to delete and recreate:** Each time the skill runs and a thread is still in "Waiting on the reporter" status, always delete any existing reminders for that thread and recreate both based on Jordan's current most-recent reply date. This keeps the dates accurate if Jordan sent a follow-up since the last run.

## 8. If the issue is resolved

If the thread looks resolved, draft a closing message that includes a review request. The ask should feel natural and low-pressure, not transactional. Include a brief rationale for why reviews matter (they help other users discover and trust the plugin, and they help the developer continue maintaining it as a free tool). Example closing:

**Never use em dashes or en dashes in replies. Use plain punctuation instead (commas, periods, or reword the sentence).**

> If you're enjoying Force Refresh, I'd really appreciate it if you took a moment to [leave a review on the WordPress plugin directory](https://wordpress.org/support/plugin/force-refresh/reviews/#new-post). Reviews help other users find the plugin and go a long way in supporting its continued development. It's free to use and every bit helps. Thanks!
