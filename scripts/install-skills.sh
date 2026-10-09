#!/usr/bin/env sh
# Copy the SKILL.md directories of both pinned plugins into a skills folder that non-Claude hosts read.
#
#   .agents/skills/   the Agent Skills standard path: Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode, Vibe
#   .claude/skills/   Claude Code (but prefer the plugin marketplace there: it also gives subagents and action skills)
#
# Usage: scripts/install-skills.sh [DEST_DIR]      (default: ../.agents/skills, i.e. the openehr-spec/ root)
# Only SKILL.md folders are copied; host-specific commands/, agents/ and hooks/ are not portable and are skipped.
set -eu
HERE="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-$HERE/../.agents/skills}"
mkdir -p "$DEST"
n=0
for src in \
  "$HERE/external/openEHR-ai-plugins/plugins/openehr-specs/skills" \
  "$HERE/external/cadasto-openehr-assistant-plugin/skills"; do
  [ -d "$src" ] || { echo "missing $src: run scripts/pull-skills.sh first" >&2; exit 1; }
  for d in "$src"/*/; do
    name="$(basename "$d")"
    [ -f "$d/SKILL.md" ] || continue
    rm -rf "$DEST/$name"; cp -R "$d" "$DEST/$name"; n=$((n+1))
    printf '  %s\n' "$name"
  done
done
echo "installed $n skills into $DEST"
