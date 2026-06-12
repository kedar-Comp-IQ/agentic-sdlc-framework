#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-review-approval  (Stop)  — adversarial review for
#            governance-recursive changes (review-framework.md Layer 2)
# ===========================================================================
# If this session edited any governance-marked path (KEEL_GOVERNANCE_GLOBS), it
# must produce an adversarial-review debate transcript that (a) names the changed
# artifact and (b) is fresh (post-dates the change). This is the generalized form
# of the production "review-debate" gate.
#
# Two failure modes this guards against (both learned the hard way):
#   - STALE: a transcript older than the change passes by accident -> mtime check.
#   - UNASSOCIATED: a transcript that doesn't name its target -> require a
#     "**Target:** <path>" marker.
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

[[ "$(keel_event_name)" == "Stop" ]] || keel_ok

cd "$KEEL_REPO_ROOT" 2>/dev/null || keel_ok

# Which governance-marked files changed in the working tree (staged+unstaged+committed
# vs the default branch)? Use git status for a cheap, reliable signal.
CHANGED="$(git -C "$KEEL_REPO_ROOT" status --porcelain 2>/dev/null | awk '{print $2}')"
[[ -z "$CHANGED" ]] && keel_ok

gov_hits=()
for f in $CHANGED; do
  for glob in $KEEL_GOVERNANCE_GLOBS; do
    # shellcheck disable=SC2053
    case "$f" in $glob) gov_hits+=("$f") ;; esac
  done
done
[[ ${#gov_hits[@]} -eq 0 ]] && keel_ok

# A debate transcript is any markdown under the debate-transcripts dir naming the target.
DEBATE_DIR="${KEEL_REPO_ROOT}/agent-outputs/reviews/debate-transcripts"
missing=()
for f in "${gov_hits[@]}"; do
  found=""
  if [[ -d "$DEBATE_DIR" ]]; then
    # transcript must reference the file via a Target marker AND be newer than the file
    while IFS= read -r t; do
      if grep -qsE "^\*\*Target:?\*\*.*$(basename "$f")" "$t" 2>/dev/null; then
        if [[ "$t" -nt "${KEEL_REPO_ROOT}/$f" ]]; then found="$t"; break; fi
      fi
    done < <(find "$DEBATE_DIR" -name '*.md' 2>/dev/null)
  fi
  [[ -z "$found" ]] && missing+=("$f")
done
[[ ${#missing[@]} -eq 0 ]] && keel_ok "governance changes have fresh debate transcripts"

keel_gate "review-L2" \
  "Governance-recursive change(s) without a fresh adversarial-review debate transcript: ${missing[*]}. Run the review-debate (independent Critic + Judge), save a transcript under agent-outputs/reviews/debate-transcripts/ with a '**Target:** <path>' marker written AFTER the change. See core/governance/review-framework.md."
