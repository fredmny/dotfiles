#!/usr/bin/env bash
# Fuzzy-find any file under $HOME with fzf and open it in nvim

cd ~ || exit 1

file=$(fd --type f --hidden \
    --exclude .git \
    --exclude Library \
    --exclude .Trash \
    --exclude node_modules \
    --exclude .cache \
    --exclude .venv |
    fzf \
        --reverse \
        --prompt '🔎  ' \
        --preview 'head -500 {}' \
        --preview-window 'down:70%:wrap')

[ -n "$file" ] && nvim "$file"
