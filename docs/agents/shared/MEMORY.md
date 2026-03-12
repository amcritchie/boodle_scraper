# McRitchie Studio — Shared Agent Memory

This file is the system's collective brain. All agents can read and write it.
Keep entries current. Remove outdated info. Last updated: 2026-03-11.

---

## System Status

| Component | Status | Notes |
|-----------|--------|-------|
| Rails app | 🟢 Running | Docker container `boodle_scraper-web-1`, port 3000 |
| PostgreSQL | 🟢 Healthy | Docker container `boodle_scraper-db-1` |
| Migrations | 🟢 Current | Latest: `add_x_post_url_to_news` (2026-03-11) |
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

## News Pipeline — Active as of 2026-03-11

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
| `enrich-news.js` | Every 10–30 min | AI enrichment → `reviewed` + Discord summary |
| `opinion-news.js` | Every hour | Turf Monster writes hot take → `content` + Discord |
| `post-to-x.js` | Every hour | Posts `edited` record to TM's X → saves `x_post_id` + `x_post_url` → `posted` + Discord |

### Running scripts manually
```bash
cd ~/.openclaw/workspace
set -a && source .secrets && set +a
node scripts/poll-schefter.js
node scripts/enrich-news.js
node scripts/opinion-news.js
node scripts/post-to-x.js
```

### News record fields populated per stage

| Stage | Fields populated |
|-------|-----------------|
| `new` | `url`, `author`, `published_at`, `title` (raw tweet) |
| `reviewed` | + `title_short`, `primary_person`, `primary_team`, `summary`, `selected_image` |
| `content` | + `opinion`, `feeling`, `feeling_emoji`, `what_happened` |
| `posted` | + `x_post_id` (X tweet ID), `x_post_url` (full X URL) |

Images saved to: `boodle_scraper/public/images/news/<tweet_id>.jpg`

### Discord notifications
Every stage transition posts to `#lobster-tank` (`1479973077021495478`):
- **reviewed** — review card with title, person, team, summary
- **content** — Turf Monster's full hot take
- **posted** — tweet URL announcement

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

## Cron Jobs

| Job | Agent | Schedule | Delivery | Status |
|-----|-------|----------|----------|--------|
| `poll-schefter` | alex | every 5 min | none | ✅ |
| `turf-monster-enrich-news` | turf-monster | every 10 min | none | ✅ |
| `review-news (turf-monster)` | alex | every 30 min | none | ✅ |
| `opinion-news (turf-monster)` | alex | every hour | none | ✅ |
| `post-to-x (turf-monster)` | alex | every hour | none | ✅ |
| `Mack Hourly LLM Ops Report` | mack | every hour | `#lobster-tank` | ✅ |
| `Mack Hourly Ops Report` | mack | every hour | `#lobster-tank` | ❌ broken delivery |
| `Alex Daily Brief` | alex | 5am MDT | `#lobster-tank` | ✅ |

**Discord delivery format** (correct):
```json
{ "mode": "announce", "to": "channel:1479973077021495478" }
```
> ⚠️ Use `to`, NOT `channel`. Using `channel` directly causes a delivery error.

---

## API Integrations

| Service | Key Location | Status | Notes |
|---------|-------------|--------|-------|
| X API v2 (polling) | `workspace/.secrets` | 🟢 Active | Bearer Token for Schefter |
| X API OAuth 1.0a (posting) | `workspace/.secrets` | 🟢 Active | TM posting, 4 credentials |
| Anthropic | `openclaw.json` + `.secrets` | 🟢 Active | Enrichment + opinion |
| Discord | `openclaw.json` + `.secrets` | 🟢 Active | 4 bots connected |
| SportRadar | `.env` | ⚪ Not configured | Trial: 1000 req/day |

---

## Strategic Decisions

- **2026-03-10** — Bootstrapped McRitchie Studio. 4-agent setup: Alex (CEO), Mack (CTO), Mason (CPO), Turf Monster (CMO).
- **2026-03-11** — Full NFL news pipeline built. Schefter → enrich → TM opinion → X post. Human gate at `edited`.
- **2026-03-11** — TM X account connected with OAuth 1.0a. Posts include opinion + tweet image.
- **2026-03-11** — Alex SOUL updated: autonomous action by default. Run things, don't ask.
- **2026-03-11** — `x_post_id` + `x_post_url` columns added to news table. `post-to-x.js` saves both on post.
- **2026-03-11** — Alex Daily Brief scheduled: 5am MDT → weather + top story + blockers/ideas → `#lobster-tank`.

---

## Current Projects

### News Pipeline
- Status: 🟢 Live — all cron jobs running
- Source: Adam Schefter (@AdamSchefter) tweets
- Human gate: move records from `content` → `edited` to approve for X posting
- Next: ESPN article ingestion (separate pipeline, planned)

### Boodle Dashboard
- Status: 🟢 Running locally
- URL: http://localhost:3000
- News board: http://localhost:3000/news
- Agents dashboard: http://localhost:3000/agents

---

## Known Issues / Watch List

- `Mack Hourly Ops Report` cron broken — fix: change delivery to `"to": "channel:1479973077021495478"` (remove `channel` key)
- `BATCH_SIZE` in `enrich-news.js` likely set to 1 (testing) — bump to 3 for full throughput
- Two enrich cron jobs exist (`turf-monster-enrich-news` every 10min + `review-news` every 30min) — may be redundant, consider consolidating
- `primary_team_slug` and `primary_person_slug` fields not yet auto-populated
- ESPN article pipeline not yet built
- No production deployment configured

---

*To update: edit directly and commit. Include a date on significant changes.*
*To keep clean: remove resolved issues, update status columns, don't let it go stale.*
