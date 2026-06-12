---
code: KN-{CODE}            # short stable code, e.g. KN-AUTH-TOKEN-ROTATION
slug: {kebab-case-slug}
description: >             # one line — write it as what future-you would SEARCH for
  {the searchable summary of the lesson}
type: insight | fix | decision | pattern | assumption
created: {YYYY-MM-DD}
relates_to: [KN-..., ADR-..., {{PROJECT}}-...]   # links make the base a graph
---

# {Title — the lesson in a phrase}

## The lesson

State the lesson directly. What is true that wasn't obvious?

## Why it was non-obvious

What made this a trap? What did it *look* like vs. what it *was*? This is the part the code
and git history don't capture — and the reason the note exists.

## How to apply it next time

Concrete guidance for the next session/agent. "When you see X, do Y / check Z first."

## Evidence / reference

Where this was learned (PR, incident, commit, debug session). Enough to verify it later.

---
<!--
Keep ONE lesson per note. If you're writing "and also…", that's a second note.
Recalled notes reflect what was true when written — if this note names a file/flag/
function, the reader should verify it still exists before acting.
-->
