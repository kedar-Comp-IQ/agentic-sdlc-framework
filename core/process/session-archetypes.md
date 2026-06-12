# Session Archetypes

Work happens in **sessions**. Each session has an archetype that determines its purpose,
the skills/lens it operates under, its entry conditions, and its exit gate. Archetypes keep
a session *coherent* — a Plan session plans; it does not quietly start implementing.

There are six. Adapt the names, but keep the separation of *deciding*, *building*, and
*verifying* — collapsing them is how unreviewed code reaches production.

| Archetype | Purpose | Produces | Exit gate |
|-----------|---------|----------|-----------|
| **Plan** | Decide *what* and *how* | Spec, ADR, API contract, schema design | Spec approved; ADRs landed |
| **Build** | Implement + unit-test | Working code, unit/integration tests, delivery record | Tests pass; self-review clean |
| **Quality** | Independently verify | Test report, security review, architecture audit | All gates PASS; no open Critical/Major |
| **Ops** | Keep it healthy | Health checks, drift reports, dependency updates | Dispatches filed for findings |
| **Troubleshooting** | Find root cause | Diagnosis, reproduction, knowledge note | Root cause identified or escalated |
| **Discussion** | Think before committing | Decision input, research, options | Decision recorded or ADR drafted |

---

## Plan
Entry: a classified Feature/Enhancement/Integration. Plan produces the artifacts the Build
session is checked against. **A Plan session never implements** — if it's writing
production code, it has drifted into Build without the exit gate. Architectural decisions
become ADRs (`../governance/adr-governance.md`).

## Build
Entry: an approved spec (or quick plan for fixes). Build implements against the
constitution and standards, writes tests as part of the change (not after), self-reviews
(SDLC gate Step 3.5), and writes a delivery record. Backend route/endpoint changes trigger
the integration/E2E requirement.

## Quality
Entry: a Build session's output. Quality is the **independent** verification pass —
deliberately separate from Build so the author isn't the only one who checked. It runs:
- **Code review** (correctness, standards, boundaries)
- **Security review** (the gate in `../constitution/security-principles.md`)
- **Architecture audit** (no boundary violations, IR-01/IR-12)
- **Test verification** (suite green, coverage met, E2E where required)

Verdicts are recorded with a token (PASS / PASS-WITH-FOLLOWUPS / CONCERN). An open Blocker
or Critical/Major finding forces CONCERN and blocks sign-off.

## Ops
Runs on a cadence (e.g. weekly). Checks health across domains: dependency freshness,
security advisories, drift between source-of-truth and reality, flaky tests. It does not
fix — it **dispatches** findings as classified work items to Build/Quality.

## Troubleshooting
Entry: an incident or a bug needing investigation. Output is a root cause and a knowledge
note — even if the fix lands in a later Build session. The discipline: reproduce, isolate,
explain, *then* fix.

## Discussion
Strategy, brainstorming, research, option analysis. No code. Output is a recorded decision
or a drafted ADR. Use it to *avoid* premature implementation, not to defer forever.

---

## Why archetypes matter for AI agents

A human naturally knows "I'm in design mode, I shouldn't be merging to main." An agent
doesn't — it will happily slide from planning into implementing into self-approving in one
unbroken motion. Archetypes + their exit gates put a **seam** between those modes that a
hook can enforce (e.g. a Plan session that tries to edit production code, or a Build session
that tries to self-sign-off the Quality gate, gets blocked).

## One session, one checkout, one branch

**Never run two agent sessions in the same working copy.** Parallel initiatives each get
their own checkout/worktree. Two sessions sharing a working tree corrupt each other's
branch state and tangle the close-gate. This is enforced by the single-session hook
(`verify-single-session`), which writes a per-checkout lock on the first action and refuses
a second concurrent session. See the enforcement README for the worktree workflow.
