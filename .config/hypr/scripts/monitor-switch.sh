#!/usr/bin/env bash
set -euo pipefail

MONITORS_FILE="$HOME/.config/hypr/monitors.lua"
WORKSPACE_RULES_FILE="$HOME/.config/hypr/workspace-rules.lua"

usage() {
  printf 'Usage: %s [both|left|right]\n' "$(basename "$0")" >&2
}

choose_layout() {
  printf 'both\nleft\nright\n' | rofi -dmenu -i -p 'Screen Layout:'
}

write_layout_files() {
  case "$1" in
    both)
      cat >"$MONITORS_FILE" <<'EOF'
-- Monitor configuration

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@143.98",
    position = "0x0",
    scale = 1.0,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60.0",
    position = "1920x-300",
    scale = 1.0,
    transform = 1,
})
EOF

      cat >"$WORKSPACE_RULES_FILE" <<'EOF'
-- Workspace rules for the active monitor layout

hl.workspace_rule({
    workspace = "1",
    monitor = "HDMI-A-1",
    default = true,
    persistent = true,
})
EOF
      ;;
    left)
      cat >"$MONITORS_FILE" <<'EOF'
-- Monitor configuration

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@143.98",
    position = "0x0",
    scale = 1.0,
})

hl.monitor({
    output = "HDMI-A-1",
    disabled = true,
})
EOF

      cat >"$WORKSPACE_RULES_FILE" <<'EOF'
-- Workspace rules for the active monitor layout

hl.workspace_rule({
    workspace = "1",
    monitor = "DP-1",
    default = true,
    persistent = true,
})
EOF
      ;;
    right)
      cat >"$MONITORS_FILE" <<'EOF'
-- Monitor configuration

hl.monitor({
    output = "DP-1",
    disabled = true,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60.0",
    position = "0x0",
    scale = 1.0,
    transform = 1,
})
EOF

      cat >"$WORKSPACE_RULES_FILE" <<'EOF'
-- Workspace rules for the active monitor layout

hl.workspace_rule({
    workspace = "1",
    monitor = "HDMI-A-1",
    default = true,
    persistent = true,
})
EOF
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

apply_layout() {
  local log_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-screen-layout.log"
  local lua

  lua=$(cat <<'EOF'
dofile(os.getenv("HOME") .. "/.config/hypr/monitors.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/workspace-rules.lua")
EOF
)

  hyprctl eval "$lua" >>"$log_file" 2>&1
}

layout="${1:-}"

if [[ -z "$layout" ]]; then
  layout="$(choose_layout || true)"
fi

if [[ -z "$layout" ]]; then
  exit 0
fi

write_layout_files "$layout"
apply_layout
