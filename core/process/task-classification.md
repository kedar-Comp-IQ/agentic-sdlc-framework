# Task Classification

Every piece of work is classified before it starts. Classification is mechanical — it
decides which planning artifact is required and which session flow applies. Get this wrong
and you either over-process a one-line fix or under-process a breaking change.

## The table

| Type | Session flow | Planning artifact | Notes |
|------|--------------|-------------------|-------|
| **Feature** | Plan → Build → Quality | Spec | New capability |
| **Enhancement** | Plan → Build → Quality | Spec | Extends existing capability |
| **New Integration** | Plan → Build → Quality | Spec | New external system/contract |
| **Bug Fix** | Build → Quality | Quick Plan | Impact analysis required |
| **Tech Debt** | Build → Quality | Quick Plan | Impact analysis if architecture changes |
| **Security Patch** | Build → Quality | Quick Plan | Impact analysis + CVE/finding ref |
| **Operational Review** | Ops → (dispatches) | — | Produces classified work items |
| **Troubleshooting** | Troubleshooting | — | Produces diagnosis + knowledge note |
| **Discussion** | Discussion | — | Produces decision / drafted ADR |

## Decision rules

- **Does it add or change observable behavior a user/integrator depends on?** → Feature /
  Enhancement / Integration → **needs a spec**.
- **Is it restoring intended behavior (something is broken)?** → Bug Fix → **quick plan**.
- **Is it improving internals with no behavior change?** → Tech Debt → **quick plan**
  (full impact analysis only if it crosses an architectural boundary).
- **Is it closing a vulnerability?** → Security Patch → **quick plan + finding reference**.
- **Is it "should we…?"** → Discussion. Don't implement to find out; decide first.

## The quick plan (for Bug / Debt / Security)

A quick plan is a tracker issue with an impact analysis — enough to make the change safe
without the ceremony of a full spec:

- Affected {{BOUNDARY_TERM}}(s) and component(s)
- API/contract changes (if any) — if breaking, this is **Tier 4**
- Schema/data changes (if any)
- Dependencies (other work items / teams)
- Rollback plan

Template: `../templates/quick-plan-template.md`.

## When in doubt, classify up

If a "bug fix" turns out to need an API change, it was a Feature wearing a disguise — stop
and get a spec. The cost of re-classifying mid-stream is small; the cost of an unreviewed
breaking change shipped as a "quick fix" is not.

## Enforcement

The `verify-spec` hook reads the work item's class (from the branch name, issue label, or
delivery-record front-matter — configurable) and blocks implementation edits if the required
artifact is absent. The classification itself is recorded in the delivery record.
