# Mack Ops — Error Protocols

This is a living document. Mack writes protocols as failure modes are encountered and tested.
Format: trigger → diagnosis → remediation → prevention.

---

## Protocol Index

| ID | Category | Description | Status |
|----|----------|-------------|--------|
| LLM_001 | LLM | Provider rate limit (429) | Draft |
| LLM_002 | LLM | Provider outage (5xx sustained) | Draft |
| DB_001 | Database | Connection refused | Draft |
| SCRAPE_001 | Scraping | Rate limit / IP block | Draft |
| AGENT_001 | Agent | Session gone silent | Draft |

---

## LLM_001 — Provider Rate Limit (429)

**Trigger:** LLM API returns 429 Too Many Requests

**Diagnosis:**
1. Check `Retry-After` header — this is authoritative
2. Check token consumption rate — are we spiking unusually?
3. Check if multiple agents are hitting same provider simultaneously

**Remediation:**
1. Honor `Retry-After` exactly — do not retry early
2. Reduce request rate by 50% for the next 5 minutes
3. If `Retry-After` > 60 seconds, route to fallback provider immediately
4. Log the rate limit event with timestamp and agent_slug

**Prevention:**
- Stagger agent request timing to avoid simultaneous bursts
- Track daily token budget and throttle at 80% of limit
- Use fallback provider proactively for non-critical requests during high-traffic periods

---

## LLM_002 — Provider Outage (5xx Sustained)

**Trigger:** 5+ consecutive 5xx responses or circuit breaker opens

**Diagnosis:**
1. Check provider status page (status.anthropic.com / status.openai.com)
2. Distinguish between full outage vs. specific endpoint degradation
3. Check if latency is spiking before errors — often a leading indicator

**Remediation:**
1. Open circuit immediately — stop sending requests to degraded provider
2. Route all affected agents to fallback provider
3. Set circuit half-open probe at 30-second intervals
4. Alert operator if outage exceeds 5 minutes
5. Log provider, start time, and affected agents

**Recovery:**
1. Single probe request to primary provider
2. If successful: close circuit, ramp traffic back gradually (25% → 50% → 100% over 3 minutes)
3. If probe fails: reset open timer, continue on fallback
4. Document outage duration and impact in `memory/YYYY-MM-DD.md`

**Prevention:**
- Always maintain at least one fallback provider with valid credentials
- Test fallback routing monthly (simulated primary outage)

---

## DB_001 — Database Connection Refused

**Trigger:** Rails logs `PG::ConnectionBad: connection to server ... failed`

**Diagnosis:**
1. `docker compose ps` — is the db container running?
2. `docker compose logs db` — any crash or OOM events?
3. Check `docker stats` — is the db container hitting memory limits?

**Remediation:**
1. If container crashed: `docker compose restart db` then `docker compose restart web`
2. If OOM: increase memory limit in docker-compose.yml, restart
3. If connection pool exhausted: restart web container (flushes pool), investigate query patterns

**Prevention:**
- Set `RAILS_MAX_THREADS` appropriately (default 5 is fine for dev)
- Monitor `pg_stat_activity` for long-running queries that exhaust the pool
- Health check interval already set to 5s in docker-compose.yml

---

## SCRAPE_001 — Rate Limit / IP Block

**Trigger:** Scraping task returns 429, 403, or unusual redirect pattern

**Diagnosis:**
1. Is it a rate limit (429 with Retry-After) or hard block (403/redirect)?
2. Has the target site changed their HTML structure? (Selector failures ≠ blocks)
3. Is the same IP being used for all scraping requests?

**Remediation:**
1. Rate limit → back off for `Retry-After` duration, retry once
2. Soft block → pause scraping for 1 hour, retry with increased delay between requests
3. Hard block → transition task to `failed`, create new task for manual review
4. Structure change → transition task to `failed`, create task for Mack to update selectors

**Prevention:**
- Add random 1–3 second jitter between scraping requests
- Rotate user-agent strings
- Respect `robots.txt` — don't scrape paths that are disallowed

---

## AGENT_001 — Agent Session Gone Silent

**Trigger:** Active agent shows no activity in activity feed for > 30 minutes during expected active hours

**Diagnosis:**
1. Check OpenClaw session status for that agent
2. Check if agent has any tasks in `in_progress` that may have stalled
3. Check if an LLM error would have caused session to hang

**Remediation:**
1. If session is dead: restart the agent's OpenClaw session, check for unsaved work
2. If task is stalled: transition task to `failed` with error "session timeout", requeue
3. If LLM error caused hang: resolve LLM issue first, then restart session
4. Log the silence event with duration and any tasks that were in-flight

**Prevention:**
- Heartbeat monitoring for all active agent sessions
- Tasks should have timeout thresholds — if `in_progress` for > 2x expected duration, auto-flag

---

*Last updated: auto-updated by Mack when new protocols are added or revised.*
*Next review: quarterly*
