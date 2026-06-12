# Change Control Tiers

This document is the operational companion to `../constitution/autonomy-tiers.md`: it maps
*kinds of change* to *who must approve them* and *what mechanical gate enforces it*. Where
autonomy tiers are about agent confidence, change control is about blast radius — the two
combine to decide whether a change flows or blocks.

## The control matrix

| Change | Tier | Approver | Mechanical gate |
|--------|------|----------|-----------------|
| Formatting, comments, docs (non-governance) | 1 | none (auto) | length/lint hooks |
| Bug fix within one {{BOUNDARY_TERM}}, tests included | 1–2 | none / batch | spec + delivery hooks |
| New feature behind existing contract | 2 | batch | spec hook + review |
| New public API / endpoint | 3 | async | API-contract hook + review |
| Schema migration (additive) | 3 | async | migration review |
| Schema drop / destructive migration | **4** | **sync** | migration hook + approver |
| Auth / authz change | **4** | **sync** | security review + approver |
| Breaking API change | **4** | **sync** | API-contract hook + approver |
| Cross-{{BOUNDARY_TERM}} architectural change | **4** | **sync** | architecture-drift hook + approver |
| Frozen-interface change (IR-22) | **4** | **sync** | interface-stability hook |
| Constitution / governance change | **4** | **sync** | review-debate hook (adversarial) |
| Production deployment | **4** | **sync** | deploy gate |
| Critical/Major security finding | **4** | **sync** | security gate (blocks) |

## How an agent uses this

Before acting, the agent matches its change to a row, reads off the tier, and:
- **Tier 1–2:** proceeds, records the classification in the delivery record.
- **Tier 3:** proceeds but flags for async approval; does not merge without it.
- **Tier 4:** **stops** and escalates with the decision format from `autonomy-tiers.md`.
  No Tier-4 surface is touched on confidence alone.

## Keeping the matrix honest

- The matrix is the single place tier assignments live; hooks and review checklists
  reference it rather than re-deciding.
- Every incident post-mortem (`../process/waivers-and-incidents.md`) reviews whether the
  offending change was tiered correctly — if a Sev-1 came from a change tiered too low, the
  row gets promoted.
- New Tier-4 triggers are added deliberately; removing one is itself a Tier-4 decision.
