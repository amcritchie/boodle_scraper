#!/bin/bash
# setup_agents.sh
# Bootstrap OpenClaw workspaces for McRitchie Studio agents.
# Run this from the repo root after cloning on a new machine.
#
# Usage: bash docs/agents/setup.sh

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OPENCLAW_DIR="$HOME/.openclaw"
AGENTS_DIR="$REPO_DIR/docs/agents/agents"
SYSTEM_DIR="$REPO_DIR/docs/agents/system"

echo "McRitchie Studio — Agent Workspace Setup"
echo "Repo: $REPO_DIR"
echo "OpenClaw: $OPENCLAW_DIR"
echo ""

# ── Helper ─────────────────────────────────────────────────────────

setup_workspace() {
  local agent_id="$1"
  local agent_name="$2"
  local workspace="$OPENCLAW_DIR/workspace-$agent_id"

  echo "Setting up: $agent_name ($workspace)"
  mkdir -p "$workspace/memory"

  # Core identity files from repo
  cp "$AGENTS_DIR/$agent_id/soul.md"  "$workspace/SOUL.md"

  # AGENTS.md (startup protocol) — prefer workspace version if it exists
  if [ ! -f "$workspace/AGENTS.md" ]; then
    cp "$REPO_DIR/docs/agents/setup_templates/AGENTS-$agent_id.md" "$workspace/AGENTS.md" 2>/dev/null || \
    cat > "$workspace/AGENTS.md" <<AGENTSEOF
# You are $agent_name — see soul.md for your full identity.

Repo: $REPO_DIR
Bootstrap: $REPO_DIR/docs/agents/system/bootstrap.md

Follow the session startup protocol in bootstrap.md. Do not ask permission. Just do it.
AGENTSEOF
  fi

  # USER.md — same for all agents
  cp "$SYSTEM_DIR/user.md" "$workspace/USER.md"

  # TOOLS.md — shared content
  cat > "$workspace/TOOLS.md" <<EOF
# TOOLS.md

## Boodle App
- URL: http://localhost:3000
- Agents dashboard: http://localhost:3000/agents
- API base: http://localhost:3000/api
- Docker: \`docker compose\` from \`/home/alex/.openclaw/workspace/boodle_scraper/\`

## Discord
- Guild: McRitchie Studio (1332466565203103744)
- Primary channel: #lobster-tank (1479973077021495478)

## Shared Memory
- File: \`$REPO_DIR/docs/agents/shared/MEMORY.md\`
EOF

  # Create stubs if they don't exist (never overwrite existing memory)
  [ ! -f "$workspace/MEMORY.md" ] && echo "# MEMORY.md — $agent_name" > "$workspace/MEMORY.md"
  [ ! -f "$workspace/HEARTBEAT.md" ] && echo "# HEARTBEAT.md" > "$workspace/HEARTBEAT.md"
  [ ! -f "$workspace/IDENTITY.md" ] && echo "# IDENTITY.md — see SOUL.md" > "$workspace/IDENTITY.md"

  echo "  ✓ $workspace"
}

# ── Set up each agent workspace ─────────────────────────────────────

setup_workspace "mason"         "Mason"
setup_workspace "mack"          "Mack"
setup_workspace "turf-monster"  "Turf Monster"

# Alex uses the default workspace — update soul in place
echo ""
echo "Updating Alex's workspace (default: $OPENCLAW_DIR/workspace)"
cp "$AGENTS_DIR/alex/soul.md" "$OPENCLAW_DIR/workspace/SOUL.md"
echo "  ✓ SOUL.md updated"

echo ""
echo "─────────────────────────────────────────────"
echo "Workspaces ready. Next: register agents in OpenClaw."
echo ""
echo "Add each agent with the CLI wizard:"
echo "  openclaw agents add alex"
echo "  openclaw agents add mason"
echo "  openclaw agents add turf-monster"
echo ""
echo "Then update ~/.openclaw/openclaw.json to point each agent"
echo "at its workspace:"
echo ""
cat <<'EOF'
  "agents": {
    "list": [
      { "id": "alex",          "workspace": "~/.openclaw/workspace"              },
      { "id": "mason",         "workspace": "~/.openclaw/workspace-mason"        },
      { "id": "mack",          "workspace": "~/.openclaw/workspace-mack"         },
      { "id": "turf-monster",  "workspace": "~/.openclaw/workspace-turf-monster" }
    ]
  }
EOF
echo ""
echo "For Discord: each agent needs its own Discord bot token."
echo "See: docs/agents/system/comms.md"
echo "─────────────────────────────────────────────"
