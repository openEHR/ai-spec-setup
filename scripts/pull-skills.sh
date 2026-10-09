#!/usr/bin/env sh
# Pull the upstream skill/MCP repos tracked as submodules under external/ to their latest default branch.
# Usage: scripts/pull-skills.sh            (init + fast-forward to recorded commits)
#        scripts/pull-skills.sh --latest   (move submodules to upstream HEAD; commit the bump afterwards)
set -eu
cd "$(dirname "$0")/.."
if [ "${1:-}" = "--latest" ]; then
  git submodule update --init --remote --recursive
  git submodule status
  echo "submodules moved to upstream HEAD; review and commit the pointer bump"
else
  git submodule update --init --recursive
  git submodule status
fi
