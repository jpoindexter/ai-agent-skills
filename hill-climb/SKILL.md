---
name: hill-climb
description: Self-paced iteration toward a single measurable target. Each wake: measure, make one improvement, commit, re-measure, log the delta. Stop when target is met or 3 wakes show no progress.
---
# Hill Climb

Drive a codebase metric toward a defined target one improvement at a time, without a fixed schedule. The loop self-paces — it polls fast when progress is being made and sleeps long when blocked.

## Arguments

- `<area>` — the scope to improve (a directory, module, or file pattern)
- `<target>` — the measurable condition to reach (e.g. "every file under 300 lines", "zero `any` types", "lint clean", "p95 under 200ms")

## Steps

1. Measure the current state — count violations, run the relevant linter/type-checker/test, or query the metric.
2. If target is already met: print "target met" and end.
3. Pick the single worst violation. Fix it — behavior-preserving, minimal change.
4. Re-run the check to confirm the fix reduced the violation count and nothing regressed.
5. Commit: `refactor: hill-climb <what> <before>→<after>`.
6. Log the violation-count delta for this wake.
7. Repeat.

## Stop conditions

- Target is met (clean measurement).
- 3 consecutive wakes with zero delta in the violation count — report the blocker and stop.

## Constraints

- One improvement per wake — don't batch several fixes in one commit.
- Never change behavior. Tests are the proof.
- Never push, deploy, or modify migrations.

## Report format (each wake)

```
Violations before: <n> | after: <n> | delta: -<d>
Fixed: <file:line> — <what>
Status: <n remaining> | target: <target>
```

## Loop usage

```
/loop hill-climb <area> to <target>.
```

Omit the interval — the loop self-paces.

## Example

```
/loop hill-climb src/ to every file under 300 lines.
```
