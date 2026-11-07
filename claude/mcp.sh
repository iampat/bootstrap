#!/bin/bash
# User-scope MCP servers. These live in ~/.claude.json (not committed, it holds auth state),
# so they are re-created here. Each line is idempotent.
set -euo pipefail
command -v claude >/dev/null 2>&1 || { echo "    claude not on PATH yet, skipping MCP"; exit 0; }

add() { # add <name> <claude mcp add args...>
  claude mcp get "$1" >/dev/null 2>&1 || claude mcp add --scope user "$@"
}

# Examples:
# add context7 -- npx -y @upstash/context7-mcp
# add github --transport http https://api.githubcopilot.com/mcp/
