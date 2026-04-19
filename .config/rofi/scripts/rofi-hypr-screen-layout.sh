#!/bin/bash


chosen=$(printf "both\nleft\nright" | rofi -dmenu -p "Screen Layout:")

if [ "$1" = "both" ]; then
  hyprctl keyword monitor "DP-1,1920x1080@143.98,0x0,1.0"
  hyprctl keyword monitor "HDMI-A-1,1920x1080@60.0,1920x-300,1.0,transform,1"
elif [ "$1" = "left" ]; then
  hyprctl keyword monitor "DP-1,1920x1080@143.98,0x0,1.0"
  hyprctl keyword monitor "HDMI-A-1, disable"
elif [ "$1" = "right" ]; then
  hyprctl keyword monitor "DP-1, disable"
  hyprctl keyword monitor "HDMI-A-1,1920x1080@60.0,1920x-300,1.0,transform,1"
fi
