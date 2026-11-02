#!/usr/bin/env bash
# Pick a saved PR description (/tmp/pr-description-* or anything under pr-drafts/
# in /tmp or $TMPDIR) with fzf and open it in nvim

# Trailing slashes make find descend into symlinked dirs (/tmp -> /private/tmp on macOS)
drafts_dirs=(/tmp/pr-drafts/)
tmpdir="${TMPDIR:-/tmp}"
[ "${tmpdir%/}" != /tmp ] && drafts_dirs+=("${tmpdir%/}/pr-drafts/")

files=()
while IFS= read -r -d '' f; do
    files+=("$f")
done < <(
    find /tmp/ -maxdepth 1 -type f -name 'pr-description-*' -print0 2>/dev/null
    find "${drafts_dirs[@]}" -type f -print0 2>/dev/null
)

if [ ${#files[@]} -eq 0 ]; then
    echo "No PR descriptions found in /tmp or pr-drafts/"
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
