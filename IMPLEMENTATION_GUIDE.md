# Keel — Implementation Guide

How to adopt {{FRAMEWORK_NAME}} in a repository, tune it to your team, and operate it over
time. Read `README.md` first for the mental model; this is the *how*.

The golden rule of adoption: **roll out enforcement in phases.** A team that gets 24
blocking gates on day one will route around them. A team that sees the gates *track* for a
week, then *warn* for a week, then *block*, internalizes them. The framework is built for
this — every hook grades its own behavior from a single config line.

---

## Part 1 — Install (30 minutes)

### 1.1 Prerequisites
- `bash` + `python3` (installer and hooks; no third-party Python packages).
- Git. If using the Claude Code adapter: Claude Code.
- Your target repo, on a feature branch (don't install onto `{{DEFAULT_BRANCH}}` directly).

### 1.2 Configure
```bash
cp framework.config.example.yaml framework.config.yaml
$EDITOR framework.config.yaml
```
Set, at minimum:
- `org`, `project`, `default_branch`
- `architecture.boundaries` + `architecture.shared_boundary` — **your** boundaries
  (services, bounded contexts, layers, modules — whatever you call them). This is the most
  important config: the boundary rule (IR-01) and several hooks key off it.
- `adapters.*` — set `true` for the stacks you use.
- `enforcement_phase: 1` — **start at tracking.** Always.

### 1.3 Dry-run, then install
```bash
bash install.sh --target /path/to/repo --config framework.config.yaml --dry-run   # preview
bash install.sh --target /path/to/repo --config framework.config.yaml             # write
```
The installer stamps tokens, writes the core to `.keel/`, the hooks to `.claude/`, the
selected adapters, and the CI workflow. It **never** overwrites a file you've customized
without `--force` (it reports conflicts instead).

### 1.4 Verify it landed
```bash
cd /path/to/repo
cat .claude/CLAUDE.md                 # your stamped master governance doc
cat .claude/hooks/lib/keel.env        # phase = 1
ls  .claude/hooks/                    # the verify-*.sh set
ls  .keel/core/                       # constitution / process / governance / templates
```
Commit this as one reviewable PR titled "Adopt {{FRAMEWORK_NAME}} governance (phase 1:
tracking)".

---

## Part 2 — The phased rollout (4–6 weeks)

Advance by editing **one line** in `.claude/hooks/lib/keel.env`
(`KEEL_ENFORCEMENT_PHASE`). No reinstall.

### Phase 1 — Tracking (week 1)
Hooks log `[keel:track …]` and never block. Goal: **make the gates visible and tune the
heuristics.** Run your normal work; watch which hooks fire and whether they fire correctly.
Tune the repo-specific bits (see Part 3) until the tracking output matches reality — false
positives now are free; false positives at phase 3 are friction.

**Exit criteria:** tracking output is accurate; the team has seen the gates.

### Phase 2 — Soft gates (weeks 2–3)
Hooks warn loudly (`[keel:WARN …]`) but still allow. Goal: **build the habit.** People
start producing specs, delivery records, and knowledge notes because they're being reminded
every time they skip one — without being blocked. Measure how often each gate would have
blocked; a gate that never fires is either perfectly internalized or mis-tuned.

**Exit criteria:** warnings are rare because the habits formed, not because the gates are
broken.

### Phase 3 — Enforcing (week 4+)
Hooks block (exit 2). Goal: **guarantee.** Now the discipline is structural. Turn on the CI
backstop (Part 4) and make it a required check so bypassed hooks still get caught.

> You don't have to advance all hooks together. If one hook's heuristic is still noisy, keep
> the global phase lower and graduate the rest by trimming that hook, or split keel.env
> reads per-hook. Pragmatism over purity.

---

## Part 3 — Tuning to your team (the expected work)

The framework is a *starter*, not a straitjacket. Expect to tune:

### 3.1 The constitution
- **Inviolable rules** (`.keel/core/constitution/inviolable-rules.md`): keep what applies,
  delete what doesn't, add yours via the template. **Single-tenant?** Delete IR-06. **No
  "no-AI-in-runtime" constraint?** Delete IR-21. Aim for a set the team can recite (≤ 25).
- **Autonomy tiers**: set the confidence thresholds and the Tier-4 trigger list to your risk
  appetite (`framework.config.yaml` + `autonomy-tiers.md`).

### 3.2 The hooks (the lines that need your repo's specifics)
Each hook is commented at its tuning points. The usual edits:
- `verify-spec.sh` / `verify-impact-analysis.sh`: the **source-path globs** (what counts as
  production code), the **spec/plan locations** it greps, and the **work-item ID regex**
  (match your `{{FEATURE_ID_PATTERN}}`).
- `verify-delivery.sh`: where delivery records and knowledge notes live.
- `verify-review-approval.sh`: `KEEL_GOVERNANCE_GLOBS` (which paths are governance-recursive)
  and the debate-transcript directory.
- `verify-status-claim.sh`: the test-command patterns for your stack.
- `check-file-length.sh`: `KEEL_MAX_FILE_LINES`.

After editing a hook, smoke-test it (see `examples/`): feed it a known violation and confirm
it tracks/warns/blocks as expected. **A hook that silently passes is worse than no hook.**

### 3.3 The adapters
- Keep only the stacks you use. Set coverage / mutation / CVE thresholds to match the
  constitution (translate the bar, don't lower it).
- The single most important adapter piece is the **boundary test** (ArchUnit /
  eslint-boundaries / import-linter) — it's how IR-01 becomes mechanical in your language.
  Get that wired before phase 3.

### 3.4 Source-of-truth & dashboards (optional but high-value)
If you adopt the "one machine-readable source, everything else rendered" pattern (quality
§6), put your state in one file and generate plans/dashboards from it. Add a CI freshness
check so a stale render fails the build. (This is what keeps governance docs from drifting
into fiction.)

---

## Part 4 — Wire the CI backstop

1. Copy `.keel/ci/governance-verify.yml` → `.github/workflows/governance-verify.yml`
   (adapt for GitLab/Azure if needed).
2. Copy the adapter CI snippet(s) from `.keel/adapters/<stack>/README.md` →
   `.github/workflows/<stack>-verify.yml` and uncomment the matching job in
   `governance-verify.yml`.
3. In branch protection: make `governance-verify` (and the adapter verify jobs) **required
   status checks**, and enable **"require branches up to date before merge."** This is the
   hard gate that closes the loop on bypassed hooks — the merge button stays greyed out
   until the checks pass.

---

## Part 5 — Operating it (ongoing)

- **Run an Ops session on a cadence** (`session-archetypes.md` → Ops): dependency freshness,
  drift, flaky tests, expired waivers. It dispatches findings; it doesn't fix them inline.
- **Every incident hardens the framework** (`waivers-and-incidents.md`): the post-mortem's
  output is a new rule / hook / Tier-4 trigger, not just a fix. This is how the constitution
  becomes the compiled memory of what's bitten you.
- **Audit the coverage matrix quarterly** (`control-coverage-matrix.md`): confirm each "yes"
  still blocks by running each hook against a known violation. Hooks rot silently.
- **Keep knowledge capture alive**: it's the cheapest high-value habit and the one most
  likely to lapse. The delivery hook checks for it; don't let "no new knowledge" become a
  reflex that hides real lessons.

---

## Part 6 — Upgrading Keel

Local tweaks live in your repo; framework upgrades are a diff you review, never a blind
overwrite:

```bash
# pull a newer framework version, then:
bash install.sh --target /path/to/repo --config framework.config.yaml --dry-run
```
The dry-run reports which bundled files changed and which of yours conflict (you've edited
them). Merge the upstream improvements you want by hand; skip the ones that fight your
customizations. Pin the framework `VERSION` you're on in your repo so the diff is meaningful.

---

## Part 7 — Anti-patterns (how adoptions fail)

- **Big-bang enforcement.** Phase 3 on day one → `--no-verify` everywhere. Always phase in.
- **Hooks that pass silently.** A mis-tuned glob that stops matching gives false assurance.
  Smoke-test, and audit quarterly.
- **A constitution nobody can recite.** 60 rules is a backlog, not a constitution. Cut.
- **Governance docs that drift from reality.** If a doc claims a control that isn't enforced,
  the `control-coverage-matrix.md` must say so honestly. Green that lies is worse than red.
- **Knowledge capture as theater.** Notes that restate git history teach nothing. Capture the
  *non-obvious lesson* or capture nothing (explicitly).
- **Self-approval of governance changes.** The author's context rationalizes its own edit.
  Spawn an independent Critic for governance-recursive changes — it's the whole point of
  Layer 2 review.

---

## Quick reference card

| I want to… | Go to |
|------------|-------|
| Understand the model | `README.md` |
| Know what's non-negotiable | `core/constitution/inviolable-rules.md` |
| Classify a task | `core/process/task-classification.md` |
| Know what blocks autonomously | `core/constitution/autonomy-tiers.md` + `core/governance/change-control-tiers.md` |
| Start/close a session right | `enforcement/claude/skills/session-protocol.md` |
| See what's actually enforced | `core/governance/control-coverage-matrix.md` |
| Tune a hook | `enforcement/hook-coverage-matrix.md` + the hook's comments |
| Add a stack | `adapters/README.md` |
| Add a rule | `core/templates/inviolable-rule-template.md` |
| Change enforcement strength | `.claude/hooks/lib/keel.env` (`KEEL_ENFORCEMENT_PHASE`) |
