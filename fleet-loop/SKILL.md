---
name: fleet-loop
description: Orchestrate a goal-owning agent + specialist subagents + an eval gate to produce and verify complex output. Use when a single-agent loop can't hold the full scope — strategy, multi-surface campaigns, large audits.
---
# Fleet Loop

A multi-agent harness for complex goals. One orchestrator owns the outcome and delegates to specialists. An eval gate blocks slop from compounding. Use when the task is too wide for one agent to do well.

## Architecture

```
Orchestrator
  ├── Research agent     — mines buyer language, market, objections, source
  ├── Strategy agent     — chooses angle, structure, approach
  ├── Specialist agents  — do the narrow work (copy, code, design, analysis)
  ├── Critic agent       — scores output against rubric; rejects weak work
  └── Editor agent       — revises low-scoring sections
```

An optional **Verifier agent** runs last to confirm the final output meets the rubric and flags remaining risk.

## Prompt template

```
Goal: [One sentence — the business outcome.]

Orchestrator: own the goal and the final decision.

Roles:
- Research agent: <what to mine — buyer language / competitors / source material>
- Strategy agent: <what to choose — angle / structure / offer shape>
- Copy/Build agent: <what to produce — sections / code / assets>
- Critic agent: score the output against the rubric; return scores + weak points.
- Editor agent: revise sections scoring below <threshold>.

Eval rubric:
[paste the rubric from /closed-loop or define a custom one]

Stop rule:
Stop when every rubric item passes or 3 revision cycles produce no improvement.
On no improvement: the critic surfaces the specific blocker — don't iterate past it.

Constraints:
- Orchestrator does not produce content — it coordinates.
- Critic agent scores before editor agent touches anything.
- Verifier runs once at the end on the final output only.
```

## Landing page fleet example

```
Orchestrator: own the conversion goal and final page.
Research agent: mine ICP, offer, competitor pages, support tickets for objections.
Strategy agent: choose page angle and offer structure.
Copy agent: write hero, proof section, mechanism, FAQ, CTA.
Critic agent: score clarity (1–10), proof (1–10), specificity (1–10), CTA (pass/fail).
Editor agent: rewrite any section below 8/10.
Verifier agent: confirm final page meets rubric; flag any remaining risk.
```

## When fleet vs closed-loop

| Situation | Use |
|---|---|
| One asset, bounded scope | `/closed-loop` |
| Multi-surface, multi-discipline | `/fleet-loop` |
| Unknown scope, creative exploration | fleet with open brief + tight critic |
| Repeatable production (email, ads) | closed-loop, author it as a skill |

## Slop prevention

- The critic agent scores BEFORE the editor touches anything — never let editing bypass evaluation.
- Define the rubric before the fleet runs. Changing it mid-run is scope creep.
- 3 revision cycles with no score improvement = stop and surface the blocker. Compounding rewrites don't fix a bad angle.
- Verifier is skeptical by default — treat "no comment" as "review incomplete."
