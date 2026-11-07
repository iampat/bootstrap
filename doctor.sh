#!/bin/bash
# Read-only health check: does this machine match the repo? Exits non-zero if anything is off.
set -uo pipefail
cd "$(dirname "$0")"
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null || true)"

fail=0
ok()   { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }
warn() { printf '  \033[33mwarn\033[0m %s\n' "$1"; }

check_link() { # check_link <repo path> <home path>
  local want="$PWD/$1" have
  have="$(readlink "$2" 2>/dev/null || true)"
  if [ "$have" = "$want" ]; then ok "$2 -> $1"
  elif [ -e "$2" ]; then bad "$2 exists but is not a link to $1"
  else bad "$2 missing"; fi
}

echo "Homebrew"
if command -v brew >/dev/null; then ok "brew $(brew --version | head -1 | cut -d' ' -f2)"; else bad "brew not installed"; fi
if brew bundle check --file=Brewfile >/dev/null 2>&1; then ok "Brewfile satisfied"
else bad "Brewfile has missing packages:"; brew bundle check --file=Brewfile --verbose 2>/dev/null | sed 's/^/         /'; fi

echo "Dotfiles"
check_link zsh/.zshrc     "$HOME/.zshrc"
check_link git/.gitconfig "$HOME/.gitconfig"
grep -q 'YOUR NAME\|you@example.com' git/.gitconfig && warn "git/.gitconfig still has placeholder identity"

echo "Claude Code"
if command -v claude >/dev/null; then ok "claude $(claude --version 2>/dev/null | head -1)"; else bad "claude not on PATH"; fi
check_link claude/settings.json "$HOME/.claude/settings.json"
check_link claude/CLAUDE.md     "$HOME/.claude/CLAUDE.md"
check_link claude/commands      "$HOME/.claude/commands"
check_link claude/agents        "$HOME/.claude/agents"
check_link claude/skills        "$HOME/.claude/skills"
if security find-generic-password -s "Claude Code-credentials" >/dev/null 2>&1 || [ -f "$HOME/.claude/.credentials.json" ]; then ok "logged in"; else warn "not logged in yet (run: claude)"; fi
if command -v claude >/dev/null; then
  for name in $(grep -E '^add ' claude/mcp.sh | awk '{print $2}'); do
    claude mcp get "$name" >/dev/null 2>&1 && ok "mcp $name" || bad "mcp $name not registered"
  done
fi

echo "Repo"
if [ -n "$(git status --porcelain)" ]; then warn "uncommitted changes in $PWD"; else ok "working tree clean"; fi
git fetch -q origin 2>/dev/null && {
  behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
  ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
  [ "$behind" = 0 ] && ok "up to date with origin" || warn "$behind commit(s) behind origin, run: git pull && ./bootstrap_mac.sh"
  [ "$ahead" = 0 ] || warn "$ahead commit(s) not pushed"
}

exit $fail
