#!/usr/bin/env sh
# Clone (or update) every openEHR specifications-* repo side by side into one workspace root.
# The openehr-specs plugin expects Claude Code to be started in that root (the parent of all
# specifications-XX folders); publish and regen-classes resolve siblings relative to it.
#
# Usage: scripts/clone-spec-repos.sh [WORKSPACE_DIR]   (default: .. = the openehr-spec folder this repo sits in)
set -eu
WS="${1:-$(dirname "$0")/../..}"
REPOS="AA_GLOBAL AM BASE CDS CNF INTG ITS ITS-BMM ITS-JSON ITS-REST ITS-XML LANG PROC QUERY RM SM TERM UML"
mkdir -p "$WS"
for c in $REPOS; do
  r="specifications-$c"
  if [ -d "$WS/$r/.git" ]; then
    echo "update  $r"; git -C "$WS/$r" pull -q --ff-only || echo "  (pull failed, check local changes)"
  else
    echo "clone   $r"; git clone -q "https://github.com/openEHR/$r.git" "$WS/$r"
  fi
done
echo "done: $(ls -d "$WS"/specifications-* | wc -l) repos in $WS"
