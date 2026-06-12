#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-architecture-drift  (PostToolUse on Edit|Write|MultiEdit)
# ===========================================================================
# Enforces IR-01 boundary isolation: a file in one {{BOUNDARY_TERM}} must not
# import another {{BOUNDARY_TERM}}'s internals (the shared one excepted). Runs
# POST-edit so it scans the file's NEW on-disk content.
#
# Heuristic + language-agnostic: it identifies the edited file's boundary from
# its path, then scans import/require/use/from lines for references to OTHER
# boundary names. Tune KEEL_BOUNDARIES / KEEL_SHARED_BOUNDARY in lib/keel.env,
# and the import-line regex below, to your language(s).
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

keel_is_file_mutation || keel_ok
FILE="$(keel_file_path)"
[[ -z "$FILE" || ! -f "$FILE" ]] && keel_ok
REL="$(keel_relpath "$FILE")"
case "$REL" in docs/*|*.md|.keel/*|.claude/*) keel_ok ;; esac

: "${KEEL_BOUNDARIES:=}"
: "${KEEL_SHARED_BOUNDARY:=}"
[[ -z "$KEEL_BOUNDARIES" ]] && keel_ok    # no boundary model configured

# --- which boundary does this file belong to? -------------------------------
own=""
for b in $KEEL_BOUNDARIES; do
  case "/$REL/" in */"$b"/*) own="$b"; break ;; esac
done
[[ -z "$own" ]] && keel_ok   # file isn't under a known boundary

# --- scan its import lines for OTHER boundaries -----------------------------
hits=""
for b in $KEEL_BOUNDARIES; do
  [[ "$b" == "$own" || "$b" == "$KEEL_SHARED_BOUNDARY" ]] && continue
  if grep -Eiq "^[[:space:]]*(import|from|require|use|using|include|#include)\b.*\b${b}\b" "$FILE" 2>/dev/null; then
    hits="${hits} ${b}"
  fi
done
[[ -z "$hits" ]] && keel_ok "no cross-boundary imports in $REL"

keel_gate "IR-01" \
  "$REL (boundary '${own}') imports across boundaries:${hits}. A ${BOUNDARY_TERM:-boundary} must not depend on another's internals (only '${KEEL_SHARED_BOUNDARY}' is shared). Route through the shared layer or a published contract. See core/constitution/inviolable-rules.md IR-01."
