# Bootstrap Guide — McRitchie Studio

Use this if the system needs to be rebuilt from scratch (new machine, disaster recovery, etc.).

Last updated: 2026-03-15

---

## Step 1 — Prerequisites

```bash
# Required on the host
node >= 18
docker + docker compose
git
npm (for openclaw)
```

---

## Step 2 — Clone the repo

```bash
git clone https://github.com/amcritchie/boodle_scraper /home/alex/.openclaw/workspace/boodle_scraper
```

Also restore the workspace scripts (not in the boodle_scraper repo):
```bash
git clone https://github.com/amcritchie/boodle_scraper /home/alex/.openclaw/workspace
# scripts/ lives at workspace/scripts/
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

Run any pending migrations:
```bash
docker exec boodle_scraper-web-1 bin/rails db:migrate
```

Seed agents (if fresh DB):
```bash
docker exec boodle_scraper-web-1 bin/rails runner "load 'db/seed_agents.rb'"
```

Seed ranks on existing news records (run after first migration):
```bash
docker exec boodle_scraper-web-1 bin/rails runner \
  "News.order(:created_at).each_with_index { |n, i| n.update_column(:rank, (i+1)*100) }"
```

---

## Step 4 — Restore credentials

Create `/home/alex/.openclaw/workspace/.secrets`:
```bash
X_BEARER_TOKEN=...
DISCORD_BOT_TOKEN=...         # Turf Monster's Discord bot token
ANTHROPIC_API_KEY=...
TM_X_API_KEY=...
TM_X_API_SECRET=...
TM_X_ACCESS_TOKEN=...
TM_X_ACCESS_SECRET=...
```

Restore `/home/alex/.openclaw/openclaw.json` with Discord bot tokens for:
- `alex` — CEO bot
- `mason` — product bot
- `mack` — infra bot
- `turf-monster` — content/posting bot

Discord Guild ID: `1332466565203103744`
Primary channel: `#lobster-tank` (`1479973077021495478`)

---

## Step 5 — Restore OpenClaw cron jobs

Re-create these cron jobs via the OpenClaw cron tool:

| Name | Agent | Schedule | Payload command |
|------|-------|----------|---------|
| poll-schefter | alex | `*/10 * * * *` | `node scripts/poll-schefter.js` |
| turf-monster-enrich-news | turf-monster | `*/10 * * * *` | `node scripts/enrich-news.js` |
| edit-post (x_post) | mason | `*/15 * * * *` | `node scripts/edit-post.js` |
| edit-reply-post (x_reply) | alex | `*/15 * * * *` | `node scripts/edit-reply-post.js` |
| emoji-approval | alex | `*/2 * * * *` | Approves emoji reactions on news records |
| mason-task-refinement | mason | `*/20 * * * *` | Mason refines `new` tasks, queues or @asks Alex |
| opinion-news | alex | `*/15 * * * *` | `node scripts/opinion-news.js` |
| post-reply-to-x (x_reply) | alex | `*/10 * * * *` | `node scripts/post-reply-to-x.js` |
| post-to-x (x_post) | alex | `*/30 * * * *` | `node scripts/post-to-x.js` |
| TM X Session Health Check | mack | `0 9 * * *` America/Denver | Mack checks Turf Monster's X session health |
| House Burns Down Protocol | alex | `0 3 * * *` America/Denver | Audits docs/agents vs live system, updates stale files, writes nightly-sync.md |
| Alex Daily Brief | alex | `0 5 * * *` America/Denver | Weather + top story + blockers + house burns down recap → #lobster-tank |

All script jobs use this wrapper:
```bash
cd /home/alex/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/<script>.js
```

Delivery format for Discord-posting jobs:
```json
{ "mode": "announce", "to": "channel:1479973077021495478" }
```
> ⚠️ Use `to`, NOT `channel`. Using `channel` directly causes a delivery error (30 consecutive errors learned the hard way).

---

## Step 6 — Verify pipeline

```bash
# Check news records
curl http://localhost:3000/api/news | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['total_count'], 'records')"

# Check agents
curl http://localhost:3000/api/agents | python3 -c "import sys,json; d=json.load(sys.stdin); [print(a['slug'], a['status']) for a in d['agents']]"

# Manual poll test
cd /home/alex/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/poll-schefter.js

# Manual enrich test
cd /home/alex/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/enrich-news.js
```

---

## Agent Roster

| Agent | Slug | Role | Discord Bot |
|-------|------|------|-------------|
| Alex Agent | alex | CEO — coordination, scoping, delegation | alex bot |
| Mason | mason | CPO — product, custom apps, UI | mason bot |
| Mack | mack | CTO — infrastructure, Docker, DB | mack bot |
| Turf Monster | turf-monster | CMO — content, enrichment, X posting | turf-monster bot |

**Domain rules:**
- Mason owns product (any custom app feature — backend + frontend as a vertical slice)
- Mack owns infrastructure (Docker, deployment, DB performance)
- Turf Monster owns content (enrichment, opinion, tone, voice)
- Alex breaks ties, escalates to operator for irreversible/budget decisions

---

## Task Board

URL: `http://localhost:3000/agents`

All work is created as tasks in the board before delegating. Discord is for comms only.

```bash
# Create a task
curl -s -X POST http://localhost:3000/api/agents/tasks \
  -H "Content-Type: application/json" \
  -d '{"task":{"title":"...","description":"...","stage":"new","priority":0,"agent_slug":"mason"}}'

# Transition a task
curl -s -X PATCH http://localhost:3000/api/agents/tasks/:id/transition \
  -H "Content-Type: application/json" \
  -d '{"transition":"start"}'
```

---

## News Pipeline Details

### Stage flow
Each Schefter tweet produces **two records**: an `x_post` (main tweet) and an `x_reply` (meme reply).

**x_post pipeline:**
```
new → reviewed → content → edited → queued → posted → archived
                                        ↑
                    human editorial gate
                    (drag edited → queued in kanban to approve for X posting)
```

**x_reply pipeline (runs in parallel):**
`opinion-news` creates sibling → `edit-reply-post` picks meme → human queues → `post-reply-to-x`

### Rank system
- All news records have a `rank` integer ordered in gaps of 100 (100, 200, 300...)
- Controlled via `PATCH /api/news/:id/rank` with optional `before_id` / `after_id`
- Drag-and-drop within kanban columns reorders by rank in real time
- Drop on card = midpoint split; drop on empty column space = append to end

### Dedup protection
- `validates :url, uniqueness: true, on: :create` in News model
- ⚠️ Must be `on: :create` — without it, stage transitions fail on duplicate-URL records
- `poll-schefter.js` pre-checks via `newsExists()` before saving
- All scripts: Discord only fires after DB save is confirmed

### Discord message templates
Templates centralized in `scripts/lib/discord-templates.js` (8 functions, refactored 2026-03-13).

| Script | Format |
|--------|--------|
| poll-schefter | `🐊🏈 **Adam Schefter** · time\n🔗 [handle](url)` |
| enrich-news | `🐊🤖 **title_short**\n- 👤 person\n- 🏈 team\nsummary\n🔗 [author](url)` |
| opinion-news | `🐊🤔 **title_short**\n*feeling • what_happened*\nopinion\n🔗 [author](url)` |
| edit-post | `feeling_emoji **title_short**\n- 👤 person\n- 🏈 team\n- #️⃣ hashtag\nopinion` |
| post-to-x | `feeling_emoji **title_short**\nopinion\n🔗 [Turf Monster](x_post_url)` |
| edit-reply-post | `🐊💬 **title_short** [REPLY]\n- 👤 person\n- 🏈 team\n- 🖼️ meme filename` |
| post-reply-to-x | `🐊💬 **title_short** [REPLY]\n🔗 replied to Schefter url` |

---

## Known Gotchas

- **Migrations**: always run inside Docker — `docker exec boodle_scraper-web-1 bin/rails db:migrate`
- **Tailwind**: app uses CDN version — no build step needed but can cause layout reflow during drag-and-drop
- **HubSpot script**: gated behind `content_for :hubspot` — don't load globally or it causes scroll jumps on the news kanban
- **Turbo scroll**: news page has `turbo-visit-control: reload` to prevent Turbo from restoring stale scroll position
- **x_reply 403**: X API blocks TM from replying directly to Schefter's tweets (his account restricts replies). Fix: change `originalTweetId` in `post-reply-to-x.js` to use the x_post record's `x_post_id` (reply to TM's own tweet instead). TM can reply to its own tweets (confirmed HTTP 201).

---

## Common Commands

```bash
# Restart app
docker compose restart web

# View app logs
docker logs -f boodle_scraper-web-1

# Rails console
docker exec -it boodle_scraper-web-1 bin/rails console

# Check cron jobs
openclaw cron list

# Post to #lobster-tank manually (alex bot)
ALEX_TOKEN=$(python3 -c "import json; d=json.load(open('/home/alex/.openclaw/openclaw.json')); print(d['channels']['discord']['accounts']['alex']['token'])")
curl -s -X POST "https://discord.com/api/v10/channels/1479973077021495478/messages" \
  -H "Authorization: Bot $ALEX_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "your message here"}'
```
