#!/usr/bin/env sh
# Set up the openehr-spec/ workspace root for one AI host: copy that host's MCP config files,
# AGENTS.md, and (for non-Claude hosts) the skills into .agents/skills/.
#
# Usage: scripts/install-host.sh <claude|cursor|codex|gemini|vibe|opencode> [ROOT_DIR]
#   ROOT_DIR defaults to the parent of this repo (openehr-spec/).
# Idempotent. Rewrites ${HOME} in copied configs to the real home path for hosts that do not expand it.
set -eu
HOST="${1:-}"; HERE="$(cd "$(dirname "$0")/.." && pwd)"; ROOT="${2:-$HERE/..}"
case "$HOST" in claude|cursor|codex|gemini|vibe|opencode) ;; *)
  echo "usage: $0 <claude|cursor|codex|gemini|vibe|opencode> [ROOT_DIR]" >&2; exit 2;; esac
[ -d "$HERE/hosts/$HOST" ] || { echo "hosts/$HOST missing: run python3 scripts/gen-host-configs.py" >&2; exit 1; }
ROOT="$(cd "$ROOT" && pwd)"

# 1. host config files (keep directory structure)
(cd "$HERE/hosts/$HOST" && find . -type f) | while read -r f; do
  mkdir -p "$ROOT/$(dirname "$f")"
  if [ "$HOST" = claude ]; then cp "$HERE/hosts/$HOST/$f" "$ROOT/$f"
  else sed "s|\${HOME}|$HOME|g" "$HERE/hosts/$HOST/$f" > "$ROOT/$f"; fi
  echo "  $f"
done

# 2. shared instructions
cp "$HERE/AGENTS.md" "$ROOT/AGENTS.md"; echo "  AGENTS.md"
[ "$HOST" = claude ] && { printf '@AGENTS.md\n' > "$ROOT/CLAUDE.md"; echo "  CLAUDE.md (-> AGENTS.md)"; }

# 3. skills: Claude Code gets them from the plugin marketplace (see README step 3); everyone else from .agents/skills
if [ "$HOST" != claude ]; then
  sh "$HERE/scripts/install-skills.sh" "$ROOT/.agents/skills"
  [ "$HOST" = vibe ] && echo "  note: Vibe also reads .vibe/skills; .agents/skills is enough"
fi
echo "done: $HOST configured in $ROOT. Start your assistant there."
