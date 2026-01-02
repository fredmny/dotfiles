#!/bin/bash

chosen=$(printf "Logout\nReboot\nShutdown\nSuspend" | rofi -dmenu -p "Power:")

case "$chosen" in
    Logout)
        hyprctl dispatch exit
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    Suspend)
        systemctl suspend
        ;;
esac
