#!/usr/bin/env bash
# Open a new window with claude, placed at the highest available index starting from 9

CURRENT_PATH="$1"

tmux new-window -c "$CURRENT_PATH" -n "claude"

for idx in 9 8 7 6 5 4 3 2 1; do
    if ! tmux list-windows -F '#{window_index}' | grep -q "^${idx}$"; then
        tmux move-window -t ":${idx}"
        break
    fi
done

tmux send-keys "claude" Enter
