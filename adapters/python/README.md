# Adapter: Python

Maps the core to a Python 3.11+ stack (FastAPI/Django/Flask service or library).

## Tooling map

| Concern | Tool | Gate |
|---------|------|------|
| Lint + format | **ruff** + **black** (`--check`) | fail on lint error / format drift |
| Types | **mypy** (`--strict` on new modules) | typecheck passes |
| Tests | **pytest** | `pytest -q` |
| Coverage | **pytest-cov** | line ≥ 80% on changed modules (`--cov-fail-under`) |
| SAST | **bandit** | block on medium+ severity |
| Dependency CVEs | **pip-audit** | block on known vulns |
| License compliance | **pip-licenses** | allowlist enforced in CI |

## Coding standard (essentials)

- Package by {{BOUNDARY_TERM}}: `src/{{PROJECT}}/{boundary}/...`. No boundary imports
  another boundary's internals except a shared `{{SHARED_BOUNDARY}}` package (IR-01).
- **Parameterized queries (IR-10):** SQLAlchemy expression language / bound params; never
  f-string SQL. bandit's `B608` catches the common case.
- **No secrets in source (IR-19):** settings from env / secrets manager (pydantic-settings,
  not literals). bandit's `B105/B106` + the secret-scan gate.
- **Layering (IR-12):** router → service → repository. Keep ORM out of routers.
- Type-hint public functions; `mypy --strict` on new modules, ratcheting on legacy.
- Respect the file-length cap; prefer small, single-responsibility modules.

## Boundary enforcement (the IR-01 mechanism)

Python lacks a built-in boundary checker; use **import-linter** with contracts:

```ini
# importlinter.ini
[importlinter]
root_package = {{PROJECT}}

[importlinter:contract:boundaries]
name = Boundaries do not import each other
type = independence
modules =
    {{PROJECT}}.ingest
    {{PROJECT}}.core
    {{PROJECT}}.api
# {{SHARED_BOUNDARY}} is intentionally NOT listed — everyone may import it.
```

Run `lint-imports` in CI; it fails on a cross-boundary import.

## CI verify (snippet → `.github/workflows/python-verify.yml`)

```yaml
name: python-verify
on: { workflow_call: {}, pull_request: { branches: ["{{DEFAULT_BRANCH}}"] } }
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11', cache: pip }
      - run: pip install -r requirements-dev.txt
      - run: ruff check . && black --check .
      - run: mypy src
      - run: lint-imports                       # boundary contracts (IR-01)
      - run: pytest --cov --cov-fail-under=80    # tests + coverage gate
      - run: bandit -r src -ll                   # SAST (medium+ blocks)
      - run: pip-audit                           # dependency CVEs
      - run: pip-licenses --fail-on 'GPL;AGPL'   # license allowlist (tune)
```
