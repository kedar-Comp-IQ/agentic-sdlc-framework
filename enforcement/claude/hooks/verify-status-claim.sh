#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-status-claim  (Stop)
# ===========================================================================
# Quality-principles §1: "done" / "tests pass" must be demonstrated, not asserted.
# Scans the session transcript for completion/green claims and checks that an
# actual test/verification command was run in the same session. Catches the
# agent's strongest bias: declaring success it didn't verify.
#
# Heuristic by nature — it errs toward a soft nudge. Tune the claim patterns and
# the test-command patterns to your stack/adapters.
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

[[ "$(keel_event_name)" == "Stop" ]] || keel_ok
TRANSCRIPT="$(keel_transcript)"
[[ -z "$TRANSCRIPT" || ! -f "$TRANSCRIPT" ]] && keel_ok

# Did the agent claim completion / passing tests?
CLAIM_RE='all tests pass|tests are passing|tests pass|done and verified|fully working|everything works|✅ *(all )?pass'
claimed="$(grep -iEo "$CLAIM_RE" "$TRANSCRIPT" 2>/dev/null | head -1 || true)"
[[ -z "$claimed" ]] && keel_ok

# Was a test/verify command actually invoked? (tune per adapter:
# mvn test / npm test / pytest / go test / playwright …)
TEST_RE='mvn +(-[^ ]+ +)*test|mvn +verify|npm +(run +)?test|npx +playwright|vitest|jest|pytest|go +test|cargo +test'
if grep -qiE "$TEST_RE" "$TRANSCRIPT" 2>/dev/null; then
  keel_ok "completion claim backed by a test run"
fi

keel_gate "quality-status" \
  "The session claims completion/passing tests ('${claimed}') but no test command was run in this session. Run the suite and cite the result in the delivery record, or soften the claim to what was actually verified (quality-principles.md §1)."
