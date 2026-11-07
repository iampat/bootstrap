#!/bin/bash
# Runs everything. Safe to re-run at any time.
set -euo pipefail
cd "$(dirname "$0")"
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# Symlink $1 (in this repo) to $2 (in $HOME), backing up anything already there.
link() {
  local src="$PWD/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%s)"
    echo "    backed up existing $dst"
  fi
  ln -sfn "$src" "$dst"
  echo "    $dst -> $src"
}

echo "==> Homebrew packages"
brew bundle --file=Brewfile --no-upgrade

echo "==> Dotfiles"
link zsh/.zshrc      "$HOME/.zshrc"
link git/.gitconfig  "$HOME/.gitconfig"

echo "==> Claude Code"
link claude/settings.json "$HOME/.claude/settings.json"
link claude/CLAUDE.md     "$HOME/.claude/CLAUDE.md"
link claude/commands      "$HOME/.claude/commands"
link claude/agents        "$HOME/.claude/agents"
link claude/skills        "$HOME/.claude/skills"
./claude/mcp.sh

echo "==> macOS defaults"
./macos.sh

echo "Done. Open a new terminal (or: exec zsh)."
