# Spec: {Feature title}

- **Work-item ID:** {{PROJECT}}-{AREA}-{NNN}   <!-- must match {{FEATURE_ID_PATTERN}}, IR-02 -->
- **Status:** DRAFT | APPROVED
- **Author:** {name}   ·   **Date:** {YYYY-MM-DD}
- **{{BOUNDARY_TERM}}(s) affected:** {list}
- **Type:** Feature | Enhancement | Integration

## Problem & goal

What user/business problem does this solve? What does success look like? (One paragraph
each. If you can't state the problem, you're not ready to spec the solution.)

## Scope

- **In scope:** …
- **Out of scope:** … (explicit non-goals prevent scope creep)

## Acceptance criteria

Each criterion must be *testable* — something a test or an observation can confirm.

- [ ] AC1 — Given …, when …, then …
- [ ] AC2 — …
- [ ] AC3 — …

## Design

How it works. Key components, data flow, and how it sits within the architecture. Note
which existing patterns/standards it follows.

## Contract impact

- **API:** new/changed endpoints or messages (attach/àlink the contract). Breaking? → **Tier 4.**
- **Schema/data:** new/changed entities, migrations. Destructive? → **Tier 4.**
- **Events/integration:** new producers/consumers; any frozen interface touched (IR-22)?

## Constitution check

- [ ] Stays within {{BOUNDARY_TERM}} boundaries (IR-01).
- [ ] Tenant isolation preserved (IR-06, if applicable).
- [ ] Auth/security surfaces identified and reviewed.
- [ ] No AI in the runtime path (IR-21, if applicable).

## Dependencies

Other work items, teams, or decisions this depends on (and that depend on it).

## Test strategy

What unit/integration/E2E tests prove the acceptance criteria. Note where mutation testing
applies (critical paths).

## Rollout & rollback

How it ships, behind what flag if any, and how to back it out safely.
