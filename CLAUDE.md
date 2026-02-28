---
description: 
alwaysApply: true
---

# CLAUDE.md

## Project Overview

Boodle Scraper is an NFL sports analytics web application that aggregates game data, player grades, betting lines, matchup predictions, and team rankings from multiple sources.

## Tech Stack

- **Ruby** 3.1.0
- **Rails** 7.0.8
- **PostgreSQL** (9.3+)
- **Docker**: Multi-stage build with docker-compose (PostgreSQL 15 + Ruby 3.1.0-slim)
- **Frontend**: Hotwire (Turbo + Stimulus), Import Maps, Tailwind CSS with theme system
- **Key gems**: httparty, nokogiri (scraping), kaminari (pagination), dotenv-rails

## Getting Started

```bash
bundle install
rails db:setup          # or pg_restore for existing dump
rails server
```

### Docker

```bash
docker compose up --build -d       # Build and start
docker compose down                # Stop
docker compose exec web bin/rails runner db/seed_articles.rb  # Seed articles
docker compose exec web bin/rails console                     # Rails console
```

The Docker entrypoint runs `db:prepare` automatically (creates DB + runs migrations).

Requires a `.env` file with `SPORTRADAR_API_KEY`, `POSTGRES_USERNAME`, `POSTGRES_PASSWORD` (see README.md for full list).

## Project Structure

```
app/
  models/           # 20 models (Game, Team, Player, Matchup, Season, etc.)
  models/concerns/  # 8 concerns (PffConcern, PredictionConcern, ScoringConcern, etc.)
  controllers/      # 10 controllers (Games, Teams, Players, Matchups, Rankings, Predictions, Home, Articles, People, Posts)
  views/            # ERB templates per controller
  javascript/       # Stimulus controllers
lib/
  tasks/            # 14 rake tasks — numbered 1-6 for sequential data pipeline
  pff/              # PFF CSV data files (gitignored)
  sportradar/       # SportRadar API integration
config/
  routes.rb         # RESTful + SEO-optimized routes
  database.yml      # PostgreSQL config
db/
  schema.rb         # Full schema (~830 lines, 20 tables)
  migrate/          # 25 migrations
  seed_articles.rb  # Sample article data with images and JSON fields
```

## Key Models & Relationships

- **Game** — NFL games with scores, odds, betting lines. Belongs to home_team/away_team/venue. Has weather, broadcast, plays.
- **Team** — 32 NFL teams with branding (colors, emoji). Has many players, coaches, matchups.
- **Player** — Athletes with PFF grades (offense, defense, pass, rush, coverage, etc.) and detailed stats.
- **Matchup** — Game matchup analysis with full offensive/defensive roster and prediction scores.
- **Season/Week** — Season structure with aggregate scoring stats per week.
- **TeamsSeason/TeamsWeek** — Team roster snapshots and power rankings per season/week.
- **Venue** — Stadium info (capacity, surface, roof, coordinates).
- **Ranking** — Aggregated player rankings by position and grade type.

## Data Pipeline (Rake Tasks)

Run in numbered order for initial setup:

1. `rake populate:seed` — Initial seed data
2. `rake populate:teams` — 32 NFL teams
3. `rake populate:players` — Player rosters (SportRadar API)
4. `rake populate:seasons` — Seasons and weeks
5. `rake populate:matchups` — Game matchups
6. `rake populate:coaches` — Coaching staff

Additional: `venue_populate`, `import_games`, `populate_teams_weeks`, `populate_contracts`, `populate_qb_rankings`, `populate_oline_rankings`

## External Data Sources

- **SportRadar API** — Game data, rosters, play-by-play (requires API key in .env)
- **PFF** — Player grades via CSV files in lib/pff/ (gitignored)
- **SportsOddsHistory** — Historical betting lines (HTML scraping)
- **Kaggle** — Historical NFL game datasets

## Common Commands

```bash
rails server                    # Start dev server
rails console                   # Rails console
rails db:migrate                # Run pending migrations
rails test                      # Run test suite
bundle exec rake -T             # List all rake tasks
docker compose up --build -d    # Build and start Docker
docker compose down             # Stop Docker
```

## Testing

Tests live in `test/`. Current test files cover Game, Team, and TeamsWeek models. Run with `rails test`.

## Conventions

- Models use slug-based lookups (e.g., `team_slug`, `game_slug`, `player_slug`) rather than foreign key IDs for most associations.
- Player grades use `grades_` prefix for raw PFF values and `_grade` suffix for decimal-precision values.
- Routes use SEO-friendly paths (e.g., `/nfl-offensive-line-rankings`, `/nfl-week-1-predictions`).
- Week references in routes use `week1` format (dynamic, not literal "1").
- Frontend uses Stimulus controllers for interactivity and CSS custom properties for theming.

## Things to Know

- The Game model is the largest (~880 lines) — scoring logic, scraping, and odds calculations.
- `.env` and `lib/pff/` are gitignored — sensitive keys and data files.
- Schema uses `jsonb` columns for game scores arrays and play event data.
- Some spelling inconsistencies exist in the schema: `reciever` (should be receiver), `defence` (British spelling), `stangest_events` (should be strangest), `gaurd` (should be guard in some contexts).

## Articles API

JSON API for managing articles. CSRF is disabled for all API endpoints. All request/response bodies use JSON (`Content-Type: application/json`).

Self-describing docs also available at `GET /api/articles/docs`.

### Article Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Auto-generated primary key |
| `title` | string | Article title |
| `title_summary` | string | Short summary of the title |
| `author` | string | Author name |
| `sport` | string | Sport category (e.g. `"nfl"`, `"nba"`) |
| `published_at` | date | Publication date (`YYYY-MM-DD`) |
| `reviewed_at` | datetime | When feedback was last given (ISO 8601, auto-set by feedback endpoint) |
| `main_team_name` | string | Display name of the primary team |
| `main_team_slug` | string | Slug of the primary team |
| `main_person_name` | string | Display name of the primary person |
| `main_person_slug` | string | Slug of the primary person |
| `teams_json` | json | Array of team objects (name, slug, role) |
| `people_json` | json | Array of people objects (name, slug, position) |
| `scores_json` | json | Score data (e.g. `{ "home": 34, "away": 20 }`) |
| `records_json` | json | Record data (wins, losses) |
| `key_stats_json` | json | Key statistics (label/value pairs) |
| `quotes_json` | json | Notable quotes (speaker/text pairs) |
| `context` | text | Article context and background |
| `feedback` | text | Free-form feedback notes |
| `article_good` | boolean | Whether the article is interesting/good |
| `person_identified` | boolean | Whether the primary person was correctly identified |
| `disposition_coherent` | boolean | Whether the disposition analysis is coherent |
| `source` | string | Source identifier (e.g. `"news-bot"`, `"rss-feed"`) |
| `source_url` | string | URL of the original article |
| `source_id` | string | External source identifier |
| `model` | string | LLM model used for processing |
| `process` | string | Processing method (e.g. `"auto-summarize"`) |
| `process_notes` | text | Notes about the processing pipeline |
| `image_options` | json | Array of image URL strings |
| `image_selected` | string | Selected image URL from image_options |
| `created_at` | datetime | Record creation timestamp |
| `updated_at` | datetime | Record last-updated timestamp |

### Endpoints

#### List Articles
```
GET /api/articles
```
Query params:
- `page` (integer, default: 1) — Page number
- `per_page` (integer, default: 25, max: 100) — Results per page
- `reviewed` (`"true"` / `"false"`) — Filter by reviewed status
- `main_person_slug` (string) — Filter by person slug
- `source` (string) — Filter by source

Response:
```json
{
  "total_count": 42,
  "page": 1,
  "per_page": 25,
  "articles": [{ "id": 1, "title": "...", ... }]
}
```

#### Get Single Article
```
GET /api/articles/:id
```
Response: `{ "article": { ... } }`
Error (404): `{ "error": "Article not found" }`

#### Create Article
```
POST /api/articles
Content-Type: application/json

{
  "article": {
    "title": "Mahomes shines in Week 1",
    "title_summary": "4 TDs as Chiefs cruise",
    "author": "News Bot",
    "sport": "nfl",
    "published_at": "2025-09-07",
    "main_person_slug": "patrick-mahomes",
    "main_person_name": "Patrick Mahomes",
    "main_team_name": "Kansas City Chiefs",
    "main_team_slug": "kansas-city-chiefs",
    "context": "Week 1 of the 2025 NFL season",
    "source": "news-bot",
    "source_url": "https://example.com/article/123",
    "source_id": "news-bot-001",
    "model": "gpt-4o",
    "process": "auto-summarize",
    "teams_json": [{ "name": "Kansas City Chiefs", "slug": "kansas-city-chiefs", "role": "home" }],
    "people_json": [{ "name": "Patrick Mahomes", "slug": "patrick-mahomes", "position": "QB" }],
    "scores_json": { "home": 34, "away": 20 },
    "key_stats_json": [{ "label": "Passing Yards", "value": "327" }],
    "image_options": ["https://example.com/img1.jpg", "https://example.com/img2.jpg"]
  }
}
```
Response (201): `{ "article": { ... } }`
Error (422): `{ "errors": ["Title can't be blank"] }`

#### Update Article
```
PATCH /api/articles/:id
Content-Type: application/json

{ "article": { "title": "Updated title" } }
```
Send only the fields you want to change. Response: `{ "article": { ... } }`

#### Quick Feedback Toggle
```
PATCH /api/articles/:id/feedback
Content-Type: application/json

{ "field": "article_good", "value": "true" }
```
Valid fields: `article_good`, `person_identified`, `disposition_coherent`.
Automatically sets `reviewed_at` to the current time.
Response: `{ "article": { ... } }`
Error (400): `{ "error": "Invalid field. Must be one of: article_good, person_identified, disposition_coherent" }`

#### Select Image
```
PATCH /api/articles/:id/select_image
Content-Type: application/json

{ "image_url": "https://example.com/img1.jpg" }
```
Sets `image_selected` from the `image_options` array.
Response: `{ "article": { ... } }`
Error (400): `{ "error": "image_url is required" }`

#### Delete Article
```
DELETE /api/articles/:id
```
Response: `{ "message": "Article deleted" }`

---

## People API

JSON API for managing people. CSRF is disabled for all API endpoints.

### Person Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Auto-generated primary key |
| `first_name` | string | First name |
| `last_name` | string | Last name |
| `slug` | string | Unique slug identifier |
| `player_slug` | string | Linked player slug (references Player model) |
| `birthday` | date | Date of birth (`YYYY-MM-DD`) |
| `twitter_account` | string | Twitter/X handle |
| `twitter_hashtag` | string | Associated hashtag |
| `created_at` | datetime | Record creation timestamp |
| `updated_at` | datetime | Record last-updated timestamp |

### Endpoints

#### List People
```
GET /api/people
```
Query params:
- `page` (integer, default: 1) — Page number
- `per_page` (integer, default: 25, max: 100) — Results per page
- `player_slug` (string) — Filter by player slug

Response:
```json
{
  "total_count": 10,
  "page": 1,
  "per_page": 25,
  "people": [{ "id": 1, "first_name": "Patrick", "last_name": "Mahomes", ... }]
}
```

#### Get Single Person
```
GET /api/people/:id
```
Response: `{ "person": { ... } }`
Error (404): `{ "error": "Person not found" }`

#### Create Person
```
POST /api/people
Content-Type: application/json

{
  "person": {
    "first_name": "Patrick",
    "last_name": "Mahomes",
    "slug": "patrick-mahomes",
    "player_slug": "patrick-mahomes",
    "birthday": "1995-09-17",
    "twitter_account": "@PatrickMahomes",
    "twitter_hashtag": "#Mahomes"
  }
}
```
Response (201): `{ "person": { ... } }`
Error (422): `{ "errors": [...] }`

#### Update Person
```
PATCH /api/people/:id
Content-Type: application/json

{ "person": { "twitter_account": "@NewHandle" } }
```
Send only the fields you want to change. Response: `{ "person": { ... } }`

#### Delete Person
```
DELETE /api/people/:id
```
Response: `{ "message": "Person deleted" }`

---

## Posts API

JSON API for managing posts. CSRF is disabled for all API endpoints.

### Post Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Auto-generated primary key |
| `title` | string | Post title |
| `sport` | string | Sport category (e.g. `"nfl"`, `"nba"`) |
| `stage` | string | Pipeline stage: `"draft"`, `"images"`, `"approved"`, `"posted"` |
| `impressions` | integer | Number of impressions after posting |
| `likes` | integer | Number of likes after posting |
| `content` | text | Post body content |
| `image_url` | string | Selected image URL |
| `image_proposals` | json | Array/object of proposed images from image search |
| `images_found_at` | datetime | When image proposals were generated |
| `image_selected_at` | datetime | When an image was selected |
| `approved_at` | datetime | When the post was approved |
| `posted_at` | datetime | When the post was published |
| `created_at` | datetime | Record creation timestamp |
| `updated_at` | datetime | Record last-updated timestamp |

### Endpoints

#### List Posts
```
GET /api/posts
```
Query params:
- `page` (integer, default: 1) — Page number
- `per_page` (integer, default: 25, max: 100) — Results per page
- `stage` (string) — Filter by stage (`draft`, `images`, `approved`, `posted`)

Response:
```json
{
  "total_count": 15,
  "page": 1,
  "per_page": 25,
  "posts": [{ "id": 1, "title": "...", "stage": "draft", ... }]
}
```

#### Get Single Post
```
GET /api/posts/:id
```
Response: `{ "post": { ... } }`
Error (404): `{ "error": "Post not found" }`

#### Create Post
```
POST /api/posts
Content-Type: application/json

{
  "post": {
    "title": "Week 1 Predictions Recap",
    "stage": "draft",
    "content": "Here are our top predictions for Week 1...",
    "image_proposals": ["https://img1.example.com", "https://img2.example.com"]
  }
}
```
Response (201): `{ "post": { ... } }`
Error (422): `{ "errors": [...] }`

#### Update Post
```
PATCH /api/posts/:id
Content-Type: application/json

{ "post": { "stage": "approved", "approved_at": "2025-09-06T12:00:00Z" } }
```
Send only the fields you want to change. Response: `{ "post": { ... } }`

#### Delete Post
```
DELETE /api/posts/:id
```
Response: `{ "message": "Post deleted" }`
