#!/bin/bash

# Rotate wallpaer to open use a random wallper (from my selection folder) each time the PC is turned on

WALLPAPER_DIR="$HOME/.config/wallpaper/selection"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# Get a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | shuf -n 1)

# Update hyprpaper config
cat > "$CONFIG_FILE" << EOF
preload = $WALLPAPER
wallpaper = , $WALLPAPER
E
