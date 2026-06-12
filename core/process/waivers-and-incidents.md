# Waivers & Incident Management

Two escape valves the framework needs to stay honest: a **waiver** process for
deliberately, temporarily accepting a gate failure, and an **incident** process for when a
constraint is violated in reality.

Without an explicit waiver process, teams suppress findings quietly (a commented-out test,
a blanket suppression file) — which reads as compliance while being its opposite. Without
an incident process, violations get patched without the lesson being captured.

---

## Waivers

A waiver is an **explicit, signed, time-boxed** decision to accept a gate failure or rule
exception. It is never a silent suppression.

### When a waiver is required
- Suppressing a SAST / dependency-scan finding
- Shipping below a coverage or mutation threshold
- A temporary exception to an inviolable rule or standard
- Disabling/skipping a test that should pass

### What a waiver must contain
```
WAIVER-<NNN>
Gate/rule waived:  <ID or check name>
Scope:             <exact files/finding — as narrow as possible>
Reason:            <why accepting this now is correct>
Risk accepted:     <what could go wrong>
Remediation plan:  <how/when it gets fixed>
Expires:           <date — waivers are time-boxed, never permanent>
Approved by:       <Tier-appropriate approver>
```

### Rules
- **Narrowest possible scope.** Waive *this finding in this file*, never a whole category.
- **Time-boxed.** Every waiver expires; an expired waiver re-blocks the gate.
- **Reviewed like code.** Suppression files live in the repo and are reviewed in the PR.
- **Tier-gated.** Waiving a Critical finding or an inviolable rule is Tier 4.
- **Tracked.** Each waiver has an ID and a follow-up item for its remediation.

Waivers live in a single ledger (e.g. `{{STANDARDS_DIR}}/../governance/waivers.md`) so the
full set of accepted risk is visible in one place.

---

## Incident Management

An incident is a violation *in reality* — a Sev-1 tenant-isolation breach, a production
outage, a security exposure, a Tier-4 change that shipped without approval.

### Severity
| Sev | Meaning | Response |
|-----|---------|----------|
| **1** | Data exposure, cross-tenant breach, prod down | Immediate, all-hands, synchronous |
| **2** | Major degradation, security finding exploitable | Same-day |
| **3** | Minor degradation, contained | Next business day |

### Flow
1. **Detect & declare** — anyone can declare; err toward declaring.
2. **Contain** — stop the bleeding before diagnosing (revert, disable, isolate).
3. **Diagnose** — root cause via a Troubleshooting session.
4. **Remediate** — fix via classified Build → Quality.
5. **Capture** — a knowledge note (IR-20) and, if the cause was a missing guardrail, a
   new hook / rule / Tier-4 trigger. **An incident that doesn't harden the framework will
   recur.**
6. **Post-mortem** — blameless; the output is system changes, not blame.

### The feedback loop that makes this matter

Every incident is a question: *what mechanical control would have prevented this?* The
answer becomes a new inviolable rule, a new hook, or a new Tier-4 trigger. This is how the
framework gets stronger over time instead of just accumulating war stories — the
constitution and hook set are the **compiled memory of past incidents**.
