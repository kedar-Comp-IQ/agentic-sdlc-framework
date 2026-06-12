# Control Coverage Matrix

The single map of **every governance control → the mechanism that enforces it → where it
runs**. This is the document that answers "is this rule actually enforced, or just written
down?" — and exposes the gaps honestly.

A control with no mechanism is **ASPIRATIONAL**: real intent, no teeth. That's fine as a
stated, visible state; what's not fine is *believing* something is enforced when it isn't.

Legend — **Where:** `in-session` (agent hook, blocks the action) · `commit` (git hook) ·
`CI` (server-side) · `review` (human/Quality gate).

| Control | Source | Mechanism | Where | Blocks? |
|---------|--------|-----------|-------|---------|
| Spec exists before implementation (IR-03) | constitution | `verify-spec` hook | in-session | yes |
| Work-item ID present & unique (IR-02) | constitution | `verify-spec` hook + CI | in-session, CI | yes |
| Boundary isolation (IR-01, IR-12) | constitution | `verify-architecture-drift` + adapter boundary tests | in-session, CI | yes |
| Cross-{{BOUNDARY_TERM}} change flagged (IR-05) | constitution | `verify-cross-module-changes` hook | in-session | warns/blocks |
| API contract stability (IR-04, IR-14) | constitution | `verify-api-contract` hook + review | in-session, review | yes (Tier 4) |
| Frozen interface unchanged (IR-22) | constitution | `verify-interface-stability` hook | in-session | yes (Tier 4) |
| Parameterized queries (IR-10) | constitution | SAST adapter | CI | yes |
| Secrets not in source (IR-19) | constitution | secret-scan hook + CI | commit, CI | yes |
| AI absent from runtime path (IR-21) | constitution | CI grep + `verify-ai-surface-stability` | in-session, CI | yes |
| No mutable global state (IR-07) | constitution | SAST/lint + review | CI, review | yes |
| Audit trail on mutations (IR-08) | constitution | review gate + tests | review | yes |
| Tenant isolation (IR-06) | constitution | review gate + isolation tests | review, CI | yes (Tier 4) |
| Delivery record at close (IR-20 / DoD) | process | `verify-delivery` hook (Stop) | in-session | yes |
| Knowledge captured (IR-20) | process | `verify-delivery` hook (Stop) | in-session | yes |
| No "done" without evidence | quality | `verify-status-claim` hook | in-session | yes |
| File length under cap | quality | `check-file-length` hook | in-session | warns/blocks |
| Impact analysis for fixes | process | `verify-impact-analysis` hook | in-session | yes |
| One session per checkout | process | `verify-single-session` hook | in-session | yes |
| Security review on changed surfaces | security | `verify-security-review` hook + Quality | in-session, review | yes |
| Governance-recursive change debated | governance | `verify-review-approval` (debate) hook | in-session | yes |
| Tier-4 change has approver sign-off | governance | review gate | review | yes |
| Dependency CVEs (≥9.0) blocked | security | dependency-scan adapter | CI | yes |
| License compliance | security | license-check adapter | CI | yes |
| Coverage threshold met | quality | coverage adapter | CI | yes |
| Source-of-truth drift | quality | drift workflow + render check | CI | warns |
| Deletion has rationale | quality | `verify-deletion-rationale` hook | in-session | warns |
| E2E results present for route changes | quality | `verify-e2e-results` hook | in-session | yes |

> The hook names above correspond to the generalized hooks in
> `enforcement/claude/hooks/`. Ten ship in v1 (spec, impact-analysis, interface-stability,
> file-length, architecture-drift, single-session, status-claim, api-contract,
> review-approval, delivery); the remaining rows are enforced by CI/review or documented in
> `enforcement/hook-coverage-matrix.md` as the natural expansion set.

## How to use this matrix

1. **Adoption:** decide which rows you want *on day one* vs. later (phased rollout — see
   `IMPLEMENTATION_GUIDE.md`). Turn rows on by registering the hook / adding the CI job.
2. **Audit:** quarterly, walk the matrix and confirm each "yes" still blocks. Hooks rot;
   a hook that exits 0 unconditionally is worse than no hook (false assurance).
3. **Gap-filling:** every ASPIRATIONAL row is a backlog item. Every incident that slipped
   through is a question of which row was missing or toothless.

## The honesty principle

This matrix is deliberately the place where the framework admits what it *doesn't* yet
enforce. A governance system that overstates its own coverage is more dangerous than one
that's modest about it — because people trust green. Keep this document truthful even when
the truth is "review only, no mechanism yet."
