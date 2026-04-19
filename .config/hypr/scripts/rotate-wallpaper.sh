#!/bin/bash

# Rotate wallpaer to open use a random wallper (from my selection folder) each time the PC is turned on

WALLPAPER_DIR="$HOME/.config/wallpaper/selection"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
WAL_COLORS="$HOME/.cache/wal/colors.json"

# Get a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Update hyprpaper config
cat > "$CONFIG_FILE" << EOF
preload = $WALLPAPER
wallpaper = , $WALLPAPER
splash=true
ipc=true
EOF

# Wait for hyprpaper IPC to be ready
for i in $(seq 1 20); do
  hyprctl hyprpaper listloaded >/dev/null 2>&1 && break
  sleep 0.5
done

# Apply wallpaper with hyprpaper if running
if pgrep -x hyprpaper >/dev/null; then
  hyprctl hyprpaper unload all
  hyprctl hyprpaper preload "$WALLPAPER"
  hyprctl hyprpaper wallpaper ",$WALLPAPER"
fi

# Regenerate pywal colors without touching wallpaper/tty/terminals
if command -v wal >/dev/null 2>&1; then
  # Try backends in order; some handle low-color images better than others
  for backend in wal colorz haishoku; do
    if wal -n -t -s --backend "$backend" -i "$WALLPAPER" 2>/dev/null; then
      break
    fi
  done
fi
