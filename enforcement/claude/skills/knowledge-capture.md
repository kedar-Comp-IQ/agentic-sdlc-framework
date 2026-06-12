# Skill: knowledge-capture

**Purpose:** capture the non-obvious lessons of a session as knowledge notes so the next
session starts where this one ended (IR-20). The in-session companion to
`.keel/core/governance/knowledge-management.md`.

## When to capture

Capture when something was *non-obvious*:
- A bug whose root cause surprised you.
- A tool/library/environment gotcha that cost real time.
- A design decision the code alone won't explain.
- A recurring pattern worth naming so it can be reused.
- An institutional lesson ("we did X, it caused Y, the structural fix is Z").

Do **not** capture what git, the code, or a standards doc already records.

## Procedure

1. **One lesson per note.** If you're writing "and also…", that's a second note.
2. **Open** `.keel/core/templates/knowledge-note-template.md`.
3. **Write the `description` as a search query** — what would future-you type to find this?
   This single line determines whether the note is ever recalled.
4. **Capture the *why-non-obvious*** — the part that distinguishes a lesson from a
   changelog entry. What did it look like vs. what it was?
5. **Give "how to apply next time"** as concrete, actionable guidance.
6. **Link related notes / ADRs / work items** so the base is a graph.
7. **Save** to `{{KNOWLEDGE_DIR}}/KN-{CODE}-{slug}.md`.

## If there's genuinely nothing to capture

That's legitimate for trivial mechanical work. Say so explicitly in the delivery record
("no new knowledge — mechanical change") so the close-gate sees a deliberate decision, not
an omission.

## The mindset

You are writing for an agent (possibly you) with **no memory of this session**. Assume it
knows the codebase but not what you just learned. The note is the only channel that lesson
has to survive.
