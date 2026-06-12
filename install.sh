#!/usr/bin/env bash
# ===========================================================================
# Keel governance framework — installer / scaffolder
# ===========================================================================
# Stamps the framework into a target repository with token substitution and
# adapter selection. Idempotent-ish: re-running diffs against what's there and
# skips identical files; it never silently clobbers a file you've edited unless
# you pass --force.
#
# Usage:
#   bash install.sh --target <repo-dir> [--config framework.config.yaml]
#                   [--dry-run] [--force] [--phase N]
#
# Examples:
#   bash install.sh --target ../atlas --config framework.config.yaml --dry-run
#   bash install.sh --target ../atlas --config framework.config.yaml
#
# Requires: bash + python3 (no third-party Python packages needed).
# ===========================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TARGET=""
CONFIG="${HERE}/framework.config.yaml"
DRY_RUN="false"
FORCE="false"
PHASE_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)  TARGET="$2"; shift 2 ;;
    --config)  CONFIG="$2"; shift 2 ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --force)   FORCE="true"; shift ;;
    --phase)   PHASE_OVERRIDE="$2"; shift 2 ;;
    -h|--help)
      grep -E '^#( |$)' "${BASH_SOURCE[0]}" | sed -E 's/^# ?//'; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "ERROR: --target <repo-dir> is required." >&2; exit 1
fi
if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: config not found: $CONFIG" >&2
  echo "       cp framework.config.example.yaml framework.config.yaml and edit it." >&2
  exit 1
fi
mkdir -p "$TARGET"

export KEEL_HERE="$HERE" KEEL_TARGET="$TARGET" KEEL_CONFIG="$CONFIG"
export KEEL_DRY_RUN="$DRY_RUN" KEEL_FORCE="$FORCE" KEEL_PHASE_OVERRIDE="$PHASE_OVERRIDE"

python3 - <<'PYEOF'
import os, sys, re, hashlib, shutil

HERE   = os.environ["KEEL_HERE"]
TARGET = os.environ["KEEL_TARGET"]
CONFIG = os.environ["KEEL_CONFIG"]
DRY    = os.environ["KEEL_DRY_RUN"] == "true"
FORCE  = os.environ["KEEL_FORCE"] == "true"
PHASE_OVERRIDE = os.environ.get("KEEL_PHASE_OVERRIDE", "")

# --- Minimal YAML reader (no PyYAML dependency) --------------------------
# Handles the flat-ish structure of framework.config.yaml: scalars,
# one level of nesting, and simple "- item" lists. Good enough for this file;
# not a general YAML parser.
def strip_inline_comment(v):
    v = v.strip()
    if not v:
        return v
    if v[0] in ('"', "'"):
        q = v[0]
        end = v.find(q, 1)
        return v[1:end] if end != -1 else v[1:]
    if v[0] == "#":                  # comment-only value (e.g. a key introducing a list)
        return ""
    hp = v.find(" #")
    if hp != -1:
        v = v[:hp]
    return v.strip().strip('"').strip("'")

def load_config(path):
    # Tokenize into (indent, stripped-line), dropping blanks/comments.
    lines = []
    with open(path) as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            if not line.strip() or line.strip().startswith("#"):
                continue
            indent = len(line) - len(line.lstrip(" "))
            lines.append((indent, line.strip()))

    root = {}
    stack = [(-1, root)]                      # (indent, container-dict)
    def parent_for(indent):
        while len(stack) > 1 and stack[-1][0] >= indent:
            stack.pop()
        return stack[-1][1]

    n, idx = len(lines), 0
    while idx < n:
        indent, s = lines[idx]
        if s.startswith("- "):                # stray list item (already consumed below)
            idx += 1; continue
        key, _, val = s.partition(":")
        key = key.strip()
        val = strip_inline_comment(val) if val.strip() else ""
        parent = parent_for(indent)
        if val == "":
            j = idx + 1
            if j < n and lines[j][0] > indent and lines[j][1].startswith("- "):
                # a list: consume contiguous "- " items at that deeper indent
                child_indent, lst = lines[j][0], []
                while j < n and lines[j][0] == child_indent and lines[j][1].startswith("- "):
                    lst.append(strip_inline_comment(lines[j][1][2:]))
                    j += 1
                parent[key] = lst
                idx = j
                continue
            # otherwise a nested mapping
            child = {}
            parent[key] = child
            stack.append((indent, child))
            idx += 1
        else:
            if val.lower() in ("true", "false"):
                val = (val.lower() == "true")
            parent[key] = val
            idx += 1
    return root

cfg = load_config(CONFIG)

def g(path, default=""):
    cur = cfg
    for part in path.split("."):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            return default
    return cur

# --- Build the token map -------------------------------------------------
boundaries = g("architecture.boundaries", []) or []
boundaries_md = ", ".join(f"`{b}`" for b in boundaries) if boundaries else "`<list your boundaries>`"
approvers = g("autonomy.approvers", []) or []
approvers_md = ", ".join(approvers) if approvers else "Lead Engineer, Repo Owner"

TOKENS = {
    "ORG":             g("org", "Your Org"),
    "PROJECT":         g("project", "YourProject"),
    "FRAMEWORK_NAME":  g("framework_name", "Keel"),
    "DEFAULT_BRANCH":  g("default_branch", "main"),
    "AGENTIC_TOOL":    g("agentic_tool", "Claude Code"),
    "BOUNDARY_TERM":   g("architecture.boundary_term", "module"),
    "BOUNDARIES":      boundaries_md,
    "BOUNDARIES_RAW":  " ".join(boundaries) if boundaries else "",
    "SHARED_BOUNDARY": g("architecture.shared_boundary", "platform"),
    "FEATURE_ID_PATTERN": g("feature_id_pattern", "{PROJECT}-{AREA}-{NNN}"),
    "TIER1_MIN":       str(g("autonomy.tier1_auto_approve_min", "0.85")),
    "TIER2_MIN":       str(g("autonomy.tier2_batch_min", "0.70")),
    "TIER3_MIN":       str(g("autonomy.tier3_async_min", "0.50")),
    "APPROVERS":       approvers_md,
    "MAX_FILE_LINES":  str(g("max_file_lines", "600")),
    "ADR_DIR":         g("adr_dir", "docs/decisions"),
    "KNOWLEDGE_DIR":   g("knowledge_dir", "docs/knowledge/notes"),
    "STANDARDS_DIR":   g("standards_dir", "docs/standards"),
}
phase = PHASE_OVERRIDE or str(g("enforcement_phase", "1"))
TOKENS["ENFORCEMENT_PHASE"] = phase

token_re = re.compile(r"\{\{([A-Z0-9_]+)\}\}")
def substitute(text):
    # Multi-pass so a token whose value contains another token still resolves
    # (e.g. FEATURE_ID_PATTERN embedding {{PROJECT}}). Capped to avoid loops.
    for _ in range(5):
        new = token_re.sub(lambda m: TOKENS.get(m.group(1), m.group(0)), text)
        if new == text:
            break
        text = new
    return text

# --- Decide which source trees to copy and where they land ---------------
# (source-rel-dir, target-rel-dir). Adapters added conditionally below.
PLAN = [
    ("core",                  ".keel/core"),
    ("enforcement/claude/hooks",  ".claude/hooks"),
    ("enforcement/claude/skills", ".claude/skills"),
    ("ci",                    ".keel/ci"),
]
# Single-file, special-destination items.
SINGLE = [
    ("enforcement/claude/CLAUDE.md.template", ".claude/CLAUDE.md"),
    ("enforcement/claude/settings.json.template", ".claude/settings.json"),
    ("IMPLEMENTATION_GUIDE.md", ".keel/IMPLEMENTATION_GUIDE.md"),
    ("README.md", ".keel/README.md"),
    ("VERSION", ".keel/VERSION"),
    ("enforcement/README.md", ".keel/enforcement/README.md"),
    ("enforcement/hook-coverage-matrix.md", ".keel/enforcement/hook-coverage-matrix.md"),
]
ADAPTER_MAP = {
    "java_spring":     ("adapters/java-spring",     ".keel/adapters/java-spring"),
    "node_typescript": ("adapters/node-typescript", ".keel/adapters/node-typescript"),
    "python":          ("adapters/python",          ".keel/adapters/python"),
}
for key, (src, dst) in ADAPTER_MAP.items():
    if g(f"adapters.{key}", False) is True:
        PLAN.append((src, dst))

# Files that are templates whose .template suffix should be stripped on write.
def dest_name(name):
    return name[:-len(".template")] if name.endswith(".template") else name

# --- Copy engine ---------------------------------------------------------
written, skipped, conflicts = [], [], []

def emit(src_abs, dst_abs):
    is_text = True
    try:
        with open(src_abs, "r", encoding="utf-8") as fh:
            content = fh.read()
    except (UnicodeDecodeError, ValueError):
        is_text = False
    if is_text:
        content = substitute(content)
        data = content.encode("utf-8")
    else:
        with open(src_abs, "rb") as fh:
            data = fh.read()
    if os.path.exists(dst_abs):
        with open(dst_abs, "rb") as fh:
            existing = fh.read()
        if hashlib.sha256(existing).digest() == hashlib.sha256(data).digest():
            skipped.append(dst_abs); return
        if not FORCE:
            conflicts.append(dst_abs); return
    if not DRY:
        os.makedirs(os.path.dirname(dst_abs), exist_ok=True)
        with open(dst_abs, "wb") as fh:
            fh.write(data)
        # preserve executable bit for shell scripts
        if dst_abs.endswith(".sh"):
            os.chmod(dst_abs, 0o755)
    written.append(dst_abs)

def walk_copy(src_rel, dst_rel):
    src_root = os.path.join(HERE, src_rel)
    if not os.path.isdir(src_root):
        return
    for dirpath, _dirs, files in os.walk(src_root):
        for f in files:
            src_abs = os.path.join(dirpath, f)
            rel = os.path.relpath(src_abs, src_root)
            rel = os.path.join(os.path.dirname(rel), dest_name(os.path.basename(rel)))
            dst_abs = os.path.join(TARGET, dst_rel, rel)
            emit(src_abs, dst_abs)

for src_rel, dst_rel in PLAN:
    walk_copy(src_rel, dst_rel)
for src_rel, dst_rel in SINGLE:
    src_abs = os.path.join(HERE, src_rel)
    if os.path.isfile(src_abs):
        emit(src_abs, os.path.join(TARGET, dst_rel))

# --- Report --------------------------------------------------------------
mode = "DRY-RUN (nothing written)" if DRY else "INSTALLED"
print(f"\n=== Keel installer — {mode} ===")
print(f"  target:   {TARGET}")
print(f"  config:   {CONFIG}")
print(f"  project:  {TOKENS['PROJECT']}  (org: {TOKENS['ORG']})")
print(f"  phase:    {phase}  (1=tracking, 2=soft gates, 3=full blocking)")
adapters_on = [k for k in ADAPTER_MAP if g(f'adapters.{k}', False) is True]
print(f"  adapters: {', '.join(adapters_on) if adapters_on else '(none — generic core only)'}")
print(f"\n  files to write: {len(written)}   identical (skipped): {len(skipped)}")
if conflicts:
    print(f"\n  !! {len(conflicts)} file(s) differ from the bundle and were NOT overwritten")
    print(f"     (you've customized them). Re-run with --force to overwrite, or merge by hand:")
    for c in conflicts[:20]:
        print(f"       - {os.path.relpath(c, TARGET)}")
    if len(conflicts) > 20:
        print(f"       ... and {len(conflicts)-20} more")
if DRY:
    print("\n  Files that WOULD be written:")
    for w in written:
        print(f"       + {os.path.relpath(w, TARGET)}")
print("\nNext: read <target>/.keel/IMPLEMENTATION_GUIDE.md and <target>/.claude/CLAUDE.md")
print("Then advance enforcement_phase in framework.config.yaml as the team is ready.\n")
PYEOF
