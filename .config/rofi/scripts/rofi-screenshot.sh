#!/usr/bin/env bash

entries="→ Active Window\n→ Current Monitor\n→ Select Region\n→ Full Screen\n→ Area → Clipboard\n→ Area → Edit"

chosen=$(echo -e "$entries" | rofi -dmenu -p "Screenshot" -theme-str 'listview {lines: 7;}')

case "$chosen" in
  "→ Active Window")      grimblast copysave active ;;
  "→ Current Monitor")    grimblast copysave output ;;
  "→ Select Region")      grimblast copysave area ;;
  "→ Full Screen")        grimblast copysave screen ;;
  "→ Area → Clipboard")   grimblast copy area ;;
  "→ Area → Edit")        grimblast edit area ;;
esac
