---
name: loop-readiness
description: Decision gate run BEFORE building any recurring loop, automation, or scheduled agent. Scores the task against the 4-condition test and 5-point checklist, returns a verdict — build it, keep it manual, or fix a precondition first. Use when asked "should this be a loop?" or before authoring any /loop, /schedule, or routine.
---
# Loop Readiness

Decide whether a task should become a loop before building one. A loop that misses a condition costs more than it returns — the honest default is "keep it manual."

## The 4-condition test (strategic)

All four must hold:

| # | Condition | Fails when |
|---|---|---|
| 1 | The task repeats — at least weekly | One-time job. A good prompt is faster and cheaper; a loop run once is just a script. |
| 2 | Verification is automated | No test, typecheck, build, or linter can reject bad output. You're back in the chair reading every diff — the job the loop was supposed to remove. |
| 3 | Token budget absorbs the waste | Loops re-read context, retry, explore. On a metered plan the bill arrives before the productivity gain does. |
| 4 | Agent has senior-engineer tools | No logs, no repro environment, can't run the code it writes — the loop iterates blind. |

Miss one → verdict: **keep it manual**.

## The 5-point checklist (tactical, per task)

1. Happens at least weekly.
2. An **objective gate** (test, typecheck, build, lint) rejects bad output — a second agent asked to "review" is just a second optimist.
3. The agent can run the code it changes.
4. A hard stop exists: token budget, iteration count, or time limit. Without one, the loop runs until someone notices the bill.
5. A human reviews before merge, deploy, or dependency changes.

## Good first loops vs bad

**Good:** CI failure triage, dependency bump PRs, lint-and-fix passes, flaky test reproduction, issue→PR drafts on well-tested code. (Test: could a junior do it from a checklist, with a test suite catching their mistakes?)

**Bad — human stays in the chair:** architecture rewrites, auth/payments code, production deploys, vague product work, anything where "done" is a judgment call.

## Build order (if verdict is "build")

1. Get one manual run reliable.
2. Turn it into a skill (SKILL.md).
3. Add a state file (see `/loop-state`).
4. Wrap it in a loop with the gate and hard stop.
5. Then schedule it.

Skipping ahead is how loops fail in production.

## Verdict format

```
Task: <one line>
4-condition test: <pass | FAIL on #n — reason>
Checklist: <5/5 | which boxes missed>
Verdict: BUILD | KEEP MANUAL | FIX FIRST (<precondition>)
If BUILD — gate: <command> | hard stop: <limit> | cadence: <interval>
```
