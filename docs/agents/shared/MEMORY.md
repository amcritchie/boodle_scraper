# McRitchie Studio — Shared Agent Memory

This file is the system's collective brain. All agents can read and write it.
Keep entries current. Remove outdated info. Last updated entries should include a date.

---

## System Status

| Component | Status | Notes |
|-----------|--------|-------|
| Rails app | 🟢 Running | Docker, port 3000 |
| PostgreSQL | 🟢 Healthy | Docker, postgres:15 |
| Migrations | 🟢 Current | All migrations applied incl. opinion fields |
| Agents seeded | 🟢 Done | 4 agents, 14 skills, 13 assignments |
| News pipeline | 🟢 Live | Polling, enriching, posting |

## Active Agents

| Agent | Slug | Role | Model | Status |
|-------|------|------|-------|--------|
| Alex Agent | alex | CEO | claude-sonnet | Active |
| Mack | mack | CTO | claude-sonnet | Active |
| Mason | mason | CPO | claude-sonnet | Active |
| Turf Monster | turf-monster | CMO | claude-sonnet | Active |

## Infrastructure

- **Repo:** `https://github.com/amcritchie/boodle_scraper`
- **Local path:** `/home/alex/.openclaw/workspace/boodle_scraper`
- **Docker:** `docker compose up --build -d` from repo root
- **Run migrations:** `docker compose exec web bin/rails db:migrate`
- **Console:** `docker compose exec web bin/rails console`
- **Logs:** `docker compose logs -f web`

---

## News Pipeline — Active as of 2026-03-11

Full end-to-end NFL news pipeline sourcing from Adam Schefter's X account.

### Stage Flow
```
new → reviewed → content → [human moves to edited] → edited → posted → archived
```

### Scripts (all in `~/.openclaw/workspace/scripts/`)

| Script | Cron | What it does |
|--------|------|-------------|
| `poll-schefter.js` | Every 5 min | Polls X API → DB + Discord |
| `review-news.js` (enrich-news.js) | Every 30 min | AI enrichment → `reviewed` + Discord |
| `opinion-news.js` | Every hour | TM forms hot take → `content` + Discord |
| `post-to-x.js` | Every hour | Posts `edited` record to TM's X account → `posted` + Discord |

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
- **new:** url, author, published_at, title (raw tweet text)
- **reviewed:** + title_short, primary_person, primary_team, summary, selected_image
- **content:** + opinion, feeling, feeling_emoji, what_happened
- **posted:** same, stage advanced after X post

### Discord notifications
Every stage transition posts to `#lobster-tank` (`1479973077021495478`):
- **reviewed** — review card with title, person, team
- **content** — Turf Monster's full take
- **posted** — tweet URL announcement

### Required credentials (in `~/.openclaw/workspace/.secrets`)
```
X_BEARER_TOKEN         # X API read token for Schefter polling
DISCORD_BOT_TOKEN      # Turf Monster Discord bot token
ANTHROPIC_API_KEY      # For AI enrichment + opinion generation
TM_X_API_KEY           # Turf Monster X app consumer key
TM_X_API_SECRET        # Turf Monster X app consumer secret
TM_X_ACCESS_TOKEN      # TM account access token
TM_X_ACCESS_SECRET     # TM account access secret
```

---

## API Integrations

| Service | Key Location | Status | Notes |
|---------|-------------|--------|-------|
| X API v2 | `workspace/.secrets` | 🟢 Active | Schefter polling, Bearer Token |
| X API OAuth 1.0a | `workspace/.secrets` | 🟢 Active | TM posting, 5 credentials |
| Anthropic | `openclaw.json` + `.secrets` | 🟢 Active | Enrichment + opinion |
| Discord | `openclaw.json` + `.secrets` | 🟢 Active | 4 bots connected |
| SportRadar | `.env` | ⚪ Not configured | Trial: 1000 req/day |

---

## Strategic Decisions

- **2026-03-10** — Bootstrapped McRitchie Studio agent system. 4-agent setup: Alex (CEO), Mack (CTO), Mason (CPO), Turf Monster (CMO).
- **2026-03-11** — Built full NFL news pipeline. Schefter → review → TM opinion → X post. Fully automated with human editorial gate at `edited` stage.
- **2026-03-11** — Turf Monster X account connected with OAuth 1.0a. Posts include opinion text + tweet image.
- **2026-03-11** — Alex SOUL updated: autonomous action by default. Run things, don't ask.

## Current Projects

### News Pipeline
- Status: 🟢 Live — all 4 cron jobs running
- Source: Adam Schefter (@AdamSchefter) tweets
- Human gate: move records from `content` → `edited` to approve for posting
- Next: ESPN article ingestion (separate pipeline, planned)

### Boodle Dashboard
- Status: 🟢 Running locally
- URL: http://localhost:3000
- News board: http://localhost:3000/news
- Agents dashboard: http://localhost:3000/agents

## Known Issues / Watch List

- `Mack Hourly Ops Report` cron has delivery config error — needs fix (use `to: "channel:<id>"` format)
- `BATCH_SIZE` in `enrich-news.js` set to 1 — change back to 3 when ready for full throughput
- ESPN article pipeline not yet built — planned next session
- No production deployment configured

---

*To update: edit directly and commit. Include a date on significant changes.*
*To keep clean: remove resolved issues, update status columns, don't let it go stale.*
