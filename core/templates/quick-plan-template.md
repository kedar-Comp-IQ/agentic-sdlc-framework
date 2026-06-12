# Quick Plan: {Bug / Debt / Security fix title}

> For Bug / Tech-Debt / Security work. Lighter than a spec, but enough to make the change
> safe. File this as the tracker issue body before implementation (SDLC gate Step 2).

- **Work-item ID:** {{PROJECT}}-{AREA}-{NNN}
- **Type:** Bug | Tech Debt | Security Patch
- **Severity / Tier:** {Sev 1–3 / Tier 1–4}
- **Reference:** {bug report / CVE / finding ID}

## What's wrong

The observed behavior vs. the intended behavior. For security: the vulnerability and its
impact. Include a reproduction if there is one.

## Root cause

Why it happens (one or two sentences). If unknown, this is a Troubleshooting session first.

## Fix approach

What you'll change and why this is the right fix (not just a symptom patch).

## Impact analysis

- **{{BOUNDARY_TERM}}(s) affected:** …
- **API/contract changes:** none / … (if breaking → **Tier 4, stop and get a spec**)
- **Schema/data changes:** none / …
- **Dependencies:** …
- **Blast radius:** who/what could this affect beyond the obvious?

## Test

- [ ] A test that **fails before** the fix and **passes after**.
- [ ] Regression coverage for the affected path.

## Rollback plan

How to back this out if it goes wrong.
