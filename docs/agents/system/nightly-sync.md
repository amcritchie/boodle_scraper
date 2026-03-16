# Nightly Sync Report
Last run: 2026-03-15 — 3:00 AM MDT (House Burns Down Protocol)

## What was checked
- Live cron job list (13 active jobs)
- Latest DB migrations (`ls boodle_scraper/db/migrate/ | tail -5`)
- Recent git commits (boodle_scraper + workspace repos)
- Rails app health (`GET /api/news`)
- Docs vs live state for:
  - `boodle_scraper/docs/agents/shared/MEMORY.md`
  - `boodle_scraper/docs/agents/system/bootstrap.md`
  - `boodle_scraper/docs/agents/system/architecture.md`
  - `workspace/MEMORY.md`

## What was updated

### `docs/agents/shared/MEMORY.md`
- **Migrations:** updated latest from `create_memes` (2026-03-13) → `add_discord_message_id_to_news` (2026-03-14)
- **News model fields:** added `discord_message_id` field (added by 2026-03-14 migration)
- **Cron table:** full refresh — schedules updated to reflect live cron, removed the two Mack Hourly jobs (no longer active), marked error-state jobs
- **Rank system:** corrected ordering direction from `ASC` → `DESC` (task #48 fixed this on 2026-03-12; docs had stale ASC note)
- **Last updated:** bumped to 2026-03-15

### `docs/agents/system/bootstrap.md`
- **Cron table:** full refresh matching live state — updated schedules, removed Mack Hourly jobs
- **Last updated:** bumped to 2026-03-15

### `workspace/MEMORY.md`
- **Cron schedule table:** refreshed with live cadences, error states, removed Mack Hourly jobs
- **News schema:** added `discord_message_id` field entry

### `docs/agents/system/architecture.md`
- No changes needed — still accurate

## System health
- Rails app: ✅ OK
- Total news records: 121
- Cron jobs active: 12 (+ House Burns Down itself = 13 total)

## Anything worth flagging

### 🔴 Multiple cron jobs in error state
The following jobs have error status and need investigation before the morning pipeline:
- `edit-post (x_post)` (mason, every 15 min) — Stage 4 of x_post pipeline; errors here stall hashtag enrichment
- `mason-task-refinement` (mason, every 60 min) — Task board won't auto-refine while this is erroring
- `turf-monster-enrich-news` (turf-monster, every 10 min) — Stage 2 of pipeline; **critical path** — new Schefter tweets will pile up in `new` without enrichment
- `Alex Daily Brief` (alex, 5am MDT) — Yesterday's brief also errored (22h ago run was in error state)

### 🟡 Mack Hourly LLM Ops Report + Mack Hourly Ops Report — removed from live cron
Both hourly Mack report jobs are gone from the live cron list. Docs had them as active. Removed from all doc tables. No action needed unless Mr. McRitchie wants them restored.

### 🟡 Cadence changes since last documented (2026-03-13)
Poll-schefter slowed from every 3 min → every 10 min. Enrich/edit/opinion all slowed or changed. Docs were stale on schedules — now corrected.

### 🟢 New migration: `add_discord_message_id_to_news` (2026-03-14)
New `discord_message_id` field on News records. Docs updated accordingly.

### 🟢 emoji-approval cron removed
Job removed — emoji reactions now processed via agent heartbeat.
