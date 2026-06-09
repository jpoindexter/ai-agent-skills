---
name: closed-loop
description: Run a bounded 5-stage agent loop (discover → plan → execute → evaluate → improve) against a defined goal, rubric, and stop rule. Use for marketing production, content ops, CRO, and any repeatable asset workflow.
---
# Closed Loop

A bounded looping harness for producing high-quality assets. You define the goal, inputs, and rubric. The loop runs discover → plan → execute → evaluate → improve until every gate passes or the iteration cap is hit.

## When to use

- Landing page rewrites
- Ad creative generation
- Email nurture sequences
- Content repurposing
- SEO articles
- Offer research and positioning

Not for open-ended exploration — use fleet-loop for that.

## The 5 stages

| Stage | Job |
|---|---|
| **Discover** | Research the market, buyer, offer, competitors, source material, or objections |
| **Plan** | Map the work into clear steps with acceptance criteria |
| **Execute** | Draft, build, or produce the asset |
| **Evaluate** | Score the output against the rubric; identify what's below threshold |
| **Improve** | Fix weak sections, re-run evaluation, repeat |

## Reusable prompt template

```
Goal:
[Business outcome — not just the asset type.]

Inputs:
- Audience:
- Offer:
- Source material:
- Brand voice:
- Constraints:

Loop:
1. Discover: research relevant context, extract useful facts.
2. Plan: break the work into clear steps.
3. Execute: produce the first draft.
4. Evaluate: score against the rubric below.
5. Improve: fix anything below the pass threshold.
6. Repeat until every gate passes or you hit the stop rule.

Eval rubric:
- Clear target buyer: pass/fail
- Specific pain or desire addressed: 1–10
- Strong proof (evidence, data, testimony): 1–10
- Differentiated angle (not generic): 1–10
- Concrete examples: 1–10
- No generic filler: pass/fail
- CTA or next step is obvious: pass/fail

Stop rule:
Stop when every scored item is 8/10 or higher and every pass/fail gate passes.
If the loop runs 3 times without improvement, stop and explain the blocker.
```

## Worked examples

### Landing page
- **Discover:** ICP, offer, competitors, objections, current page
- **Plan:** hero, proof, mechanism, offer, CTA, FAQ
- **Execute:** rewrite each section
- **Eval:** clarity, specificity, proof, objection handling, CTA strength
- **Improve:** fix any section under 8/10

### Ad creative
- **Discover:** customer language, reviews, competitor ads, pain points
- **Plan:** angles (pain, proof, contrarian, urgency, identity, demo)
- **Execute:** hooks, body copy, CTA
- **Eval:** reject generic claims, weak hooks, unclear offer
- **Improve:** 3 stronger variants per winning angle

### Content repurposing
- **Discover:** thesis, claims, proof, sharp lines from source
- **Plan:** formats (LinkedIn, X thread, newsletter, short script)
- **Execute:** draft each asset
- **Eval:** voice fidelity, platform fit, specificity, usefulness
- **Improve:** cut generic sections, add concrete examples

## Slop prevention

- The eval gate is the difference between compounding quality and compounding slop.
- Loose goals ("make it better") always produce generic output. Specify what "better" means.
- Cap iterations. If quality stops improving after 3 runs, surface the blocker — don't iterate into noise.
