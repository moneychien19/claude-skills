#!/usr/bin/env bash
set -euo pipefail

REPO="moneychien19/claude-skills"
BRANCH="main"
SKILLS_DEST="$HOME/.claude/skills"

# When run via `curl | bash`, BASH_SOURCE[0] is empty or /dev/stdin.
# In that case, download the repo tarball from GitHub instead.
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "/dev/fd/"* ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || true
fi

TMP_DIR=""
if [[ -n "$SCRIPT_DIR" ]] && [[ -d "$SCRIPT_DIR/../skills" ]]; then
  SKILLS_SRC="$(cd "$SCRIPT_DIR/../skills" && pwd)"
else
  echo "Downloading skills from GitHub ($REPO@$BRANCH)..."
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  curl -fsSL "https://api.github.com/repos/$REPO/tarball/$BRANCH" \
    | tar xz -C "$TMP_DIR" --strip-components=1
  SKILLS_SRC="$TMP_DIR/skills"
fi

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
