#!/usr/bin/env bash
set -euo pipefail

SKILLS_SRC="$(cd "$(dirname "$0")/../skills" && pwd)"
SKILLS_DEST="$HOME/.claude/skills"

mkdir -p "$SKILLS_DEST"

installed=0
updated=0

for src_file in "$SKILLS_SRC"/*.md; do
  [ -f "$src_file" ] || continue
  name="$(basename "$src_file" .md)"
  dest_dir="$SKILLS_DEST/$name"

  if [ -d "$dest_dir" ]; then
    action="updated"
    ((updated++)) || true
  else
    action="installed"
    ((installed++)) || true
  fi

  mkdir -p "$dest_dir"
  cp "$src_file" "$dest_dir/SKILL.md"
  echo "[$action] $name"
done

echo ""
echo "Done. $installed installed, $updated updated → $SKILLS_DEST"
