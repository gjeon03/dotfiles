#!/usr/bin/env bash
# statusline.sh — Claude Code status line
#
# ccstatusline이 설치되어 있으면 사용하고, 없으면 내장 fallback을 출력한다.
# 머신마다 다른 설치 경로를 하드코딩하지 않기 위한 래퍼.

input=$(cat)

# ─── ccstatusline (선호) ──────────────────────────────────
if command -v ccstatusline &>/dev/null; then
  printf '%s' "$input" | CCSTATUSLINE_WIDTH=400 ccstatusline
  exit 0
fi

if command -v node &>/dev/null; then
  for candidate in \
    "$HOME/.bun/install/global/node_modules/ccstatusline/dist/ccstatusline.js" \
    "$HOME/.npm-global/lib/node_modules/ccstatusline/dist/ccstatusline.js" \
    "/opt/homebrew/lib/node_modules/ccstatusline/dist/ccstatusline.js" \
    "/usr/local/lib/node_modules/ccstatusline/dist/ccstatusline.js"; do
    if [[ -f "$candidate" ]]; then
      printf '%s' "$input" | CCSTATUSLINE_WIDTH=400 node "$candidate"
      exit 0
    fi
  done
fi

# ─── Fallback: user@host:dir (branch) | Model [style] | Cost ───
if ! command -v jq &>/dev/null; then
  printf "\033[2m%s@%s\033[0m" "$(whoami)" "$(hostname -s)"
  exit 0
fi

cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir')
model=$(printf '%s' "$input" | jq -r '.model.display_name')
style=$(printf '%s' "$input" | jq -r '.output_style.name')
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // "0.00"')

git_info=""
if [[ -d "$cwd/.git" ]]; then
  branch=$(cd "$cwd" && git branch --show-current 2>/dev/null)
  git_info=" (${branch:-unknown})"
fi

printf "\033[2m%s@%s:%s%s | %s [%s] | Cost: \$%s\033[0m" \
  "$(whoami)" "$(hostname -s)" "$(basename "$cwd")" "$git_info" "$model" "$style" "$cost"
