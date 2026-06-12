#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-interface-stability  (PreToolUse on Edit|Write|MultiEdit)
# ===========================================================================
# Enforces IR-22: designated frozen interfaces (the extension points a future
# swap depends on) must not change without explicit Tier-4 sign-off. Any edit to
# a file matching KEEL_FROZEN_INTERFACES (lib/keel.env) is blocked at phase 3 and
# routed to the escalation path — this is intentionally strict, because a silent
# frozen-interface change defeats the swap it exists to enable.
#
# Configure KEEL_FROZEN_INTERFACES as space-separated path globs, e.g.:
#   KEEL_FROZEN_INTERFACES="*/EventPublisher.java */contracts/*.proto"
# Empty (default) = no frozen interfaces declared yet -> hook is a no-op.
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

keel_is_file_mutation || keel_ok
FILE="$(keel_file_path)"
[[ -z "$FILE" ]] && keel_ok
REL="$(keel_relpath "$FILE")"

: "${KEEL_FROZEN_INTERFACES:=}"
[[ -z "$KEEL_FROZEN_INTERFACES" ]] && keel_ok

for glob in $KEEL_FROZEN_INTERFACES; do
  # shellcheck disable=SC2053
  case "$REL" in
    $glob)
      keel_gate "IR-22" \
        "$REL is a FROZEN interface (IR-22). Changing its surface is Tier 4 — it must require zero call-site refactoring to swap implementations. Stop and escalate with the decision format (core/constitution/autonomy-tiers.md); land the change only with an approver sign-off + ADR. If this file should NOT be frozen, remove it from KEEL_FROZEN_INTERFACES."
      ;;
  esac
done
keel_ok
