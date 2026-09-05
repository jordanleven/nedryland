#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <thread_url> <last_reply_date YYYY-MM-DD>" >&2
  exit 1
fi

thread_url=$1
last_reply_date=$2

# Weekdays get 6:00 PM, weekends get 2:00 PM, per the skill's follow-up policy.
format_reminder_date() {
  local date_str=$1
  local weekday
  weekday=$(date -j -f "%Y-%m-%d" "$date_str" +%u) # 1=Mon .. 7=Sun

  local time_str
  if [ "$weekday" -ge 6 ]; then
    time_str="2:00 PM"
  else
    time_str="6:00 PM"
  fi

  local month_day_year
  month_day_year=$(date -j -f "%Y-%m-%d" "$date_str" +"%B %d, %Y" | sed -E 's/ 0([0-9]),/ \1,/')
  echo "${month_day_year} ${time_str}"
}

nudge_date_raw=$(date -j -v+2d -f "%Y-%m-%d" "$last_reply_date" +"%Y-%m-%d")
close_date_raw=$(date -j -v+5d -f "%Y-%m-%d" "$last_reply_date" +"%Y-%m-%d")

nudge_date=$(format_reminder_date "$nudge_date_raw")
close_date=$(format_reminder_date "$close_date_raw")

# Delete any existing reminders for these threads before recreating them,
# so re-runs keep dates accurate instead of piling up duplicates.
osascript -e '
tell application "Reminders"
  set matches to (every reminder whose name is "Follow up on Force Refresh support request" or name is "Close out Force Refresh support request")
  repeat with r in matches
    delete r
  end repeat
end tell'

osascript -e "
tell application \"Reminders\"
  make new reminder with properties {name:\"Follow up on Force Refresh support request\", due date:date \"${nudge_date}\", body:\"${thread_url}\"}
end tell"

osascript -e "
tell application \"Reminders\"
  make new reminder with properties {name:\"Close out Force Refresh support request\", due date:date \"${close_date}\", body:\"${thread_url}\"}
end tell"

echo "Reminders set for ${thread_url}:"
echo "- Nudge: ${nudge_date}"
echo "- Close-out: ${close_date}"
