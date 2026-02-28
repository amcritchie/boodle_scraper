# Memory - Turf Monster

## Identity
- **GitHub:** @turfmonster (collaborator on amcritchie/boodle_scraper)
- **Owner:** Alex (amcritchie)
- **Primary working model:** Claude Sonnet 4 for code decisions

## Preferences
- **Brevity is always appreciated** - Keep code and PRs concise
- Prefers working code over verbose documentation

## Technical Setup
- **Repo:** amcritchie/boodle_scraper (Ruby on Rails)
- **Access:** @turfmonster added as collaborator with PAT
- **App running:** http://localhost:3000 (Docker)
- **Database:** PostgreSQL in Docker

## Skills Created
- `skills/article-extraction/` - Article data extraction with LLM prompts
- `skills/sports-image-fetcher/` - Image fetching from og:image, Google, Wikimedia

## LLM Models Available
- MiniMax M2.1, M2.5
- Claude Sonnet 4, Opus 4
- GPT-4o (key issues - invalid)
- Grok 3
- Gemini 2.0 Flash

## Task System

The app now has a Task-based workflow for reliable processing:

### Task States
- **idle** → waiting to be picked up
- **active** → currently processing
- **completed** → finished successfully
- **failed** → finished with error (max 3 retries)

### Fields
- `execute_count` - tracks retry attempts
- `error_summary` - JSON array of errors from each attempt
- `input_json` - params passed in
- `output_json` - result data

### Heartbeat
- Runs every 3 minutes
- Checks for stuck "active" tasks (>2 min) → resets to idle
- Processes "idle" tasks
- Skips tasks that exceeded MAX_RETRIES (3)

### Usage
```ruby
ArticleIngestionService.ingest(url: "...")
# Creates 3 tasks (one per model), processes sequentially
```

### UI
- Task board: http://localhost:3000/tasks
- Agile board view with columns: idle, active, pending, running, completed, failed

## Article Ingestion Pipeline

### Workflow
```
URL → Task created (idle) → Sub-agent picks up → LLM extraction → og:image download → Article saved → Task completed
```

### Article Fields
- `title_summary` - **3-5 word identifier** (consistent across LLMs)
- `main_person_name` - Primary athlete
- `main_team_name` - Primary team
- `teams_json` - All teams mentioned
- `people_json` - All people mentioned
- `key_stats_json` - Statistics
- `model` - LLM used (claude-sonnet, minimax-m2.1, grok-3)
- `image_options` - og:image path

### title_summary Rules (IMPORTANT)
- MUST be 3-5 words
- MUST be consistent across all LLMs for the same article
- Examples: "Jokic Dort confrontation", "Pistons beat Cavaliers"

## Image Fetching

### Sources (priority order)
1. **Article og:image** - Easiest, always matches the story
2. **Google Images** - Best for action shots (via browser)
3. **Wikimedia Commons** - Free/legal, established players only

## API Keys
- Brave Search: Configured
- xAI (Grok): Configured
- Anthropic (Claude): Configured
- Google (Gemini): Configured
- OpenAI: Invalid key
