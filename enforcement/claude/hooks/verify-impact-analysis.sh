#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-impact-analysis  (PreToolUse on Edit|Write|MultiEdit)
# ===========================================================================
# Complements verify-spec for Bug/Debt/Security work: those skip the full spec
# but MUST carry a quick-plan with impact analysis (task-classification.md).
# Fires when the branch is a fix/bug/hotfix branch and no impact analysis is
# found for the work item.
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

keel_is_file_mutation || keel_ok
FILE="$(keel_file_path)"; [[ -z "$FILE" ]] && keel_ok
REL="$(keel_relpath "$FILE")"
case "$REL" in docs/*|*.md|.keel/*|.claude/*) keel_ok ;; esac

BRANCH="$(git -C "$KEEL_REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
# Only fixes need impact analysis here (features are covered by verify-spec).
case "$BRANCH" in
  bugfix/*|fix/*|hotfix/*|debt/*|security/*|chore/*) : ;;
  *) keel_ok ;;
esac

WORK_ID="$(echo "$BRANCH" | grep -oE '[A-Z][A-Z0-9]+-[A-Z0-9]+-[0-9]+' | head -1 || true)"

# Look for an impact-analysis marker tied to the work item (a quick-plan with the
# canonical headings, or an issue export). Tune the markers to your tracker.
if grep -rqsi --include='*.md' -e "Impact analysis" -e "Rollback plan" \
     "$KEEL_REPO_ROOT/docs" "$KEEL_REPO_ROOT/specs" 2>/dev/null; then
  if [[ -z "$WORK_ID" ]] || grep -rqs --include='*.md' "$WORK_ID" \
       "$KEEL_REPO_ROOT/docs" "$KEEL_REPO_ROOT/specs" 2>/dev/null; then
    keel_ok "impact analysis present"
  fi
fi

keel_gate "task-class" \
  "Fix branch '$BRANCH' is editing code without a quick-plan + impact analysis (affected boundaries, contract/schema impact, dependencies, rollback). See core/templates/quick-plan-template.md."
