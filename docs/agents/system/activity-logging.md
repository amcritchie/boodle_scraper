# Agent Activity Logging

Activity logging is how the agent team leaves a persistent, searchable trail of what happened. Tasks tell you *what agents are supposed to do*. Activity logs tell you *what they actually did*.

Good logging means faster debugging, clearer accountability, and a real-time record that survives context resets. Skip it for noise. Write it for anything that matters.

---

## Endpoint

```
POST /api/agents/activities
```

---

## Fields

### Required

| Field | Type | Description |
|-------|------|-------------|
| `agent_slug` | string | The agent logging the activity (e.g. `mack`, `mason`, `turf-monster`) |
| `activity_type` | string | One of the defined vocabulary types below |

### Optional

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Human-readable summary of what happened |
| `task_slug` | string | Slug of the related task, if this activity is tied to one |
| `metadata` | object | Arbitrary structured data — counts, IDs, URLs, error details, etc. |

---

## Activity Type Vocabulary

Use only these defined values for `activity_type`. Don't invent new ones without updating this doc and the API schema.

| Type | When to use |
|------|-------------|
| `task_started` | Agent picks up a task and begins execution |
| `task_completed` | Agent successfully finishes a task |
| `task_failed` | Agent encounters an unrecoverable error; task transitions to failed |
| `ops_report` | Mack's periodic ops/health summary (every 30 min) |
| `content_published` | An article, post, or page went live |
| `scrape_completed` | A scraping job finished (whether full success or partial) |
| `error` | A notable error occurred outside of a failing task (API timeout, auth failure, etc.) |
| `message_sent` | Agent sent a Discord message, email, or other external comms |

---

## Example: Basic Activity

```bash
curl -s -X POST http://localhost:3000/api/agents/activities \
  -H "Content-Type: application/json" \
  -d '{
    "activity": {
      "agent_slug": "mack",
      "activity_type": "scrape_completed",
      "description": "Scraped Week 3 betting lines — 16/16 games collected",
      "task_slug": "scrape-week-3-betting-lines-a1b2c3d4"
    }
  }'
```

## Example: Activity with Metadata

```bash
curl -s -X POST http://localhost:3000/api/agents/activities \
  -H "Content-Type: application/json" \
  -d '{
    "activity": {
      "agent_slug": "turf-monster",
      "activity_type": "content_published",
      "description": "Published Week 3 predictions article",
      "task_slug": "publish-week-3-predictions-e5f6g7h8",
      "metadata": {
        "article_id": 112,
        "url": "https://boodlescout.com/predictions/week-3",
        "games_covered": 16,
        "word_count": 1840
      }
    }
  }'
```

## Example: Error Log

```bash
curl -s -X POST http://localhost:3000/api/agents/activities \
  -H "Content-Type: application/json" \
  -d '{
    "activity": {
      "agent_slug": "mack",
      "activity_type": "error",
      "description": "SportRadar API returned 503 — retried 3 times, gave up",
      "metadata": {
        "status_code": 503,
        "endpoint": "/v7/nfl/games",
        "retries": 3
      }
    }
  }'
```

---

## When TO Log

Log activity when something meaningful happened that another agent, or a human reviewing the logs, would want to know about.

**Always log:**
- Task stage transitions (`task_started`, `task_completed`, `task_failed`)
- Scheduled job completions (scrapes, prediction runs, ops reports)
- Content going live
- External messages sent
- Errors that affect outcomes or require human attention
- Anything that changes data, state, or external systems

**Log when it helps:**
- Partial successes with counts (e.g., "14/16 games scraped — 2 missing")
- When something took longer than expected
- When a fallback path was taken

---

## When NOT to Log

Don't flood the activity feed with noise. Skip logging for:

- **Heartbeats** — Routine "still alive" pings add zero signal
- **Trivial reads** — Fetching task lists, reading config, polling APIs that returned nothing
- **Routine polls** — Checking for new tasks and finding none
- **In-progress sub-steps** — Log the outcome, not every intermediate step
- **Redundant events** — If the task system already captures it fully, don't duplicate

**Rule of thumb:** If someone scanning the logs tomorrow wouldn't care, don't write it.

---

## Tips

- Use `metadata` liberally — structured data is more useful than prose when debugging
- Always include `task_slug` when an activity is tied to a task
- Keep `description` short and factual — one sentence, past tense ("Scraped", "Published", "Failed")
- For `error` activities, include status codes, endpoint names, and retry counts in `metadata`
