# Bootstrap Guide — McRitchie Studio

Use this to rebuild from scratch (new machine, disaster recovery, etc.).

**Last updated:** 2026-03-15

---

## Step 1 — Prerequisites

```bash
node >= 18
docker + docker compose
git
npm install -g openclaw
```

---

## Step 2 — Clone repos

```bash
# Rails app
git clone https://github.com/amcritchie/boodle_scraper /home/alex/.openclaw/workspace/boodle_scraper

# Workspace (scripts, memory, config)
git clone https://github.com/amcritchie/workspace /home/alex/.openclaw/workspace
# scripts/ lives at workspace/scripts/
# If no separate workspace repo, restore scripts/ manually from backup
```

---

## Step 3 — Start the Rails app

```bash
cd /home/alex/.openclaw/workspace/boodle_scraper
docker compose up --build -d

# Verify
docker ps | grep boodle
curl http://localhost:3000/api/news
```

Run migrations:
```bash
docker exec boodle_scraper-web-1 bin/rails db:migrate
```

Seed fresh DB:
```bash
docker exec boodle_scraper-web-1 bin/rails runner "load 'db/seed_agents.rb'"
docker exec boodle_scraper-web-1 bin/rails runner "load 'db/seed_teams.rb'"
```

---

## Step 4 — Restore credentials

### workspace/.secrets
```bash
X_BEARER_TOKEN=...                  # X API v2 Bearer Token (Schefter polling)
ANTHROPIC_API_KEY=...               # Claude API key
TM_X_API_KEY=...                    # Turf Monster X OAuth 1.0a
TM_X_API_SECRET=...
TM_X_ACCESS_TOKEN=...
TM_X_ACCESS_SECRET=...
```

### openclaw.json Discord bot tokens
Four bots — each agent has its own. All stored under `channels.discord.accounts.<slug>.token`:

| Agent | Slug | Bot Name | Discord ID |
|-------|------|----------|------------|
| Alex | `alex` | Alex | `1481150857809760399` |
| Mason | `mason` | Mason | — |
| Mack | `mack` | Mack | — |
| Turf Monster | `turf-monster` | Turf Monster | — |

To get a token: `python3 -c "import json; d=json.load(open('/home/alex/.openclaw/openclaw.json')); print(d['channels']['discord']['accounts']['alex']['token'])"`
Replace `alex` with `mason`, `mack`, or `turf-monster` as needed.

### openclaw.json agent config
Each agent entry needs:
- `id` — agent slug
- `model` — their default LLM
- `workspace` — path to their workspace dir
- `heartbeat.every` — heartbeat interval

**Agent models (as of 2026-03-15):**
| Agent | Model |
|-------|-------|
| alex | `anthropic/claude-sonnet-4-6` |
| mason | `anthropic/claude-sonnet-4-6` |
| mack | `google/gemini-3-flash-preview` |
| turf-monster | `xai/grok-3` |

### Agent auth-profiles.json
Each agent's auth lives at `~/.openclaw/agents/<slug>/agent/auth-profiles.json`.
Copy the alex auth-profiles.json to all agents as a base, then add provider-specific keys:

```json
{
  "version": 1,
  "profiles": {
    "anthropic:default": { "type": "api_key", "provider": "anthropic", "key": "sk-ant-..." },
    "openai:default":    { "type": "api_key", "provider": "openai",    "key": "sk-proj-..." },
    "google:default":    { "type": "api_key", "provider": "google",    "key": "AIza..." }
  }
}
```

All agents should have all three providers configured so fallover works.

Discord Guild ID: `1332466565203103744`
Primary channel: `#lobster-tank` (`1479973077021495478`)
Alex Discord bot ID: `1481150857809760399`
Mr. McRitchie Discord ID: `536552944271753216`

---

## Step 5 — Restore OpenClaw cron jobs

All script jobs use this wrapper:
```bash
cd /home/alex/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/<script>.js
```

⚠️ Discord delivery: always use `"to": "channel:1479973077021495478"` — NOT `"channel": "..."` (causes delivery errors).

### Pipeline cron jobs

| Name | Agent | Schedule | Script |
|------|-------|----------|--------|
| poll-schefter | alex | `*/10 * * * *` | `poll-schefter.js` |
| turf-monster-enrich-news | turf-monster | `*/10 * * * *` | `enrich-news.js` |
| opinion-news | alex | `*/15 * * * *` | `opinion-news.js` |
| edit-post (x_post) | mason | `*/15 * * * *` | `edit-post.js` |
| edit-reply-post (x_reply) | alex | `*/15 * * * *` | `edit-reply-post.js` |
| post-to-x (x_post) | alex | `*/30 * * * *` | `post-to-x.js` |
| post-reply-to-x (x_reply) | alex | `*/10 * * * *` | `post-reply-to-x.js` |

### Agent ops cron jobs

| Name | Agent | Schedule | Notes |
|------|-------|----------|-------|
| alex-dev-loop | alex | `0 * * * *` | Alex dev loop: review done → finish in_progress → pick up queued → start new |
| mason-task-refinement | mason | `0 * * * *` | Mason dev loop: finish in_progress → pick up queued → refine new |
| mack-dev-loop | mack | `0 * * * *` | Mack dev loop: finish in_progress → pick up queued |
| sync-cron-usage | alex | `0 * * * *` | Syncs OpenClaw cron token usage to Rails (task #70) |
| TM X Session Health Check | mack | `0 9 * * *` MDT | Checks `.x-session.json` age |
| House Burns Down Protocol | alex | `0 3 * * *` MDT | Nightly doc audit + writes nightly-sync.md |
| mack-daily-ops | mack | `0 4 * * *` MDT | Memory cleanup + LLM health + token spend → #lobster-tank |
| alex-daily-brief | alex | `0 5 * * *` MDT | Weather + top story + blockers → #lobster-tank |
| mason-dev-report | mason | `0 6 * * *` MDT | Tasks completed/blocked → #lobster-tank |
| tm-gm-checkin | turf-monster | `0 7 * * *` MDT | Posts "Hi" to #lobster-tank |

### Alex dev-loop cron payload
```
You are Alex, CEO & Senior Engineer of McRitchie Studio. Run your dev loop.
Read your role at /home/alex/.openclaw/workspace/boodle_scraper/docs/agents/agents/alex/role.md

1. Review Done (first pass) → archive clean / fix bad / notify #lobster-tank
2. Finish In Progress (alex tasks)
3. Pick up Queued (alex tasks) → start → execute → complete
4. Start New (tasks alex can own) → move to in_progress and build
5. Review Done (second pass) → catch anything that landed during loop
6. Nothing? HEARTBEAT_OK
```

### Mason task-refinement cron payload
```
You are Mason, CPO & Senior Engineer of McRitchie Studio. Run your dev loop.
Read your role at /home/alex/.openclaw/workspace/boodle_scraper/docs/agents/agents/mason/role.md

1. Finish In Progress (mason tasks)
2. Pick up Queued (mason tasks) → start → execute → complete
3. Refine New tasks → enrich + queue, or @Alex in #lobster-tank with 🐊🔍 questions
4. Nothing? HEARTBEAT_OK
```
- Agent: mason | Schedule: `*/20 * * * *` | model: `anthropic/claude-sonnet-4-6` | timeoutSeconds: 180 | delivery: none

### sync-cron-usage cron payload
```
Run the cron usage sync script:
cd /home/alex/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/sync-cron-usage.js
```
- Agent: alex | Schedule: `0 * * * *` | model: `anthropic/claude-haiku-4-5` | timeoutSeconds: 60 | delivery: none

### Alex Daily Brief cron payload
```
You are the Alex Agent, CEO of McRitchie Studio. Compose and post the Daily Brief to #lobster-tank.

SECTION 1 — WEATHER: curl -s 'wttr.in/Denver?format=%l:+%C+%t+(%f+feels+like)+💧%h+💨%w'
SECTION 2 — TURF MONSTER'S TOP HIT: curl -s 'http://localhost:3000/api/news?stage=posted&per_page=20' — pick most notable from yesterday
SECTION 3 — BLOCKERS & IDEAS: app health check + any known pipeline issues
SECTION 4 — HOUSE BURNS DOWN REPORT: cat /home/alex/.openclaw/workspace/boodle_scraper/docs/agents/system/nightly-sync.md

Post to #lobster-tank. Sign off: — Alex 🦞
```
- Agent: alex | Schedule: `0 5 * * *` America/Denver | timeoutSeconds: 300 | delivery: `{ "mode": "announce", "to": "channel:1479973077021495478" }`
- ⚠️ timeoutSeconds must be 300+ — job does weather + API calls + Discord post

### Mack dev-loop cron payload
```
You are Mack, CTO & Infrastructure Lead of McRitchie Studio. Run your dev loop.
Read your role at /home/alex/.openclaw/workspace/boodle_scraper/docs/agents/agents/mack/role.md

1. Finish In Progress (mack tasks)
2. Pick up Queued (mack tasks) → start → execute → complete
3. Nothing? HEARTBEAT_OK
```

---

## Step 6 — Verify pipeline

```bash
# App health
curl http://localhost:3000/api/news | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['total_count'], 'records')"

# Agents
curl http://localhost:3000/api/agents/agents | python3 -c "import sys,json; d=json.load(sys.stdin); [print(a['slug'], a['status']) for a in d['agents']]"

# Manual pipeline run
cd /home/alex/.openclaw/workspace && set -a && source .secrets && set +a
node scripts/poll-schefter.js
node scripts/enrich-news.js
node scripts/opinion-news.js

# Check task board
curl http://localhost:3000/api/agents/tasks | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['total_count'], 'tasks')"

# Check cron jobs
openclaw cron list
```

---

## Agent Roster

| Agent | Slug | Role | Model | Heartbeat |
|-------|------|------|-------|-----------|
| Alex | alex | CEO & Senior Engineer — primary dev, quality gate | claude-sonnet-4-6 | 30m |
| Mason | mason | CPO & Senior Engineer — second line dev, task refinement | claude-sonnet-4-6 | 60m |
| Mack | mack | CTO — infra, Docker, monitoring, error protocols | gemini-3-flash-preview | 30m |
| Turf Monster | turf-monster | CMO — content, enrichment, X voice | grok-3 | 30m |

---

## Dev Philosophy (established 2026-03-15)

**Alex is the primary developer.** When Mr. McRitchie and Alex scope something together in chat, it goes straight to `in_progress` or gets built inline — no task queue overhead.

**Mason is the second line.** Same skills, same taste, same standards. Handles parallel workstreams on big projects. Ancillary features get dropped into `new` and Mason picks them up via cron.

**Alex owns the quality gate.** Reviews `done` tasks: archive clean ones (notify Mr. McRitchie in #lobster-tank), fix bad ones directly.

**Heartbeat = ambient awareness only:** Discord monitoring, pipeline fires, responding to humans. NOT for scheduled/mechanical work (that's cron).

### Alex dev loop (Code Push button or manual)
1. Review Done → archive clean / fix bad
2. Finish In Progress
3. Pick up Queued
4. Start New I can own
5. Review Done again (second pass)

### Mason dev loop (cron every 60min + Code Push)
1. Finish In Progress → 2. Pick up Queued → 3. Refine New

### Mack dev loop (Code Push)
1. Finish In Progress → 2. Pick up Queued

---

## Task Board

URL: `http://localhost:3000/agents`
Stages: `new → queued → in_progress → done → archived` (also: `failed`)

```bash
# Create task
curl -s -X POST http://localhost:3000/api/agents/tasks \
  -H "Content-Type: application/json" \
  -d '{"task":{"title":"...","description":"...","priority":1,"agent_slug":"mason"}}'

# Transition
curl -s -X PATCH http://localhost:3000/api/agents/tasks/:id/transition \
  -H "Content-Type: application/json" \
  -d '{"transition":"queue"}'   # queue | start | complete | fail | archive
```

**Code Push button** (pending task #73):
- Lives on /agents page
- Triggers Alex → Mason → Mack loops sequentially
- `POST /api/agents/push`

---

## News Pipeline Details

### Stage flow
Each Schefter tweet → TWO records: `x_post` (main tweet) + `x_reply` (meme reply)

```
poll-schefter → enrich-news → opinion-news → edit-post → [human queues] → post-to-x
                                           ↘ creates x_reply sibling → edit-reply-post → [human queues] → post-reply-to-x
```

Full stage sequence: `new → reviewed → content → edited → queued → posted → archived`

### Rank system
- Gap-based 100s spacing, DESC order (highest rank = top priority = top of kanban column)
- `PATCH /api/news/:id/rank` with `before_id` / `after_id` for drag-drop reorder
- "Organize Ranks" button re-sequences all stages to clean 100s

### Dedup protection
- `validates :url, uniqueness: { scope: :content_type }, on: :create`
- `on: :create` is critical — without it stage transitions fail on duplicate-URL records

### Human approval (emoji reactions)
- 🔥 on a TM Discord message → moves news item from `edited` → `queued`
- 🍻 on a TM Discord message → queues + immediately posts to X
- Processed via agent heartbeat

---

## Token Usage Logging

All scripts that make LLM API calls must log usage via `scripts/lib/usage-tracker.js`:
```js
const { logUsage } = require('./lib/usage-tracker');
await logUsage('agent-slug', 'claude-haiku-4-5', response.usage, 'script-name.js');
```

Rails endpoints:
- `GET/POST /api/agents/usages` — daily rollup by agent+model
- `GET/POST /api/agents/activities` — per-call event log

---

## Known Gotchas

- **Migrations**: always run inside Docker — `docker exec boodle_scraper-web-1 bin/rails db:migrate`
- **OpenClaw delivery config**: use `"to": "channel:ID"` NOT `"channel": "ID"` in cron delivery
- **Mason model**: must be `anthropic/claude-sonnet-4-6` — was misconfigured as `openai/gpt-4o` causing 25+ consecutive errors
- **Mack model**: must be `google/gemini-3-flash-preview` — was misconfigured as `anthropic/claude-sonnet-4-6`
- **Auth profiles**: each agent needs its own `auth-profiles.json` with provider keys — gateway does NOT share alex's auth with other agents automatically
- **x_reply 403**: X API blocks TM from replying to Schefter's tweets. Fix: change `originalTweetId` in `post-reply-to-x.js` to use `x_post_id` (reply to TM's own tweet). TM can reply to its own tweets (HTTP 201 confirmed).
- **Alex Daily Brief timeout**: needs `timeoutSeconds: 300` minimum — job does a lot (weather + API + Discord post)

---

## Common Commands

```bash
# Restart Rails app
docker compose restart web

# View logs
docker logs -f boodle_scraper-web-1

# Rails console
docker exec -it boodle_scraper-web-1 bin/rails console

# Run migrations
docker exec boodle_scraper-web-1 bin/rails db:migrate

# Run a script manually
cd /home/alex/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/poll-schefter.js

# Check cron jobs
openclaw cron list

# Post to #lobster-tank (alex bot)
ALEX_TOKEN=$(python3 -c "import json; d=json.load(open('/home/alex/.openclaw/openclaw.json')); print(d['channels']['discord']['accounts']['alex']['token'])")
curl -s -X POST "https://discord.com/api/v10/channels/1479973077021495478/messages" \
  -H "Authorization: Bot $ALEX_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "your message here"}'

# Force a cron job run
openclaw cron run <jobId>
```

---

## Pending Work (as of 2026-03-15)

| # | Title | Agent | Notes |
|---|-------|-------|-------|
| ~~69~~ | ~~usage-tracker.js + wire into scripts~~ | ~~mason~~ | ✅ Done |
| ~~70~~ | ~~sync-cron-usage.js~~ | ~~mack~~ | ✅ Done |
| ~~71~~ | ~~parse-session-usage.js~~ | ~~mack~~ | ✅ Done |
| ~~72~~ | ~~archived stage for AgentTask~~ | ~~mason~~ | ✅ Done |
| 73 | Code Push button + /api/agents/push | mason | Triggers all dev loops |
| 64-68 | Video pipeline (Content model, refine, generate, render) | mason/mack | Kling integration |
| — | x_reply 403 fix | mack | Reply to TM's own x_post_id instead of Schefter |
