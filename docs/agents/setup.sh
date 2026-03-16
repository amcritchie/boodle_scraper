#!/bin/bash
# setup.sh — McRitchie Studio Agent Workspace Bootstrap
#
# Bootstraps OpenClaw workspaces for all 4 agents from the repo.
# Run from the repo root after cloning on a new machine.
#
# Usage:
#   bash docs/agents/setup.sh                  # workspace setup only (non-interactive)
#   bash docs/agents/setup.sh --interactive    # prompt for all credentials + workspace setup
#   bash docs/agents/setup.sh --workspaces     # workspace setup only (explicit)

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OPENCLAW_DIR="$HOME/.openclaw"
OPENCLAW_JSON="$OPENCLAW_DIR/openclaw.json"
AGENTS_DIR="$REPO_DIR/docs/agents/agents"
SYSTEM_DIR="$REPO_DIR/docs/agents/system"

# ── Parse args ─────────────────────────────────────────────────────

INTERACTIVE=false
for arg in "$@"; do
  case "$arg" in
    --interactive|-i) INTERACTIVE=true ;;
    --workspaces)     INTERACTIVE=false ;;
  esac
done

# Default to interactive when called with no args and stdin is a terminal
if [ "$#" -eq 0 ] && [ -t 0 ]; then
  INTERACTIVE=true
fi

# ── Helpers ────────────────────────────────────────────────────────

print_header() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  McRitchie Studio — Agent Workspace Setup"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Repo:      $REPO_DIR"
  echo "  OpenClaw:  $OPENCLAW_DIR"
  echo ""
}

prompt_credential() {
  local varname="$1"
  local label="$2"
  local hint="${3:-}"
  local val=""
  while [ -z "$val" ]; do
    if [ -n "$hint" ]; then
      printf "  %-28s (%s): " "$label" "$hint"
    else
      printf "  %-28s: " "$label"
    fi
    read -r -s val 2>/dev/null || read -r val
    echo ""
    if [ -z "$val" ]; then
      echo "  ⚠️  Cannot be empty. Try again."
    fi
  done
  eval "$varname=\"\$val\""
}

prompt_optional() {
  local varname="$1"
  local label="$2"
  local hint="${3:-optional, press Enter to skip}"
  printf "  %-28s (%s): " "$label" "$hint"
  read -r val 2>/dev/null || read -r val
  echo ""
  eval "$varname=\"\$val\""
}

# Write a key into openclaw.json using Python (jq not guaranteed to be present)
# Usage: set_openclaw_key 'channels.discord.accounts.mack.token' 'TOKEN_VALUE'
set_openclaw_key() {
  local key_path="$1"
  local value="$2"

  python3 - "$OPENCLAW_JSON" "$key_path" "$value" <<'PYEOF'
import sys, json, os

config_file = sys.argv[1]
key_path    = sys.argv[2]
value       = sys.argv[3]

if os.path.exists(config_file):
  with open(config_file) as f:
    data = json.load(f)
else:
  data = {}

# Walk/create the path
parts = key_path.split('.')
node = data
for part in parts[:-1]:
  if part not in node or not isinstance(node[part], dict):
    node[part] = {}
  node = node[part]
node[parts[-1]] = value

with open(config_file, 'w') as f:
  json.dump(data, f, indent=2)
  f.write('\n')
PYEOF
}

setup_workspace() {
  local agent_id="$1"
  local agent_name="$2"
  local agent_dir="${3:-$agent_id}"
  local workspace="$OPENCLAW_DIR/workspace-$agent_id"

  echo "  Setting up: $agent_name"
  mkdir -p "$workspace/memory"

  cp "$AGENTS_DIR/$agent_dir/soul.md" "$workspace/SOUL.md"

  if [ ! -f "$workspace/AGENTS.md" ]; then
    cp "$REPO_DIR/docs/agents/setup_templates/AGENTS-$agent_id.md" "$workspace/AGENTS.md" 2>/dev/null || \
    cat > "$workspace/AGENTS.md" <<AGENTSEOF
# You are $agent_name — see SOUL.md for your full identity.

Repo: $REPO_DIR
Bootstrap: $REPO_DIR/docs/agents/system/bootstrap.md

Follow the session startup protocol in bootstrap.md. Do not ask permission. Just do it.
AGENTSEOF
  fi

  cp "$SYSTEM_DIR/user.md" "$workspace/USER.md"

  cat > "$workspace/TOOLS.md" <<EOF
# TOOLS.md

## Boodle App
- URL: http://localhost:3000
- Agents dashboard: http://localhost:3000/agents
- API base: http://localhost:3000/api
- Docker: \`docker compose\` from \`$REPO_DIR\`

## Discord
- Guild: McRitchie Studio (1332466565203103744)
- Primary channel: #lobster-tank (1479973077021495478)

## Shared Memory
- File: \`$REPO_DIR/docs/agents/shared/MEMORY.md\`
EOF

  [ ! -f "$workspace/MEMORY.md" ]    && echo "# MEMORY.md — $agent_name"   > "$workspace/MEMORY.md"
  [ ! -f "$workspace/HEARTBEAT.md" ] && echo "# HEARTBEAT.md"              > "$workspace/HEARTBEAT.md"
  [ ! -f "$workspace/IDENTITY.md" ]  && echo "# IDENTITY.md — see SOUL.md" > "$workspace/IDENTITY.md"

  echo "  ✓ $workspace"
}

# ── Interactive credential collection ──────────────────────────────

collect_credentials() {
  echo "Credential Setup"
  echo "────────────────────────────────────────────────────"
  echo "Press Enter to skip optional credentials."
  echo ""

  echo "LLM Providers:"
  prompt_credential ANTHROPIC_KEY "Anthropic API key" "sk-ant-..."
  prompt_credential GOOGLE_KEY    "Google AI API key" "AIza..."
  prompt_optional   OPENAI_KEY    "OpenAI API key (fallback)" "sk-..."
  echo ""

  echo "GitHub:"
  prompt_credential GITHUB_PAT "GitHub Personal Access Token" "repo scope"
  echo ""

  echo "Discord Bot Tokens (one per agent):"
  prompt_credential DISCORD_TOKEN_ALEX         "Alex bot token"
  prompt_credential DISCORD_TOKEN_MASON        "Mason bot token"
  prompt_credential DISCORD_TOKEN_MACK         "Mack bot token"
  prompt_credential DISCORD_TOKEN_TURF_MONSTER "Turf Monster bot token"
  echo ""

  echo "App Credentials:"
  prompt_credential SPORTRADAR_KEY  "Sportradar API key"
  prompt_credential POSTGRES_PASS   "Postgres password" "choose any value"

  echo ""
  echo "News Pipeline — X API (Schefter polling):"
  prompt_credential X_BEARER_TOKEN  "X Bearer Token (read-only)" "developer.x.com"
  echo ""

  echo "News Pipeline — Turf Monster X Account (OAuth 1.0a for posting):"
  prompt_credential TM_X_API_KEY       "TM X API Key (Consumer Key)"
  prompt_credential TM_X_API_SECRET    "TM X API Secret (Consumer Secret)"
  prompt_credential TM_X_ACCESS_TOKEN  "TM X Access Token"
  prompt_credential TM_X_ACCESS_SECRET "TM X Access Token Secret"
  echo ""

  echo ""
  echo "Cron Job Intervals:"
  echo "  Enter cron intervals for each pipeline job."
  echo "  Format: cron expression (e.g. */10 * * * * for every 10 min, 0 * * * * for hourly)"
  echo ""
  prompt_credential CRON_POLL_SCHEFTER       "poll-schefter interval"        "default: */10 * * * *"
  prompt_credential CRON_ENRICH_NEWS         "enrich-news interval"          "default: */10 * * * *"
  prompt_credential CRON_OPINION_NEWS        "opinion-news interval"         "default: */15 * * * *"
  prompt_credential CRON_EDIT_POST           "edit-post interval"            "default: */15 * * * *"
  prompt_credential CRON_EDIT_REPLY_POST     "edit-reply-post interval"      "default: */15 * * * *"
  prompt_credential CRON_POST_TO_X           "post-to-x interval"            "default: */30 * * * *"
  prompt_credential CRON_POST_REPLY_TO_X     "post-reply-to-x interval"      "default: */10 * * * *"
  prompt_credential CRON_MASON_REFINEMENT    "mason-task-refinement interval" "default: 0 * * * *"
  echo ""

  echo "Generating Rails SECRET_KEY_BASE..."
  SECRET_KEY=$(openssl rand -hex 64)
  echo "  ✓ Generated"
}

# ── Apply credentials ──────────────────────────────────────────────

apply_credentials() {
  echo ""
  echo "Applying credentials..."
  echo ""

  # ── Anthropic key → openclaw.json ──
  echo "  → Anthropic key → openclaw.json"
  set_openclaw_key "auth.profiles.anthropic:default.provider"  "anthropic"
  set_openclaw_key "auth.profiles.anthropic:default.mode"      "api_key"
  set_openclaw_key "auth.profiles.anthropic:default.apiKey"    "$ANTHROPIC_KEY"

  # ── Google key → openclaw.json ──
  echo "  → Google key → openclaw.json"
  set_openclaw_key "auth.profiles.google:default.provider"  "google"
  set_openclaw_key "auth.profiles.google:default.mode"      "api_key"
  set_openclaw_key "auth.profiles.google:default.apiKey"    "$GOOGLE_KEY"

  # ── OpenAI key → openclaw.json (if provided) ──
  if [ -n "$OPENAI_KEY" ]; then
    echo "  → OpenAI key → openclaw.json"
    set_openclaw_key "auth.profiles.openai:default.provider"  "openai"
    set_openclaw_key "auth.profiles.openai:default.mode"      "api_key"
    set_openclaw_key "auth.profiles.openai:default.apiKey"    "$OPENAI_KEY"
  fi

  # ── Per-agent auth-profiles.json ──
  echo "  → Per-agent auth-profiles.json"
  for agent_slug in alex mason mack turf-monster; do
    local agent_auth_dir="$OPENCLAW_DIR/agents/$agent_slug/agent"
    mkdir -p "$agent_auth_dir"
    cat > "$agent_auth_dir/auth-profiles.json" <<AUTHEOF
{
  "version": 1,
  "profiles": {
    "anthropic:default": { "type": "api_key", "provider": "anthropic", "key": "$ANTHROPIC_KEY" },
    "google:default":    { "type": "api_key", "provider": "google",    "key": "$GOOGLE_KEY" }$([ -n "$OPENAI_KEY" ] && echo ",
    \"openai:default\":    { \"type\": \"api_key\", \"provider\": \"openai\",    \"key\": \"$OPENAI_KEY\" }" || echo "")
  }
}
AUTHEOF
    echo "  ✓ $agent_auth_dir/auth-profiles.json"
  done

  # ── Discord tokens → openclaw.json ──
  echo "  → Discord tokens → openclaw.json"
  set_openclaw_key "channels.discord.accounts.alex.token"          "$DISCORD_TOKEN_ALEX"
  set_openclaw_key "channels.discord.accounts.mason.token"         "$DISCORD_TOKEN_MASON"
  set_openclaw_key "channels.discord.accounts.mack.token"          "$DISCORD_TOKEN_MACK"
  set_openclaw_key "channels.discord.accounts.turf-monster.token"  "$DISCORD_TOKEN_TURF_MONSTER"

  # ── Discord groupPolicy + guild allowlist ──
  set_openclaw_key "channels.discord.groupPolicy"                          "allowlist"
  set_openclaw_key "channels.discord.guilds.1332466565203103744"           "{}"
  # guilds entry must be an object, not a string — fix it
  python3 - "$OPENCLAW_JSON" <<'PYEOF'
import sys, json
f = sys.argv[1]
with open(f) as fh: data = json.load(fh)
guilds = data.get('channels', {}).get('discord', {}).get('guilds', {})
for gid in guilds:
  if not isinstance(guilds[gid], dict):
    guilds[gid] = {}
with open(f, 'w') as fh:
  json.dump(data, fh, indent=2)
  fh.write('\n')
PYEOF

  # ── Agent-Discord bindings ──
  echo "  → Agent bindings → openclaw.json"
  python3 - "$OPENCLAW_JSON" <<'PYEOF'
import sys, json
f = sys.argv[1]
with open(f) as fh: data = json.load(fh)
new_bindings = [
  {"agentId": "alex",         "match": {"channel": "discord", "accountId": "alex"}},
  {"agentId": "mason",        "match": {"channel": "discord", "accountId": "mason"}},
  {"agentId": "mack",         "match": {"channel": "discord", "accountId": "mack"}},
  {"agentId": "turf-monster", "match": {"channel": "discord", "accountId": "turf-monster"}}
]
existing = data.get('bindings', [])
# Remove old discord bindings, keep others
kept = [b for b in existing if b.get('match', {}).get('channel') != 'discord']
data['bindings'] = kept + new_bindings
with open(f, 'w') as fh:
  json.dump(data, fh, indent=2)
  fh.write('\n')
PYEOF

  # ── GitHub remote ──
  echo "  → GitHub PAT → git remote"
  cd "$REPO_DIR"
  git remote set-url origin "https://${GITHUB_PAT}@github.com/amcritchie/boodle_scraper.git"
  echo "  ✓ git remote updated"

  # ── .env ──
  echo "  → Generating .env from .env.example"
  if [ ! -f "$REPO_DIR/.env.example" ]; then
    echo "  ⚠️  .env.example not found — skipping .env generation"
  else
    cp "$REPO_DIR/.env.example" "$REPO_DIR/.env"
    # Use Python to do safe substitutions (avoids sed quoting nightmares)
    python3 - "$REPO_DIR/.env" "$SPORTRADAR_KEY" "$POSTGRES_PASS" "$SECRET_KEY" <<'PYEOF'
import sys
env_file     = sys.argv[1]
sportradar   = sys.argv[2]
pg_pass      = sys.argv[3]
secret_key   = sys.argv[4]

with open(env_file) as f:
  lines = f.readlines()

replacements = {
  'SPORTRADAR_API_KEY=': f'SPORTRADAR_API_KEY={sportradar}\n',
  'POSTGRES_PASSWORD=':  f'POSTGRES_PASSWORD={pg_pass}\n',
  'SECRET_KEY_BASE=':    f'SECRET_KEY_BASE={secret_key}\n',
}

out = []
for line in lines:
  replaced = False
  for prefix, new_line in replacements.items():
    if line.startswith(prefix):
      out.append(new_line)
      replaced = True
      break
  if not replaced:
    out.append(line)

with open(env_file, 'w') as f:
  f.writelines(out)
PYEOF
    echo "  ✓ .env written"
  fi

  # ── .secrets (news pipeline) ──
  SECRETS_FILE="$OPENCLAW_DIR/workspace/.secrets"
  echo "  → Writing news pipeline credentials → $SECRETS_FILE"
  cat > "$SECRETS_FILE" <<SECRETSEOF
# News pipeline credentials — DO NOT COMMIT
X_BEARER_TOKEN=$X_BEARER_TOKEN
DISCORD_BOT_TOKEN=$DISCORD_TOKEN_TURF_MONSTER
ANTHROPIC_API_KEY=$ANTHROPIC_KEY

# Turf Monster X OAuth 1.0a (for posting tweets)
TM_X_API_KEY=$TM_X_API_KEY
TM_X_API_SECRET=$TM_X_API_SECRET
TM_X_ACCESS_TOKEN=$TM_X_ACCESS_TOKEN
TM_X_ACCESS_SECRET=$TM_X_ACCESS_SECRET
SECRETSEOF
  chmod 600 "$SECRETS_FILE"
  echo "  ✓ .secrets written (chmod 600)"

  # ── Validate config ──
  echo ""
  echo "  Running openclaw doctor..."
  openclaw doctor --fix 2>&1 | grep -E "^(✓|✗|⚠|ERROR|Fixed)" || true
  echo ""
}

# ── Summary ────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Setup Complete"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  ✓ Agent workspaces created"

  if [ "$INTERACTIVE" = true ]; then
    echo "  ✓ LLM provider keys set in openclaw.json"
    echo "  ✓ Discord bot tokens set in openclaw.json"
    echo "  ✓ Agent-Discord bindings configured"
    echo "  ✓ GitHub remote updated with PAT"
    echo "  ✓ .env generated"
    echo "  ✓ .secrets written (news pipeline X + Anthropic keys)"
    echo "  ✓ Per-agent auth-profiles.json (Anthropic + Google$([ -n "$OPENAI_KEY" ] && echo " + OpenAI"))"
    echo ""
    echo "  Cron intervals collected:"
    echo "    poll-schefter:        $CRON_POLL_SCHEFTER"
    echo "    enrich-news:          $CRON_ENRICH_NEWS"
    echo "    opinion-news:         $CRON_OPINION_NEWS"
    echo "    edit-post:            $CRON_EDIT_POST"
    echo "    edit-reply-post:      $CRON_EDIT_REPLY_POST"
    echo "    post-to-x:            $CRON_POST_TO_X"
    echo "    post-reply-to-x:      $CRON_POST_REPLY_TO_X"
    echo "    mason-refinement:     $CRON_MASON_REFINEMENT"
    echo ""
    echo "  Still manual:"
    echo "  • Register agents: openclaw agents add alex / mason / mack / turf-monster"
    echo "  • Pair Discord bots: DM each bot → openclaw pairing approve discord <CODE>"
    echo "  • Restart gateway: openclaw gateway restart"
    echo "  • Start app: docker compose up --build -d  (from repo root)"
    echo "  • Run seeds: docker exec boodle_scraper-web-1 bin/rails runner db/seed_agents.rb"
    echo "  •            docker exec boodle_scraper-web-1 bin/rails runner db/seed_articles.rb"
    echo "  •            docker exec boodle_scraper-web-1 bin/rails runner db/seed_news.rb"
    echo "  • Set up cron jobs using intervals above (see bootstrap.md § Cron Jobs)"
    echo "  • Verify .secrets news pipeline credentials: ~/.openclaw/workspace/.secrets"
  else
    echo ""
    echo "  Next steps:"
    echo "  • Run --interactive to configure credentials"
    echo "  • Or set credentials manually (see docs/agents/system/credentials.md)"
  fi
  echo ""
  echo "  Full guide: docs/agents/system/bootstrap.md"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ── Main ───────────────────────────────────────────────────────────

print_header

if [ "$INTERACTIVE" = true ]; then
  collect_credentials
  apply_credentials
fi

# Always run workspace setup
echo "Setting up agent workspaces..."
echo ""

setup_workspace "mason"         "Mason"
setup_workspace "mack"          "Mack"
setup_workspace "turf-monster"  "Turf Monster" "turf_monster"

echo ""
echo "Updating Alex's workspace (default: $OPENCLAW_DIR/workspace)"
mkdir -p "$OPENCLAW_DIR/workspace/memory"
cp "$AGENTS_DIR/alex/soul.md" "$OPENCLAW_DIR/workspace/SOUL.md"
cp "$SYSTEM_DIR/user.md"      "$OPENCLAW_DIR/workspace/USER.md"
[ ! -f "$OPENCLAW_DIR/workspace/MEMORY.md" ]    && echo "# MEMORY.md — Alex Agent"  > "$OPENCLAW_DIR/workspace/MEMORY.md"
[ ! -f "$OPENCLAW_DIR/workspace/HEARTBEAT.md" ] && echo "# HEARTBEAT.md"            > "$OPENCLAW_DIR/workspace/HEARTBEAT.md"
echo "  ✓ $OPENCLAW_DIR/workspace"

print_summary
