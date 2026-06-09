---
name: keep-green
description: Run typecheck + tests + build on the current branch, fix any breaks, commit the fix. Use when asked to keep a repo building, or as the body of a /loop or /schedule job.
---
# Keep Green

Keep the current branch green by running the full gate, repairing breaks, and committing the fix.

## Steps

1. Detect the project's check commands — `package.json` scripts, `Makefile`, `cargo`, or `pyproject.toml`.
2. Run in order: typecheck → tests → build. Stop at the first red gate.
3. Read the failure output. Fix minimally — do not refactor beyond the break.
4. Re-run the failed gate until it passes, then run the full sequence to confirm nothing regressed.
5. Commit from the repo root with a conventional message: `fix: <what was broken>`.

## Constraints

- Never push to main/master.
- Never run migrations or touch `.env`/secrets.
- Never deploy.
- Give up after 3 attempts on the same failure — report the blocker instead of guessing.

## Report format (each run)

```
What broke: <gate + error>
What changed: <files + lines>
Status: green | still red
```

Already green → print "clean" and end.

## Loop usage

```
/loop 15m keep this repo green on the current branch.
```

or as a nightly routine:

```
/schedule every night 02:00: run /keep-green across <repos>.
```
