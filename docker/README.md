# Containerized cc-gtd

Runs Claude Code inside a Docker container with a Squid proxy that restricts outbound network access to an allowlist of domains. This limits the blast radius of indirect prompt injection from external data sources (Gmail, Trello, etc.).

## Architecture

```
  host-install-claude.sh
  (download + verify checksum)
           │
           ▼
     claude-bin/  ──── read-only mount ────┐
                                           │
┌────────────────────────────┐     ┌───────┴──────────────────┐
│    framework container     │     │     squid container       │
│                            │     │                           │
│  CLI tools + /opt/claude   │────>│  Squid (port 3128)        │──> Internet
│  (read-only, host-verified)│     │  socat IMAP fwd (1993)    │   (allowlisted
│  cc-gtd bind-mounted      │     │                           │    domains only)
│  credentials (read-only)   │     │  allowed-domains.txt      │
│                            │     │                           │
│  NO direct internet        │     └──────────────────────────┘
│  (internal network only)   │
│                            │
│  Obsidian MCP via ──────────────> host.docker.internal:8787
│  host SSE bridge           │
└────────────────────────────┘
```

The framework container sits on an internal-only Docker network with no internet gateway. All HTTP/HTTPS traffic goes through the squid proxy, which only permits connections to domains listed in `allowed-domains.txt`. Gmail IMAP is forwarded via socat through the squid container.

## Prerequisites

- Docker Desktop running
- `ANTHROPIC_API_KEY` set in your environment (or in a `.env` file in this directory)
- Run `./host-install-claude.sh` before first use (downloads and verifies Claude Code)
- Credential files in place for the providers you use:
  - `~/.trello-cli/` — Trello CLI auth
  - `~/.gcalcli/` (or set `GCALCLI_OAUTH_DIR`) — gcalcli OAuth tokens
  - `integrations/scripts/gmail-gtd/<account>` — Gmail app passwords

## Quick start

```bash
cd docker

# First time: install Claude Code on the host (verified checksum)
./host-install-claude.sh

# Build both images (slow first time — compiles Rust)
docker compose build

# Start
docker compose up -d

# Attach to Claude Code interactively
docker compose exec -it framework claude

# When done
docker compose down
```

## Environment variables

Set these in your shell or in `docker/.env`:

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `ANTHROPIC_API_KEY` | Yes | — | Claude API key |
| `ASANA_ACCESS_TOKEN` | No | — | Asana personal access token |
| `CC_GTD_PATH` | No | `..` | Path to cc-gtd repo on host |
| `SYSTEMS_PATH` | No | `../systems` | Path to systems directory on host |
| `GCALCLI_OAUTH_DIR` | No | `~/.gcalcli` | Path to gcalcli OAuth credentials |

## Updating Claude Code

Claude Code is installed on the host and mounted read-only into the container. To update:

```bash
./host-install-claude.sh
docker compose restart framework
```

The host script downloads the latest Claude Code in a temporary container, verifies its checksum against the official manifest, and stores the verified binary in `claude-bin/`. This directory is mounted read-only at `/opt/claude` — the agent cannot modify the binary, the checksum, or the entrypoint at runtime.

## Modifying the domain allowlist

Edit `allowed-domains.txt`, then rebuild the squid image:

```bash
docker compose build squid
docker compose up -d
```

The current allowlist permits:

- **Claude Code runtime**: `api.anthropic.com`, Sentry, Statsig
- **Provider APIs**: Trello, Todoist, Asana, Google (Calendar, OAuth)
- **Package managers**: npm registry (for gmail-gtd dependency install)

Notably excluded: `storage.googleapis.com` (Claude Code binary distribution) — this is a shared GCS namespace and is only accessed at build time, never at runtime.

## Obsidian MCP access

The Obsidian MCP server runs on the host. To make it accessible from inside the container, run an SSE bridge on the host:

```bash
# On host — bridge the Obsidian MCP stdio server to SSE on port 8787
npx supergateway --stdio "npx obsidian-mcp-tools" --port 8787
```

Then configure Claude Code inside the container to use the SSE endpoint. Add to your MCP settings (`.claude/settings.json` or via `claude mcp add`):

```json
{
  "mcpServers": {
    "obsidian": {
      "type": "sse",
      "url": "http://host.docker.internal:8787/sse"
    }
  }
}
```

The `host.docker.internal` hostname is mapped to the host via `extra_hosts` in the compose file.

## Verifying the security boundary

```bash
# Start containers
docker compose up -d

# Allowed domain works
docker compose exec framework curl -s -o /dev/null -w "%{http_code}" https://api.trello.com
# => 301

# Blocked domain rejected by squid
docker compose exec framework curl -v https://evil.com 2>&1 | grep "response 403"
# => CONNECT tunnel failed, response 403

# No direct internet (bypassing proxy)
docker compose exec framework bash -c 'unset HTTP_PROXY HTTPS_PROXY; curl -s --connect-timeout 5 https://example.com || echo "BLOCKED"'
# => BLOCKED
```

## Troubleshooting

**Claude Code not found**: Run `./host-install-claude.sh` to install the verified binary, then restart: `docker compose restart framework`

**Squid health check failing**: Check `docker compose logs squid`. Common cause: DNS resolution issues in the container network.

**Slow build on first run**: The Rust compilation of `tod` (Todoist CLI) takes several minutes. Subsequent builds use Docker layer caching and are fast unless system packages change.

**Gmail IMAP connection issues**: IMAP traffic is forwarded through socat in the squid container (`squid:1993` -> `imap.gmail.com:993`). Check that socat is running: `docker compose exec squid pgrep socat`

**Tool not found inside container**: Run `docker compose logs framework` and check the tool availability table printed at startup.
