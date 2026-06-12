# Definition of Ready / Definition of Done

Two checklists that bound every unit of work. **Ready** gates entry into Build; **Done**
gates exit from Quality. They make "is this ready to start?" and "is this actually
finished?" mechanical instead of a judgment call.

---

## Definition of Ready (before Build starts)

A work item is *Ready* when:

- [ ] **Classified** (`task-classification.md`) and assigned a unique work-item ID (IR-02).
- [ ] **Planning artifact exists and is approved** — a spec for Features/Enhancements/
      Integrations, a quick plan for Bug/Debt/Security.
- [ ] **Acceptance criteria are explicit and testable** — each criterion is something a
      test or an observation can confirm.
- [ ] **Affected {{BOUNDARY_TERM}}(s) identified** and no undeclared cross-boundary scope.
- [ ] **Contract/schema impact known** — and if breaking, flagged Tier 4 with an approver.
- [ ] **Dependencies identified** — blocking work items / teams listed and not themselves
      blocking.
- [ ] **Rollback/abort path understood** for anything that touches data or production.

If an item isn't Ready, it goes back to Plan — Build does not "figure it out as we go."

---

## Definition of Done (before Quality sign-off)

A work item is *Done* when:

### Verification
- [ ] All acceptance criteria demonstrably met (evidence in the delivery record).
- [ ] Unit tests added/updated and passing; coverage threshold met on changed units.
- [ ] Integration/E2E tests passing where a contract/endpoint/flow changed.
- [ ] No new Critical/Major security or SAST findings; dependency scan clean (or waived).

### Documentation
- [ ] Spec/contract/schema docs reflect what was actually built.
- [ ] ADRs filed for any architectural decision made along the way.
- [ ] Knowledge note(s) captured for non-obvious lessons (IR-20).

### Review
- [ ] Code review APPROVED — no open CONCERNs.
- [ ] Architecture audit clean — no boundary violations (IR-01/IR-12).
- [ ] Security review APPROVED for changed surfaces.
- [ ] Any governance-recursive change survived adversarial review
      (`../governance/review-framework.md`).

### Closure
- [ ] Delivery record complete (`../templates/delivery-record-template.md`).
- [ ] Follow-ups filed as tracked items (no silent TODOs).
- [ ] Work-item status updated; dependencies confirmed satisfied.

---

## Enforcement

The mechanical subset of Done — delivery record present, knowledge captured, tests claimed
with evidence, no unresolved Tier-4 block — is checked by the `verify-delivery` and
`verify-status-claim` hooks at session close. The judgment subset (review verdicts,
acceptance) is the Quality session's job. **Done is not self-declared by the Build session**
— it is conferred by Quality.
