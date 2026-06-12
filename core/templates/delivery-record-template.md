# Delivery Record: {Work-item ID} — {title}

> The durable evidence that a change met the bar. Written at the end of a Build session;
> the `verify-delivery` hook checks for its presence before session close.

- **Work-item ID:** {{PROJECT}}-{AREA}-{NNN}
- **Type / Classification:** {Feature | Bug | …}
- **Session date:** {YYYY-MM-DD}
- **Branch / PR:** {ref}
- **Highest tier touched:** {1–4}   ·   **Approver (if Tier 3/4):** {name or —}

## What changed

Concise summary of the change and the files/areas touched.

## Acceptance criteria — evidence

| AC | Met? | Evidence (test name / observed behavior) |
|----|------|------------------------------------------|
| AC1 | ✅ | … |
| AC2 | ✅ | … |

## Verification (the CoVe record)

- **Intended effect:** {one line}
- **What could break:** {callers, data, contracts, tenants}
- **How each was checked:** {test / grep / run — be specific}
- **Confidence / tier:** {value → tier}

## Tests

- Unit: {added/updated, result}
- Integration/E2E: {added/updated, result — or "N/A: no contract change"}
- Coverage on changed units: {%}

## Constitution & standards

- [ ] Boundary isolation respected (IR-01).
- [ ] No new Critical/Major security or SAST findings.
- [ ] Relevant standards (coding/API/testing) followed.
- [ ] Tier-4 surfaces (if any) approved.

## Follow-ups filed

| ID | What | Why deferred |
|----|------|--------------|
| … | … | … |

## Knowledge captured

- {KN-CODE-slug} — {one-line lesson}   (link)
