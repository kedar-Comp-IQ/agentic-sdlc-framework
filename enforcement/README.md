# Enforcement layer

This is where the framework grows teeth. The constitution and process docs describe the
rules; the hooks here **make them mechanical** — they run at the moment of action and block
(or warn, or log) when a rule would be violated.

The v1 adapter targets **Claude Code**. The patterns are documented so they can be re-homed
to another agentic tool, git hooks, or CI (see *Porting* below).

---

## How it works

Claude Code fires **hooks** at lifecycle events. Each hook is a shell command that receives
a JSON event on stdin and signals via exit code:

| Exit | Effect |
|------|--------|
| `0` | allow |
| `2` | **block** the action; stderr is shown to the agent so it can correct |

Events used:

| Event | When | Hooks registered |
|-------|------|------------------|
| `UserPromptSubmit` | each user turn | single-session lock |
| `PreToolUse` (Edit/Write) | before a file mutation | spec, impact-analysis |
| `PostToolUse` (Edit/Write) | after a file mutation | file-length, single-session |
| `Stop` | session close | status-claim, review-approval, delivery, single-session |

Registration lives in `claude/settings.json.template`; the installer stamps it to
`.claude/settings.json`. The shared library `claude/hooks/lib/common.sh` handles event
parsing (python3, no jq), repo-root resolution, and the **graded outcome** logic.

## The phased rollout (the key adoption feature)

Dropping 24 blocking gates on a team at once breeds resentment and `--no-verify`. Every hook
reads `KEEL_ENFORCEMENT_PHASE` from `claude/hooks/lib/keel.env` and grades itself:

| Phase | Behavior | Use it to… |
|-------|----------|------------|
| **1 — tracking** | log only, never block | let the team *see* the gates fire without friction |
| **2 — soft** | warn loudly, still allow | build the habit; measure how often gates would fire |
| **3 — enforcing** | block (exit 2) | full discipline once the team has internalized it |

Advance one phase at a time by editing one line in `keel.env`. No reinstall, no settings
edit. The single-session hook is the one exception — collisions always block, because a
collision corrupts state and there's no safe "soft" version.

## The hooks (v1 set)

See `hook-coverage-matrix.md` for the table. All seven are reference implementations:
they work out of the box on the common repo shapes, and they're **heavily commented at the
exact lines you'll want to tune** (source-path globs, spec locations, work-item ID regex,
test-command patterns). Treat them as a starting point, not a black box.

## The worktree workflow (one session per checkout)

The single-session hook enforces "never two agent sessions in one working tree." The
companion workflow:

```bash
# create an isolated checkout for a parallel initiative
git worktree add ../<repo>-<slug> <branch>
cd ../<repo>-<slug>        # open your agent here

# when the initiative's PR merges
git worktree remove ../<repo>-<slug>
```

If a session crashes holding the lock, inspect/clear it:
```bash
cat .claude/.session-lock.json     # who holds it, how old
rm  .claude/.session-lock.json     # only if you're sure no session is active
```

## Porting to another agentic tool / CI

Each hook depends only on the **contract**, not on Claude Code internals:
*read a JSON event on stdin → exit 2 to block.* To re-home:

- **Another agentic tool:** map its pre-edit / pre-commit / session-end lifecycle to the
  same three moments, feed each hook the equivalent event JSON, honor exit 2.
- **Git hooks:** the `Stop`-time hooks (delivery, review-approval, status-claim) map cleanly
  to `pre-push`; the `PreToolUse` hooks (spec, impact-analysis) map to `pre-commit`. They
  read the working tree via git, so they need no event JSON at all in that mode.
- **CI:** run the same scripts in a job over the PR diff as a server-side backstop (see
  `../ci/`). Belt-and-suspenders: hooks catch it in-session, CI catches it if hooks were
  bypassed.

The `common.sh` library is the only file with tool-specific parsing; swap it and the hooks
follow.
