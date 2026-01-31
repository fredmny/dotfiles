#!/bin/bash
COUNT=$(checkupdates 2>/dev/null | wc -l)
if [ "$COUNT" -eq 0 ]; then
  printf '{"text": " ", "tooltip": "System up to date"}'
else
  printf '{"text": "  %s", "tooltip": "%s updates available"}' "$COUNT" "$COUNT"
fi
