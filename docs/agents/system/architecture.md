# architecture.md

## Agent Roster

| Agent | Title | Slug | Type | Domain | Model | Workspace |
|-------|-------|------|------|--------|-------|-----------|
| Alex Agent | CEO | `alex` | strategy | Coordination, priorities, quality review | — | `~/.openclaw/workspace` (default) |
| Mason | CPO | `mason` | product | Product vision, feature prioritization, UX quality | — | `~/.openclaw/workspace-mason` |
| Mack | CTO | `mack` | engineering | Infrastructure, data pipelines, reliability | claude-sonnet | `~/.openclaw/workspace-mack` |
| Turf Monster | CMO | `turf-monster` | content | Sports media, content creation, audience growth | claude-sonnet | `~/.openclaw/workspace-turf-monster` |

## System Architecture

```
┌─────────────────────────────────────┐
│         Alex Agent (CEO)            │
│   Strategy · Coordination · QA      │
└──────┬──────────┬──────────┬────────┘
       │          │          │
 ┌─────▼───┐ ┌───▼─────┐ ┌──▼───────────┐
 │  Mason  │ │  Mack   │ │ Turf Monster │
 │  (CPO)  │ │  (CTO)  │ │    (CMO)     │
 │ Product │ │  Infra  │ │   Content    │
 │   UX    │ │  Data   │ │   Media      │
 └─────────┘ └─────────┘ └──────────────┘
```

## Task Pipeline

```
new → queued → in_progress → done | failed
```

Tasks are created, assigned to agents, and tracked through completion. Each transition is logged in the activity feed.

## Skill Categories

- **product** — Product strategy, user research, feature prioritization, quality assurance
- **content** — Article summarization, social media writing, image search
- **data** — Web scraping, API integration, RSS monitoring
- **analytics** — Data analysis, prediction modeling

## Communication

- **Inter-agent:** Task API (create tasks for each other)
- **To operator:** Discord notifications, dashboard alerts
- **Logging:** All actions tracked in activity feed
