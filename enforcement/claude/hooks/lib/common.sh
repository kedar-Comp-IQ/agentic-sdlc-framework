#!/usr/bin/env bash
# ===========================================================================
# Keel hook library — shared helpers for every verify-*.sh guardrail.
# ===========================================================================
# Source this at the top of a hook:
#
#     source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
#     keel_init                       # reads the stdin event once, loads config
#
# The Claude Code hook contract this relies on (and that you'd re-implement for
# another agentic tool):
#   - The hook receives a JSON event on STDIN.
#   - Exit code 2  => BLOCK the action; stderr is shown to the agent.
#   - Exit code 0  => allow.
#   - For PreToolUse: event has .tool_name and .tool_input (e.g. .tool_input.file_path).
#   - For Stop:       event has .hook_event_name == "Stop".
#
# Requires: bash + python3 (no jq dependency).
# ===========================================================================

# --- locate repo root canonically (pairs git toplevel with pwd -P) ---------
# NOTE: git rev-parse --show-toplevel returns a CANONICAL path. Pairing it with
# a logical $PWD breaks prefix-stripping under symlinks (e.g. macOS /tmp). Always
# use `pwd -P`. (Hard-won lesson — keep it.)
keel_repo_root() {
  git -C "$(pwd -P)" rev-parse --show-toplevel 2>/dev/null || pwd -P
}

KEEL_INPUT=""
KEEL_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

keel_init() {
  # Read the event once (hooks get a single stdin pass).
  KEEL_INPUT="$(cat)"
  # Load runtime config.
  if [[ -f "${KEEL_LIB_DIR}/keel.env" ]]; then
    # shellcheck disable=SC1091
    source "${KEEL_LIB_DIR}/keel.env"
  fi
  : "${KEEL_ENFORCEMENT_PHASE:=3}"
  : "${KEEL_MAX_FILE_LINES:=600}"
  export KEEL_REPO_ROOT="$(keel_repo_root)"
}

# --- field extraction (python3, no jq) -------------------------------------
# keel_field <dotted.path>  — echoes the value or empty string.
# JSON is passed via env (KEEL_JSON) so the heredoc can own stdin for the script.
keel_field() {
  KEEL_PATH="$1" KEEL_JSON="$KEEL_INPUT" python3 <<'PY'
import json, os, sys
try:
    data = json.loads(os.environ.get("KEEL_JSON", "") or "{}")
except Exception:
    print(""); sys.exit(0)
cur = data
for part in os.environ["KEEL_PATH"].split("."):
    if isinstance(cur, dict) and part in cur:
        cur = cur[part]
    else:
        print(""); sys.exit(0)
print(cur if isinstance(cur, str) else json.dumps(cur))
PY
}

keel_event_name() { keel_field "hook_event_name"; }
keel_tool_name()  { keel_field "tool_name"; }
keel_file_path()  {
  local p
  p="$(keel_field "tool_input.file_path")"
  [[ -z "$p" ]] && p="$(keel_field "tool_input.path")"
  echo "$p"
}
keel_transcript() { keel_field "transcript_path"; }
keel_session_id() { keel_field "session_id"; }

# Is the current tool call a file mutation (Edit/Write/MultiEdit/NotebookEdit)?
keel_is_file_mutation() {
  case "$(keel_tool_name)" in
    Edit|Write|MultiEdit|NotebookEdit) return 0 ;;
    *) return 1 ;;
  esac
}

# repo-relative path for a given absolute/any path
keel_relpath() {
  python3 - "$1" "$KEEL_REPO_ROOT" <<'PY'
import os, sys
p, root = sys.argv[1], sys.argv[2]
try:
    print(os.path.relpath(os.path.realpath(p), os.path.realpath(root)))
except Exception:
    print(p)
PY
}

# --- graded outcome: track / warn / block by phase -------------------------
# keel_gate "<rule-id>" "<message>"
#   phase 1 -> log only (allow)   phase 2 -> warn (allow)   phase 3 -> block (exit 2)
keel_gate() {
  local rule="$1"; shift
  local msg="$*"
  case "${KEEL_ENFORCEMENT_PHASE}" in
    1) echo "[keel:track ${rule}] ${msg}" >&2; exit 0 ;;
    2) echo "[keel:WARN ${rule}] ${msg}" >&2; exit 0 ;;
    *) echo "" >&2
       echo "🛑 [keel:BLOCK ${rule}] ${msg}" >&2
       echo "   (To bypass deliberately: file a waiver per core/process/waivers-and-incidents.md," >&2
       echo "    or lower KEEL_ENFORCEMENT_PHASE in .claude/hooks/lib/keel.env if rolling out.)" >&2
       exit 2 ;;
  esac
}

# keel_ok — explicit allow with optional note.
keel_ok() { [[ -n "${1:-}" ]] && echo "[keel:ok] ${1}" >&2; exit 0; }

# keel_log — always-allow breadcrumb.
keel_log() { echo "[keel] $*" >&2; }
