#!/usr/bin/env bash
# ===========================================================================
# Keel hook: verify-api-contract  (Stop)
# ===========================================================================
# Enforces IR-04/IR-14: API contracts are immutable within a version. Watches the
# contract files (KEEL_CONTRACT_GLOBS) and, when one changed in this session,
# inspects the diff:
#   - additions only  -> non-breaking, allowed (logged).
#   - removals/renames of paths/fields/operations -> POTENTIALLY BREAKING ->
#     Tier 4: blocked unless an approval marker is present (an ADR reference or a
#     "contract-change-approved: <id>" line in the changed set).
#
# Heuristic: line-level removal detection, not full semantic diff. Tune the glob
# list and the "breaking" pattern to your contract format (OpenAPI / protobuf / …).
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

[[ "$(keel_event_name)" == "Stop" ]] || keel_ok
cd "$KEEL_REPO_ROOT" 2>/dev/null || keel_ok

: "${KEEL_CONTRACT_GLOBS:=*openapi.yaml *openapi.yml *api-contract.yaml *api-contract.yml *.proto}"

CHANGED="$(git -C "$KEEL_REPO_ROOT" status --porcelain 2>/dev/null | awk '{print $2}')"
[[ -z "$CHANGED" ]] && keel_ok

contracts=()
for f in $CHANGED; do
  for glob in $KEEL_CONTRACT_GLOBS; do
    # shellcheck disable=SC2053
    case "$f" in $glob) contracts+=("$f") ;; esac
  done
done
[[ ${#contracts[@]} -eq 0 ]] && keel_ok

# Removed/changed lines that look like contract surface (paths, operations, fields).
BREAK_RE='(paths:|operationId|/v[0-9]|^-? *(get|post|put|patch|delete):|required:|rpc |message |enum |type )'
removed="$(git -C "$KEEL_REPO_ROOT" diff HEAD -- "${contracts[@]}" 2>/dev/null \
            | grep -E '^-[^-]' | grep -Ei "$BREAK_RE" || true)"

if [[ -z "$removed" ]]; then
  keel_ok "contract changed (additive only): ${contracts[*]}"
fi

# Potentially breaking — is there an approval marker?
if git -C "$KEEL_REPO_ROOT" diff HEAD 2>/dev/null | grep -Eiq 'contract-change-approved|ADR-[0-9]+'; then
  keel_log "breaking contract change carries an approval/ADR marker — allowed"
  keel_ok
fi

keel_gate "IR-04" \
  "Contract file(s) ${contracts[*]} have removed/changed surface (potentially BREAKING). Breaking API changes are Tier 4: bump the version (immutable-within-version), or get approver sign-off + an ADR reference. Add 'contract-change-approved: <id>' or reference the ADR if this is intentional and versioned. See core/constitution/inviolable-rules.md IR-04/IR-14."
