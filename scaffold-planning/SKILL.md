---
name: scaffold-planning
description: Generate the 5-file planning structure (PRD.md, ROADMAP.md, DECISIONS.md, PARKED.md, ERRORS.md) at the project root, pre-filled from the current conversation. Refuses to overwrite existing files.
---
# Scaffold Planning

Create the standard planning document set at the project root. Pre-fill each file from context already in the conversation — do not leave placeholders or ask for content that has been stated.

## Files to create

### PRD.md
One page maximum. Structure:
- One-liner: what it is and who it's for
- Problem being solved
- Target user
- **v0 done criteria** (checkboxes — these are the north star)
- In-scope items
- Out-of-scope items (→ PARKED.md)
- Constraints
- Non-goals

### ROADMAP.md
Ordered slice list. Structure:
- `## v0 — Shippable to one user` — ordered slices, sequential not parallel
- `## v1 — After first real user`
- `## v2+ — Aspirational`

### DECISIONS.md
Append-only log. Pre-fill any decisions already made in the conversation. Format per entry:
```
## YYYY-MM-DD — <title>
**Choice:** <what was decided>
**Alternatives:** <what was rejected>
**Why:** <reasoning>
**Reversible?** yes | no
```

### PARKED.md
Deferred ideas — never refused, only promoted. Pre-fill any out-of-scope items surfaced in the conversation. Format:
```
## <idea>
**Captured:** YYYY-MM-DD
**Why parked:** <reason>
**Cost to revisit:** <rough estimate>
```

### ERRORS.md
Append-only failure log. Empty at scaffold time (no prior failures). Format for future entries:
```
## YYYY-MM-DD — <task>
**What failed:** <approach>
**What worked:** <fix>
**Why it failed:** <root cause>
```

## Constraints

- Never overwrite a file that already exists — abort for that file and report.
- PRD.md must stay under one page — cut anything that isn't a v0 done criterion.
- DECISIONS.md and ERRORS.md are append-only — never edit prior entries.
- All items that are out of scope for v0 go into PARKED.md, not PRD.md.

## Usage

```
/scaffold-planning <project name>
```

or:

```
We're building <X>. Scaffold the planning docs.
```
