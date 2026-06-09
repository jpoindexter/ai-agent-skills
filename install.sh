#!/usr/bin/env bash
# Install all skills into ~/.claude/skills/
# Usage: ./install.sh [--dry-run]

set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

mkdir -p "$SKILLS_DIR"

for skill_dir in "$SOURCE_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  [[ -f "$skill_file" ]] || continue

  dest="$SKILLS_DIR/$skill_name"

  if $DRY_RUN; then
    echo "[dry-run] would install: $skill_name → $dest"
  else
    mkdir -p "$dest"
    cp "$skill_file" "$dest/SKILL.md"
    echo "installed: $skill_name"
  fi
done

echo ""
echo "Done. Reload Claude Code to pick up new skills."
