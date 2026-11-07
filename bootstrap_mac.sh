#!/bin/bash
# Runs everything. Safe to re-run at any time.
set -euo pipefail
cd "$(dirname "$0")"
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"

echo "==> Homebrew packages"
brew bundle --file=Brewfile

echo "==> Dotfiles (home/<tool>/ mirrors \$HOME, linked with stow)"
# A real file where a link should go would make stow refuse; move it aside first.
while IFS= read -r f; do
  dst="$HOME/${f#home/*/}"
  if [ -e "$dst" ] && [ ! -L "$dst" ] && [ ! -d "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%s)"
    echo "    backed up existing $dst"
  fi
done < <(find home -mindepth 2 -type f)
stow --dir=home --target="$HOME" --verbose=1 -- $(ls home) 2>&1 | sed 's/^/    /'

echo "==> Claude Code MCP servers"
./mcp.sh

echo "==> macOS defaults"
./macos.sh

echo "Done. Open a new terminal (or: exec zsh). Some macOS settings apply after logout."
