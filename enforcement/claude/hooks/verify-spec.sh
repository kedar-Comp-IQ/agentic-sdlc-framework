#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-spec  (PreToolUse on Edit|Write|MultiEdit)
# ===========================================================================
# Enforces IR-03 "Spec First": implementation edits to production source require
# an approved planning artifact (a spec for features, a quick-plan/impact-analysis
# for fixes). Heuristic and intentionally tunable — adjust the source-path and
# spec-location globs to your repo.
#
# Strategy:
#   1. Only fires on production source edits (not docs/tests/config).
#   2. Derives a work-item ID from the branch name (e.g. ATLAS-API-001).
#   3. Looks for a spec/quick-plan that references that ID.
#   4. No artifact found => gate (block at phase 3).
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

keel_is_file_mutation || keel_ok
FILE="$(keel_file_path)"
[[ -z "$FILE" ]] && keel_ok
REL="$(keel_relpath "$FILE")"

# --- 1. Is this production source? (tune these globs) ----------------------
is_source=false
case "$REL" in
  src/*|app/*|lib/*|pkg/*|internal/*|*/src/*) is_source=true ;;
esac
# Exclusions: tests, docs, config, the governance tree itself.
case "$REL" in
  *test*|*spec/*|*__tests__/*|docs/*|*.md|*.yaml|*.yml|*.json|.keel/*|.claude/*) is_source=false ;;
esac
$is_source || keel_ok

# --- 2. Derive work-item ID from branch ------------------------------------
BRANCH="$(git -C "$KEEL_REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
# Matches PROJECT-AREA-NNN style IDs. Tune to {{FEATURE_ID_PATTERN}}.
WORK_ID="$(echo "$BRANCH" | grep -oE '[A-Z][A-Z0-9]+-[A-Z0-9]+-[0-9]+' | head -1 || true)"

if [[ -z "$WORK_ID" ]]; then
  keel_gate "IR-03" \
    "Editing production source ($REL) but the branch '$BRANCH' carries no work-item ID (expected ${FEATURE_ID_PATTERN:-PROJECT-AREA-NNN}). Classify the work and branch from a planning artifact first."
fi

# --- 3. Find a planning artifact referencing the ID ------------------------
# Searches common spec/plan locations + the tracker-export dir. Tune as needed.
if grep -rqs --include='*.md' "$WORK_ID" \
     "$KEEL_REPO_ROOT/docs" "$KEEL_REPO_ROOT/specs" 2>/dev/null; then
  keel_ok "spec/quick-plan found for $WORK_ID"
fi

keel_gate "IR-03" \
  "No spec or quick-plan references $WORK_ID. Features need an approved spec; fixes need a quick-plan with impact analysis (see core/process/sdlc-gate.md) before implementation."
