---
name: cluster-feedback
description: Pull new items from a feedback source (Reddit, X, support inbox, reviews), cluster into themes, rank by volume, and report the delta vs last run.
---
# Cluster Feedback

Pull new feedback from a source, group it into themes, and surface what changed since the last run.

## Steps

1. Pull items from `<source>` since the last run timestamp.
2. Group into themes by the underlying complaint or desire — not by surface wording.
3. Rank themes by volume (number of items).
4. Per theme: one verbatim quote + a one-line "what they want."
5. Compare to last run: mark themes as new / growing / faded / gone.
6. Write the delta report to Drive (or the configured output) and end.

## Constraints

- Report the delta vs last run — do not re-surface stable themes as if new. Persist last-run timestamp and theme counts in a state file (see `/loop-state`); the delta is impossible without it.
- Do not editorialize about whether themes are valid. Report what people said.
- Nothing new → print "no movement" and end.

## Report format

```
Source: <source> | Window: <from> → <to>
Themes:
  [NEW]     <theme> — <count> items — "<verbatim quote>" — what they want: <one line>
  [GROWING] <theme> — <count> (+<delta>) items
  [FADED]   <theme> — <count> (-<delta>) items
```

## Loop usage

```
/loop 30m cluster new complaints from <source>.
```

## Source examples

- Reddit: a specific subreddit or saved search
- X/Twitter: a search query or account mentions
- Support inbox: Gmail filtered by label
- App store reviews: Vercel-hosted review feed
