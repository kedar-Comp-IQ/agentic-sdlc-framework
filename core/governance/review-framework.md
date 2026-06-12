# Review Framework

How changes get reviewed — by whom, against what, and with what verdict. The framework
distinguishes **ordinary review** (most changes) from **adversarial review** (changes that
modify the governance system itself), because the second category has a failure mode the
first doesn't: a plausible-looking change that quietly breaks the rules' own logic.

---

## Layer 1 — Ordinary review

Every change gets a code review against:
- **Correctness** — does it do what the spec/quick-plan says, with evidence?
- **Constitution** — does it honor the inviolable rules and boundaries?
- **Standards** — does it match the stack adapter's coding/API/testing standards?
- **Tests** — are they present, meaningful, and passing?

### Verdict tokens
| Token | Meaning | Can it merge? |
|-------|---------|---------------|
| **PASS** | Meets the bar | Yes |
| **PASS-WITH-FOLLOWUPS** | Meets the bar; non-blocking improvements filed as tracked items | Yes |
| **CONCERN** | An open Blocker or Critical/Major finding | **No** — resolve or formally waive first |

Verdict coherence is a rule, not a vibe: an **open Blocker forces CONCERN** even if
everything else passes. (Production lesson: PASS-WITH-FOLLOWUPS is only legitimate for open
*non-blocking* items; reaching for it to wave through an open Blocker is the most common
review-integrity failure.)

---

## Layer 2 — Adversarial review (governance-recursive changes)

When a change edits the governance system itself — an inviolable rule, a hook, the autonomy
tiers, this framework — ordinary review isn't enough, because the author and reviewer can
share the same blind spot about the system's own logic. These changes run an **adversarial
debate** before they land:

```
Author  — states the change and the case for it.
Critic  — an INDEPENDENT reviewer whose job is to find the flaw, the
          contradiction, the case the change breaks. Argues to reject.
Judge   — weighs both and rules, citing specifics.
```

The discipline that makes this work:
- **The Critic must be genuinely independent.** In an agentic setup, spawn a *separate*
  agent/context for the Critic — do not let the author "self-synthesize" the critique.
  (Production lesson: a spawned independent Critic caught 14 real defects, including 4
  major, that an inline self-review had missed — the author's context recalls its own
  reasoning and rationalizes it.)
- **The debate is recorded** as a transcript artifact linked to the change.
- **Default to skepticism.** The Critic argues for rejection; the change must *survive*,
  not merely be plausible.

### Why governance-recursive changes get the most scrutiny
A bug in feature code breaks a feature. A bug in a *rule* or a *hook* silently breaks the
enforcement of everything that rule governs — and does so invisibly, because the gate keeps
reporting green. The blast radius is the whole system. Hence: the changes most likely to be
waved through as "just a doc edit" get the deepest review.

### Mechanical enforcement
The `verify-review-approval` (a.k.a. review-debate) hook detects edits to governance-marked
paths and blocks session close unless a fresh, correctly-associated debate transcript
exists for the change. Two failure modes the production system learned to guard against:
1. **Staleness** — the transcript must post-date the change (mtime/commit check), or a hook
   will pass an old debate against new content. Write the debate *after* the change, or
   re-verify.
2. **Association** — the transcript must explicitly name its target (`**Target:** <path>`),
   or the hook can't link debate to artifact and falls back to "no debate found."

---

## Who reviews what

| Change class | Reviewer | Gate |
|--------------|----------|------|
| Ordinary code | Peer / Quality session | Layer 1 |
| Tier-4 (schema, auth, breaking API, cross-boundary) | Approver sign-off | Layer 1 + explicit approval |
| Governance-recursive | Independent Critic + Judge | Layer 1 + Layer 2 debate |
| Security-sensitive surface | Security review | Security gate (see security-principles.md) |
