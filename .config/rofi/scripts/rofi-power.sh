#!/bin/bash

chosen=$(printf "shutdown\nreboot\nlogout\nsuspend" | rofi -dmenu -p "Power:")

case "$chosen" in
    logout)
        pkill Hyprland
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
    suspend)
        systemctl suspend
        ;;
esac
