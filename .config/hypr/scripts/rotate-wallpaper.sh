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

# Update Hyprland active border with the new wallpaper colors
COLORS_FILE="$HOME/.cache/wal/colors-hyprland.conf"
if [ -f "$COLORS_FILE" ]; then
  COLOR3=$(grep '^\$color3' "$COLORS_FILE" | sed 's/^\$color3\s*=\s*//')
  COLOR6=$(grep '^\$color6' "$COLORS_FILE" | sed 's/^\$color6\s*=\s*//')
  if [ -n "$COLOR3" ] && [ -n "$COLOR6" ]; then
    eval "$(python3 - "$COLOR3" "$COLOR6" << 'PYEOF'
import sys, re

def convert(rgba_str):
    m = re.match(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)', rgba_str)
    if m:
        r, g, b, a = int(m[1]), int(m[2]), int(m[3]), float(m[4])
        return f'rgba({r:02x}{g:02x}{b:02x}{int(a*255):02x})'
    return ''

print(f"C3='{convert(sys.argv[1])}'")
print(f"C6='{convert(sys.argv[2])}'")
PYEOF
)"
    hyprctl eval "hl.general['col.active_border'] = '$C3 $C6 45deg' "
  fi
fi

# Sync RGB fans/mouse LEDs with the new wallpaper palette
"$HOME/.config/hypr/scripts/openrgb-wal.sh" &


