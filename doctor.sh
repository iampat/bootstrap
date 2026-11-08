#!/bin/bash
# Read-only health check: does this machine match the repo? Exits non-zero if anything is off.
set -uo pipefail
cd "$(dirname "$0")"
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null || true)"

fail=0
ok()   { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }
warn() { printf '  \033[33mwarn\033[0m %s\n' "$1"; }

echo "Homebrew"
if command -v brew >/dev/null; then ok "brew $(brew --version | head -1 | cut -d' ' -f2)"; else bad "brew not installed"; fi
if brew bundle check --file=Brewfile >/dev/null 2>&1; then ok "Brewfile satisfied"
else bad "Brewfile has missing or outdated packages:"; brew bundle check --file=Brewfile --verbose 2>/dev/null | sed 's/^/         /'; fi

echo "Dotfiles"
if ! command -v stow >/dev/null; then bad "stow not installed"
elif [ -z "$(ls home)" ]; then warn "home/ is empty"
else
  # Dry run. Silence means every link is already in place; any output is drift or a conflict.
  pkgs=(); for d in home/*/; do pkgs+=("$(basename "$d")"); done
  out="$(stow --dir=home --target="$HOME" --no --no-folding --verbose=1 "${pkgs[@]}" 2>&1 | grep -v "^WARNING: in simulation mode" || true)"
  if [ -z "$out" ]; then ok "all of home/ linked"; else bad "stow would change something:"; echo "$out" | sed 's/^/         /'; fi
fi
if [ -n "$(git config --global --includes user.email 2>/dev/null)" ]; then ok "git identity $(git config --global --includes user.name) <$(git config --global --includes user.email)>"
else warn "git identity not set (bootstrap_mac.sh asks for it, or: git config --file ~/.gitconfig.local user.email ...)"; fi

echo "Claude Code"
if command -v claude >/dev/null; then ok "claude $(claude --version 2>/dev/null | head -1)"; else bad "claude not on PATH"; fi
if security find-generic-password -s "Claude Code-credentials" >/dev/null 2>&1 || [ -f "$HOME/.claude/.credentials.json" ]; then ok "logged in"; else warn "not logged in yet (run: claude)"; fi
if command -v claude >/dev/null; then
  for name in $(grep -E '^add ' mcp.sh | awk '{print $2}'); do
    claude mcp get "$name" >/dev/null 2>&1 && ok "mcp $name" || bad "mcp $name not registered"
  done
fi

echo "Repo"
if [ -n "$(git status --porcelain)" ]; then warn "uncommitted changes in $PWD"; else ok "working tree clean"; fi
if git fetch -q origin 2>/dev/null && git rev-parse -q --verify '@{u}' >/dev/null 2>&1; then
  behind=$(git rev-list --count 'HEAD..@{u}'); ahead=$(git rev-list --count '@{u}..HEAD')
  [ "$behind" = 0 ] && ok "up to date with origin" || warn "$behind commit(s) behind origin, run: git pull && ./bootstrap_mac.sh"
  [ "$ahead" = 0 ] || warn "$ahead commit(s) not pushed"
else
  warn "could not compare with origin (offline or no upstream)"
fi

exit $fail
