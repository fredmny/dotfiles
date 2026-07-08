#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
CTX_USED=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
PR_NUMBER=$(echo "$input" | jq -r '.pr.number // empty')
PR_STATE=$(echo "$input" | jq -r '.pr.review_state // "open"')

# Fall back to computing percentage from token counts if used_percentage is absent
if [ -z "$PCT" ]; then
  if [ "$CTX_SIZE" -gt 0 ]; then PCT=$((CTX_USED * 100 / CTX_SIZE)); else PCT=0; fi
fi

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; GRAY='\033[90m'; RESET='\033[0m'

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

CTX_USED_K=$((CTX_USED / 1000)); CTX_SIZE_K=$((CTX_SIZE / 1000))

BRANCH=""
git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git -C "$DIR" --no-optional-locks branch --show-current 2>/dev/null)"

PR_SEGMENT=""
if [ -n "$PR_NUMBER" ]; then
  case "$PR_STATE" in
    approved) PR_COLOR="$GREEN"; PR_ICON="✅" ;;
    changes_requested) PR_COLOR="$RED"; PR_ICON="❌" ;;
    draft) PR_COLOR="$GRAY"; PR_ICON="📝" ;;
    pending|*) PR_COLOR="$YELLOW"; PR_ICON="⏳" ;;
  esac
  PR_SEGMENT=" | ${PR_COLOR}${PR_ICON} PR #${PR_NUMBER} (${PR_STATE})${RESET}"
fi

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}$BRANCH$PR_SEGMENT"
COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% (${CTX_USED_K}k/${CTX_SIZE_K}k) | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"
