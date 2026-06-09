---
name: prod-watch
description: Poll Vercel runtime logs and Supabase logs since the last run, cluster new errors by cause, and triage. Triage only — no deploys, no data changes.
---
# Prod Watch

Watch production for new errors using connected MCP tools, cluster them by cause, and surface the ones that need attention.

## Steps

1. Pull Vercel runtime logs for `<project>` since the last run timestamp.
2. Pull Supabase error logs for the same window.
3. Deduplicate and cluster new errors by root cause (not by message string — group similar causes together).
4. Per cluster: give likely cause + file:line or route + request path.
5. Rank clusters by volume (highest first).

## Constraints

- Triage only — never deploy, never modify data, never change config.
- If you see a critical error (data loss risk, auth bypass, billing), escalate immediately instead of waiting for the next run.

## Report format (each run)

```
New error clusters: <count>
Top 3:
  1. <cause> — <count> occurrences — <file:line or route>
  2. ...
  3. ...
Escalation needed: yes | no
```

Quiet → print "quiet" and end.

## Loop usage

```
/loop 30m watch prod errors on <project>.
```

Requires: Vercel MCP + Supabase MCP connected.
