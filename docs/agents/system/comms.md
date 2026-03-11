# Agent Communication Protocol

Agents in this system do not message each other directly. All inter-agent communication happens through the **task API**. This is intentional — it keeps work traceable, prioritized, and auditable.

---

## How It Works

**Creating a task for another agent:**
```
POST /api/agents/tasks
{
  "task": {
    "title": "Scrape Week 2 betting lines",
    "description": "Collect opening lines for all Week 2 games from SportsOddsHistory",
    "agent_slug": "mack",
    "stage": "queued",
    "priority": 1,
    "required_skills": ["web-scraping"]
  }
}
```

**Picking up work (how an agent finds its tasks):**
```
GET /api/agents/tasks?agent_slug=mack&stage=queued
```

**Starting a task:**
```
PATCH /api/agents/tasks/:id/transition
{ "transition": "start" }
```

**Completing a task with results:**
```
PATCH /api/agents/tasks/:id/transition
{ "transition": "complete" }

PATCH /api/agents/tasks/:id
{ "task": { "result": { "lines_scraped": 14, "games_updated": 14 } } }
```

**Failing a task:**
```
PATCH /api/agents/tasks/:id/transition
{ "transition": "fail" }

PATCH /api/agents/tasks/:id
{ "task": { "error_message": "SportsOddsHistory returned 403 — IP block suspected" } }
```

---

## Complete Example: Alex → Mack → Turf Monster

**Scenario:** Alex notices the Week 2 prediction page has no odds data. He needs Mack to scrape them, then Turf Monster to run the prediction model.

### Step 1 — Alex creates a task for Mack

```
POST /api/agents/tasks
{
  "task": {
    "title": "Scrape Week 2 betting lines",
    "description": "Collect opening lines for all 16 Week 2 games. SportsOddsHistory is the source. Priority: Turf Monster needs this data to run predictions.",
    "agent_slug": "mack",
    "stage": "queued",
    "priority": 2,
    "required_skills": ["web-scraping"]
  }
}
```
→ Response includes `id: 42`

### Step 2 — Mack discovers the task

On session startup (or periodic poll), Mack runs:
```
GET /api/agents/tasks?agent_slug=mack&stage=queued
```
Sees task 42 with priority 2 (Urgent). Picks it up.

### Step 3 — Mack starts the task

```
PATCH /api/agents/tasks/42/transition
{ "transition": "start" }
```

Mack runs the scrape. 16 games, 14 succeed, 2 fail on first try (retry logic kicks in, both eventually succeed).

### Step 4 — Mack completes the task

```
PATCH /api/agents/tasks/42/transition
{ "transition": "complete" }

PATCH /api/agents/tasks/42
{ "task": { "result": { "games_scraped": 16, "lines_found": 16, "retries": 2 } } }
```

### Step 5 — Mack creates the downstream task for Turf Monster

Mack knows the prediction model needs this data. She creates the next task:

```
POST /api/agents/tasks
{
  "task": {
    "title": "Run Week 2 prediction model",
    "description": "Betting lines are loaded. Run prediction scores for all 16 Week 2 matchups.",
    "agent_slug": "turf-monster",
    "stage": "queued",
    "priority": 1,
    "required_skills": ["prediction-modeling", "data-analysis"]
  }
}
```

### Step 6 — Turf Monster picks it up and runs it

Turf Monster finds the task on startup, runs the model, posts results, transitions to done.

---

## Task Conventions

**Title format:** `[Verb] [Object] [Scope]`
- ✅ "Scrape Week 2 betting lines"
- ✅ "Generate social posts for Mahomes article"
- ❌ "betting lines stuff"
- ❌ "Task for Mack"

**Description should include:**
- What to do (specific enough to act on)
- Why it matters (helps prioritize if queue gets long)
- Any dependencies or blockers known at creation time

**Result format:** JSON object with measurable outcomes. Not "done" — include counts, IDs, or other evidence of completion.

**Error messages:** Specific and actionable. Not "it failed" — include what failed, what was tried, and what would unblock it.

---

## When to Create a Task vs. When to Act Directly

**Create a task when:**
- The work is in another agent's domain
- The work needs to be tracked and reported
- The work depends on something not yet available

**Act directly when:**
- The work is clearly in your own domain
- It's small enough that creating a task adds more overhead than the work itself
- You're in the middle of a larger task and this is a sub-step

When in doubt: create a task. The system is most useful when it has a complete record.

---

## Discord for Humans

Task API is for agent-to-agent. Discord `#lobster-tank` is for agent-to-human.

Use Discord when:
- You need operator input or approval
- Something is escalating that the operator should know about
- A report or summary should be surfaced to the human

Do not use Discord as a substitute for the task system. The task system is the source of truth.
