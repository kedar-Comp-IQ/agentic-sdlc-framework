# Skill: sdlc-gate

**Purpose:** classify a unit of work and enforce that the right planning artifact exists
before implementation. This is the in-session companion to
`.keel/core/process/sdlc-gate.md`.

## Procedure

1. **Classify** (`task-classification.md`):
   - Adds/changes observable behavior → Feature/Enhancement/Integration → **spec required**.
   - Restores intended behavior → Bug → **quick plan**.
   - Internal-only improvement → Tech Debt → **quick plan** (impact analysis if it crosses
     a boundary).
   - Closes a vulnerability → Security → **quick plan + finding ref**.
   - "Should we…?" → Discussion (decide before implementing).

2. **Check the artifact exists and is approved.**
   - Spec: `.keel/core/templates/feature-spec-template.md` → lives in your specs location,
     references the work-item ID (IR-02), has testable acceptance criteria.
   - Quick plan: `.keel/core/templates/quick-plan-template.md` → impact analysis +
     rollback.
   - If missing: **create it (Plan)** or **stop and request it** — do not start
     implementing. (`verify-spec` / `verify-impact-analysis` hooks will block you anyway.)

3. **Tier-check the change** against `change-control-tiers.md`. Tier 4 → escalate now.

4. **Implement → self-review (Step 3.5)** against coding/API/testing standards + inviolable
   rules before declaring done.

## When the gate blocks you

A hook blocking you is the gate working. The fix is almost never to bypass it — it's to
produce the missing artifact. If the block is genuinely wrong (false positive), file a
narrow, time-boxed waiver (`waivers-and-incidents.md`) or correct the hook's heuristic;
don't disable the gate.
