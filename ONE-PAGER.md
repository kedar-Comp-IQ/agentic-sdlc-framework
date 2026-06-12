# Keel — One-Pager

**Agentic SDLC governance, in a box.** Drop disciplined, auditable, machine-enforced
engineering process into any repo — any language, any agentic coding tool — and tune it to
your team.

---

## The problem it solves

AI coding agents are fast and tireless, but they have **no institutional memory**, no sense
of "we already decided this," and a strong bias toward output that *looks* right. Ungoverned,
they ship code that compiles and quietly breaks the things that matter: tenant isolation,
API stability, security posture, architectural boundaries. Governance-by-documentation
doesn't help — nobody re-reads the standards doc on edit #400.

**Keel's premise: the rules that matter are enforced mechanically, at the moment of action
— not written down and hoped for.**

## What you get

A ready-to-deploy bundle (52 files), distilled from a production system that runs ~24
enforcement hooks across a real multi-product platform:

- **A constitution** — inviolable rules, autonomy tiers, quality + security principles. The non-negotiables.
- **A process** — SDLC gate, six session archetypes, task classification, Definition of Ready/Done, waivers + incident loop.
- **Governance** — ADR process, an adversarial review framework, knowledge capture, change-control tiers, and a control-coverage matrix that tells you honestly what's enforced.
- **The teeth** — 10 phase-aware enforcement hooks (Claude Code-native) + 4 agent skills that block non-compliant actions in-session.
- **Stack adapters** — Java/Spring, Node/TypeScript, Python (drop-in; delete what you don't use; add your own).
- **An installer** — one command stamps it into your repo with your names/boundaries/thresholds. CI backstop included.

## Why it won't get rejected by your team

**Phased rollout is built in.** Every hook self-grades from one config line:

| Phase | Behavior | Purpose |
|-------|----------|---------|
| **1 — Tracking** | logs, never blocks | make the gates visible; tune them with zero friction |
| **2 — Soft** | warns, still allows | build the habit |
| **3 — Enforcing** | blocks | guarantee |

You don't drop 24 gates on people on day one (that just breeds `--no-verify`). You phase
them in over ~4 weeks, flipping one value as the team is ready.

## What's actually enforced today (the 10 shipped hooks)

Spec-before-code · impact-analysis-for-fixes · one-session-per-checkout · file-length ·
boundary-isolation · frozen-interface protection · API-contract breaking-change guard ·
"done" claims must show a test run · governance changes need adversarial review ·
delivery-record + knowledge-capture at close.

All ten were smoke-tested across all three phases before release.

## Adopt it in four steps (~30 min to install, ~4 weeks to full enforcement)

```bash
cp framework.config.example.yaml framework.config.yaml   # 1. set org, project, boundaries, stack
bash install.sh --target /path/to/repo --dry-run         # 2. preview
bash install.sh --target /path/to/repo                   # 3. install at phase 1 (tracking)
# 4. advance the phase in .claude/hooks/lib/keel.env as the team internalizes each tier
```

Full walkthrough: `IMPLEMENTATION_GUIDE.md`. Mental model: `README.md`.

## The three ideas worth stealing even if you adopt nothing else

1. **Mechanical over advisory** — if a rule matters, a hook enforces it; unenforced rules are aspirations (and the coverage matrix says so honestly).
2. **Tiered autonomy** — most work auto-approves; only high-blast-radius changes (schema, auth, breaking APIs, cross-boundary, frozen interfaces) block on a human.
3. **The framework is compiled memory** — every incident hardens it into a new rule or hook, and every non-obvious lesson becomes a knowledge note the next agent reads at session start.

---

*Keel v1.0.0 · technology-agnostic · JusTransform internal-use license (see LICENSE) ·
renameable via config. Questions / pilot: contact the platform team.*
