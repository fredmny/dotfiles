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

# Wait for hyprpaper process to start
for i in $(seq 1 10); do
  pgrep -x hyprpaper >/dev/null && break
  sleep 0.3
done

# Apply wallpaper with hyprpaper if running
# Note: unload all and preload aren't used here because they fail
# when routed through the Hyprland socket (wallpaper loads on the fly)
if pgrep -x hyprpaper >/dev/null; then
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
# pywal writes rgba(R,G,B,A) but hyprctl keyword expects rgba(rrggbbaa)
COLORS_FILE="$HOME/.cache/wal/colors-hyprland.conf"
if [ -f "$COLORS_FILE" ]; then
  COLOR3=$(grep '^\$color3' "$COLORS_FILE" | sed 's/^\$color3\s*=\s*//')
  COLOR6=$(grep '^\$color6' "$COLORS_FILE" | sed 's/^\$color6\s*=\s*//')
  if [ -n "$COLOR3" ] && [ -n "$COLOR6" ]; then
    COLOR3=$(python3 -c "
import sys, re
m = re.match(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)', sys.argv[1])
if m:
    r, g, b, a = int(m[1]), int(m[2]), int(m[3]), float(m[4])
    print(f'rgba({r:02x}{g:02x}{b:02x}{int(a*255):02x})')
" "$COLOR3")
    COLOR6=$(python3 -c "
import sys, re
m = re.match(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)', sys.argv[1])
if m:
    r, g, b, a = int(m[1]), int(m[2]), int(m[3]), float(m[4])
    print(f'rgba({r:02x}{g:02x}{b:02x}{int(a*255):02x})')
" "$COLOR6")
    hyprctl eval "hl.general['col.active_border'] = '$COLOR3 $COLOR6 45deg' "
  fi
fi
