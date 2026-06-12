#!/usr/bin/env bash
# ===========================================================================
# Keel hook: check-file-length  (PostToolUse on Edit|Write|MultiEdit)
# ===========================================================================
# Soft cap on file length (quality-principles.md §5: small, reviewable units).
# Warns/blocks when an edited file exceeds KEEL_MAX_FILE_LINES so growth toward
# unreviewable mega-files gets caught early.
# ===========================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
keel_init

keel_is_file_mutation || keel_ok
FILE="$(keel_file_path)"
[[ -z "$FILE" || ! -f "$FILE" ]] && keel_ok

# Only count text files; skip generated/vendored trees.
case "$FILE" in
  *node_modules/*|*/dist/*|*/build/*|*/.next/*|*/target/*|*/vendor/*|*.min.*) keel_ok ;;
esac

LINES="$(wc -l < "$FILE" | tr -d ' ')"
if [[ "$LINES" -gt "$KEEL_MAX_FILE_LINES" ]]; then
  REL="$(keel_relpath "$FILE")"
  keel_gate "quality-filelen" \
    "$REL is ${LINES} lines (cap ${KEEL_MAX_FILE_LINES}). Consider splitting into cohesive units before it becomes unreviewable."
fi
keel_ok
