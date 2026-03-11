# credentials.md — McRitchie Studio Credential Reference

Every credential the system needs. Where to get it, where it goes, how to verify.

Run `bash docs/agents/setup.sh --interactive` to set all of these in one pass.

---

## LLM Providers

### Anthropic API Key (primary)

| | |
|---|---|
| **Get it** | [console.anthropic.com](https://console.anthropic.com) → API Keys → Create Key |
| **Looks like** | `sk-ant-api03-...` |
| **Goes into** | `~/.openclaw/openclaw.json` under `auth.profiles.anthropic:default.apiKey` |
| **Verify** | `openclaw models list` → should show claude models |

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

Or via CLI:
```bash
openclaw onboard --auth-choice token
```

---

### OpenAI API Key (fallback)

| | |
|---|---|
| **Get it** | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) → Create new secret key |
| **Looks like** | `sk-proj-...` or `sk-...` |
| **Goes into** | `~/.openclaw/openclaw.json` under `auth.profiles.openai:default.apiKey` |
| **Verify** | `openclaw models list` → should show gpt-4o and similar |

```json
{
  "auth": {
    "profiles": {
      "openai:default": {
        "provider": "openai",
        "mode": "api_key",
        "apiKey": "sk-..."
      }
    }
  }
}
```

---

## Discord

Four bots, one per agent. Each needs its own application and token.

**Guild:** McRitchie Studio — `1332466565203103744`  
**Primary channel:** #lobster-tank — `1479973077021495478`

### Creating a bot (do this 4 times)

1. [discord.com/developers/applications](https://discord.com/developers/applications) → **New Application**
2. Name it after the agent (Alex, Mason, Mack, Turf Monster)
3. **Bot** tab → **Reset Token** → copy token
4. Enable **Message Content Intent** and **Server Members Intent** under Privileged Gateway Intents
5. **OAuth2 → URL Generator** → scopes: `bot` + `applications.commands` → permissions: View Channels, Send Messages, Read Message History, Embed Links, Add Reactions → copy invite URL → authorize for McRitchie Studio

### Discord Bot Token — Alex

| | |
|---|---|
| **Get it** | Discord Dev Portal → Alex app → Bot → Reset Token |
| **Goes into** | `~/.openclaw/openclaw.json` → `channels.discord.accounts.alex.token` |
| **Verify** | `openclaw channels status` → alex account shows Connected |

### Discord Bot Token — Mason

| | |
|---|---|
| **Get it** | Discord Dev Portal → Mason app → Bot → Reset Token |
| **Goes into** | `~/.openclaw/openclaw.json` → `channels.discord.accounts.mason.token` |
| **Verify** | `openclaw channels status` → mason account shows Connected |

### Discord Bot Token — Mack

| | |
|---|---|
| **Get it** | Discord Dev Portal → Mack app → Bot → Reset Token |
| **Goes into** | `~/.openclaw/openclaw.json` → `channels.discord.accounts.mack.token` |
| **Verify** | `openclaw channels status` → mack account shows Connected |

### Discord Bot Token — Turf Monster

| | |
|---|---|
| **Get it** | Discord Dev Portal → Turf Monster app → Bot → Reset Token |
| **Goes into** | `~/.openclaw/openclaw.json` → `channels.discord.accounts.turf-monster.token` |
| **Verify** | `openclaw channels status` → turf-monster account shows Connected |

### Full Discord config block in openclaw.json

```json
{
  "channels": {
    "discord": {
      "accounts": {
        "alex":          { "token": "ALEX_BOT_TOKEN" },
        "mason":         { "token": "MASON_BOT_TOKEN" },
        "mack":          { "token": "MACK_BOT_TOKEN" },
        "turf-monster":  { "token": "TURF_MONSTER_BOT_TOKEN" }
      },
      "groupPolicy": "allowlist",
      "guilds": {
        "1332466565203103744": {}
      }
    }
  },
  "bindings": [
    { "agentId": "alex",         "match": { "channel": "discord", "accountId": "alex" } },
    { "agentId": "mason",        "match": { "channel": "discord", "accountId": "mason" } },
    { "agentId": "mack",         "match": { "channel": "discord", "accountId": "mack" } },
    { "agentId": "turf-monster", "match": { "channel": "discord", "accountId": "turf-monster" } }
  ]
}
```

### After editing openclaw.json

```bash
openclaw doctor --fix
openclaw gateway restart
```

### Pairing bots

After restarting the gateway, DM each bot in Discord. It responds with a pairing code:

```bash
openclaw pairing list discord
openclaw pairing approve discord <CODE>
```

Repeat for all four.

### Verify end-to-end

```bash
openclaw message send \
  --channel discord \
  --account alex \
  --target 1479973077021495478 \
  -m "👋 Test from Alex"
```

---

## GitHub

### Personal Access Token (PAT)

| | |
|---|---|
| **Get it** | github.com → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token |
| **Scope needed** | `repo` |
| **Goes into** | Git remote URL |
| **Verify** | `git push --dry-run origin main` |

```bash
git remote set-url origin https://<TOKEN>@github.com/amcritchie/boodle_scraper.git
git push --dry-run origin main
```

Keep the token in a password manager. Do not commit it to the repo.

---

## App / Docker

### Rails SECRET_KEY_BASE

| | |
|---|---|
| **Get it** | Generate locally |
| **Goes into** | `.env` → `SECRET_KEY_BASE=` |
| **Verify** | `docker compose logs web` — no `Missing secret_key_base` error |

```bash
openssl rand -hex 64
# → paste into .env as SECRET_KEY_BASE=<value>
```

### Postgres Password

| | |
|---|---|
| **Get it** | Choose any password — you're setting it, not retrieving it |
| **Goes into** | `.env` → `POSTGRES_PASSWORD=` |
| **Verify** | `docker compose exec db psql -U postgres -c '\l'` lists databases |

The Docker Postgres service uses `POSTGRES_HOST_AUTH_METHOD: trust` by default (no password needed for local dev). You can leave `POSTGRES_PASSWORD` blank if you prefer.

### Sportradar API Key

| | |
|---|---|
| **Get it** | [developer.sportradar.com](https://developer.sportradar.com) — register for a trial key |
| **Goes into** | `.env` → `SPORTRADAR_API_KEY=` |
| **Verify** | `curl "https://api.sportradar.com/nfl/official/trial/v7/en/league/hierarchy.json?api_key=YOUR_KEY"` → 200 response |
| **Limits** | Trial: 1,000 requests/day |

---

## Summary Table

| Credential | File | Key |
|-----------|------|-----|
| Anthropic API key | `~/.openclaw/openclaw.json` | `auth.profiles.anthropic:default.apiKey` |
| OpenAI API key | `~/.openclaw/openclaw.json` | `auth.profiles.openai:default.apiKey` |
| GitHub PAT | git remote URL | embedded in URL |
| Discord — Alex | `~/.openclaw/openclaw.json` | `channels.discord.accounts.alex.token` |
| Discord — Mason | `~/.openclaw/openclaw.json` | `channels.discord.accounts.mason.token` |
| Discord — Mack | `~/.openclaw/openclaw.json` | `channels.discord.accounts.mack.token` |
| Discord — Turf Monster | `~/.openclaw/openclaw.json` | `channels.discord.accounts.turf-monster.token` |
| Sportradar API key | `.env` | `SPORTRADAR_API_KEY` |
| Postgres password | `.env` | `POSTGRES_PASSWORD` |
| Rails SECRET_KEY_BASE | `.env` | `SECRET_KEY_BASE` |

---

## Security Notes

- `.env` is gitignored — never commit it
- `~/.openclaw/openclaw.json` contains live secrets — never commit or share it
- GitHub PAT lives only in the git remote URL on this machine — regenerate if it leaks
- Discord bot tokens can be reset in the Dev Portal without recreating the app
