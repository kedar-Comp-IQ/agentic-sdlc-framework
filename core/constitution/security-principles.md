# Security Principles

The security posture every change clears. These are constitution-level; the inviolable
rules IR-06..IR-19 are their hard, enforced edges. Stack-specific scanners live in the
adapters.

## 1. Secure by construction, not by review

Security properties come from *structure*, not vigilance. Tenant isolation comes from a
constrained data boundary (IR-06), not a remembered `WHERE` clause. Injection-safety comes
from parameter binding being the only available path (IR-10), not from careful escaping.
Design so the insecure thing is hard to express.

## 2. Least privilege, everywhere

Every component, credential, token, and role gets the minimum access it needs. Default
deny; grant explicitly. Service accounts are scoped per-service, not shared. Broad
"admin" credentials are a finding.

## 3. Secrets live in a manager, never in source

No credentials, keys, or tokens in the repo, in config files, or in logs. They come from a
secrets manager at runtime (IR-19). Secret-scanning blocks the commit, not the release.

## 4. Defense in depth

No single control is trusted alone. Auth at the edge *and* authorization at the data
boundary. Input validation *and* output encoding. A bypass of one layer should not be a
breach.

## 5. Everything is encrypted in transit (and sensitive data at rest)

TLS 1.2+ on every hop including internal ones (IR-18). Sensitive data encrypted at rest
with managed keys. No plaintext fallback "for local dev" that can leak to other
environments.

## 6. Auditability is a security control

Every security-relevant action (auth, authz decisions, data mutations, privilege changes)
is logged immutably with actor, tenant, and before/after (IR-08). You cannot investigate
what you didn't record.

## 7. Dependencies are attack surface

Third-party dependencies are scanned for known vulnerabilities on every build. Critical
CVEs (CVSS ≥ 9.0) block the build; lower severities are tracked with SLAs. License
compliance is checked in the same pass — an un-vetted license is a legal vulnerability.
Adapters wire the scanner (OWASP dependency-check / npm-audit / pip-audit).

## 8. Static analysis on every change

SAST runs in CI and, where possible, in-session. Injection, unsafe deserialization,
path traversal, weak crypto, and hardcoded secrets are caught mechanically
(FindSecBugs / eslint-plugin-security / bandit per adapter). Findings are triaged by
severity; Critical/Major are Tier-4 blockers.

## 9. Security findings escalate, never silently waive

A Critical or Major finding blocks (Tier 4). Waiving one requires an explicit, signed,
time-boxed waiver (`core/process/waivers-and-incidents.md`) with a remediation plan —
never a quiet suppression. Suppression files are reviewed like code.

## 10. Threat-model the seams

When a change adds a trust boundary (a new external input, a new integration, a new
tenant-facing surface), it gets a lightweight threat model: what can an attacker send
here, and what stops them. Recorded in the spec or an ADR.

---

### The security review gate

Quality sessions run a dedicated security pass (see
`core/process/session-archetypes.md` → Quality). It verifies: no Critical/Major SAST or
dependency findings open, secrets clean, auth/authz correct for new surfaces, audit logging
present, and tenant isolation intact. The gate's verdict is recorded; a CONCERN blocks
sign-off until resolved or formally waived.
