---
name: ship-preflight
description: Block-on-red gate before calling a slice done or running a deploy. Runs the full suite (typecheck → tests → build → lint). Any red stops everything and names the failing gate.
---
# Ship Preflight

Run the full verification suite before declaring a slice done or issuing a deploy command. This is a one-shot gate, not a loop.

## Steps

1. Detect the project's check suite from `package.json`, `Cargo.toml`, `Makefile`, or the project's CLAUDE.md.
2. Run in strict order:
   - `typecheck` — must exit 0
   - `tests` — ALL must pass (no skips, no flakes tolerated)
   - `build` — must produce a clean artifact
   - `lint` / `size gate` — if configured
3. If any gate is red: stop immediately, name the gate that failed, and report the error. Do not continue.
4. If all gates pass: print the green confirmation and the next step (e.g. the deploy command). Do not run the deploy automatically.

## Constraints

- On kernel/host changes, run the FULL suite — not a subset.
- Never skip a gate to unblock a deploy.
- Never push or deploy automatically — print the command, let the human run it.
- A dropped tool connection counts as "gate incomplete" — re-run, don't assume pass.

## Report format

```
Gate results:
  typecheck  — PASS | FAIL (<error summary>)
  tests      — PASS (<n> passed) | FAIL (<n> failed, <first failure>)
  build      — PASS | FAIL
  lint       — PASS | FAIL (<violation count>)

Overall: GREEN — ready to ship | RED — blocked on <gate>
Next step: <deploy command or "fix <gate> first">
```

## Usage

Run it as a one-shot before any slice completion claim:

```
Run /ship-preflight before marking this done.
```

Or as a pre-commit hook or pre-deploy check in a loop:

```
After building the card, run /ship-preflight. Only move it to shipped if all gates pass.
```
