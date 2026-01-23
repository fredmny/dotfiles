#!/bin/bash


chosen=$(printf "docked\ndocked2\nmobile" | rofi -dmenu -p "Screen Layout:")

# Switch to docked mode (external monitors only)
if [ "$chosen" = "docked" ]; then
  hyprctl keyword monitor "eDP-1, disable"
  hyprctl keyword monitor "DVI-I-1,1920x1080@60.0,3840x0,1.0"
  hyprctl keyword monitor "DVI-I-1,transform,1"
  hyprctl keyword monitor "DVI-I-2,1920x1080@60.0,1920x341,1.0"
elif [ "$chosen" = "docked2" ]; then
  hyprctl keyword monitor "eDP-1, disable"
  hyprctl keyword monitor "DVI-I-2,1920x1080@60.0,3840x0,1.0"
  hyprctl keyword monitor "DVI-I-2,transform,1"
  hyprctl keyword monitor "DVI-I-1,1920x1080@60.0,1920x341,1.0"
# Switch to mobile mode (laptop display only)
elif [ "$chosen" = "mobile" ]; then
  hyprctl keyword monitor "eDP-1,1920x1080@60.05,0x341,1.0"
  hyprctl keyword monitor "DVI-I-1, disable"
  hyprctl keyword monitor "DVI-I-2, disable"
fi
