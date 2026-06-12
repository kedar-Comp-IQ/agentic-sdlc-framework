# ADR Governance

Architectural decisions are captured as **Architecture Decision Records** — short,
immutable documents that record *what was decided, why, and what was traded away*. ADRs are
the institutional memory that stops an agent (or a new hire) from re-litigating a settled
decision, and the only legitimate way to change the constitution.

## What needs an ADR

- Any change to the constitution (inviolable rules, autonomy tiers, principles)
- Choice of a foundational technology (framework, datastore, deployment model)
- A cross-{{BOUNDARY_TERM}} architectural pattern
- Introducing or freezing an extension-point interface (IR-22)
- Anything Tier 4 that sets a precedent future work will follow

If you're about to make a decision that the next person will have to *discover* by reading
code, write an ADR instead.

## Lifecycle

```
DRAFT ──▶ PROPOSED ──▶ ACCEPTED ──▶ (later) SUPERSEDED / DEPRECATED
   │           │
   └───────────┴──▶ REJECTED
```

- **DRAFT** — being written; not yet up for decision.
- **PROPOSED** — complete, awaiting a decision from the architecture authority.
- **ACCEPTED** — decided and in force. **ACCEPTED ADRs are immutable** — you supersede,
  you don't edit.
- **REJECTED** — considered and declined (kept, so the option isn't re-proposed blindly).
- **SUPERSEDED** — replaced by a newer ADR (which links back).

## Numbering & location

- Sequential, never reused: `ADR-001`, `ADR-002`, …
- One file per ADR in `{{ADR_DIR}}/ADR-{NNN}-{slug}.md`.
- Template: `../templates/ADR-template.md`.

## Authority

Who can move an ADR to ACCEPTED depends on its scope:

| Scope | Authority |
|-------|-----------|
| Technical / process (within the team's mandate) | Tech lead (delegated) |
| Constitution change | Architecture authority |
| Commercial / customer / vendor commitment | Business owner |

Record the delegation explicitly so an agent knows when it may self-approve a technical ADR
vs. when it must escalate. (In the source system, a delegation ADR formalized exactly this:
the tech lead self-approves technical/process ADRs; commercial scope still escalates.)

## ADRs that change the framework itself

An ADR that modifies the governance system (a new inviolable rule, a hook policy, the
review framework) is **governance-recursive** and must pass adversarial review before
ACCEPTED — see `review-framework.md`. The lesson from production: governance changes are
exactly the changes most likely to contain a subtle self-contradiction, so they get the
*most* scrutiny, not the least.

## Citing ADRs

Code comments, rule entries, and hook messages reference the ADR that established them
(`per ADR-017`). This makes the *why* one grep away from the *what*.
