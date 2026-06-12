# Knowledge Management

Knowledge management is how the system *learns*. An AI agent has no memory across sessions;
a team has imperfect memory across people and time. Knowledge notes are the durable,
git-backed, greppable record of every non-obvious lesson — so the next session doesn't
relearn it the hard way.

This is IR-20 (Knowledge Capture is Mandatory) made concrete.

## What a knowledge note is

A short markdown file capturing **one lesson** — the kind of thing that, if forgotten, gets
rediscovered painfully. Not a changelog (git has that). Not documentation (that's `docs/`).
A *lesson*: "this looked like X but was actually Y, and here's how to recognize it next
time."

Good knowledge-note triggers:
- A bug whose root cause was non-obvious.
- A gotcha in a tool/library/environment that wasted real time.
- A design decision and the reasoning the code alone won't reveal.
- A pattern that recurs (so future work can apply it directly).
- An institutional lesson — "we did X and it caused Y; the structural fix is Z."

Bad knowledge notes (skip these):
- Restating what the code or git history already shows.
- Conversation-specific trivia with no future relevance.
- Anything a standards doc or ADR is the right home for.

## Format

Each note is one file, `{{KNOWLEDGE_DIR}}/KN-{CODE}-{slug}.md`, with front-matter and a
body. Template: `../templates/knowledge-note-template.md`. The body states the lesson, then
**why** it was non-obvious and **how to apply** it next time. Notes link to related notes so
the knowledge base is a graph, not a pile.

## The capture discipline

- **Capture at the moment, not later.** Knowledge captured "at session close" is a
  mechanical step, not a someday-task. The delivery hook checks for it.
- **The lesson, not the event.** "Fixed the null check in Foo.java" is a commit message.
  "Append-only entities silently skip the version column, which trips the optimistic-lock
  test only under concurrency" is a knowledge note.
- **One fact per note.** Findability beats completeness; a note that tries to hold five
  lessons gets recalled for none of them.

## Recall

At session start, the agent queries the knowledge base for notes matching the
initiative/domain and loads the most relevant few. A note's front-matter `description` is
what makes it findable — write it as "the thing future-me would search for."

> Recalled notes reflect what was true *when written*. If a note names a file, flag, or
> function, verify it still exists before acting on it — the knowledge base records
> lessons, not current ground truth.

## The compounding effect

A team running this for six months has a searchable corpus of every expensive lesson it has
learned, available to every agent at session start. That corpus is the difference between an
agent that repeats the team's old mistakes and one that starts where the team left off. It
is, with the constitution and hooks, the third pillar of institutional memory:
**rules prevent, hooks enforce, knowledge notes teach.**
