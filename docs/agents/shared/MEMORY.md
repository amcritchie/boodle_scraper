# McRitchie Studio — Shared Agent Memory

This file is the system's collective brain. All agents can read and write it.
Keep entries current. Remove outdated info. Last updated: 2026-03-12.

---

## System Status

| Component | Status | Notes |
|-----------|--------|-------|
| Rails app | 🟢 Running | Docker container `boodle_scraper-web-1`, port 3000 |
| PostgreSQL | 🟢 Healthy | Docker container `boodle_scraper-db-1` |
| Migrations | 🟢 Current | Latest: `add_rank_to_news` (2026-03-12) |
| Agents seeded | 🟢 Done | 4 agents, 14 skills, 13 assignments |
| News pipeline | 🟢 Live | Polling → enriching → opinion → posting to X |
| Daily Brief | 🟢 Scheduled | 5am MDT, Alex posts to #lobster-tank |

---

## Active Agents

| Agent | Slug | Role | Model | Status |
|-------|------|------|-------|--------|
| Alex Agent | alex | CEO | claude-sonnet | Active |
| Mack | mack | CTO | claude-sonnet | Active |
| Mason | mason | CPO | claude-sonnet | Active |
| Turf Monster | turf-monster | CMO | claude-sonnet | Active |

---

## Infrastructure

- **Repo:** `https://github.com/amcritchie/boodle_scraper`
- **Local path:** `/home/alex/.openclaw/workspace/boodle_scraper`
- **App files are live-mounted** into Docker — edits in the workspace take effect immediately
- **Docker:**
  ```bash
  docker compose up --build -d          # start everything
  docker ps | grep boodle               # verify containers
  ```
- **Run migrations:**
  ```bash
  docker exec boodle_scraper-web-1 bin/rails db:migrate
  ```
- **Rails console:**
  ```bash
  docker exec -it boodle_scraper-web-1 bin/rails console
  ```
- **Logs:**
  ```bash
  docker logs -f boodle_scraper-web-1
  ```

> ⚠️ Do NOT use `bin/rails` directly — Ruby is only inside the container. Always use `docker exec boodle_scraper-web-1 bin/rails ...`

---

## News Pipeline — Active as of 2026-03-12

Full end-to-end NFL news pipeline sourcing from Adam Schefter's X account.

### Stage Flow
```
new → reviewed → content → edited → posted → archived
                               ↑
                    human editorial gate
                    (move content → edited to approve for posting)
```

### Scripts (all in `~/.openclaw/workspace/scripts/`)

| Script | Cron | What it does |
|--------|------|-------------|
| `poll-schefter.js` | Every 5 min | Polls X API → saves to DB → Discord announce |
| `enrich-news.js` | Every 10 min | AI enrichment → `reviewed` + Discord summary |
| `opinion-news.js` | Every 15 min | Turf Monster writes hot take → `content` |
| `post-to-x.js` | Every 30 min | Posts `edited` record to TM's X → saves `x_post_id` + `x_post_url` → `posted` |

### Running scripts manually
```bash
cd ~/.openclaw/workspace
set -a && source .secrets && set +a
node scripts/poll-schefter.js
node scripts/enrich-news.js
node scripts/opinion-news.js
node scripts/post-to-x.js
```

### News model key fields

| Field | Stage populated | Description |
|-------|-----------------|-------------|
| `title` | new | Raw tweet text |
| `url` | new | Original Schefter tweet URL (unique, enforced on create) |
| `author` | new | Twitter handle |
| `published_at` | new | Tweet timestamp |
| `title_short` | reviewed | 3-5 word punchy headline (AI) |
| `primary_person` | reviewed | Full name of main subject |
| `primary_team` | reviewed | "City Team Name" format |
| `summary` | reviewed | 2-3 sentence AI summary |
| `selected_image` | reviewed | Path e.g. `/images/news/<tweet_id>.jpg` |
| `opinion` | content | Turf Monster hot take |
| `feeling` / `feeling_emoji` | content | Emotional tone |
| `what_happened` | content | 1-2 word event label (Signed, Traded, etc.) |
| `rank` | any | Integer ordering (100, 200, 300...) — controls pipeline pickup order |
| `x_post_id` | posted | X tweet ID saved after posting |
| `x_post_url` | posted | Full X tweet URL saved after posting |

### Rank system (added 2026-03-12)
- Records are ordered by `rank ASC, created_at DESC`
- Ranks use gap-based 100s spacing (100, 200, 300...) for easy insertion
- Midpoint insert: drop between 200 and 300 → 250
- Append to end: max rank + 100, rounded to nearest 100
- API: `PATCH /api/news/:id/rank` with optional `before_id` / `after_id`
- Drag-and-drop within kanban columns respects rank order

### Dedup protection (added 2026-03-12)
- `validates :url, uniqueness: true, on: :create` — blocks duplicate URLs on creation only
- `poll-schefter.js` pre-checks `newsExists(url)` before saving
- `saveToRails()` handles 422 gracefully — logs `[SKIP]` instead of erroring
- Discord notification only fires when record actually saves

### Discord message templates
All scripts gate Discord behind a confirmed DB save — no ghost announcements.

| Script | Template |
|--------|---------|
| `poll-schefter.js` | `🐊🏈 **Adam Schefter** · 6:32 PM\n🔗 [AdamSchefter](url)` |
| `enrich-news.js` | `🐊🤖 **title_short**\n- 👤 person\n- 🏈 team\nsummary\n🔗 [author](url)` |
| `opinion-news.js` | `🐊🤔 **title_short**\n*feeling • what_happened*\nopinion\n🔗 [author](url)` |
| `post-to-x.js` | `feeling_emoji **title_short**\nopinion\n🔗 [Turf Monster](x_post_url)` |

Posts to `#lobster-tank` (`1479973077021495478`) via the Discord bots.

### Required credentials (in `~/.openclaw/workspace/.secrets`)
```bash
X_BEARER_TOKEN         # X API v2 read-only token for Schefter polling
DISCORD_BOT_TOKEN      # Turf Monster Discord bot token
ANTHROPIC_API_KEY      # For AI enrichment + opinion generation
TM_X_API_KEY           # Turf Monster X app consumer key
TM_X_API_SECRET        # Turf Monster X app consumer secret
TM_X_ACCESS_TOKEN      # TM account access token
TM_X_ACCESS_SECRET     # TM account access secret
```

---

## Task Board

All work flows through the Boodle task board at `http://localhost:3000/agents`.

**API:**
```bash
POST   /api/agents/tasks              # create task
PATCH  /api/agents/tasks/:id/assign   # assign to agent slug
PATCH  /api/agents/tasks/:id/transition  # body: { "transition": "queue|start|complete|fail" }
GET    /api/agents/tasks              # list tasks
```

**Task stages:** `new → queued → in_progress → done / failed`

**Protocol:**
- Alex creates tasks in the board BEFORE delegating work
- Discord #lobster-tank is for updates, blockers, group planning, and retros
- Never use Discord as a substitute for a task

---

## Cron Jobs

| Job | Agent | Schedule | Delivery | Status |
|-----|-------|----------|----------|--------|
| `poll-schefter` | alex | every 5 min | none | ✅ |
| `turf-monster-enrich-news` | turf-monster | every 10 min | none | ✅ |
| `opinion-news (turf-monster)` | alex | every 15 min | none | ✅ |
| `post-to-x (turf-monster)` | alex | every 30 min | none | ✅ |
| `Mack Hourly LLM Ops Report` | mack | every hour | `#lobster-tank` | ✅ |
| `Mack Hourly Ops Report` | mack | every hour | `#lobster-tank` | ❌ broken delivery |
| `Alex Daily Brief` | alex | 5am MDT | `#lobster-tank` | ✅ |

**Discord delivery format** (correct):
```json
{ "mode": "announce", "to": "channel:1479973077021495478" }
```
> ⚠️ Use `to`, NOT `channel`. Using `channel` directly causes a delivery error.

---

## News Kanban UI

- Board: `http://localhost:3000/news`
- Columns: New → Reviewed → Content → Edited → Posted
- Drag card between columns = stage transition
- Drag card within column = rank reorder (with drop indicator line)
- Drop on empty column space = append to end of column (highest rank + 100)
- Card layout (content/edited/posted): feeling row (emoji + feeling), then opinion, then metadata row (what_happened + rank badge)

---

## API Integrations

| Service | Key Location | Status | Notes |
|---------|-------------|--------|-------|
| X API v2 (polling) | `workspace/.secrets` | 🟢 Active | Bearer Token for Schefter |
| X API OAuth 1.0a (posting) | `workspace/.secrets` | 🟢 Active | TM posting, 4 credentials |
| Anthropic | `openclaw.json` + `.secrets` | 🟢 Active | Enrichment + opinion |
| Discord | `openclaw.json` | 🟢 Active | 4 bots: alex, mason, mack, turf-monster |
| SportRadar | `.env` | ⚪ Not configured | Trial: 1000 req/day |

---

## Strategic Decisions

- **2026-03-10** — Bootstrapped McRitchie Studio. 4-agent setup: Alex (CEO), Mack (CTO), Mason (CPO), Turf Monster (CMO).
- **2026-03-11** — Full NFL news pipeline built. Schefter → enrich → TM opinion → X post. Human gate at `edited`.
- **2026-03-11** — TM X account connected with OAuth 1.0a. Posts include opinion + tweet image.
- **2026-03-11** — `x_post_id` + `x_post_url` columns added. `post-to-x.js` saves both on post.
- **2026-03-11** — Alex Daily Brief scheduled: 5am MDT → weather + top story + blockers/ideas → `#lobster-tank`.
- **2026-03-12** — `rank` column added to news. Gap-based 100s ordering. `PATCH /api/news/:id/rank` endpoint live.
- **2026-03-12** — Within-column drag reorder added to kanban. Drop indicators on hover. Cross-column card drop fixed.
- **2026-03-12** — URL uniqueness validation added to News model (`on: :create` only — prevents transition breakage).
- **2026-03-12** — Duplicate enrich cron removed (`review-news`). Single enrich job at 10 min.
- **2026-03-12** — Pipeline cadence tightened: opinion every 15 min, post-to-x every 30 min.
- **2026-03-12** — Task board established as source of truth. Discord = comms only.

---

## Current Projects

### News Pipeline
- Status: 🟢 Live — all cron jobs running
- Source: Adam Schefter (@AdamSchefter) tweets
- Human gate: move records from `content` → `edited` to approve for X posting
- Rank system: controls pipeline pickup order + kanban display order

### Boodle Dashboard
- Status: 🟢 Running locally
- URL: http://localhost:3000
- News board: http://localhost:3000/news
- Agents dashboard: http://localhost:3000/agents

---

## Known Issues / Watch List

- `Mack Hourly Ops Report` cron broken — fix: change delivery to `"to": "channel:1479973077021495478"`
- `primary_team_slug` and `primary_person_slug` fields not yet auto-populated
- ESPN article pipeline not yet built
- No production deployment configured
- Pre-existing duplicate news URLs in DB (from before dedup fix) — may cause issues if records are re-ingested

---

*To update: edit directly and commit. Include a date on significant changes.*
*To keep clean: remove resolved issues, update status columns, don't let it go stale.*
