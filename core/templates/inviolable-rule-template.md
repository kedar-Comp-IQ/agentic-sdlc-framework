# Inviolable Rule template

> Copy this block into `core/constitution/inviolable-rules.md` under the right category,
> assign the next free `IR-NN`, and land it via ADR. A new inviolable rule is a
> governance-recursive change — it requires adversarial review (`review-framework.md`).

```
### IR-NN — {Short rule name}
{One or two sentences stating what must always be true. Write it as an assertion that can
be checked: "Every X does Y" / "No A imports B". If you can't imagine a check for it, it's
a principle, not an inviolable rule — put it in the principles docs instead.}
**Enforcement:** {hook name / CI check / SAST rule / review gate — or ASPIRATIONAL if none
yet, which makes filling that gap a tracked follow-up}. {Mark **Tier 4** if any change to
the governed surface is high-blast-radius.}
```

## Quality bar for a new inviolable rule

- **Checkable.** It asserts something a machine or a reviewer can verify true/false.
- **Inviolable.** A violation is genuinely never acceptable — not "usually." If there are
  legitimate exceptions, it's a standard with a waiver path, not an inviolable rule.
- **Enforced (or honestly aspirational).** Name the mechanism. If there's no mechanism yet,
  say `ASPIRATIONAL` and file the follow-up — don't pretend.
- **Stable ID.** Never reuse a retired IR number.
- **Cited.** Hooks/CI/reviews reference it by ID.

## Before you add one, ask

- Could this be a **standard** (stack-specific, evolves freely) instead? Most "rules" are.
- Could this be an **autonomy tier trigger** (it's about *who approves*, not *what's true*)?
- Is it already implied by an existing rule? Don't multiply rules; the set must stay
  recitable (aim ≤ 25).
