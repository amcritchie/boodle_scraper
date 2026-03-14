# Nightly Sync Report
Last run: 2026-03-14 03:00 AM MDT (09:00 UTC)

## What was checked
- `boodle_scraper/docs/agents/shared/MEMORY.md`
- `boodle_scraper/docs/agents/system/bootstrap.md`
- `boodle_scraper/docs/agents/system/architecture.md`
- `workspace/MEMORY.md`
- Live cron jobs (`openclaw cron list`) — 13 active jobs
- Latest migration (`ls db/migrate/ | tail -5`)
- App health (`GET /api/news`)
- Recent git log (both repos)

## What was updated

### `boodle_scraper/docs/agents/shared/MEMORY.md`
- **Migrations row**: updated from `add_default_rank_to_news` → `create_memes` (actual latest as of 2026-03-13)
- **Pipeline description**: added x_reply pipeline (sibling records, parallel flow)
- **Scripts table**: added `edit-reply-post.js` and `post-reply-to-x.js` (were undocumented)
- **Cron table**: added `edit-reply-post (x_reply)`, `post-reply-to-x (x_reply)`, and `TM X Session Health Check` (3 missing jobs); fixed `edit-post` label to clarify x_post only; fixed Mack Hourly Ops Report from ❌ broken → ✅ (resolved last session)
- **Discord templates**: added `edit-reply-post` and `post-reply-to-x` entries; noted 8-function lib
- **Known Issues**: removed stale "Mack Hourly Ops Report broken" (resolved 2026-03-13); added x_reply 403 note

### `boodle_scraper/docs/agents/system/bootstrap.md`
- **Cron restoration table**: added `edit-reply-post (x_reply)`, `post-reply-to-x (x_reply)`, `Mack Hourly Ops Report`, `TM X Session Health Check` (all missing)
- **Pipeline section**: added x_reply parallel flow description
- **Discord templates table**: added `edit-reply-post` and `post-reply-to-x` entries
- **Known Gotchas**: replaced stale "Mack Hourly Ops Report broken" with x_reply 403 gotcha (current blocker)

### `workspace/MEMORY.md`
- **Cron schedule table**: added `TM X Session Health Check` (mack, 9am MDT daily)

### `boodle_scraper/docs/agents/system/architecture.md`
- No changes needed — high-level file, still accurate

## System health
- Rails app: OK
- Total news records: 109
- Latest migration: `20260313181345_create_memes.rb`
- Cron jobs active: 13

## Anything worth flagging
- **x_reply 403 (HIGH)**: `post-reply-to-x.js` gets 403 when replying to Schefter's tweets — his account blocks third-party replies. Fix is known: change `originalTweetId` source to the x_post record's `x_post_id` (reply to TM's own tweet instead). TM replying to its own tweets works (HTTP 201 confirmed). Needs Mr. McRitchie sign-off on the behavior change before shipping.
- **TM X Session Health Check** (mack, 9am MDT): New cron, no docs existed before tonight. Added to all tables but behavior/payload not fully documented — Mack should clarify what she's checking.
- **Meme tags sparse**: 10 memes seeded but `team_slug` is null on all of them. Claude meme picker works but degrades without team context. Low-priority polish.
