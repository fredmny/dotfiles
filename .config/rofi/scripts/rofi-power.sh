#!/bin/bash

chosen=$(printf "shutdown\nreboot\nlogout\nsuspend" | rofi -dmenu -p "Power:")

case "$chosen" in
    logout)
        hyprctl dispatch exit
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
