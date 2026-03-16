# Architecture — McRitchie Studio

**Last updated:** 2026-03-15

---

## Agent Roster

| Agent | Title | Slug | Model | Workspace |
|-------|-------|------|-------|-----------|
| Alex | CEO & Senior Engineer | `alex` | claude-sonnet-4-6 | `~/.openclaw/workspace` |
| Mason | CPO & Senior Engineer | `mason` | claude-sonnet-4-6 | `~/.openclaw/workspace-mason` |
| Mack | CTO | `mack` | gemini-3-flash-preview | `~/.openclaw/workspace-mack` |
| Turf Monster | CMO | `turf-monster` | grok-3 | `~/.openclaw/workspace-turf-monster` |

---

## System Architecture

```
  Mr. McRitchie (operator)
         │
         ▼
  ┌─────────────────────────────────┐
  │        Alex (CEO + Senior Eng)  │
  │  Primary dev · Quality gate     │
  │  Builds directly · Delegates    │
  └────────┬──────────┬─────────────┘
           │          │
    ┌──────▼──┐  ┌────▼──────────────────┐
    │  Mason  │  │  Mack                 │
    │  CPO    │  │  CTO                  │
    │  Senior │  │  Infra · Docker · DB  │
    │  Eng    │  │  Error protocols      │
    └──────┬──┘  └───────────────────────┘
           │
    ┌──────▼────────┐
    │ Turf Monster  │
    │ CMO           │
    │ Content · X   │
    └───────────────┘
```

---

## Dev Philosophy

**Alex builds first.** Anything scoped in conversation with Mr. McRitchie goes straight to `in_progress` or gets built inline. No queue overhead for things already designed in chat.

**Mason is second line.** Same skills, same taste. Runs parallel on big projects. Picks up ancillary features from `new` via cron.

**Alex owns quality.** Reviews `done` tasks. Archives clean ones (notifies Mr. McRitchie), fixes bad ones directly.

**Heartbeat = awareness.** Discord monitoring + pipeline fires. NOT for scheduled work.

---

## Dev Loops

### Alex Dev Loop (Code Push button or manual)
```
1. Review Done      → archive clean / fix bad / notify #lobster-tank
2. Finish In Progress
3. Pick up Queued
4. Start New (can own)
5. Review Done again
```

### Mason Dev Loop (cron every 20min + Code Push)
```
1. Finish In Progress (mason)
2. Pick up Queued (mason)
3. Refine New → enrich + queue, or @Alex in #lobster-tank
```

### Mack Dev Loop (Code Push)
```
1. Finish In Progress (mack)
2. Pick up Queued (mack)
```

---

## Task Pipeline

```
new → queued → in_progress → done → archived
                           ↘ failed
```

- **new** — just created, needs refinement
- **queued** — scoped, ready to execute
- **in_progress** — being actively worked
- **done** — complete, pending Alex review
- **archived** — approved by Alex, notify Mr. McRitchie
- **failed** — errored out, needs diagnosis

Tasks scoped in conversation with Mr. McRitchie → created as `in_progress` directly (already refined).

---

## News Pipeline

### Flow
Each Schefter tweet produces **two records**: `x_post` + `x_reply`

```
Adam Schefter tweets
       │
       ▼
poll-schefter.js          (every 10min)
       │ creates x_post record
       ▼
enrich-news.js            (every 10min) — title, person, team, summary, image
       │
       ▼
opinion-news.js           (every 15min) — TM hot take + creates x_reply sibling
       │
       ├──────────────────────────────────────────┐
       ▼                                          ▼
edit-post.js (x_post)                  edit-reply-post.js (x_reply)
hashtag lookup → edited                meme picker → edited
       │                                          │
       ▼                                          ▼
[human approves via 🔥/🍻 reaction]    [human approves same way]
       │                                          │
       ▼                                          ▼
post-to-x.js                           post-reply-to-x.js
posts tweet → posted                   posts meme reply → posted
```

### Stage sequence
`new → reviewed → content → edited → queued → posted → archived`

### Human approval
- 🔥 reaction on TM's Discord message → `edited` → `queued`
- 🍻 reaction → `edited` → `queued` → immediately post to X
- Processed by `emoji-approval` cron (every 2min)

---

## Cron Schedule

| Job | Agent | Interval | Purpose |
|-----|-------|----------|---------|
| poll-schefter | alex | 10min | Poll Schefter's X account |
| turf-monster-enrich-news | turf-monster | 10min | AI enrichment |
| opinion-news | alex | 15min | TM hot take + x_reply sibling |
| edit-post (x_post) | mason | 15min | Hashtag lookup |
| edit-reply-post (x_reply) | alex | 15min | Meme picker |
| post-to-x (x_post) | alex | 30min | Post to X |
| post-reply-to-x (x_reply) | alex | 10min | Post meme reply |
| emoji-approval | alex | 2min | Process 🔥/🍻 reactions |
| mason-task-refinement | mason | 20min | Mason dev loop |
| sync-cron-usage | alex | hourly | Sync cron token usage to Rails |
| TM X Session Health Check | mack | 9am MDT | Check X session age |
| House Burns Down Protocol | alex | 3am MDT | Nightly doc audit |
| Alex Daily Brief | alex | 5am MDT | Morning summary → #lobster-tank |

---

## Token Usage Logging

All LLM calls logged to Rails via `scripts/lib/usage-tracker.js`.

**Phases:**
1. Script-level (task #69) — `usage-tracker.js` wired into all 4 pipeline scripts
2. Cron-level (task #70) — `sync-cron-usage.js` reads OpenClaw run history hourly
3. Session-level (task #71) — `parse-session-usage.js` reads JSONL transcripts nightly

**Rails endpoints:**
- `GET/POST /api/agents/usages` — daily rollup by agent + model
- `GET/POST /api/agents/activities` — per-call event log
- Dashboard: `/agents/usage/overview`

---

## Rails App

- **Location:** `~/.openclaw/workspace/boodle_scraper`
- **Running:** Docker, container `boodle_scraper-web-1`, port `3000`
- **Migrations:** always inside container — `docker exec boodle_scraper-web-1 bin/rails db:migrate`
- **Files:** live-mounted from workspace — no copy needed after edits

### Key APIs
| Endpoint | Purpose |
|----------|---------|
| `GET/POST /api/news` | News records |
| `PATCH /api/news/:id` | Update fields |
| `PATCH /api/news/:id/transition` | Stage transition |
| `PATCH /api/news/:id/rank` | Reorder in kanban |
| `GET /api/teams/search?name=` | Team + hashtag lookup |
| `GET/POST /api/agents/tasks` | Task board |
| `PATCH /api/agents/tasks/:id/transition` | Task lifecycle |
| `POST /api/agents/push` | Code Push (pending #73) |
| `GET/POST /api/agents/usages` | Token usage |
| `GET/POST /api/agents/activities` | Activity log |
| `GET/POST /api/memes` | Meme library |

---

## Discord

- **Guild:** McRitchie Studio (`1332466565203103744`)
- **Primary channel:** `#lobster-tank` (`1479973077021495478`)
- **Mr. McRitchie Discord ID:** `536552944271753216`
- **Alex bot ID:** `1481150857809760399`
- **Bot accounts:** alex, mason, mack, turf-monster (tokens in `openclaw.json`)
- **Delivery format:** `{ "mode": "announce", "to": "channel:1479973077021495478" }` ← use `to`, NOT `channel`

---

## Pending Work

| # | Title | Agent | Priority |
|---|-------|-------|---------|
| 69 | usage-tracker.js + wire into scripts | mason | High |
| 70 | sync-cron-usage.js | mack | Med |
| 71 | parse-session-usage.js | mack | Med |
| 72 | archived stage for AgentTask | mason | High |
| 73 | Code Push button + /api/agents/push | mason | High |
| 64–68 | Turf Monster video pipeline | mason/mack | Med |
| — | x_reply 403 fix (reply to own tweet) | mack | High |
