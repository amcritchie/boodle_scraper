# McRitchie Studio — Shared Agent Memory

This file is the system's collective brain. All agents can read and write it.
Keep entries current. Remove outdated info. Last updated entries should include a date.

---

## System Status

| Component | Status | Notes |
|-----------|--------|-------|
| Rails app | 🟢 Running | Docker, port 3000 |
| PostgreSQL | 🟢 Healthy | Docker, postgres:15 |
| Migrations | 🟢 Current | 32 migrations applied |
| Agents seeded | 🟢 Done | 4 agents, 12 skills, 9 tasks |

## Active Agents

| Agent | Slug | Role | Model | Status |
|-------|------|------|-------|--------|
| Alex Agent | alex | CEO | — | Active |
| Mack | mack | CTO | claude-sonnet | Active |
| Mason | mason | CPO | — | Active |
| Turf Monster | turf-monster | CMO | claude-sonnet | Active |

## LLM Providers

| Provider | Status | Priority | Notes |
|----------|--------|----------|-------|
| Anthropic | Unknown | Primary | Key not yet validated |
| OpenAI | Unknown | Fallback | Key not yet validated |
| xAI | Unknown | Tertiary | Key not yet validated |

*Mack: update this table when providers are tested. Add key expiry dates when known.*

## Infrastructure

- **Repo:** `https://github.com/amcritchie/boodle_scraper`
- **Local path:** `/home/alex/.openclaw/workspace/boodle_scraper`
- **Docker:** `docker compose up --build -d` from repo root
- **Entrypoint:** Runs `db:prepare` automatically on first boot (creates DB + migrations)
- **Agent seed:** `docker compose exec web bin/rails runner db/seed_agents.rb`
- **Article seed:** `docker compose exec web bin/rails runner db/seed_articles.rb`
- **Console:** `docker compose exec web bin/rails console`
- **Logs:** `docker compose logs -f web`

## API Integrations

| Service | Key Location | Status | Limits |
|---------|-------------|--------|--------|
| SportRadar | `.env` → `SPORTRADAR_API_KEY` | Not configured | Trial: 1000 req/day |
| SportsOddsHistory | No key needed | Active | Rate limit: slow down on 429 |
| PFF | CSV files in `lib/pff/` (gitignored) | Not configured | N/A |

## Strategic Decisions

- **2026-03-10** — Bootstrapped McRitchie Studio agent system from `boodle_scraper` repo. 4-agent setup: Alex (CEO), Mack (CTO), Mason (CPO), Turf Monster (CMO).
- **2026-03-10** — Mack role expanded to include LLM connection guardian + agent health monitoring + error log analysis. Primary focus: keep all agents online.
- **2026-03-10** — Primary LLM provider to be confirmed. Anthropic as preferred, OpenAI as fallback.

## Current Projects

### Boodle Dashboard
- Status: Running locally, seeded, not deployed to production
- URL: http://localhost:3000
- Agents dashboard: http://localhost:3000/agents
- Outstanding: SportRadar API key needed to populate game data

### Content Pipeline (Turf Monster)
- Status: Infrastructure ready, content not yet flowing
- Article stage pipeline: draft → images → approved → posted
- Twitter/X posting: @turfmonstershowSports (not yet connected to app)

## Known Issues / Watch List

- `.env` file has placeholder `SPORTRADAR_API_KEY` — replace before running data rake tasks
- Articles table had schema drift (schema.rb ahead of migrations) — fixed 2026-03-10 with migration `20260310235900`
- No production deployment configured yet

---

*To update this file: edit directly and commit. Include a date on significant changes.*
*To keep it clean: remove resolved issues, update status columns, don't let it go stale.*
