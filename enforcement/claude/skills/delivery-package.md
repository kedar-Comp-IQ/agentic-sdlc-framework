# Skill: delivery-package

**Purpose:** produce the delivery record that closes a Build session — the durable evidence
a change met the bar. The `verify-delivery` hook checks for it before close.

## Procedure

1. **Open the template** `.keel/core/templates/delivery-record-template.md`.
2. **Fill the evidence, not the intention.** For each acceptance criterion, cite the test
   name or the observed behavior that proves it — not "should work."
3. **Record the CoVe result:** intended effect, what could break, how each was checked,
   resulting confidence/tier.
4. **State the test reality:** what unit/integration/E2E ran, the result, and coverage on
   changed units. If E2E was skipped, say why (no contract change) — don't omit it.
5. **List follow-ups as tracked items.** Anything deferred gets an ID and an owner. No
   silent TODOs (quality-principles §9).
6. **Link the knowledge notes** captured this session.

## Quality bar for a delivery record

- A reviewer can reconstruct *what changed and why it's safe* from this record alone.
- Every "✅" has evidence next to it.
- The highest tier touched is named, with an approver if Tier 3/4.

## Where it goes

Write it where your `verify-delivery` hook looks (default: an `agent-outputs/` deliveries/
handoffs location, or a delivery-records directory). Keep one record per work item /
session.
