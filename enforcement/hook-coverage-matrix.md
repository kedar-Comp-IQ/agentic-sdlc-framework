# Hook Coverage Matrix (v1 shipped hooks)

The hooks bundled in this adapter, what each enforces, and what to tune. For the *full*
control→mechanism map (including controls enforced by CI/review rather than hooks), see
`../core/governance/control-coverage-matrix.md`.

| Hook | Event | Rule / principle | What it does | Tune these |
|------|-------|------------------|--------------|-----------|
| `verify-single-session.sh` | UserPromptSubmit, PostToolUse, Stop | session discipline | Per-checkout lock; blocks a 2nd concurrent session | `TTL_SECONDS` |
| `verify-spec.sh` | PreToolUse (Edit/Write) | IR-03 Spec First | Blocks production-source edits with no spec/quick-plan for the branch's work-item ID | source-path globs, spec locations, work-item regex |
| `verify-impact-analysis.sh` | PreToolUse (Edit/Write) | task classification | On fix/bug/hotfix branches, requires a quick-plan + impact analysis | branch prefixes, impact-analysis markers |
| `check-file-length.sh` | PostToolUse (Edit/Write) | quality §5 | Warns/blocks files over the soft line cap | `KEEL_MAX_FILE_LINES`, skip-globs |
| `verify-status-claim.sh` | Stop | quality §1 | Flags "tests pass / done" claims with no test run this session | claim patterns, test-command patterns |
| `verify-review-approval.sh` | Stop | review framework L2 | Requires a fresh, target-associated adversarial-review transcript for governance-recursive edits | `KEEL_GOVERNANCE_GLOBS`, debate dir |
| `verify-delivery.sh` | Stop | IR-20 / DoD | Requires a delivery record + knowledge capture when production source changed | delivery/knowledge locations |
| `verify-architecture-drift.sh` | PostToolUse (Edit/Write) | IR-01 boundary isolation | Scans an edited file's imports for cross-{{BOUNDARY_TERM}} references | `KEEL_BOUNDARIES`, `KEEL_SHARED_BOUNDARY`, import regex |
| `verify-interface-stability.sh` | PreToolUse (Edit/Write) | IR-22 frozen interfaces | Blocks edits to declared frozen-interface files (Tier 4) | `KEEL_FROZEN_INTERFACES` |
| `verify-api-contract.sh` | Stop | IR-04 / IR-14 | Flags removed/renamed contract surface as potentially breaking (Tier 4) unless approved | `KEEL_CONTRACT_GLOBS`, breaking regex, approval marker |

## Phase behavior

All hooks (except single-session collision) grade via `KEEL_ENFORCEMENT_PHASE` in
`claude/hooks/lib/keel.env`:
- **1** → `[keel:track …]` to stderr, allow.
- **2** → `[keel:WARN …]` to stderr, allow.
- **3** → `🛑 [keel:BLOCK …]`, exit 2.

## The expansion set (documented, not shipped in v1)

The source system this was distilled from ran ~24 hooks. **Ten** ship here; the rest are
natural next additions, each following the same `common.sh` contract:

- `verify-security-review` — block close if a changed security surface lacks a review.
- `verify-cross-module-changes` — flag edits spanning {{BOUNDARY_TERM}}s (IR-05).
- `verify-deletion-rationale` — require a reason for deletions.
- `verify-e2e-results` — require E2E evidence for route/endpoint changes.
- `verify-ai-surface-stability` — guard the no-AI-in-runtime boundary (IR-21).

Add them as the team is ready; each is a focused script + one registration line.

## A note on hook rot

A hook that silently exits 0 (because a path glob stopped matching, or a tool changed its
event shape) is *worse than no hook* — it gives false assurance. The quarterly audit
(`control-coverage-matrix.md` §audit) should include running each hook against a known
violation to confirm it still blocks. The bundled `examples/` includes a smoke test pattern
for this.
