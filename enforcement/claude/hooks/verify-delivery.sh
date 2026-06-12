#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-delivery  (Stop)
# ===========================================================================
# Enforces the close-gate (sdlc-gate.md Step 6 + DoD): if this session changed
# production source, it must leave behind (a) a delivery record and (b) at least
# one knowledge note OR an explicit "no new knowledge" marker. Prevents the
# "wrote code, closed session, captured nothing" failure (IR-20).
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

[[ "$(keel_event_name)" == "Stop" ]] || keel_ok
cd "$KEEL_REPO_ROOT" 2>/dev/null || keel_ok

CHANGED="$(git -C "$KEEL_REPO_ROOT" status --porcelain 2>/dev/null | awk '{print $2}')"
[[ -z "$CHANGED" ]] && keel_ok    # nothing changed => nothing to deliver

# Did production source change? (mirror verify-spec's notion of "source")
src_changed=false
for f in $CHANGED; do
  case "$f" in
    src/*|app/*|lib/*|pkg/*|internal/*|*/src/*)
      case "$f" in *test*|*spec/*|*__tests__/*|docs/*|*.md) ;; *) src_changed=true ;; esac ;;
  esac
done
$src_changed || keel_ok "no production-source changes; delivery record not required"

# Delivery record present? (a changed file under a deliveries/handoffs path, or a
# file matching the delivery-record template heading). Tune the location.
has_delivery=false
for f in $CHANGED; do
  case "$f" in
    *delivery*|*handoff*|agent-outputs/*|*/deliveries/*) has_delivery=true ;;
  esac
done
if ! $has_delivery; then
  if grep -rqsl "Delivery Record" "$KEEL_REPO_ROOT/agent-outputs" 2>/dev/null; then
    has_delivery=true
  fi
fi

# Knowledge captured? (a changed/new KN note) or an explicit opt-out marker.
has_knowledge=false
for f in $CHANGED; do
  case "$f" in *KN-*|*/knowledge/*) has_knowledge=true ;; esac
done

missing=()
$has_delivery  || missing+=("delivery record (core/templates/delivery-record-template.md)")
$has_knowledge || missing+=("knowledge note OR explicit 'no new knowledge' justification (IR-20)")

[[ ${#missing[@]} -eq 0 ]] && keel_ok "delivery + knowledge present"

keel_gate "IR-20" \
  "Session changed production source but is missing: ${missing[*]}. Complete the close-gate before ending the session (sdlc-gate.md Step 4-6)."
