#!/bin/bash
# Runs everything. Safe to re-run at any time.
set -euo pipefail
cd "$(dirname "$0")"
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"

echo "==> Homebrew packages"
brew update
brew bundle --file=Brewfile

echo "==> Dotfiles (home/<tool>/ mirrors \$HOME, linked file by file with stow)"
pkgs=(); for d in home/*/; do pkgs+=("$(basename "$d")"); done
if [ ${#pkgs[@]} -gt 0 ]; then
  # Walk each target path from $HOME down. Anything on the way that stow does not own would make
  # it refuse, so move it aside (.bak). A directory link of ours from an older run is removed so
  # stow can recreate it unfolded.
  ts=$(date +%s)
  while IFS= read -r f; do
    rel="${f#home/*/}"; pkg="${f#home/}"; pkg="${pkg%%/*}"
    IFS=/ read -ra parts <<< "$rel"; acc=""
    for part in "${parts[@]}"; do
      acc="${acc:+$acc/}$part"; dst="$HOME/$acc"
      if [ -L "$dst" ]; then
        if [[ "$(readlink "$dst")" == *"/home/$pkg/$acc" ]]; then
          [ "$acc" = "$rel" ] || { rm "$dst"; echo "    unfolding $dst"; }
        else
          echo "    removed foreign link $dst -> $(readlink "$dst")"; rm "$dst"
        fi
        break
      elif [ -e "$dst" ] && [ ! -d "$dst" ]; then
        mv "$dst" "$dst.bak.$ts"; echo "    backed up existing $dst"; break
      elif [ ! -e "$dst" ]; then break
      fi
    done
  done < <(find home -mindepth 2 -type f)
  # --no-folding: never link a directory itself, so ~/.claude and friends stay real directories
  # and their runtime state stays out of the repo. --restow: drop links to files removed from repo.
  # No "--" before the package list: stow 2.4 drops everything after it.
  stow --dir=home --target="$HOME" --restow --no-folding "${pkgs[@]}"
  echo "    linked: ${pkgs[*]}"
fi

echo "==> Git identity"
if [ -z "$(git config --global --includes user.email || true)" ]; then
  if [ -t 0 ]; then
    read -rp "    Git name:  " git_name
    read -rp "    Git email: " git_email
    git config --file "$HOME/.gitconfig.local" user.name "$git_name"
    git config --file "$HOME/.gitconfig.local" user.email "$git_email"
    echo "    written to ~/.gitconfig.local"
  else
    echo "    not set and no terminal to ask; set later with: git config --file ~/.gitconfig.local user.email you@example.com"
  fi
else
  echo "    $(git config --global --includes user.name) <$(git config --global --includes user.email)>"
fi

echo "==> Claude Code MCP servers"
./mcp.sh

echo "==> macOS defaults"
./macos.sh

echo "Done. Open a new terminal (or: exec zsh). Some macOS settings apply after logout."
