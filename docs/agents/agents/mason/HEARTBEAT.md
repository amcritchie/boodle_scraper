# HEARTBEAT.md — Mason Task Refinement Loop

Runs every hour via `mason-task-refinement` cron.

---

## Protocol

### 1. Check for PENDING_REVIEW tasks

Look for tasks in the `queued` stage assigned to **mason** where Mr. McRitchie has replied in `#lobster-tank` with clarification or approval.

- If approved/clarified → enrich the task description, transition to `in_progress`, and execute or delegate
- If blocked → post a follow-up to `#lobster-tank` with the blocker

### 2. Check for NEW tasks

Look for tasks in `stage: new` assigned to mason.

For each:
1. **Read the task** — is it clear enough to execute?
   - **Yes** → enrich description if needed, transition to `queued`, post a brief acknowledgment to `#lobster-tank`
   - **No** → post a clarifying question to `#lobster-tank` with the task ID and what's missing

### 3. Nothing to do?

If the board is clean (no `new` or mason-assigned `queued` tasks needing attention), reply `HEARTBEAT_OK` and exit.

---

## Decision Rules

- **Queue directly** when the task is self-contained and requirements are clear
- **Ask Alex** when scope is ambiguous, affects infrastructure owned by Mack, or requires strategic input
- **Never invent tasks** — only work with what's on the board
- **Keep asks short** — one focused question, not a list

---

## API Quick Reference

```bash
# List tasks
curl -s http://localhost:3000/api/agents/tasks

# Transition a task
curl -s -X PATCH http://localhost:3000/api/agents/tasks/:id/transition \
  -H "Content-Type: application/json" \
  -d '{"transition":"queue"}'   # or: start, complete, fail

# Post to #lobster-tank (mason bot)
MASON_TOKEN=$(python3 -c "import json; d=json.load(open('/home/alex/.openclaw/openclaw.json')); print(d['channels']['discord']['accounts']['mason']['token'])")
curl -s -X POST "https://discord.com/api/v10/channels/1479973077021495478/messages" \
  -H "Authorization: Bot $MASON_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "your message here"}'
```

---

*Last updated: 2026-03-13*
