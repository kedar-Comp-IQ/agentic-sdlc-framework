#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-single-session  (UserPromptSubmit + PostToolUse + Stop)
# ===========================================================================
# Enforces "one agent session per checkout" (see core/process/session-archetypes.md).
# Writes a per-checkout lock on first activity; refuses a SECOND concurrent session
# from a different session_id while the lock is fresh (TTL). This is the guardrail
# that prevents two sessions tangling branch state in one working tree.
#
# This hook ALWAYS blocks on collision regardless of rollout phase — a session
# collision corrupts state, so there is no "soft" version of it. (It still respects
# phase for the informational path.)
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

LOCK="${KEEL_REPO_ROOT}/.claude/.session-lock.json"
TTL_SECONDS=3600                     # 60 min; a stale lock past this is reclaimable
NOW="$(date +%s)"
ME="$(keel_session_id)"
[[ -z "$ME" ]] && keel_ok    # no session id in event => nothing to enforce

mkdir -p "$(dirname "$LOCK")"

if [[ -f "$LOCK" ]]; then
  HOLDER="$(KEEL_INPUT="$(cat "$LOCK")" keel_field session_id)"
  WHEN="$(KEEL_INPUT="$(cat "$LOCK")" keel_field ts)"
  WHEN="${WHEN:-0}"
  AGE=$(( NOW - WHEN ))
  if [[ "$HOLDER" != "$ME" && "$AGE" -lt "$TTL_SECONDS" ]]; then
    echo "" >&2
    echo "🛑 [keel:BLOCK IR-session] SESSION COLLISION" >&2
    echo "   This checkout is locked by another session ($HOLDER, ${AGE}s ago)." >&2
    echo "   Never run two agent sessions in one working tree." >&2
    echo "   Spin a separate worktree for this initiative:" >&2
    echo "       git worktree add ../$(basename "$KEEL_REPO_ROOT")-<slug> <branch>" >&2
    echo "   If you are certain no other session is active, delete: $LOCK" >&2
    exit 2
  fi
fi

# (Re)claim the lock for this session.
printf '{"session_id":"%s","ts":%s}\n' "$ME" "$NOW" > "$LOCK"
keel_ok
