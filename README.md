# AI Agent Skills

12 reusable skills for loop engineering — building small systems that prompt coding agents for you instead of prompting them by hand. Each is a self-contained `SKILL.md` you can install into Claude Code or any agent harness that reads the format.

---

## Why this exists

For the last two years, working with a coding agent meant holding it the whole time: write a prompt, wait, read the diff, write the next prompt. The agent was a tool and you were the operator. That's ending. Agents are now good enough that the leverage has moved one floor up — from typing prompts to designing the **loop** that prompts: a small system that finds the work, hands it to the agent, checks the result, records what happened, and decides the next move on its own. You design it once; it prompts the agent from then on.

### What a loop is made of

Every working loop has the same four parts:

| Part | Job | Skill |
|---|---|---|
| **Automation** | A schedule or trigger that fires the run — `/loop`, `/schedule`, a routine, a webhook | — |
| **Skill** | Project knowledge written once, read every run, so the loop doesn't re-derive context from zero | any `SKILL.md` here |
| **State file** | Persistent memory outside the conversation — what's done, in progress, escalated, learned. The agent forgets; the repo does not. | `loop-state` |
| **Gate** | An objective check that can fail bad work without a human in the room — tests, typecheck, build, lint | `ship-preflight`, `keep-green` |

The gate is the part that decides whether the loop helps or just spends. A second agent asked to "review" is not a gate — it's a second optimist. Gates return exit codes.

### When a loop earns its cost — and when it doesn't

Loops are not free. They re-read context, retry, and explore, and that burns tokens whether or not the run ships anything. A loop earns its cost only when **all four** of these hold:

1. **The task repeats** — at least weekly. A loop amortizes its setup across runs; for a one-time job, a good prompt is faster and cheaper.
2. **Verification is automated** — something objective can reject bad output. Otherwise you're back in the chair reading every diff, which is the exact job the loop was supposed to remove.
3. **Your token budget absorbs the waste** — on a metered plan, the bill arrives before the productivity gain does.
4. **The agent has senior-engineer tools** — logs, a reproduction environment, the ability to run what it writes. Without those, it iterates blind.

Miss one and the loop costs more than it returns. `loop-readiness` runs this test for you before you build anything.

Good first loops: CI failure triage, dependency bumps, lint-and-fix passes, flaky-test reproduction, issue→PR drafts on well-tested code. Bad first loops — keep a human in the chair: architecture rewrites, auth and payments code, production deploys, anything where "done" is a judgment call.

### How loops fail

The failure modes are known and named, and the skills here are built to block them:

- **Quiet exits** — the loop declares done on a half-finished job because nothing objective failed it. Fix: a real gate (`ship-preflight`), not a soft "looks good."
- **Self-grading** — the agent that wrote the output also verifies it, and it's way too nice grading its own homework. Fix: a separate skeptic context (`adversarial-verify`).
- **Restarting from zero** — every run re-derives what the last run already learned. Fix: a state file read at start, written at end (`loop-state`).
- **Goal drift** — constraints from the original brief evaporate over long sessions. Fix: a standing spec reread each run (`scaffold-planning` + `loop-state`).
- **No hard stop** — the loop runs until a rate limit or an invoice kills it. Fix: token budget, iteration cap, or time limit, set up front.
- **Rot** — gates stop catching the failures they were built for, permissions creep, diffs go unread. Fix: a monthly audit with a kill verdict on the table (`loop-audit`).

### The lifecycle

The 12 skills map onto one lifecycle:

```
DECIDE   loop-readiness                          should this be a loop at all?
SCAFFOLD scaffold-planning · loop-state          docs + persistent memory
RUN      keep-green · prod-watch ·               the loop bodies — code, prod,
         cluster-feedback · hill-climb ·         feedback, metrics, assets,
         closed-loop · fleet-loop                multi-agent fleets
VERIFY   adversarial-verify · ship-preflight     skeptic + objective gate
AUDIT    loop-audit                              monthly: healthy, fix, or kill
```

Build order matters: get one manual run reliable → turn it into a skill → add a state file → wrap it in a loop with a gate and a hard stop → then schedule it. Skipping ahead is how loops fail in production.

The metric that decides whether any of this is working is **cost per accepted change** — not tokens spent, not tasks attempted. If fewer than half the loop's proposed changes get accepted, you're doing the review work the loop was supposed to save, and the loop is losing.

One last rule that no tooling enforces: **read the diffs.** A loop that ships code nobody reads is comprehension debt at compound interest — the expensive day is the one where you debug a system no one on the team has read.

---

## Install

### Fresh clone (recommended)

```bash
git clone https://github.com/jpoindexter/ai-agent-skills
cd ai-agent-skills
./bootstrap.sh
```

`bootstrap.sh` does two things in one step:
1. Installs all skills to `~/.claude/skills/`
2. Wires a `post-merge` git hook so future `git pull`s auto-reinstall

Reload Claude Code after running. You're done — no manual steps needed after this.

### Existing clone / manual install

```bash
./install.sh
```

Copies all `*/SKILL.md` files to `~/.claude/skills/`. Use this if you cloned before `bootstrap.sh` existed, or want to reinstall without pulling.

Preview what will be installed first:

```bash
./install.sh --dry-run
```

### Keeping skills up to date

Once `bootstrap.sh` has been run once, `git pull` handles everything:

```bash
git pull  # post-merge hook fires automatically → skills reinstalled
```

No manual `install.sh` needed after a pull.

### Install a single skill

```bash
cp keep-green/SKILL.md ~/.claude/skills/keep-green/SKILL.md
```

---

## Skill format

Every skill is a `SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name
description: One line — used by the agent to decide when to trigger this skill.
---
# Skill Title
...instructions...
```

The `description` field is the trigger surface. Claude matches it against your prompt to decide when to activate the skill. Keep it specific to avoid shadowing other skills.

---

## Skills

### `keep-green`

**What it does:** Runs the full check suite on the current branch — typecheck, tests, build — in that order. If anything is red, it reads the failure, fixes it minimally, re-runs until green, then commits the fix. Gives up after 3 attempts on the same failure and reports the blocker instead.

**When to use it:**
- As a standing loop to keep a branch green while you work on something else
- As a nightly scheduled routine across multiple repos
- After a batch of changes that might have broken something

**How to invoke:**

One-shot:
```
Run /keep-green on this branch.
```

As a 15-minute loop:
```
/loop 15m keep this repo green on the current branch.
```

As a nightly scheduled routine:
```
/schedule every night 02:00: run /keep-green across hashmark and prova.
```

**Constraints it enforces:** Never pushes to main. Never touches migrations or `.env`. Never deploys. Reports the blocker rather than hacking around it.

---

### `prod-watch`

**What it does:** Pulls Vercel runtime logs and Supabase error logs since the last run, deduplicates them, clusters new errors by root cause (not by message string), ranks clusters by volume, and surfaces the ones that need attention. Triage only — it never deploys or modifies data.

**When to use it:**
- Watching a live deployment while you build something else
- Catching regressions after a release
- Keeping eyes on prod without manually checking dashboards

**How to invoke:**

As a 30-minute loop:
```
/loop 30m watch prod errors on <project>.
```

One-shot triage:
```
Run /prod-watch on <project> and tell me what's broken.
```

**Requires:** Vercel MCP and Supabase MCP connected to the session.

**Output format:**
```
New error clusters: <count>
Top 3:
  1. <cause> — <count> occurrences — <route or file:line>
  2. ...
Escalation needed: yes | no
```

Quiet → prints "quiet" and ends.

---

### `cluster-feedback`

**What it does:** Pulls new items from a feedback source (Reddit, X, support inbox, app store reviews), groups them into themes by the underlying complaint or desire, ranks themes by volume, and reports the delta vs the last run — what's new, growing, fading, or gone. Writes the result to Drive or the configured output.

**When to use it:**
- Monitoring a subreddit or search query for product signal
- Tracking support ticket themes over time
- Building a running picture of what users complain about before writing copy or specs

**How to invoke:**

As a 30-minute loop:
```
/loop 30m cluster new complaints from r/ObsidianMD.
```

One-shot:
```
Run /cluster-feedback on my Gmail support label since last Monday.
```

**Output format:**
```
Source: <source> | Window: <from> → <to>
Themes:
  [NEW]     <theme> — <n> items — "<verbatim quote>" — what they want: <one line>
  [GROWING] <theme> — <n> (+<delta>) items
  [FADED]   <theme> — <n> (-<delta>) items
```

Nothing new → prints "no movement" and ends.

---

### `hill-climb`

**What it does:** Iterates toward a single measurable target one improvement at a time. Each wake it measures the current state, picks the single worst violation, fixes it (behavior-preserving, minimal change), commits, re-measures, and logs the delta. Self-paced — no fixed interval — it polls fast when progress is happening and sleeps long when blocked. Stops when the target is met or 3 consecutive wakes show zero progress.

**When to use it:**
- Paying down code-size violations (files over 300 lines, functions over 50)
- Eliminating `any` types across a codebase
- Getting a linter clean
- Reducing bundle size to a target
- Any metric-based improvement with a clear definition of done

**How to invoke:**

Self-paced (omit the interval):
```
/loop hill-climb src/ to every file under 300 lines.
```

```
/loop hill-climb src/ to zero TypeScript `any` types.
```

```
/loop hill-climb the codebase to a clean lint.
```

**Per-wake report:**
```
Violations before: <n> | after: <n> | delta: -<d>
Fixed: <file:line> — <what>
Status: <n remaining> | target: <target>
```

**Constraints it enforces:** One improvement per wake. Never changes behavior — tests are the proof. Never pushes, deploys, or touches migrations.

---

### `ship-preflight`

**What it does:** Runs the full verification suite before declaring a slice done or issuing a deploy command. Strict order: typecheck → tests (all must pass, no skips) → build → lint/size gate if configured. Any red gate stops everything immediately, names the failing gate, and reports the error. On green, it prints the next step (e.g. the deploy command) but does not run it automatically.

**When to use it:**
- Before calling any feature slice done
- Before deploying or notarizing a build
- As the gate inside a build loop after each card ships

**How to invoke:**

One-shot before shipping:
```
Run /ship-preflight before I merge this.
```

Inside a build loop:
```
/loop after each shipped card, run /ship-preflight. Only move the card to shipped if all gates pass.
```

**Output format:**
```
Gate results:
  typecheck  — PASS | FAIL (<error summary>)
  tests      — PASS (<n> passed) | FAIL (<n> failed, <first failure>)
  build      — PASS | FAIL
  lint       — PASS | FAIL (<violation count>)

Overall: GREEN — ready to ship | RED — blocked on <gate>
Next step: <deploy command or "fix <gate> first">
```

**Key rule:** On kernel or host-layer changes, always run the full suite — not a subset. A dropped tool connection counts as "gate incomplete," not "passed."

---

### `scaffold-planning`

**What it does:** Generates the 5-file planning structure at the project root — PRD.md, ROADMAP.md, DECISIONS.md, PARKED.md, ERRORS.md — pre-filled from context already in the conversation. Never overwrites existing files. PRD.md is capped at one page. Any out-of-scope items go into PARKED.md, not PRD.md. DECISIONS.md and ERRORS.md are append-only by design.

**The 5 files:**

| File | Purpose |
|---|---|
| `PRD.md` | What + why + done. One page. v0 done criteria are the north star. |
| `ROADMAP.md` | v0 → v1 → v2 ordered slices. Sequential, not parallel. |
| `DECISIONS.md` | Append-only log of locked choices with reasoning. |
| `PARKED.md` | Deferred ideas. Promote, never delete. |
| `ERRORS.md` | Append-only failure log. What failed, what worked, why. |

**When to use it:**
- Starting a new project
- Catching up a project that's been running on chat memory
- Externalizing decisions made in conversation before they drift

**How to invoke:**

```
/scaffold-planning indx
```

```
We're building a UX research pre-screening tool. Scaffold the planning docs.
```

**Rules it enforces:** PRD.md stays under one page. Existing files are never touched. Out-of-scope ideas go to PARKED.md. DECISIONS.md and ERRORS.md entries are never edited, only appended.

---

### `adversarial-verify`

**What it does:** Sends a diff, finding list, spec, or draft to a skeptic agent whose default posture is "not real." The skeptic must refute or confirm each finding with file:line evidence — no evidence means the finding is rejected regardless of how plausible it sounds. Only confirmed findings survive. If the skeptic connection drops, the review is incomplete — re-run, never assume pass.

**When to use it:**
- After shipping a card, before declaring it done
- After a security audit to cut false positives
- After generating a bug list to avoid chasing phantom issues
- Pre-merge, as a second opinion on a diff

**How to invoke:**

One-shot:
```
Verify this diff adversarially before I merge.
```

After each shipped card (loop):
```
/loop after each shipped card, run /adversarial-verify on the diff before moving on.
```

Security audit (3-skeptic panel):
```
Run /adversarial-verify on these security findings with 3 independent skeptics. Require all 3 to confirm before surfacing.
```

**Output format:**
```
Findings submitted: <n>
Confirmed (with evidence): <n>
  - <finding> — <file:line> — <what to fix>
Refuted: <n>
  - <finding> — <reason rejected>
Review status: complete | incomplete (skeptic dropped — re-run)
```

**Scaling:** 1–3 findings: one skeptic. 4+ findings: one skeptic per finding in parallel, majority required. Security/critical: 3 skeptics per finding, all must confirm.

---

### `closed-loop`

**What it does:** A bounded 5-stage looping harness for producing high-quality assets — landing pages, ad creative, email sequences, SEO articles, offer positioning, content repurposing. The loop runs discover → plan → execute → evaluate → improve until every rubric gate passes or the iteration cap (3 rounds without improvement) is hit. The eval gate is what separates compounding quality from compounding slop.

**The 5 stages:**

| Stage | Job |
|---|---|
| **Discover** | Research market, buyer, offer, competitors, objections, source material |
| **Plan** | Map work into clear steps with acceptance criteria |
| **Execute** | Draft, build, or produce the asset |
| **Evaluate** | Score against rubric; identify everything below threshold |
| **Improve** | Fix weak sections; re-run evaluation |

**When to use it:**
- Any repeatable asset workflow where quality matters
- Marketing production, content ops, CRO, email
- When you want an agent to self-improve output rather than just produce one draft

**Reusable prompt template:**

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
1. Discover relevant context, extract useful facts.
2. Plan the work into clear steps.
3. Produce the first draft.
4. Evaluate against the rubric below.
5. Fix anything below the pass threshold.
6. Repeat until every gate passes or the stop rule hits.

Eval rubric:
- Clear target buyer: pass/fail
- Specific pain or desire addressed: 1–10
- Strong proof (evidence, data, testimony): 1–10
- Differentiated angle: 1–10
- Concrete examples: 1–10
- No generic filler: pass/fail
- CTA or next step obvious: pass/fail

Stop rule:
Every scored item 8/10 or higher and every pass/fail gate passes.
3 rounds without improvement → stop, explain the blocker.
```

**Worked examples:**

*Landing page:* Discover ICP + objections → plan hero/proof/mechanism/CTA → write each section → score clarity/proof/specificity → fix anything under 8/10.

*Ad creative:* Discover customer language + competitor ads → plan angles (pain, proof, contrarian, identity) → write hooks + body + CTA → reject generic claims and weak hooks → produce 3 variants per winning angle.

*Email nurture:* Discover segment stage + objections → sequence jobs (educate, agitate, prove, compare, close) → draft each email → check subject/first line/one job per email/CTA → rewrite weak emails.

---

### `fleet-loop`

**What it does:** A multi-agent harness for goals too wide for a single agent. One orchestrator owns the outcome and delegates to specialist subagents. A critic agent scores before any editing happens. An optional verifier runs last. Use when the task spans multiple disciplines, surfaces, or requires genuine parallelism that a single context can't hold.

**Architecture:**

```
Orchestrator (owns the goal and final decision)
  ├── Research agent     — mines buyer language, market, source
  ├── Strategy agent     — chooses angle, structure, approach
  ├── Specialist agents  — copy, code, design, analysis (as needed)
  ├── Critic agent       — scores output; rejects weak work before editing
  └── Editor agent       — revises low-scoring sections
       └── Verifier agent — confirms final output meets rubric (optional)
```

**When to use it vs `closed-loop`:**

| Situation | Use |
|---|---|
| One asset, bounded scope | `closed-loop` |
| Multi-surface, multi-discipline | `fleet-loop` |
| Large audit or competitive analysis | `fleet-loop` |
| Repeatable production (email, ads) | `closed-loop`, then author it as a skill |

**Prompt template:**

```
Goal: [One sentence — the business outcome.]

Orchestrator: own the goal and the final decision.

Roles:
- Research agent: <what to mine>
- Strategy agent: <what to choose>
- Copy/Build agent: <what to produce>
- Critic agent: score against the rubric; return scores + weak points.
- Editor agent: revise sections below <threshold>.

Eval rubric:
[define your rubric or use the one from /closed-loop]

Stop rule:
Every rubric item passes, OR 3 revision cycles with no improvement.
On no improvement: the critic surfaces the specific blocker.

Constraints:
- Orchestrator coordinates, does not produce content.
- Critic scores before editor touches anything.
- Verifier runs once at the end on the final output only.
```

**Landing page fleet example:**

```
Orchestrator: own the conversion goal and final page.
Research agent: mine ICP, offer, competitor pages, support tickets for objections.
Strategy agent: choose page angle and offer structure.
Copy agent: write hero, proof section, mechanism, FAQ, CTA.
Critic agent: score clarity (1–10), proof (1–10), specificity (1–10), CTA (pass/fail).
Editor agent: rewrite any section below 8/10.
Verifier agent: confirm final page meets rubric; flag remaining risk.
```

**Critical rule:** The critic scores before the editor touches anything. Never let editing bypass evaluation — that's how slop compounds.

---

### `loop-readiness`

**What it does:** Decision gate run *before* building any loop, automation, or scheduled agent. Scores the task against the 4-condition test (repeats weekly / automated verification / budget absorbs waste / agent has senior-engineer tools) and a 5-point tactical checklist, then returns a verdict: BUILD, KEEP MANUAL, or FIX FIRST. Includes the build order for a minimum viable loop: manual run → skill → state file → loop → schedule.

**When to use it:**
- Before authoring any `/loop`, `/schedule`, or routine
- When tempted to automate a task that might not earn it
- Triaging which of several candidate tasks deserves a loop first

**How to invoke:**
```
Run /loop-readiness on "nightly CI failure triage for hashmark".
```

**Key rule:** Miss one of the 4 conditions → keep it manual. A loop with no objective gate is the agent grading its own homework; a loop with no hard stop runs until the invoice arrives.

---

### `loop-state`

**What it does:** Creates or updates a persistent `STATE.md` for a recurring loop — last run, in progress, completed, escalated, lessons learned. The agent forgets; the repo does not. A loop without state restarts every run; a loop with state resumes. Pairs the state file (where the loop *is*) with a standing spec reread each run (where it's *going*) to prevent goal drift.

**When to use it:**
- Authoring any new loop (every loop gets one state file)
- A recurring task keeps restarting from zero or rediscovering the same environment quirks
- A loop's "since the last run" data has nowhere to live

**How to invoke:**
```
Set up /loop-state for the prod-watch loop on prova.
```

**Rules it enforces:** Read at start, write at end — every run. Lessons-learned is append-only. Escalations are only cleared by humans. One file per loop.

---

### `loop-audit`

**What it does:** Monthly health and security audit of running loops. Checks the named failure modes — quiet exits (Ralph Wiggum loops), self-grading, goal drift, gate rot, missing hard stops — plus the security tax of unattended automation: unreviewed merges, skill injection vectors, credentials in logs, permission scope creep. Verdict per loop: HEALTHY, FIX, or KILL.

**The metric:** cost per accepted change. Accepted-change rate below 50% means you're doing the review work the loop was supposed to save — the loop is losing.

**When to use it:**
- Monthly, across all active loops and routines
- A loop's PRs are piling up unread
- Before granting a loop any new permission

**How to invoke:**
```
/schedule monthly: run /loop-audit across all active loops.
```

**Output format:**
```
Loop: <name> | Accepted-change rate: <pct>
Failure modes: <none | found>
Security: <clean | finding>
Verdict: HEALTHY | FIX | KILL
```

---

## Composing skills

Skills chain naturally. Some common patterns:

**Ship loop:**
```
/loop after each card ships, run /adversarial-verify on the diff, then /ship-preflight. Only move to done if both pass.
```

**Steady-state dev:**
```
/loop 15m /keep-green
/loop 30m /prod-watch on <project>
```

**New project start:**
```
We're building <X>. Run /scaffold-planning, then use /closed-loop to draft the landing page.
```

**Quality drive:**
```
/loop /hill-climb src/ to zero lint violations, then /ship-preflight before stopping.
```

**Loop lifecycle:**
```
Run /loop-readiness on the task. If BUILD: set up /loop-state, wrap in /loop with the gate.
/schedule monthly: /loop-audit across all active loops.
```

