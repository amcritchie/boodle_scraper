# McRitchie Studio Agent Operating System
## bootstrap.md — Definitive Setup Guide

You are part of the **McRitchie Studio Agent System** — a four-agent AI ecosystem running on OpenClaw, operating the Boodle sports analytics platform.

**Company:** McRitchie Studio  
**Primary domain:** NFL sports analytics and media  
**Agents:** Alex (CEO), Mason (CPO), Mack (CTO), Turf Monster (CMO)  
**Repo:** `https://github.com/amcritchie/boodle_scraper`

---

# Are You Already Set Up?

If this machine has run before, check first:

```bash
openclaw agents list          # Are all 4 agents registered?
docker compose ps             # Is the app running? (run from repo root)
git remote -v                 # Does the GitHub remote show the right URL?
openclaw channels status      # Are Discord bots connected?
openclaw cron list            # Are Mack's cron jobs scheduled?
```

If everything checks out, skip to **Session Startup Protocol** below.  
If anything is missing, find the relevant section and run only what's needed.

---

# Credential Checklist — Gather These First

Before running any setup steps, collect these. You'll need them all.

| Credential | Where to get it | Goes into |
|-----------|----------------|-----------|
| Anthropic API key | [console.anthropic.com](https://console.anthropic.com) | OpenClaw config or env |
| OpenAI API key | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) | OpenClaw config or env |
| GitHub PAT | github.com → Settings → Developer settings → PATs (classic) | git remote URL |
| Discord bot token — Alex | [discord.com/developers/applications](https://discord.com/developers/applications) | `~/.openclaw/openclaw.json` |
| Discord bot token — Mason | same | same |
| Discord bot token — Mack | same | same |
| Discord bot token — Turf Monster | same | same |
| Sportradar API key | [developer.sportradar.com](https://developer.sportradar.com) | `.env` |
| Postgres password | you choose | `.env` + Docker |
| Rails SECRET_KEY_BASE | `rails secret` or `openssl rand -hex 64` | `.env` |

The interactive setup script (`docs/agents/setup.sh --interactive`) will prompt for and place all of these for you. Or do it manually section by section below.

---

# First-Time Machine Setup

Run these in order. On a fresh machine, do all of them. On a partial setup, run only what's missing.

---

## 1. Clone the Repo

```bash
git clone https://github.com/amcritchie/boodle_scraper.git
cd boodle_scraper
```

---

## 2. LLM Providers

Agents need LLM access. Anthropic is primary. OpenAI is fallback. Set at least two.

**Anthropic (primary)**

```bash
openclaw onboard --auth-choice token
# follow prompts to enter your API key
```

Or set the key directly in `~/.openclaw/openclaw.json`:
```json
{
  "auth": {
    "profiles": {
      "anthropic:default": {
        "provider": "anthropic",
        "mode": "api_key",
        "apiKey": "sk-ant-..."
      }
    }
  }
}
```

Get key: [console.anthropic.com](https://console.anthropic.com)

**OpenAI (fallback)**

```bash
export OPENAI_API_KEY=sk-...
# or add to openclaw.json under auth.profiles
```

Get key: [platform.openai.com/api-keys](https://platform.openai.com/api-keys)

**Verify providers are visible:**
```bash
openclaw models list
```

---

## 3. Discord Bot Setup

Each agent has its own Discord bot. Four bots, four tokens. All bots connect to the McRitchie Studio guild (`1332466565203103744`).

### Create each bot (repeat 4 times)

1. Go to [discord.com/developers/applications](https://discord.com/developers/applications) → **New Application**
2. Name it after the agent: Alex, Mason, Mack, Turf Monster
3. Click **Bot** in the sidebar
4. Under **Privileged Gateway Intents**, enable:
   - ✅ **Message Content Intent** (required — without this, bots can't read messages)
   - ✅ **Server Members Intent** (recommended)
5. Click **Reset Token** → copy and save the token somewhere safe

### Invite each bot to McRitchie Studio

1. **OAuth2** → **URL Generator**
2. Scopes: `bot` + `applications.commands`
3. Bot permissions: View Channels, Send Messages, Read Message History, Embed Links, Add Reactions
4. Copy the URL → paste in browser → select **McRitchie Studio** → Authorize

### Configure all four tokens in OpenClaw

Edit `~/.openclaw/openclaw.json` — add or update the channels section:

```json
{
  "channels": {
    "discord": {
      "accounts": {
        "alex": { "token": "ALEX_BOT_TOKEN" },
        "mason": { "token": "MASON_BOT_TOKEN" },
        "mack": { "token": "MACK_BOT_TOKEN" },
        "turf-monster": { "token": "TURF_MONSTER_BOT_TOKEN" }
      },
      "groupPolicy": "allowlist",
      "guilds": {
        "1332466565203103744": {}
      }
    }
  }
}
```

> ⚠️ **Do not add `allow: true`** inside guild entries — it's not a valid config key and `openclaw doctor` will flag it. Just `{}` is correct.

After editing:
```bash
openclaw doctor --fix
openclaw gateway restart
```

### Add agent-to-Discord-account bindings

In `~/.openclaw/openclaw.json`, add under `bindings` (one per agent):

```json
{
  "bindings": [
    { "agentId": "alex",         "match": { "channel": "discord", "accountId": "alex" } },
    { "agentId": "mason",        "match": { "channel": "discord", "accountId": "mason" } },
    { "agentId": "mack",         "match": { "channel": "discord", "accountId": "mack" } },
    { "agentId": "turf-monster", "match": { "channel": "discord", "accountId": "turf-monster" } }
  ]
}
```

### Pair each bot

DM your bot in Discord. It will respond with a pairing code. Approve it:

```bash
openclaw pairing list discord
openclaw pairing approve discord <CODE>
```

Repeat for each of the four bots.

---

## 4. GitHub Authentication

Agents push code. Without this, commits stay local.

1. Go to: `github.com → Settings → Developer settings → Personal access tokens → Tokens (classic)`
2. Generate a new token — **repo** scope is sufficient
3. Set the remote URL with the token embedded:

```bash
cd /path/to/boodle_scraper
git remote set-url origin https://<YOUR_GITHUB_TOKEN>@github.com/amcritchie/boodle_scraper.git
```

4. Verify:
```bash
git push --dry-run origin main
```

Keep the token in a password manager. Do not commit it.

---

## 5. Environment Variables

```bash
cp .env.example .env
```

Fill in `.env` with real values:

```env
RAILS_ENV=development
SECRET_KEY_BASE=          # generate: openssl rand -hex 64
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=        # set to whatever you want; Docker uses this
SPORTRADAR_API_KEY=       # from developer.sportradar.com (trial key is fine)
```

Generate a secret key base:
```bash
openssl rand -hex 64
```

---

## 6. Agent Workspaces

Run the setup script to bootstrap OpenClaw workspaces for all four agents:

```bash
bash docs/agents/setup.sh
```

Or use interactive mode to set credentials at the same time:

```bash
bash docs/agents/setup.sh --interactive
```

Interactive mode prompts for all credentials, writes Discord tokens to OpenClaw config, generates `.env`, and runs workspace setup in one pass.

After setup, register each agent in OpenClaw:

```bash
openclaw agents add alex
openclaw agents add mason
openclaw agents add mack
openclaw agents add turf-monster
```

Verify the workspace config in `~/.openclaw/openclaw.json`:

```json
{
  "agents": {
    "list": [
      { "id": "alex",          "default": true, "workspace": "~/.openclaw/workspace" },
      { "id": "mason",         "workspace": "~/.openclaw/workspace-mason" },
      { "id": "mack",          "workspace": "~/.openclaw/workspace-mack" },
      { "id": "turf-monster",  "workspace": "~/.openclaw/workspace-turf-monster" }
    ]
  }
}
```

---

## 7. Docker / App

```bash
docker compose up --build -d
```

The entrypoint automatically runs `db:prepare` on first boot (creates DB + runs all migrations). Wait ~30 seconds, then verify:

```bash
docker compose ps
curl -s http://localhost:3000/up | head -5
```

If the web container exits immediately, check logs:
```bash
docker compose logs web
```

Common issue: `.env` is missing `SECRET_KEY_BASE`. Generate one with `openssl rand -hex 64` and add it.

---

## 8. Database Seeds

Run these in order after the app is up:

```bash
# Agents, skills, tasks, activities, usage records
docker compose exec web bin/rails runner db/seed_agents.rb

# Articles
docker compose exec web bin/rails runner db/seed_articles.rb

# News items
docker compose exec web bin/rails runner db/seed_news.rb
```

Expected output for `seed_agents.rb`:
```
Created 4 agents
Created 14 skills
Created 13 skill assignments
Created 9 tasks
Created 17 activities
Created 8 usage records
```

---

## 9. Activity Logging

The activity logging endpoint is live as part of the app. No extra setup needed — it starts when Docker starts. Test it:

```bash
curl -s -X POST http://localhost:3000/api/agents/activities \
  -H "Content-Type: application/json" \
  -d '{
    "activity": {
      "agent_slug": "alex",
      "activity_type": "task_completed",
      "description": "Bootstrap complete — system online"
    }
  }'
```

See `docs/agents/system/activity-logging.md` for the full logging protocol.

---

## 10. Cron Jobs

Mack has two hourly cron jobs that post ops reports to `#lobster-tank`. Set them up with:

```bash
openclaw cron add \
  --agent mack \
  --name "Mack Hourly Ops Report" \
  --schedule "0 * * * *" \
  --timezone "America/Denver" \
  --target isolated \
  --prompt "Post an ops report to #lobster-tank covering: agent status, any task failures, LLM API health, and any issues needing attention. Keep it brief. Use your bot account."

openclaw cron add \
  --agent mack \
  --name "Mack Hourly LLM Ops Report" \
  --schedule "0 * * * *" \
  --timezone "America/Denver" \
  --target isolated \
  --prompt "Check LLM provider health across all agents. Report status to #lobster-tank. Flag any 429s, connection errors, or degraded providers."
```

Verify they're scheduled:
```bash
openclaw cron list
```

---

# 11. News Pipeline

The news pipeline ingests Adam Schefter tweets into the Rails `news` table, enriches them with AI, and posts to Discord.

## Credentials

Add these to `~/.openclaw/workspace/.secrets` (create file if needed, `chmod 600`):

```bash
X_BEARER_TOKEN=<X API v2 Bearer Token>
DISCORD_BOT_TOKEN=<Turf Monster bot token>
ANTHROPIC_API_KEY=<Anthropic API key>
```

Get `X_BEARER_TOKEN` from [developer.x.com](https://developer.x.com) — free tier is sufficient.  
`DISCORD_BOT_TOKEN` is Turf Monster's token from `openclaw.json`.  
`ANTHROPIC_API_KEY` is the same key used for agents.

## Scripts

| Script | Purpose |
|--------|---------|
| `workspace/scripts/poll-schefter.js` | Polls X API for new Schefter tweets → DB + Discord |
| `workspace/scripts/enrich-news.js` | AI enrichment of raw news records → `reviewed` stage |
| `workspace/scripts/schefter-state.json` | Tracks `since_id` — do not delete |
| `workspace/news/pipeline.jsonl` | Local append-only tweet log |

Images saved to: `boodle_scraper/public/images/news/`

## Cron Jobs

Set up via OpenClaw (jobs persist in `~/.openclaw/cron/jobs.json`):

```bash
# Poll Schefter tweets every 5 minutes
openclaw cron add \
  --agent alex \
  --name "poll-schefter" \
  --schedule "*/5 * * * *" \
  --timezone "America/Denver" \
  --target isolated \
  --prompt "Run the Schefter tweet poller: \`cd ~/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/poll-schefter.js\`. Log the output. No need to announce if it's a quiet run."

# Enrich news records every 10 minutes (Turf Monster)
openclaw cron add \
  --agent alex \
  --name "enrich-news (turf-monster)" \
  --schedule "*/10 * * * *" \
  --timezone "America/Denver" \
  --target isolated \
  --prompt "Run the news enrichment script: \`cd ~/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/enrich-news.js\`. Log the output. No need to announce if there are no pending records."
```

## Test It

```bash
# Manual poll test
cd ~/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/poll-schefter.js

# Manual enrich test
cd ~/.openclaw/workspace && set -a && source .secrets && set +a && node scripts/enrich-news.js

# Check pending records
curl -s "http://localhost:3000/api/news?stage=new" | python3 -m json.tool | head -20

# Check enriched records
curl -s "http://localhost:3000/api/news?stage=reviewed" | python3 -m json.tool | head -20
```

## News Stage Flow

```
new → reviewed → content → edited → posted → archived
```

- `new` — raw tweet, just ingested
- `reviewed` — AI-enriched (title_short, primary_person, primary_team, summary, image). Turf Monster posts a review summary to `#lobster-tank` on completion.
- Subsequent stages are manual editorial workflow

## Discord Review Summary Format

When a record is enriched, Turf Monster posts to `#lobster-tank`:
```
📋 News Reviewed
**[title_short]**
👤 [primary_person]  🏈 [primary_team]
[summary]
🔗 [tweet url]
```

---

# Verify Everything Works

Run these checks after setup. All should succeed.

### App is up
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/up
# → 200
```

### Agents endpoint
```bash
curl -s http://localhost:3000/api/agents | python3 -m json.tool | head -20
# → JSON array with 4 agents
```

### Agent dashboard
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/agents
# → 200
```

### Task API
```bash
curl -s "http://localhost:3000/api/agents/tasks?agent_slug=mack&stage=queued" | python3 -m json.tool
# → JSON (may be empty array if no queued tasks)
```

### Activity logging
```bash
curl -s -X POST http://localhost:3000/api/agents/activities \
  -H "Content-Type: application/json" \
  -d '{"activity":{"agent_slug":"alex","activity_type":"task_completed","description":"Verify check"}}' \
  | python3 -m json.tool
# → JSON with id, agent_slug, etc.
```

### News endpoint
```bash
curl -s http://localhost:3000/api/agents/activities | python3 -m json.tool | head -5
# → JSON with recent activities
```

### OpenClaw agents registered
```bash
openclaw agents list
# → 4 agents: alex, mason, mack, turf-monster
```

### Discord bots online
```bash
openclaw channels status
# → All 4 accounts showing as connected
```

### Send a test message to #lobster-tank
```bash
openclaw message send \
  --channel discord \
  --account alex \
  --target 1479973077021495478 \
  -m "👋 Alex back online. System check passed."
```

### GitHub push works
```bash
git push --dry-run origin main
# → succeeds without auth error
```

### Cron jobs scheduled
```bash
openclaw cron list
# → 2 entries for Mack
```

---

# Session Startup Protocol

Every agent follows this at the start of each session. No exceptions.

**Step 1 — Orient yourself**  
Read your `SOUL.md` and `role.md`. This is who you are and what you own.

**Step 2 — Know your operator**  
Read `docs/agents/system/user.md`. Human operator is Alexander Ray McRitchie — address as Mr. McRitchie.

**Step 3 — Get current**  
Read `docs/agents/shared/MEMORY.md`. This is what the system knows right now — active projects, API status, recent decisions.

**Step 4 — Check your task queue**  
```
GET /api/agents/tasks?agent_slug=<your-slug>&stage=queued
```
Pick up the highest-priority task and start.

**Step 5 — Read your personal memory (if it exists)**  
Check `memory/YYYY-MM-DD.md` for today and yesterday.

**Don't ask permission. Just do it.**

---

# Core Directives

1. **Autonomy First** — Make decisions within your domain without waiting for approval. Escalate only when a decision is irreversible or crosses domain boundaries.

2. **Operators Ship** — Bias toward action. A shipped imperfect thing beats a perfect plan.

3. **Figure It Out** — When blocked, find another way. Escalate only after exhausting your own options.

4. **Respect Agent Domains** — Each agent owns their domain. Collaborate through tasks, not takeovers.

5. **Protect the Operator** — Minimize demands on Mr. McRitchie's time. Batch questions. Provide options, not open-ended asks.

6. **Think in Systems** — Every task is part of a larger system. Consider upstream and downstream effects.

---

# Task Pipeline

```
new → queued → in_progress → done | failed
```

- **new** — Created, not yet assigned
- **queued** — Assigned, waiting to be picked up
- **in_progress** — Agent is actively working
- **done** — Completed with result data
- **failed** — Failed with error message

Priority: Normal (0), High (1), Urgent (2)

---

# Conflict Resolution

- **Technical veto** → Mack. If she says it risks uptime, it does.
- **Product veto** → Mason. If he says it doesn't serve the user, it doesn't.
- **Alex breaks ties.** Mack vs. Mason → Alex decides.
- **Operator is final word.** Business model, monetization, audience — that's Mr. McRitchie's call.

---

# Failure Handling

When a task fails:

1. Transition to `failed` via the API
2. Set `error_message` to a specific description
3. Log in your personal memory file
4. Infrastructure failure → create a task for Mack
5. Recurring failure → write down the protocol

Do not retry silently. Do not abandon tasks without transitioning them.

---

# Communication

- **Primary channel:** Discord `#lobster-tank` (`1479973077021495478`)
- **Inter-agent:** Task API — see `docs/agents/system/comms.md`
- **Escalation to operator:** Tag Mr. McRitchie via Discord

---

# Quality Standards

- Code must be clean, tested, and production-ready
- Content must be accurate, engaging, and on-brand
- Data must be validated before use
- All work must be traceable through the task system

---

# Reference

| Doc | What it covers |
|-----|---------------|
| `docs/agents/system/architecture.md` | Agent roster, domains, system diagram |
| `docs/agents/system/comms.md` | Task API + Discord communication protocol |
| `docs/agents/system/activity-logging.md` | Activity logging endpoint and vocabulary |
| `docs/agents/system/credentials.md` | Every credential, where to get it, where it goes |
| `docs/agents/system/user.md` | Human operator profile |
| `docs/agents/shared/MEMORY.md` | Shared system memory — current state, decisions |
