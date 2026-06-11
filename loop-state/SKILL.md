---
name: loop-state
description: Create or update a persistent STATE.md for a recurring loop — last run, in progress, completed, escalated, lessons learned. Use when authoring a loop, when a loop needs "since the last run" data, or when a recurring task keeps restarting from zero instead of resuming.
---
# Loop State

The agent forgets; the repo does not. A loop without persistent state restarts every run — a loop with state resumes. Every recurring loop reads its state file at the start of each run and writes it at the end.

## Where it lives

| Pattern | When |
|---|---|
| `STATE.md` at repo root or `.claude/state/<loop-name>.md` | Solo / small team. Version-controlled, diff-readable. Default. |
| External system (Linear, GitHub Issues, a DB) | Production loops where multiple humans need visibility, or state spans repos. |

One file per loop. Two loops sharing a state file overwrite each other's context.

## Template

```markdown
# Loop state · <loop-name>

## Last run
<ISO timestamp> · <one-line outcome: n found, n fixed, n escalated>

## In progress
- <branch or item> — <status, what it's waiting on>

## Completed (this week)
- <item> → <outcome (merged / closed / shipped)>

## Escalated to humans
- <item> — <why the loop couldn't handle it>

## Lessons learned (write here, not in chat)
- <YYYY-MM-DD>: <environment quirk, flaky pattern, "don't do X because Y">

## Stop conditions met since last review
- <goal/gate> achieved on <commit/ref> at <timestamp>
```

## Rules

- **Read at start, write at end** — every run, no exceptions. A run that doesn't update state didn't happen.
- **Lessons learned is append-only.** This is where environment quirks compound ("this runner needs bash, not PowerShell") instead of being rediscovered every run.
- **Prune Completed** entries older than a week — state files are working memory, not history. Git holds the history.
- **Escalations stay until a human clears them.** The loop never deletes its own escalations.
- **Pair with a standing spec** (`VISION.md` / `AGENTS.md` / `PRD.md`) reread each run. State says where the loop is; the spec says where it's going. This is the mitigation for goal drift — "don't do X" constraints disappear from chat memory by turn 47, not from a file.

## Loop usage

Inside any loop prompt:

```
Read .claude/state/<loop>.md before starting. Resume in-progress items first.
Update it before ending the run: last run, completed, escalated, lessons.
```
