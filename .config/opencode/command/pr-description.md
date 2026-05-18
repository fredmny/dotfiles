---
description: Generate PR Description
---

# Generate PR Description

Create a concise PR description for the current branch and save it to a temporary file.

## Instructions

1. **Identify branches**:
   - Get the current branch name via `git branch --show-current`
   - Determine the base branch by checking (in order): upstream tracking branch, then `main`, `master`, `develop`

2. **Gather changes**:
   - Run `git diff $(git merge-base HEAD <base>)..HEAD` to see the full diff
   - Run `git log --oneline $(git merge-base HEAD <base>)..HEAD` to get commit history

3. **Check for a PR template**:
   - Search common locations: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `docs/pull_request_template.md`
   - If a template exists, use its structure exactly

4. **Write the description**:
   - If no template exists, use this structure:
     - **Summary**: 1-2 sentences explaining what and why
     - **Changes**: bullet list of notable changes
     - **Notes**: breaking changes, migration steps, or testing notes (only if relevant)
   - Be clear and succinct — focus on "what" and "why", not restating commits
   - For small or trivial changes (e.g. single config tweak, typo fix, dependency bump), keep it to 1-3 sentences total — skip the full structure
   - Do not mention line counts; they change during review
   - Maximum ~150 words unless the template requires more

5. **Save output**:
   - Write the final markdown to a temp file (use `/tmp/pr-description-<branch>.md`)
   - Print the file path so it can be easily copied or piped to `gh pr create --body-file`

## Process

1. Identify base branch
2. Gather diff and commits
3. Look for PR template
4. Generate description
5. Save to temp file and report the path

## Extra Context

If the user provided additional context, use it to guide the tone, focus, or framing of the description: $ARGUMENTS

Do not commit anything or execute any git/GitHub operations beyond reading.
