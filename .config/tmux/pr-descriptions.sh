#!/usr/bin/env bash
# Pick a saved PR description (/tmp/pr-description-*) with fzf and open it in nvim

shopt -s nullglob
files=(/tmp/pr-description-*)

if [ ${#files[@]} -eq 0 ]; then
    echo "No PR descriptions found in /tmp"
    read -n 1 -s -r -p "Press any key to close"
    exit 0
fi

# Newest first
file=$(ls -t "${files[@]}" | fzf \
    --reverse \
    --prompt '📝  ' \
    --preview 'cat {}' \
    --preview-window 'down:85%:wrap')

[ -n "$file" ] && nvim "$file"
