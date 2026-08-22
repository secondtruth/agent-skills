#!/usr/bin/env bash
# Compare every skill in this marketplace with the copy claude.ai has synced to
# this machine. Reports SAME, DIFFER (with the changed files) or NOT ONLINE.
#
# Usage: scripts/check-drift.sh [plugins-dir]
set -euo pipefail

root="${1:-$(cd "$(dirname "$0")/.." && pwd)/plugins}"
sync_root="${CLAUDE_SKILLS_SYNC:-}"
if [ -z "$sync_root" ]; then
  sync_root=$(find "$HOME/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin" \
    -maxdepth 3 -type d -name skills 2>/dev/null | head -1)
fi
[ -d "$sync_root" ] || { echo "claude.ai skill sync directory not found; set CLAUDE_SKILLS_SYNC" >&2; exit 2; }

same=0; differ=0; missing=0
for skill_md in $(find "$root" -name SKILL.md -path '*/skills/*' | sort); do
  dir=$(dirname "$skill_md"); name=$(basename "$dir")
  if [ ! -d "$sync_root/$name" ]; then
    printf 'NOT ONLINE  %s\n' "$name"; missing=$((missing+1)); continue
  fi
  if out=$(diff -rq --exclude=.DS_Store --exclude=CHANGELOG.md "$dir" "$sync_root/$name" 2>&1); then
    printf 'same        %s\n' "$name"; same=$((same+1))
  else
    printf 'DIFFER      %s\n' "$name"; differ=$((differ+1))
    printf '%s\n' "$out" | sed "s|$dir/|  repo:   |; s|$sync_root/$name/|  online: |; s/^Files /  /; s/^Only in /  only in /" | head -10
  fi
done
printf '\n%d same, %d differ, %d not online\n' "$same" "$differ" "$missing"
[ "$differ" -eq 0 ]
