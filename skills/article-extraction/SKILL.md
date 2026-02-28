# Article Extraction Skill

## Purpose

Extract structured data from sports articles using LLMs. Used by ArticleIngestionService and sub-agents.

## Article Schema

| Field | Type | Description | Rules |
|-------|------|-------------|-------|
| `title_summary` | string | Short identifier | **3-5 words**, consistent across all LLMs for same article |
| `sport` | string | Sport category | NFL, NBA, MLB, NCAAB, NCAAF, NHL, Soccer |
| `teams_json` | array | Team names | All teams mentioned in article |
| `people_json` | array | Person names | All people mentioned |
| `key_stats_json` | array | Statistics | Numbers with context (e.g., "36 points") |
| `context` | string | Background | 1-2 sentences |
| `main_person_name` | string | Primary athlete | Most important person |
| `main_team_name` | string | Primary team | Most important team |

## title_summary Rules (IMPORTANT)

**MUST BE:**
- Exactly **3-5 words**
- **Consistent** across all LLM models for the same article
- A short identifier, NOT a sentence

**Examples:**
- ✅ "Jokic Dort confrontation"
- ✅ "Pistons beat Cavaliers"
- ✅ "Chiefs beat Ravens"
- ❌ "Nikola Jokic had 36 points in an exciting game against the Denver Nuggets"

## Extraction Prompt Template

```
You are extracting structured data from a sports article for storage in a database.

Return ONLY valid JSON with these EXACT fields (no other text):
{
  "title_summary": "3-5 word identifier (consistent across all LLMs)",
  "sport": "NFL, NBA, MLB, etc.",
  "teams_json": ["team names"],
  "people_json": ["person names"],
  "key_stats_json": ["statistics"],
  "context": "1-2 sentence background",
  "main_person_name": "primary athlete",
  "main_team_name": "primary team"
}

Article content (first 8000 chars):
[CONTENT]
```

## Usage

```ruby
ArticleIngestionService.ingest(url: "https://...")
# Creates 3 tasks (one per model), each runs extraction

ArticleIngestionService.ingest_single(url: "...", model: "claude-sonnet")
# Single model
```

## Models

- claude-sonnet (Anthropic)
- minimax-m2.1 (MiniMax)
- grok-3 (xAI)
