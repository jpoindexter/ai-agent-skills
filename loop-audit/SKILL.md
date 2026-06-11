---
name: loop-audit
description: Health and security audit of running loops, automations, and scheduled agents — quiet failures, gate rot, self-grading, permission scope creep, secrets in logs, unread diffs, cost per accepted change. Use monthly, or when asked whether existing loops are still safe and earning their keep.
---
# Loop Audit

A loop running unattended is also an attack surface and a cost center running unattended. Audit every active loop monthly. Verdict per loop: healthy, fix, or kill.

## The metric

**Cost per accepted change** — not tokens spent, not tasks attempted. If the accepted-change rate is below 50%, you're doing the review work the loop was supposed to save, and the loop is losing. Measure: changes merged ÷ changes proposed since last audit.

## Failure modes to check

| Mode | Symptom | Fix |
|---|---|---|
| Quiet exit (Ralph Wiggum) | Loop declares done on a half-finished job; no objective signal failed it | Replace soft conditions with a gate that returns pass/fail: test, build, lint exit code |
| Self-grading | The agent that wrote the output also verified it | Separate verifier context with no exposure to the maker's reasoning (see `/adversarial-verify`) |
| Goal drift | Constraints from the original brief no longer enforced after long sessions | Standing spec file reread each run (see `/loop-state`) |
| Agentic laziness | "Done enough" at partial completion | Objective stop condition checked by a fresh context, not the maker |
| No hard stop | Loop runs until a rate limit or invoice kills it | Token budget, iteration cap, or time limit — pick one, enforce it |
| Gate rot | The test that approves the loop's PRs no longer catches the failure mode it was built for | Spot-check: pick 2–3 recent loop PRs, verify the approving gate actually fails when the bug is reintroduced |

## Security checks

- **Unreviewed merges** — does the gate include security checks (SAST, dependency audit, secret scanning), or just functional tests? A loop opening PRs faster than humans read them merges insecure code automatically.
- **Skill injection** — any skill the loop loads was source-audited before install. Never auto-install community skills; audited samples show a meaningful fraction leak credentials or carry prompt injection in descriptions.
- **Credentials in logs** — verbose/debug logging off in production loops; spot-check recent logs for secrets.
- **Permission scope creep** — re-audit permissions every 30 days. A loop tested read-only that gained "just one" write permission for convenience is the canonical hole.

## Comprehension debt checks

- **Diffs are being read.** Unread loop output is comprehension debt at compound interest — the bill is the day you debug a system no one has read.
- **The loop is blocked from judgment-call work.** Small, machine-checkable changes only. Architecture, auth, payments stay human.

## Report format

```
Loop: <name> | Last audit: <date>
Accepted-change rate: <n merged>/<n proposed> (<pct>) — <above|below> 50%
Failure modes: <none | mode: evidence>
Security: <clean | finding: detail>
Comprehension: <diffs read | n unread PRs>
Verdict: HEALTHY | FIX (<what>) | KILL (<why>)
```

## Loop usage

```
/schedule monthly: run /loop-audit across all active loops and routines.
```
