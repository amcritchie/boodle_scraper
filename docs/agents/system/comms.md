# Agent Communication Protocol

Agents in this system have two communication channels. Use the right one for the right thing.

| Channel | Use For |
|---------|---------|
| **Task API** | Formal work handoffs, structured assignments, status tracking |
| **Discord #lobster-tank** | Casual coordination, questions, status updates, team banter |

Both are real. Both matter. Task API is the backbone. Discord is where the team actually feels like a team.

---

## Discord — Team Communication

**Channel:** `#lobster-tank` in McRitchie Studio (`1479973077021495478`)

This is the team's open channel. Agents should use it naturally — with personality. @mention teammates, share quick updates, ask questions, make observations. Don't treat Discord like a log file. Treat it like a group chat with your coworkers.

**@Mention format:**
- `@Alex` or `@AlexAgent` — CEO, strategy, coordination
- `@Mack` — CTO, infra, data pipelines, LLM health
- `@Mason` — CPO, product, UX, roadmap
- `@TurfMonster` — CMO, content, articles, posts

**Good reasons to post in Discord:**
- Flagging something for another agent's attention without creating a full task
- Status updates ("Betting lines scraped for Week 2, Turf Monster they're ready 🏈")
- Quick questions between agents ("@Mack — SportRadar API is returning 503s, is that on your radar?")
- Completing something worth noting ("Week 2 predictions are up")
- Mack Ops reports (Mack posts every 30 minutes)
- Anything the human operator should be able to see in context

**Don't use Discord to replace the task system.** If work needs to be done, create a task. Discord is coordination and visibility, not a to-do list.

---

## Task Stage → Discord Notifications

Every time an agent transitions a task, they post a Discord update in `#lobster-tank`. Short, personality-appropriate, not a wall of text.

| Transition | Who Posts | Format |
|------------|-----------|--------|
| `new → queued` | assigning agent | `@[assignee] queued: [task title]` |
| `queued → in_progress` | working agent | `starting [task title] 🔧` |
| `in_progress → done` | working agent | `[task title] done — [1-line result]. [tag next agent if needed]` |
| `in_progress → failed` | working agent | `@Mack / @Alex [task title] failed: [specific error]. [what would unblock it]` |

**Examples by agent:**

Mack picks up a scraping task:
> starting Week 2 betting lines scrape 🔧

Mack completes it:
> Week 2 lines in — 16/16 games. @TurfMonster you're up 🟢

Turf Monster fails on image search:
> @Mack image search rate-limited on the Barkley article. Failed task 47 — needs a retry window or API key rotation.

Mason completes a spec:
> Week 2 predictions page spec done — 6 features defined, acceptance criteria written. @Mack @TurfMonster review it when you have a sec 🐩

Alex queues new work:
> @Mack scrape task queued for Week 3 odds (urgent). Data pipeline needs to run before Thursday.

Keep them short. Let the personality come through naturally. No need to narrate every sub-step — just the meaningful stage transitions.

---

## Task API — Formal Work Protocol

How agents create and pass work to each other.

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

**Picking up work:**
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

**Scenario:** Alex notices the Week 2 prediction page has no odds data. He messages Discord first, then creates the formal task.

### Step 0 — Alex posts in Discord

```
@Mack — prediction page for Week 2 has no odds data.
Can you grab the lines from SportsOddsHistory? Tagging it urgent,
Turf Monster needs them to run the model.
```

### Step 1 — Alex creates the task for Mack

```
POST /api/agents/tasks
{
  "task": {
    "title": "Scrape Week 2 betting lines",
    "description": "Collect opening lines for all 16 Week 2 games. SportsOddsHistory is the source. Turf Monster needs this to run predictions.",
    "agent_slug": "mack",
    "stage": "queued",
    "priority": 2,
    "required_skills": ["web-scraping"]
  }
}
```
→ Response includes `id: 42`

### Step 2 — Mack sees the Discord mention, picks up the task

Mack polls on startup (or periodic check):
```
GET /api/agents/tasks?agent_slug=mack&stage=queued
```

### Step 3 — Mack starts the task

```
PATCH /api/agents/tasks/42/transition
{ "transition": "start" }
```

Mack posts in Discord: `@Alex on it. Running the scrape now.`

### Step 4 — Mack completes, creates downstream task, posts Discord update

```
PATCH /api/agents/tasks/42/transition
{ "transition": "complete" }

PATCH /api/agents/tasks/42
{ "task": { "result": { "games_scraped": 16, "lines_found": 16 } } }
```

Mack creates the next task for Turf Monster:
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

Mack posts in Discord:
```
@TurfMonster Week 2 lines are in — all 16 games. 
Queued you a prediction run. 🟢
```

### Step 5 — Turf Monster picks it up, runs the model, announces completion

```
@Alex @Mack Week 2 predictions are done. All 16 matchups scored.
Chiefs -6.5 at home — we like it. 🏈
```

---

## Task Conventions

**Title format:** `[Verb] [Object] [Scope]`
- ✅ "Scrape Week 2 betting lines"
- ✅ "Generate social posts for Mahomes article"
- ❌ "betting lines stuff" / ❌ "Task for Mack"

**Description:** What to do + why it matters + known blockers.

**Result:** Measurable outcomes. Not "done" — include counts, IDs, or evidence.

**Error messages:** Specific. Include what failed, what was tried, what would unblock it.

---

## Escalation to Operator

Use Discord to escalate to Alex McRitchie (the human operator).

Escalate when:
- A decision is irreversible (deploys, deletions, external commitments)
- You've exhausted options on something that's blocked
- Something needs budget approval
- An incident has been ongoing > 5 minutes and the operator should know

Format: `@Alex [what's wrong] [what was tried] [what you need]`. One message. Don't drip.
