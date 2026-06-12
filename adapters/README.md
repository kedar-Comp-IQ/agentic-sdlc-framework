# Stack Adapters

The core is technology-agnostic. **Adapters** are where language/stack specifics live:
coding standards, the test framework + coverage gate, the SAST scanner, the dependency and
license scanners, boundary-test tooling, and a CI verify job.

Install only the adapters you need (set them `true` in `framework.config.yaml`); delete the
rest. **Adding a new stack is copy-an-adapter, not fork-the-core** — the constitution and
process never change.

## What every adapter provides

| Concern | Purpose | Maps to |
|---------|---------|---------|
| Coding standard | language idioms, structure, naming | quality principles |
| Testing standard | unit/integration/E2E + coverage gate | quality §2–4 |
| Boundary tests | enforce IR-01/IR-12 in code | architecture controls |
| SAST | injection, unsafe patterns, secrets | security §8, IR-10 |
| Dependency scan | known-CVE gate (block ≥ CVSS 9.0) | security §7 |
| License check | disallowed-license gate | security §7 |
| CI verify job | run all the above in CI | ci/ layer |

## Shipped adapters

- **`java-spring/`** — Maven multi-module, ArchUnit boundary tests, JaCoCo + PIT, SpotBugs +
  FindSecBugs, OWASP dependency-check, Flyway migration standard.
- **`node-typescript/`** — ESLint + eslint-plugin-security, Vitest, Playwright E2E,
  npm-audit / better-npm-audit, license-checker.
- **`python/`** — ruff + black, pytest + coverage, bandit, pip-audit, mypy.

## Writing a new adapter

1. `cp -r java-spring <your-stack>` and gut the specifics.
2. Map each row of the table above to a concrete tool in your stack.
3. Set the coverage / mutation / CVE thresholds to match the constitution's quality + security
   principles (don't lower the bar — translate it).
4. Provide a `ci/<stack>-verify.yml` job and wire it into `ci/governance-verify.yml`.
5. Document the **boundary-test mechanism** — the single most important adapter piece, since
   it's how IR-01 (boundary isolation) becomes mechanical in your language.
