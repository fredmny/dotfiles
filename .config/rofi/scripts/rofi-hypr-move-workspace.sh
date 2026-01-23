#!/bin/bash

monitors=$(hyprctl monitors -j | jq -r '.[] | select(.focused == false) | "\(.name) - \(.description)"')

chosen=$(printf "%s" "$monitors" | rofi -dmenu -p "Move to monitor:")

if [ -n "$chosen" ]; then
    monitor_name=$(echo "$chosen" | cut -d' ' -f1)
    hyprctl dispatch movecurrentworkspacetomonitor "$monitor_name"
fi
