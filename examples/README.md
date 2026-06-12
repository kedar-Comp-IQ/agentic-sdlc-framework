# Examples & smoke tests

A hook that silently exits 0 is worse than no hook — it gives false assurance. Use these to
confirm your hooks still bite after you tune them (and quarterly thereafter, per the coverage
matrix audit).

## Smoke-testing a hook

Hooks read a JSON event on stdin and signal via exit code. To test one in isolation, pipe it
a synthetic event and check the exit code under each phase.

```bash
# A PreToolUse Edit event targeting production source (should trip verify-spec at phase 3
# if no spec exists for the branch's work item):
echo '{"hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"src/core/Foo.java"},"session_id":"smoke"}' \
  | KEEL_ENFORCEMENT_PHASE=3 bash .claude/hooks/verify-spec.sh ; echo "exit=$?"
# expect: exit=2 (blocked) with a [keel:BLOCK IR-03] message

# Same event at phase 1 (tracking) should NOT block:
echo '{"hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"src/core/Foo.java"},"session_id":"smoke"}' \
  | KEEL_ENFORCEMENT_PHASE=1 bash .claude/hooks/verify-spec.sh ; echo "exit=$?"
# expect: exit=0 with a [keel:track …] message

# A Stop event with a completion claim but no test run (verify-status-claim) — point it at a
# transcript file you craft:
echo '{"hook_event_name":"Stop","session_id":"smoke","transcript_path":"/tmp/fake-transcript.txt"}' \
  | KEEL_ENFORCEMENT_PHASE=3 bash .claude/hooks/verify-status-claim.sh ; echo "exit=$?"
```

## The discipline

For each hook you rely on:
1. Construct an event that **should** block. Confirm `exit=2` at phase 3.
2. Construct an event that **should not** block. Confirm `exit=0`.
3. Confirm phase 1 never blocks and phase 2 never blocks (both `exit=0`).

If (1) returns 0, your hook has rotted (a glob stopped matching, a path moved) — fix it
before trusting it.

## A minimal worked adoption

The shortest real adoption path:
1. `install.sh --target <repo>` with `enforcement_phase: 1` and one adapter.
2. Do a week of normal work; watch `[keel:track]` lines; tune the source/spec globs in
   `verify-spec.sh` until they match your tree.
3. Flip to phase 2; produce specs/delivery records when warned.
4. Flip to phase 3; turn on the CI backstop as a required check.
5. First incident → add a hook/rule. The framework grows with you.
