# Adapter: Node / TypeScript

Maps the core to a Node 20+ / TypeScript stack (Next.js/React or a TS service). Delete the
front-end-specific rows if you're building a service.

## Tooling map

| Concern | Tool | Gate |
|---------|------|------|
| Lint | **ESLint** (`--max-warnings 0`) + `eslint-plugin-security` | fail on any warning |
| Types | **tsc --noEmit** | typecheck passes (no `any` escape hatches in new code) |
| Unit tests | **Vitest** (or Jest) | `vitest run` |
| Coverage | Vitest coverage | line ≥ 80% on changed files |
| E2E | **Playwright** | required when a route/flow/contract changes |
| SAST | `eslint-plugin-security` + `npm audit` | injection/regex/unsafe patterns |
| Dependency CVEs | **better-npm-audit** | `--level high --production` blocks |
| License compliance | **license-checker** | allowlist enforced in CI |

## Coding standard (essentials)

- Module/feature by {{BOUNDARY_TERM}}: `src/features/{boundary}/...`. No feature imports
  another feature's internals except a shared `src/{{SHARED_BOUNDARY}}/` (IR-01).
- **No direct DB/contract bypass from the client (IR-04):** the frontend talks to the API,
  never around it.
- **Parameterized queries (IR-10):** parameterized query builders / prepared statements
  only; never template-string SQL.
- **No secrets in client bundles (IR-19):** server-only env vars; the secret-scan gate +
  Next.js `NEXT_PUBLIC_` discipline.
- Strict TypeScript (`strict: true`); avoid `any` and non-null `!` in new code.
- Components: one responsibility each; respect the file-length cap (the `check-file-length`
  hook nudges you).

## Boundary enforcement (the IR-01 mechanism)

ESLint is the boundary gate in TS. Use `eslint-plugin-boundaries` or
`import/no-restricted-paths`:

```jsonc
// .eslintrc — boundaries: a feature may not import another feature's internals
"import/no-restricted-paths": ["error", {
  "zones": [
    { "target": "src/features/ingest", "from": "src/features", "except": ["src/features/ingest", "src/{{SHARED_BOUNDARY}}"] },
    { "target": "src/features/core",   "from": "src/features", "except": ["src/features/core",   "src/{{SHARED_BOUNDARY}}"] }
    // …one zone per boundary
  ]
}]
```

## CI verify (snippet → `.github/workflows/node-verify.yml`)

```yaml
name: node-verify
on: { workflow_call: {}, pull_request: { branches: ["{{DEFAULT_BRANCH}}"] } }
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: npm }
      - run: npm ci
      - run: npm run lint            # eslint --max-warnings 0 (+ security plugin)
      - run: npm run typecheck       # tsc --noEmit
      - run: npm run test:coverage   # vitest + coverage gate
      - run: npx playwright install --with-deps && npm run test:e2e   # if routes/flows changed
      - run: npx better-npm-audit audit --level high --production
      - run: node scripts/check-licenses.mjs
```

> **Lockfile gotcha:** regenerate `package-lock.json` inside a Linux container if your CI is
> Linux — a macOS `npm install` can omit platform-specific optional/transitive deps that
> Linux `npm ci` then demands. Use `docker run node:20 ... npm install --package-lock-only`.
