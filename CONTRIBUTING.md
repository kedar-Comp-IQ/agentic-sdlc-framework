# Contributing to Keel

Keel is a **shared, versioned framework** that other teams pin and depend on. That changes
how you contribute to it versus contributing to an ordinary app: a change here can ripple
into every repo that has adopted it. So this guide draws a hard line between **tuning Keel
in your own repo** (do that freely) and **changing Keel itself** (do that carefully).

> Keel governs its own development. Changes to this repo follow the same constitution,
> SDLC gate, and review framework that Keel ships — we dogfood it. If a rule is too
> burdensome to follow even here, that's a signal the rule is wrong, not that this repo is
> exempt.

---

## 1. First decide: tune locally, or contribute upstream?

| You want to… | Where it goes |
|--------------|---------------|
| Adjust globs, thresholds, rollout phase, or the rule set **for your repo** | Your repo's installed copy (`.keel/`, `.claude/`). **Don't** send it here. |
| Fix a bug in a hook / installer that affects everyone | Here (a PR to Keel). |
| Add a hook, adapter, template, or rule that's **generally useful** | Here. |
| Improve docs / the implementation guide | Here. |

The test: *would every adopting team want this?* If it's specific to your stack, product, or
risk appetite, it's a local tune. If it's a general improvement or a real defect, it belongs
upstream. When in doubt, open an issue describing the case before writing code.

---

## 2. Versioning discipline (read before any change)

Keel uses semantic versioning at the framework level (`VERSION` + `CHANGELOG.md`). Adopting
teams pin a version, so **breaking their pinned contract is the cardinal sin.**

- **PATCH** (`1.0.x`) — bug fix in a hook/installer/doc; no behavior change for a correctly
  configured adopter.
- **MINOR** (`1.x.0`) — new hook/adapter/template/rule, or a new opt-in capability.
  Backward compatible: an existing install keeps working without edits.
- **MAJOR** (`x.0.0`) — anything that changes existing config keys, token names, hook
  contracts, file locations, or default-blocking behavior. Requires a migration note.

Every PR updates `CHANGELOG.md` and, when warranted, `VERSION`. A change that would force
adopters to edit their config or re-tune hooks is **MAJOR** — flag it loudly.

---

## 3. The rules for each kind of contribution

### Changing a hook
- Keep the `common.sh` contract: read the event, exit `2` to block, respect the rollout
  phase via `keel_gate`. Never hard-block regardless of phase (the single-session collision
  is the one deliberate exception).
- **Smoke-test it across phases before opening the PR** (this is required, not optional —
  see `examples/README.md`). A hook that exits 0 silently is worse than no hook. Include the
  test commands and their output in the PR.
- Put every repo-specific assumption behind a `keel.env` variable or a clearly-commented
  tuning point — don't bake one team's paths into a shipped hook.

### Adding a hook
- Mirror an existing hook's structure. Register it in `settings.json.template` at the right
  event. Add config vars to `keel.env` (use the `${VAR:-default}` form so it's
  env-overridable for testing).
- Add a row to `enforcement/hook-coverage-matrix.md` **and** the relevant row in
  `core/governance/control-coverage-matrix.md`. The matrices must stay truthful — if the
  hook only warns, say so.

### Adding / changing an inviolable rule, autonomy tier, or anything under `core/constitution`, `core/governance`
- This is a **governance-recursive change**. It requires an **adversarial review** before
  merge: an independent Critic argues to reject, a Judge rules, and the debate transcript is
  committed with the PR (`core/governance/review-framework.md` Layer 2). Spawn a *separate*
  reviewer — do not self-synthesize the critique.
- Land it via an ADR (`core/templates/ADR-template.md` → `docs/decisions/`). Keep the rule
  set recitable (≤ ~25); prefer editing an existing rule over adding a near-duplicate.

### Adding a stack adapter
- `cp -r adapters/java-spring adapters/<your-stack>` and replace the specifics. Map every
  row of the adapter table (coding, testing, boundary test, SAST, deps, license, CI).
- The **boundary-test mechanism** is the most important piece — it's how IR-01 becomes
  mechanical in that language. Don't ship an adapter without it.
- Don't lower the constitution's bar; translate it (coverage/CVE/mutation thresholds).

### Changing the installer
- Keep it dependency-free (bash + python3 only). Preserve `--dry-run` and the
  no-clobber-without-`--force` behavior.
- Test against a throwaway target repo and confirm: zero leftover `{{TOKEN}}`s, correct
  adapter selection, and that re-running reports conflicts rather than overwriting edits.

---

## 4. PR checklist

- [ ] Classified the change (bug / feature / governance-recursive) and planned to the right
      depth (quick-plan or ADR).
- [ ] `CHANGELOG.md` updated; `VERSION` bumped if warranted; bump level (PATCH/MINOR/MAJOR)
      correct and a migration note added if MAJOR.
- [ ] Hooks changed/added are smoke-tested across phases, with output in the PR.
- [ ] Coverage matrices updated and still honest about what's enforced.
- [ ] Governance-recursive changes carry an adversarial-review transcript + an ADR.
- [ ] Docs reflect the change (README / IMPLEMENTATION_GUIDE / ONE-PAGER / index.html as
      relevant).
- [ ] No team-specific paths/secrets baked into shipped files.

## 5. Branching & commits

- Branch from `main`: `fix/<slug>`, `feat/<slug>`, or `gov/<slug>` for governance-recursive.
- One logical change per PR. Conventional-style commit subjects (`fix:`, `feat:`, `docs:`,
  `gov:`).
- PRs need at least one reviewer; governance-recursive PRs need the Critic + Judge debate in
  addition to the normal reviewer.

## 6. Reporting issues

Open an issue describing the case, the affected adopters, and whether it's a local-tune or a
real upstream concern. For a suspected enforcement gap, include the violation that slipped
through — that becomes the smoke-test for the fix.

---

*By contributing you agree your contributions are assigned to JusTransform and licensed
under the terms in `LICENSE`.*
