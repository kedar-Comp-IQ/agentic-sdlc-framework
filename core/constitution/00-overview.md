# Constitution — Overview

The constitution is the **non-negotiable layer**. Everything else in {{FRAMEWORK_NAME}}
(process, templates, tooling) exists to make the constitution legible and enforceable.

It has four parts:

| Document | What it fixes | Changeable by |
|----------|---------------|---------------|
| `inviolable-rules.md` | The rules that must never be violated, and which are mechanically enforced | Architecture authority only, via ADR |
| `autonomy-tiers.md` | When the agent may act alone vs. escalate to a human | Lead, via config (`framework.config.yaml`) |
| `quality-principles.md` | The quality bar all work clears | Lead, via ADR for material changes |
| `security-principles.md` | The security posture all work clears | Security authority, via ADR |

## How the constitution differs from "standards"

Standards (in `{{STANDARDS_DIR}}` / the stack adapters) tell you *how to write good code*
in a given language. The constitution tells you *what must be true regardless of language*.

- A standard says "name React components in PascalCase."
- The constitution says "code in one {{BOUNDARY_TERM}} never imports another
  {{BOUNDARY_TERM}}'s internals."

Standards evolve freely. The constitution changes only through an Architecture Decision
Record (see `core/governance/adr-governance.md`), because changing it changes the meaning
of every existing artifact.

## The enforcement contract

Each inviolable rule names its **enforcement mechanism** — the hook, CI check, or review
gate that makes it mechanical rather than advisory. A rule with no enforcement mechanism
is a candidate for one, or an honest admission that it's currently aspirational. The
`enforcement/hook-coverage-matrix.md` is the authoritative map of rule → mechanism.

> **Principle:** if a rule matters enough to be inviolable, it matters enough to be
> enforced by a machine. Humans forget; agents hallucinate compliance. Hooks don't.
