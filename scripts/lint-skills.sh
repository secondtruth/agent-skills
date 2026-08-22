#!/usr/bin/env bash
# Lint every skill in this marketplace against the writing-for-agents rubric:
# description budget, hard references to sibling skills, negation density,
# personal/private markers, and licence frontmatter.
#
# Usage: scripts/lint-skills.sh [--public] [--strict] [plugins-dir]
#   --public   treat personal markers as errors (public repository)
#   --strict   exit non-zero when any error was reported
set -u

public=0; strict=0; root=""
for arg in "$@"; do
  case "$arg" in
    --public) public=1 ;;
    --strict) strict=1 ;;
    *) root="$arg" ;;
  esac
done
root="${root:-$(cd "$(dirname "$0")/.." && pwd)/plugins}"

DESCRIPTION_BUDGET=60
NEGATION_BUDGET=8          # negated lines per 100 body lines
PERSONAL='Christian|secondtruth|Flamebound|OWTA|stLabs|secondVerse|IceFlame|FlameCore|Sailscale|seabreeze|AgentFinger|notion\.so|[0-9a-f]{32}|/Users/|forge\.|midgard|sleipnir|Tinyauth|Pocket ID|caddy-docker-proxy|Freundschaft|E-Rolli'
NEGATION="\\b([Dd]on'?t|[Nn]ever|[Dd]o not|[Nn]o |[Nn]ot |NOT |[Aa]void)\\b"

errors=0; warnings=0
if [ -n "${NO_COLOR:-}" ] || [ ! -t 1 ]; then red=""; yellow=""; reset=""; else red=$'\033[31m'; yellow=$'\033[33m'; reset=$'\033[0m'; fi
err()  { printf '  %sERR %s %s\n' "$red" "$reset" "$*"; errors=$((errors+1)); }
warn() { printf '  %swarn%s %s\n' "$yellow" "$reset" "$*"; warnings=$((warnings+1)); }
report() { # level, label, matches (multi-line); prints up to 5 matches under one heading
  local level=$1 label=$2 matches=$3 count
  [ -z "$matches" ] && return 0
  count=$(printf '%s\n' "$matches" | wc -l | tr -d ' ')
  "$level" "$label ($count):"
  printf '%s\n' "$matches" | head -5 | sed 's/^/       /'
}

skill_names=$(find "$root" -name SKILL.md -path '*/skills/*' | sed -E 's|.*/skills/([^/]+)/SKILL\.md|\1|' | sort -u)

frontmatter() { awk 'NR==1 && /^---$/ {f=1; next} f && /^---$/ {exit} f {print}' "$1"; }
body()        { awk 'NR==1 && /^---$/ {f=1; next} f==1 && /^---$/ {f=2; next} f==2 {print}' "$1"; }
description() {
  frontmatter "$1" | awk '
    /^description:/ { sub(/^description:[ ]*[>|]?-?[ ]*/, ""); d=$0; on=1; next }
    on && /^[a-zA-Z_-]+:/ { on=0 }
    on { d = d " " $0 }
    END { gsub(/^[ "]+|[ "]+$/, "", d); print d }'
}

for skill_md in $(find "$root" -name SKILL.md -path '*/skills/*' | sort); do
  dir=$(dirname "$skill_md"); name=$(basename "$dir")
  printf '%s\n' "${skill_md#"$root"/}"

  desc=$(description "$skill_md")
  words=$(printf '%s' "$desc" | wc -w | tr -d ' ')
  if [ "$words" -eq 0 ]; then err "description missing"
  elif [ "$words" -gt "$DESCRIPTION_BUDGET" ]; then warn "description is $words words (budget $DESCRIPTION_BUDGET)"; fi

  if [ "$public" -eq 1 ] && ! frontmatter "$skill_md" | grep -q '^license:'; then warn "no license: in frontmatter"; fi

  report warn "hard references" "$(grep -rnE "(^|[^a-zA-Z0-9_/.])/[a-z][a-z0-9-]+ skill|anthropic-skills:|mattpocock-skills:|[Pp]rinciple [0-9]+" "$dir" 2>/dev/null | sed "s|^$dir/||")"

  paths=""; named=""
  for other in $skill_names; do
    [ "$other" = "$name" ] && continue
    m=$(grep -rnE "\b$other/(references|SKILL\.md|scripts)" "$dir" 2>/dev/null | sed "s|^$dir/||"); [ -n "$m" ] && paths="$paths${paths:+$'\n'}$m"
    m=$(grep -rnE "\`$other\`" "$dir" 2>/dev/null | grep -vE 'available|when present|if present' | sed "s|^$dir/||"); [ -n "$m" ] && named="$named${named:+$'\n'}$m"
  done
  report warn "paths into sibling skills" "$paths"
  report warn "siblings named without availability clause" "$named"

  total=0; neg=0
  for md in $(find "$dir" -name '*.md'); do
    t=$(body "$md" | grep -c .); n=$(body "$md" | grep -cE "$NEGATION")
    total=$((total+t)); neg=$((neg+n))
  done
  if [ "$total" -gt 0 ]; then
    density=$((neg*100/total))
    [ "$density" -gt "$NEGATION_BUDGET" ] && warn "negation density $density per 100 lines ($neg of $total)"
  fi

  hits=$(grep -rnE "$PERSONAL" "$dir" 2>/dev/null | grep -v '\.DS_Store' | sed "s|^$dir/||")
  if [ "$public" -eq 1 ]; then report err "personal/private markers" "$hits"; else report warn "personal/private markers" "$hits"; fi
done

printf '\n%d error(s), %d warning(s)\n' "$errors" "$warnings"
if [ "$strict" -eq 1 ] && [ "$errors" -gt 0 ]; then exit 1; fi
exit 0
