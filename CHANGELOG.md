# Changelog

All notable changes to the Keel governance framework are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); Keel uses semantic
versioning at the *framework* level (independent of any adopting project's version).

## [1.0.0] — Initial release

Distilled and generalized from a production agentic SDLC governance system.

### Core (technology-agnostic)
- Constitution: inviolable-rules framework + starter rule set, autonomy tiers,
  quality principles, security principles.
- Process: SDLC gate, six session archetypes, task classification, Definition of
  Ready / Done, waivers + incident management.
- Governance: ADR governance, review framework (incl. adversarial review for
  governance-recursive changes), knowledge management, change-control tiers,
  control-coverage matrix.
- Templates: ADR, feature spec, quick plan, delivery record, knowledge note,
  inviolable-rule.

### Enforcement (Claude Code adapter)
- `CLAUDE.md` master-governance template + `settings.json` hook registration.
- Ten generalized guardrail hooks + shared bash library (spec, impact-analysis,
  interface-stability, file-length, architecture-drift, single-session, status-claim,
  api-contract, review-approval, delivery).
- Four core skills: sdlc-gate, delivery-package, knowledge-capture, session-protocol.
- Hook-coverage matrix mapping every control to its enforcing hook.

### CI
- Generic governance-verify workflow (server-side backstop for the hooks).

### Adapters
- Java/Spring (Maven), Node/TypeScript, Python — standards + tooling + CI snippets.

### Tooling
- `install.sh` token-substituting scaffolder with `--dry-run`.
- `framework.config.example.yaml`.
