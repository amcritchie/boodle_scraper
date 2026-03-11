# Memory Architecture

Agents wake up fresh each session. Memory files are their continuity.

## Two Layers

### Layer 1 — Individual Memory (Private)

Each agent maintains their own memory in their OpenClaw workspace:

- `memory/YYYY-MM-DD.md` — Daily session logs (raw notes, what happened, what was tried)
- `MEMORY.md` — Long-term curated memory (distilled insights, not raw logs)

These files are private to each agent. Write to them freely during every session. At the end of a session or during a scheduled check-in, review daily notes and promote significant learnings to `MEMORY.md`.

**What belongs in individual memory:**
- Tasks completed and how they went
- Errors encountered and how they were resolved
- Lessons learned that will affect future behavior
- Preferences and patterns specific to this agent's work
- Anything that would save time on the next session

### Layer 2 — Shared Memory (Cross-Agent)

All agents share a common memory layer:

**File:** `docs/agents/shared/MEMORY.md`

This file is the system's collective brain — the team's whiteboard. Any agent can read and write it. It lives in the repo and is Git-versioned.

**What belongs in shared memory:**
- Active project status ("Boodle dashboard: deployed on port 3000, seeded with 4 agents")
- Strategic decisions ("Primary LLM: Anthropic. Fallback: OpenAI. As of 2026-03-10.")
- API configurations and known limits ("SportRadar: trial key, 1000 req/day limit")
- Agent health notes ("Turf Monster image-search rate-limited 2x this week — using backup approach")
- System discoveries ("Docker container needs `db:prepare` on first boot — handled by entrypoint")
- Cross-agent coordination notes ("Alex queued 3 tasks for Mack on 2026-03-10, all in pipeline")

**What does NOT belong in shared memory:**
- Private operator context (keep in individual MEMORY.md)
- Raw logs (keep in daily files)
- Completed work that's already in the task system (it's already tracked there)
- Speculative notes that aren't actionable

## Memory Maintenance

During each session, every agent should:

1. Read `docs/agents/shared/MEMORY.md` on startup (Step 3 of the startup protocol)
2. Write to personal `memory/YYYY-MM-DD.md` throughout the session
3. Before ending: update shared memory if anything cross-agent-relevant was learned
4. Periodically (weekly): distill daily logs into `MEMORY.md` (personal long-term)

## Memory vs. Task System

The task system (`AgentTask`) tracks *work*. Memory tracks *context*.

| Use the task system for... | Use memory for... |
|---------------------------|-------------------|
| Work to be done | Why a decision was made |
| Work in progress | How to approach a recurring problem |
| Completed work with results | What was learned from a failure |
| Failed work with error messages | System state and configuration facts |

## File Locations

```
docs/agents/shared/MEMORY.md        ← Shared cross-agent memory (in repo)

~/.openclaw/agents/[slug]/workspace/
  MEMORY.md                         ← Long-term individual memory
  memory/
    YYYY-MM-DD.md                   ← Daily session logs
```
