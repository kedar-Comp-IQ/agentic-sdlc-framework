# CI layer

The hooks catch violations **in-session**. CI is the **server-side backstop** that catches
them if the hooks were bypassed (`--no-verify`, a misconfigured local env, a human editing
on the web). Belt and suspenders: the same controls, enforced again where they can't be
skipped.

`governance-verify.yml` is a generic GitHub Actions workflow (adapt the syntax for GitLab
CI / Azure Pipelines / etc.). It runs on every PR and:

1. **Re-runs the Stop-time hooks over the PR diff** in CI mode — delivery record present,
   no un-debated governance-recursive change, no status-claim without test evidence.
2. **Checks source-of-truth freshness** — if you have generated artifacts (dashboards,
   plans), it fails when they're stale vs. their source (quality §6).
3. **Hands off to the stack adapter's verify job** — tests, coverage, SAST, dependency and
   license scans (those live in the adapter so this file stays language-neutral).

## Why both hooks *and* CI

| | Hooks (in-session) | CI (server-side) |
|---|---|---|
| Catches | violations as they happen, with immediate agent feedback | violations that reached a PR |
| Bypassable? | yes (`--no-verify`, env) | no (required check) |
| Speed | instant | minutes |
| Best at | teaching + prevention | guarantee |

Make the CI governance check a **required status check** on your default branch (and enable
"require branches up to date before merge") so the merge button is greyed out until it
passes. That's the hard gate that closes the loop on bypassed hooks.

## Adapter CI

Each stack adapter ships its own verify workflow snippet (tests, coverage gate, SAST,
dependency/license scan). Compose them with this governance workflow — e.g. call the
adapter job as a dependency of the governance job, or run them in parallel and require both.
