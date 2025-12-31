#!/bin/bash

current_kb_variant=$(hyprctl getoption input:kb_variant -j | jq -r '.str')

if [ "$current_kb_variant" = "intl" ]; then
  hyprctl keyword input:kb_variant ""
  notify-send "Keyboard" "Variant: US (default)"
else
  hyprctl keyword input:kb_variant "intl"
  notify-send "Keyboard" "Variant: US International"
fi
