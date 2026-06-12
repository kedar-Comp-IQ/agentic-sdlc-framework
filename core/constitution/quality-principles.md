# Quality Principles

The quality bar every piece of work clears, regardless of language. Stack-specific *how*
(coverage tools, linters, test frameworks) lives in the adapters; the *what* lives here.

## 1. Correctness is demonstrated, not asserted

"Done" means *verified*. A change is not complete because it looks right or compiles — it
is complete when there is evidence it does what it's supposed to: a passing test, an
observed run, a reproduced-then-fixed bug. The delivery record states what was verified and
how. **Claiming completion without verification is the cardinal quality sin** — and the
status-claim hook checks for it.

## 2. Tests are part of the change, not a follow-up

Every behavioral change ships with the tests that prove it. New code paths get unit tests;
new endpoints/flows get integration or end-to-end tests. Bug fixes ship with a test that
fails before the fix and passes after. Coverage thresholds are enforced per adapter
(default: 80% line coverage on changed units), but coverage is a floor, not the goal —
**a test that can't fail proves nothing.**

## 3. The test pyramid is respected

Many fast unit tests, fewer integration tests, a thin layer of end-to-end tests. E2E is
required when a change touches an externally observable contract (an endpoint, a UI flow);
it is *not* required for pure refactors with no contract change. Don't push logic that
belongs in a unit test up into a slow E2E.

## 4. Mutation-resistance for critical paths

For the units where correctness is load-bearing, line coverage isn't enough — mutation
testing (does the suite actually *catch* injected faults?) is the real bar. Adapters wire
this up (PIT, Stryker, mutmut) behind an opt-in profile so the default loop stays fast.

## 5. Small, reviewable units of change

One logical change per pull request. Files have a soft length cap ({{MAX_FILE_LINES}}
lines) — past it, the length hook nudges you to split. Large mechanical changes
(renames, generated code) are separated from semantic changes so review can focus.

## 6. The source of truth is generated, never hand-maintained

State that drives dashboards, plans, or status lives in **one** machine-readable file;
everything derived from it is *rendered*, not hand-edited. Hand-maintained mirrors drift;
generated ones can't. If you find yourself updating the same fact in two places, one of
them should be a render of the other.

## 7. Refactor under green

Behavior-preserving change happens with the test suite passing before and after. If you
can't tell whether a refactor changed behavior, you're missing the test that would tell
you — write it first.

## 8. Definition of Done is a checklist, not a vibe

Work is done when it meets the Definition of Done
(`core/process/definition-of-ready-done.md`): verified, tested, documented, reviewed,
knowledge captured. The Stop/delivery hook checks the mechanical parts before a session can
close.

## 9. Quality debt is tracked, not silently carried

When you knowingly ship below bar (a skipped test, a deferred edge case), it goes on a
follow-up ledger with an ID and an owner — never a silent TODO. Silent truncation reads as
"covered everything" when it isn't.

---

### Anti-patterns this bars

- "Tests pass" without showing the run.
- Coverage gamed with assertion-free tests.
- A 2,000-line file because splitting felt like overhead.
- A dashboard hand-edited to match reality instead of regenerated.
- A skipped test with no tracking issue.
- "I'll add tests in a follow-up PR" for net-new behavior.
