# Inviolable Rules

These are the rules that must **never** be violated in {{PROJECT}}. They are mechanically
enforced wherever possible (see the *Enforcement* column and
`enforcement/hook-coverage-matrix.md`). Changing this document requires an ADR
(`core/governance/adr-governance.md`) — it redefines the meaning of every artifact.

> **How to use this file:** the rules below are a *starter set* generalized from a
> production system. Keep the ones that apply, delete the ones that don't, and add your
> own using `core/templates/inviolable-rule-template.md`. Rules that are intrinsically
> language-specific live in the stack adapters, not here. Aim for **a number you can
> recite** — 15-25 rules. A constitution nobody can hold in their head isn't a
> constitution, it's a backlog.

Each rule has a stable ID (`IR-NN`). IDs are never reused. Hooks, CI checks, and review
comments cite rules by ID.

---

## Category A — Architecture & Boundaries

### IR-01 — Boundary Isolation
Every source file belongs to exactly one {{BOUNDARY_TERM}} ({{BOUNDARIES}}). No
{{BOUNDARY_TERM}} imports another {{BOUNDARY_TERM}}'s internal/domain code. The only
cross-importable {{BOUNDARY_TERM}} is `{{SHARED_BOUNDARY}}` (shared utilities).
**Enforcement:** architecture-drift hook + adapter boundary tests (e.g. ArchUnit) + CI.

### IR-02 — Work-Item ID Uniqueness
Every tracked unit of work has a unique ID matching `{{FEATURE_ID_PATTERN}}`. No duplicate
IDs; IDs are greppable across the repo and the tracker.
**Enforcement:** spec hook (rejects missing/duplicate IDs) + CI.

### IR-03 — Spec First
Features, enhancements, and new integrations cannot proceed without an approved spec in
the designated specs location. Bugs/debt/security fixes use a quick plan instead (see
`core/process/task-classification.md`).
**Enforcement:** `verify-spec` hook (blocks implementation edits without a spec/quick-plan).

### IR-04 — API Contract Stability
Public API contracts are immutable within a version. Breaking changes require a new
version; old versions are deprecated with notice, not removed. Frontend and backend are
independently versioned; no client reaches around the contract.
**Enforcement:** API-contract hook (diffs the contract file) + review gate. **Tier 4.**

### IR-05 — Module/Service Cohesion
All code for one logical unit lives under that unit's directory. One unit = one
deployment/ownership boundary. No "misc" or "common dumping ground" outside
`{{SHARED_BOUNDARY}}`.
**Enforcement:** cross-module-change hook (flags edits spanning units) + review.

---

## Category B — Data Integrity & Multi-tenancy

> Keep IR-06 only if you are multi-tenant. If single-tenant, delete it and renumber
> nothing (IDs are stable — just mark it `RETIRED`).

### IR-06 — Tenant Isolation by Construction
Every tenant-scoped data access happens inside a boundary that constrains it to the
caller's tenant (e.g. a per-tenant schema / row-security context), not a hand-written
`WHERE tenant_id = ?`. Cross-tenant access is a boundary violation and a Sev-1 incident,
not a query bug.
**Enforcement:** review gate + integration tests asserting isolation. **Tier 4.**

### IR-07 — No Mutable Global State
Request-handling components are stateless. No `static`/module-global fields holding
request- or tenant-scoped data. Context flows explicitly (request attributes, params).
**Enforcement:** SAST/lint rule + review.

### IR-08 — Audit Trail on Mutations
Every data-modifying operation records `{timestamp, actor, tenant, action, resource,
before/after}` to an append-only audit sink. Security review verifies presence.
**Enforcement:** review gate + test assertion.

### IR-09 — Transactions at the Seam
Multi-step operations are atomic — wrapped in a transaction at the correct boundary with
an explicit isolation level. No partial state visible to concurrent callers.
**Enforcement:** review gate + adapter standard.

### IR-10 — Parameterized Queries Only
Every query uses parameter binding. String-interpolated SQL/NoSQL/command strings are
forbidden anywhere user-influenced data can reach.
**Enforcement:** SAST (e.g. FindSecBugs/bandit/eslint-security) — blocks on detection.

### IR-11 — Explicit Referential Behavior
Every foreign key / relationship declares its cascade/restrict behavior explicitly and
documents the rationale in the schema design.
**Enforcement:** schema-design review gate.

---

## Category C — Layering & Errors

### IR-12 — Layered Responsibility
Transport/route layer holds no business logic; service layer holds no data-access; the
data layer holds all persistence. (Adapt the layer names to your architecture.)
**Enforcement:** architecture-drift hook + review.

### IR-13 — Clear Error Boundaries
Each layer translates errors appropriately: transport maps domain errors to protocol
status codes; services raise domain errors; the data layer raises storage errors. No raw
stack traces or storage errors leak to clients.
**Enforcement:** review gate + contract tests.

---

## Category D — API Discipline

### IR-14 — Versioned, Immutable APIs
Version lives in the path (`/v1/...`). Breaking change = new version. Deprecation notice
precedes removal.
**Enforcement:** API-contract hook. **Tier 4 for breaking changes.**

### IR-15 — Stable REST/RPC Contracts
Verbs map to semantics (create/replace/modify/delete/read) consistently; idempotency
honored where the protocol requires it; response shapes documented in the contract file.
**Enforcement:** contract tests + review.

### IR-16 — Pagination & Bounded Responses
Every collection endpoint bounds its output (limit + offset/cursor) with a stable sort.
No unbounded list responses.
**Enforcement:** contract review + test.

---

## Category E — Security

### IR-17 — Strong Asymmetric Auth Tokens
Auth tokens use asymmetric signing (e.g. RS256/EdDSA); private keys live in a secrets
manager/HSM; public keys are published. No shared-secret/symmetric tokens for
cross-service auth.
**Enforcement:** security review + config check. **Tier 4 to change.**

### IR-18 — Transport Encryption Everywhere
All endpoints — including internal — are encrypted in transit (TLS 1.2+). No plaintext
fallback. Certificate validation enforced.
**Enforcement:** security review + deployment config check.

### IR-19 — Secrets Never in Source
No credentials, keys, or tokens committed to the repo. Secrets come from a manager at
runtime.
**Enforcement:** secret-scanning hook + CI (e.g. detect-secrets/gitleaks) — blocks commit.

---

## Category F — Process Integrity

### IR-20 — Knowledge Capture is Mandatory
Every session that produces a fix, an insight, or a design decision captures it as a
knowledge note (`core/templates/knowledge-note-template.md`). The lesson, not the event.
**Enforcement:** delivery hook (Stop) checks for capture before session close.

### IR-21 — AI Stays in the Build Realm
*(Keep this if you have a "no AI in the critical execution path" constraint — e.g. for
determinism, compliance, or IP reasons.)* No LLM/agent calls in the production execution
path ({{PROJECT}}'s runtime transaction path). AI assists at design/build time only.
**Enforcement:** CI grep over runtime packages + AI-surface-stability hook. **Tier 4.**

### IR-22 — Frozen Interfaces Stay Frozen
Designated extension-point interfaces (the ones a future swap depends on) never change
their call sites. Swapping the implementation must require zero call-site refactoring.
Any change to a frozen interface is **Tier 4**.
**Enforcement:** interface-stability hook (e.g. event-publisher-stability) + review.

---

## Adding, retiring, and citing rules

- **Add:** copy `core/templates/inviolable-rule-template.md`, assign the next free `IR-NN`,
  name an enforcement mechanism (or mark it explicitly `ASPIRATIONAL` until one exists),
  land it via ADR.
- **Retire:** mark the rule `RETIRED (ADR-NNN)`. Never delete the ID or reuse it.
- **Cite:** hooks, CI failures, and review comments reference rules by ID so violations are
  unambiguous and greppable.
