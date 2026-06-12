# The SDLC Gate

The SDLC gate is the single decision point every piece of work passes through **before
implementation starts**. It answers three questions mechanically:

1. **What kind of work is this?** → `task-classification.md`
2. **What must exist before I write code?** → a spec or a quick plan
3. **What must exist before I claim done?** → a delivery record + knowledge capture

The gate is enforced by hooks: the `verify-spec` hook blocks implementation edits when the
required planning artifact is missing; the `verify-delivery` hook blocks session close when
the delivery record or knowledge capture is missing.

---

## Step 1 — Classify

Determine the work type (Feature / Enhancement / Integration / Bug / Tech-Debt /
Security / Ops / Troubleshooting / Discussion). See `task-classification.md` for the full
table and decision rules. Classification decides which planning artifact is required.

## Step 2 — Plan to the right depth

| If the work is… | You need… | Where it lives |
|-----------------|-----------|----------------|
| Feature / Enhancement / Integration | An **approved spec** (`feature-spec-template.md`) | specs location |
| Bug / Tech-Debt / Security fix | A **quick plan** with impact analysis (`quick-plan-template.md`) | tracker issue |
| Ops / Troubleshooting / Discussion | Neither (but capture knowledge) | — |

A spec is not bureaucracy — it is the contract the implementation is checked against. The
quick plan is its lightweight cousin: affected {{BOUNDARY_TERM}}s, contract/schema changes,
dependencies, rollback plan. Both name the work-item ID (IR-02).

## Step 3 — Implement against the constitution

During implementation the agent continuously self-checks against:
- the inviolable rules (`../constitution/inviolable-rules.md`)
- the relevant standards (the stack adapter)
- the autonomy tiers (block at Tier 4)

### Step 3.5 — Self-review before declaring done

Before writing a delivery record, the agent reviews its own diff against the three standards
docs (coding, API, testing for the stack) and the inviolable rules. This is the cheap pass
that catches the obvious before a human or a review gate does.

## Step 4 — Deliver

Complete a **delivery record** (`delivery-record-template.md`): what changed, what was
verified and how, which rules/tiers applied, what follow-ups were filed. This is the
durable evidence the change met the bar.

## Step 5 — Capture knowledge

Every fix, insight, or decision becomes a knowledge note (IR-20). Capture the *lesson*
(why it was non-obvious), not the event.

## Step 6 — Gate close

The Stop/delivery hook verifies the mechanical parts (delivery record present, knowledge
captured, no unresolved Tier-4 block) before the session can close cleanly.

---

## The gate as a state machine

```
classify ─▶ plan (spec | quick-plan) ─▶ implement ─▶ self-review
                                                          │
                                                          ▼
                                   deliver (record) ─▶ capture ─▶ close-gate
```

Each arrow has a hook or a review gate behind it. The point of the gate isn't ceremony —
it's that **no step can be silently skipped**, because skipping it trips a mechanical
check, not a human's memory.
