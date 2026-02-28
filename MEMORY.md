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
- `skills/code-review/` - Code review framework
- `skills/sports-reader/` - Sports article analysis with multiple LLM support
- `skills/sports-image-fetcher/` - Image fetching from multiple sources

## LLM Models Available
- MiniMax M2.1, M2.5
- Claude Sonnet 4, Opus 4
- GPT-4o (key issues - invalid)
- Grok 3
- Gemini 2.0 Flash

## Article Ingestion Pipeline

The boodle_scraper app now has a complete article ingestion system:

### Workflow
```
URL → web_fetch → LLM extracts (main_person_name, main_team_name, etc.)
         ↓
      Image search (multiple sources)
         ↓
      Save to Article model
```

### Article Fields
- `title` - Actual headline
- `title_summary` - 3-5 word identifier (consistent across LLMs)
- `main_person_name` - Primary athlete/person
- `main_team_name` - Primary team
- `teams_json` - All teams mentioned
- `people_json` - All people mentioned
- `key_stats_json` - Statistics
- `context` - Background
- `model` - LLM used (claude-sonnet, minimax-m2.1, grok-3)
- `process` - Extraction process ("sports-reader")
- `image_options` - Array of image paths (future)
- `image_selected` - Primary image (future)

### Models Tested
- Claude Sonnet - Concise, fast, lowest token usage
- MiniMax M2.1 - More detailed, included specific names
- Grok 3 - Verbose, fast but high token usage

## Image Fetching Strategy

### Sources (in priority order)
1. **Article og:image** - Easiest, always matches the story
2. **Google Images** - Best for action shots (via browser)
3. **Wikimedia Commons** - Works for established players only
4. **League sites** - NBA.com, NFL.com (URLs unpredictable)
5. **Team sites** - Player galleries

### Notes
- Wikimedia only works for established players (Jokic ✅, Aaron Glenn ✅)
- Newer players (Duren) have no Wikimedia category
- Google Images via browser works visually but getting direct URLs is tricky
- Rate limits apply to Wikimedia

## Today's Progress
- Set up multi-LLM article ingestion
- Created sports-reader skill for structured extraction
- Created sports-image-fetcher skill for images
- Tested with 6 articles across NFL/NBA
- Article IDs 1-9 in database (plus seeded data)
- Successfully created PRs to GitHub

## API Keys to Remember
- Brave Search: Configured (BSA_*)
- xAI (Grok): Configured
- Anthropic (Claude): Configured
- Google (Gemini): Configured
- OpenAI: Invalid key needs fixing
