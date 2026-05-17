#!/bin/bash

monitors=$(hyprctl monitors -j | jq -r '.[] | select(.focused == false) | "\(.name) - \(.description)"')

chosen=$(printf "%s" "$monitors" | rofi -dmenu -p "Move to monitor:")

if [ -n "$chosen" ]; then
    monitor_name=$(printf "%s" "$chosen" | cut -d' ' -f1)

    # hyprctl dispatch now expects a Lua dispatcher expression.
    monitor_name_lua=${monitor_name//\\/\\\\}
    monitor_name_lua=${monitor_name_lua//\'/\\\'}
    hyprctl dispatch "hl.dsp.workspace.move({ monitor = '${monitor_name_lua}' })"
fi
