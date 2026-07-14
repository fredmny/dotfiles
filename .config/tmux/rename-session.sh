#!/usr/bin/env bash
# Rename a tmux session, prompting for the new name (prefilled with the old one).
# Uses a query-only fzf (no candidates) as a text input box, since it stays on
# the same tty that fzf's execute() already controls -- tmux command-prompt
# invoked this way doesn't reliably attach to the popup and silently no-ops.
SESSION="$1"
NEW_NAME="$(fzf --print-query --query "$SESSION" \
  --prompt "Rename '$SESSION' to: " \
  --header 'Enter to confirm, Esc to cancel' < /dev/null)"

if [ -n "$NEW_NAME" ] && [ "$NEW_NAME" != "$SESSION" ]; then
    tmux rename-session -t "$SESSION" -- "$NEW_NAME"
fi
