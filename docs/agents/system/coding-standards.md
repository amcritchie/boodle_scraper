# Coding Standards — McRitchie Studio

Operator development preferences. All agents follow these when writing code.

---

## Model Selection

- **Use Opus (`claude-opus-4-6`) for all coding and engineering tasks.** This includes writing code, debugging, refactoring, architecture decisions, code review, migration work, and test writing. The operator values quality over speed for software work — put your best foot forward.
- **Use Sonnet (`claude-sonnet-4-6`) for non-coding tasks** where speed matters more — content drafting, research, summarization, Discord messages, routine ops.
- **When in doubt, check:** if the task touches code or requires reasoning about software systems, use Opus.

---

## Rails Conventions

- **Loose validations by default.** The operator prefers practical, friction-free models. Don't add presence/uniqueness/format validations unless there's a concrete reason — premature validation creates unwanted friction and blocks rapid iteration. Validate at system boundaries (user-facing forms, external API intake) not on every model field.
- **Nullable columns by default.** Keep columns nullable unless there's a strong reason not to. Filling in NOT NULL constraints too early creates long-term rigidity. If that means skipping uniqueness constraints, that's fine.
- Models use **slug-based lookups** (`team_slug`, `game_slug`, `player_slug`) rather than foreign key IDs for most associations
- Player grades use `grades_` prefix for raw PFF values and `_grade` suffix for decimal-precision values
- Agent-related associations use `slug` as the foreign key (not `id`) — Agent, AgentTask, AgentSkill, AgentSkillAssignment, AgentActivity, AgentUsage
- Schema uses `jsonb` columns for structured data (game scores arrays, play event data, agent config/metadata)

## JavaScript / Node.js

- All scripts that make LLM API calls must log token usage via `scripts/lib/usage-tracker.js` before exiting
- Discord templates live in `scripts/lib/discord-templates.js` — use shared functions, don't inline message formats
- Discord posts use `flags: 4` (suppress embeds) and masked links (`[label](url)`)
- Cron scripts wrap `logUsage()` in a `finally` block so it fires even on error

## Database

- Always run migrations inside Docker: `docker exec boodle_scraper-web-1 bin/rails db:migrate`
- Historical spelling inconsistencies (`reciever`, `defence`, `stangest_events`, `gaurd`) have been corrected in the consolidated migration set
- PostgreSQL 15, accessed via Docker container `boodle_scraper-db-1`

## Frontend (Tailwind / Stimulus)

- Frontend uses **Stimulus controllers** for interactivity and CSS custom properties for theming
- Hotwire stack: Turbo + Stimulus via Import Maps
- Navbar highlights active links using `controller_name` checks with emerald color
- Agent avatar SVGs in `app/assets/images/agent-*.svg` — views use initials fallback when `avatar_url` is blank

## API Design

- CSRF disabled for all API endpoints
- All request/response bodies use JSON (`Content-Type: application/json`)
- Pagination: `page` + `per_page` params (default 25, max 100)
- Routes use SEO-friendly paths (`/nfl-offensive-line-rankings`, `/nfl-week-1-predictions`)
- Week references in routes use `week1` format (dynamic, not literal)

## Git & Workflow

- Task board is source of truth — Discord `#lobster-tank` is for updates, blockers, and coordination only
- Tasks scoped in conversation with Mr. McRitchie go straight to `in_progress` (already refined)
- Task stages: `new -> queued -> in_progress -> done -> archived` (also `failed`)
- OpenClaw delivery config: use `"to": "channel:ID"` NOT `"channel": "ID"`

## Testing

Run the full suite:

```bash
rails test                                # All 75 tests
rails test test/models/                   # Model tests only
rails test test/controllers/              # API integration tests only
rails test test/models/news_test.rb       # Single file
rails test test/models/news_test.rb:34    # Single test by line number
```

### Test Files

**Model tests** (`test/models/`):
- `agent_test.rb` — Agent validations, scopes, associations (11 tests)
- `agent_task_test.rb` — Stage transitions, auto-slug, priority labels, scopes (17 tests)
- `news_test.rb` — URL uniqueness scoping, stage machine, posted_to_x?, defaults (12 tests)
- `game_test.rb`, `team_test.rb`, `teams_week_test.rb` — existing scaffold tests

**API integration tests** (`test/controllers/`):
- `agents_api_test.rb` — Agents CRUD, tasks CRUD, transitions, assignment, usages, activities (14 tests)
- `news_api_test.rb` — News CRUD, filtering, transitions, rank reorder, posting schedule (12 tests)
- `articles_api_test.rb` — Articles CRUD, filtering, feedback toggle, image select, docs (9 tests)

### Fixtures

All fixtures in `test/fixtures/`. Key custom fixtures:
- `agents.yml` — 4 agents (alex, mack, mason, turf_monster)
- `agent_tasks.yml` — 5 tasks across all stages (new, queued, in_progress, done, failed)
- `news.yml` — 4 news items (new, reviewed, posted, x_reply)
- `articles.yml` — 2 articles (reviewed + unreviewed)
- `teams.yml` — Chiefs + Broncos
- `games.yml` — 2 games with slug-based team refs
