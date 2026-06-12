# Autonomy Tiers

Autonomy tiers decide **when an AI agent (or a junior engineer) may act alone, and when a
human must be in the loop**. They turn "use good judgment" into a mechanical, auditable
rule keyed on *blast radius* and *confidence*.

The thresholds are configuration (`framework.config.yaml`), not dogma. Tune them to your
team's risk appetite.

## The four tiers

| Tier | Confidence | Human involvement | Latency |
|------|-----------|-------------------|---------|
| **1** | ≥ {{TIER1_MIN}} | None — auto-approve | Immediate |
| **2** | {{TIER2_MIN}}–{{TIER1_MIN}} | Batch review (2–3×/day) | Hours |
| **3** | {{TIER3_MIN}}–{{TIER2_MIN}} | Async approval (same-day) | Same-day |
| **4** | < {{TIER3_MIN}} **or** a Tier-4 trigger | Synchronous block | Immediate |

**Approvers:** {{APPROVERS}}.

Confidence is the agent's honest self-assessment of "will this do what's intended without
unintended consequences." It is *not* "how sure am I the code compiles." Over-confidence is
the failure mode; the Tier-4 trigger list exists precisely because confidence is unreliable
for high-blast-radius changes.

## Tier-4 triggers — always block, regardless of confidence

Some changes are high-blast-radius by nature. These **always** require a synchronous human
decision even if the agent is 99% confident:

- Schema drops / destructive migrations
- Authentication / authorization system changes
- API contract **breaking** changes
- Security findings rated Critical or Major
- Production deployments
- Changes spanning multiple architectural {{BOUNDARY_TERM}}s
- Changes to a frozen interface (IR-22)
- Changes to the constitution itself (this directory)
- Cross-team / cross-work-package dependency changes (verify all owners aligned)

> Maintain your Tier-4 trigger list as deliberately as your inviolable rules. Every
> production incident that "an agent shouldn't have done autonomously" is a candidate new
> trigger.

## Confidence calibration (the CoVe habit)

Before claiming a tier, the agent runs a lightweight **Chain-of-Verification**:

1. State the change and its intended effect in one sentence.
2. List what could break (callers, data, contracts, tenants).
3. State how each was checked (test, grep, read).
4. *Then* assign confidence. Unverifiable item ⇒ cap confidence below Tier 1.

This is cheap and catches the "looks right" trap. The delivery record
(`core/templates/delivery-record-template.md`) captures the result.

## Escalation format

When blocking at Tier 3/4, the agent presents — not a yes/no, but a *decision*:

```
ESCALATION — Tier {3|4}
Change:        <one line>
Why blocked:   <trigger or confidence reason>
Options:       A) <recommended> — <tradeoff>
               B) <alternative> — <tradeoff>
Recommendation: A, because <reason>
Reversibility: <easy | hard | irreversible>
```

Give the human a decision to make, not a problem to solve.

## Where tiers are enforced

- **Pre-action:** the agent self-classifies and blocks itself at Tier 4 (session protocol
  skill).
- **Mechanical backstop:** hooks block specific Tier-4 surfaces (schema, auth, frozen
  interfaces, constitution edits) regardless of what the agent believes.
- **Review:** the review framework requires Tier-4 changes to carry an approver sign-off
  before merge.
