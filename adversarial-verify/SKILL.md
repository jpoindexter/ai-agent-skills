---
name: adversarial-verify
description: Send a diff or output to a skeptic agent tasked with refuting it. Surface only findings the skeptic can defend with file:line evidence. Default posture is "not real" — findings must earn their place.
---
# Adversarial Verify

After producing output (a shipped card, a security audit, a bug report, a spec), send it to a skeptic agent whose job is to REFUTE each finding. Only confirmed findings with file:line evidence survive.

## Steps

1. Collect the output to verify: a diff, a list of findings, a written spec, or a draft.
2. Spawn a skeptic agent with this brief:
   ```
   Your job is to REFUTE the following findings. Default posture: not real.
   For each finding, either:
   - Confirm it with file:line evidence (the only way it survives), or
   - Refute it with a specific reason (misread, already handled, wrong file, etc.)
   Do not hedge. Pick a side per finding.
   ```
3. Collect the skeptic's verdicts.
4. Keep only findings the skeptic confirmed with file:line.
5. Fix confirmed findings, then re-run the base gate (typecheck + tests + build).

## Constraints

- A dropped or failed skeptic connection = "review incomplete" — re-run, never assume pass.
- No file:line evidence = finding is rejected, regardless of how plausible it sounds.
- Do not ask the same agent that produced the output to self-verify — use a separate agent context.
- For 3+ findings, run skeptic agents in parallel (one per finding).

## Report format

```
Findings submitted: <n>
Confirmed (with evidence): <n>
  - <finding> — <file:line> — <what to fix>
Refuted: <n>
  - <finding> — <reason rejected>
Review status: complete | incomplete (skeptic dropped — re-run)
```

## Loop usage

Run after each shipped card:

```
/loop after each shipped card, run /adversarial-verify on the diff before moving on.
```

Or as a one-shot pre-merge check:

```
Verify this diff adversarially before I merge.
```

## Scaling

- 1–3 findings: one skeptic handles all.
- 4+ findings: one skeptic per finding in parallel; require majority confirmation (≥2/3) to surface.
- Security audit: use 3 independent skeptics per finding; require all 3 to confirm.
