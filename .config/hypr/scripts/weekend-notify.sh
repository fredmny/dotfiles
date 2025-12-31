#!/bin/bash

# Weekend first-boot notification script
# Shows a notification on the first boot of each weekend day (Saturday/Sunday)

MARKER_FILE="/tmp/weekend-notify-$(date +%Y%m%d)"

# Check if it's a weekend (6=Saturday, 7=Sunday)
DAY_OF_WEEK=$(date +%u)

if [[ "$DAY_OF_WEEK" -ne 6 && "$DAY_OF_WEEK" -ne 7 ]]; then
    exit 0
fi

# Check if we've already shown the notification today
if [[ -f "$MARKER_FILE" ]]; then
    exit 0
fi

# Create marker file to prevent duplicate notifications
touch "$MARKER_FILE"

# Show notification with category for mako config (no timeout)
# Using --wait to block until action is taken or notification is dismissed
# --action format: "action_name:Button Label"
ACTION=$(notify-send \
    --category=weekend-reminder \
    --action="open=Open Obsidian" \
    --wait \
    "**Reminder**" \
    "Do weekly review")

# Handle the action
if [[ "$ACTION" == "open" ]]; then
    hyprctl dispatch workspace 7
    obsidian &
fi
