# Skill: session-protocol

**Purpose:** the standard operating procedure an agent follows at the start, middle, and
end of every session. Load this skill first; it orchestrates the others.

## On session start

1. **Establish scope.** What initiative / work item? What session archetype (Plan / Build /
   Quality / Ops / Troubleshooting / Discussion)?
2. **Confirm session safety.** One session per checkout — if this is a parallel initiative,
   you should be in its own worktree. (The single-session hook enforces this; don't fight
   it, spin a worktree.)
3. **Load governance.** Read `.keel/core/constitution/inviolable-rules.md` and the relevant
   standards. Note any Tier-4 surfaces the work might touch.
4. **Recall knowledge.** Query `{{KNOWLEDGE_DIR}}/` for notes matching the
   initiative/domain; load the most relevant few. Verify any file/flag a note names still
   exists before relying on it.
5. **Classify the work** (`task-classification.md`) and confirm the required planning
   artifact exists (or create it if you're the Plan session).

## During the session

- **Stay in archetype.** Don't slide from planning into implementing into self-approving.
- **Self-classify every change against the tiers.** Tier-4 surface → stop and escalate with
  the decision format, don't proceed on confidence.
- **Run the CoVe habit** before claiming a change works: state intended effect, list what
  could break, check each, then assign confidence.
- **Capture as you go.** A non-obvious lesson is a knowledge note now, not at close.

## On session close

1. **Self-review** the diff against the standards + inviolable rules (SDLC gate Step 3.5).
2. **Write the delivery record** (`delivery-package` skill).
3. **Capture knowledge** (`knowledge-capture` skill).
4. **Verify your claims.** Don't say "tests pass" unless you ran them this session.
5. Let the close-gate hooks run; satisfy them rather than working around them.

## Red flags (stop and reconsider)

- You're about to edit a frozen interface, schema, auth, or the constitution → Tier 4.
- You're editing production source and can't point to the spec/quick-plan → you skipped the
  gate.
- You're about to declare done without a test run → you're asserting, not demonstrating.
- You want to switch branches mid-session in this checkout → spin a worktree instead.
