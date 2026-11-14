#!/bin/bash
# Runs everything. Safe to re-run at any time.
set -euo pipefail
cd "$(dirname "$0")"
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"

# Steps this script cannot do by itself (no terminal for sudo, App Store not signed in, ...)
# are recorded here and printed together at the end, so nothing silently stays undone.
manual_steps=()
manual() { manual_steps+=("$1"); echo "    manual: $1"; }

echo "==> Homebrew packages"
brew update
brew bundle --file=Brewfile

echo "==> App Store apps"
# One `mas_app <id> <name>` line per app, not `mas` lines in the Brewfile: a failed mas there
# makes brew bundle exit non-zero and aborts the whole run. A missing app is offered as a
# `mas install` (needs a signed-in App Store and sudo) or as a link to click; no terminal
# means the link goes to the manual steps. doctor.sh reads these lines.
mas_app() {
  local id=$1 name=$2 url="https://apps.apple.com/app/id$1" yn=""
  if mas list 2>/dev/null | grep -Eq "^ *$id "; then echo "    $name"; return; fi
  if [ -t 0 ]; then
    read -rp "    $name is missing. Install it now with mas (needs sudo)? [y/N] " yn
    if [[ "$yn" =~ ^[Yy] ]] && sudo mas install "$id"; then echo "    installed $name"; return; fi
  fi
  manual "install $name from the App Store: $url   (or: sudo mas install $id)"
}
mas_app 497799835 Xcode
mas_app 937984704 Amphetamine
mas_app 899247664 TestFlight
mas_app 1475387142 Tailscale
mas_app 1450874784 Transporter

xcode_dev=/Applications/Xcode.app/Contents/Developer
if [ -d /Applications/Xcode.app ]; then
  if [ "$(xcode-select -p)" != "$xcode_dev" ]; then
    if [ -t 0 ]; then sudo xcode-select -s "$xcode_dev"; echo "    xcode-select now points at Xcode.app"
    else manual "sudo xcode-select -s $xcode_dev"; fi
  fi
  # -runFirstLaunch accepts the license and installs the extra components; the check is its guard.
  if ! "$xcode_dev/usr/bin/xcodebuild" -checkFirstLaunchStatus >/dev/null 2>&1; then
    if [ -t 0 ]; then sudo "$xcode_dev/usr/bin/xcodebuild" -runFirstLaunch; echo "    first launch done"
    else manual "sudo xcodebuild -runFirstLaunch"; fi
  fi
  echo "    $("$xcode_dev/usr/bin/xcodebuild" -version 2>/dev/null | head -1)"
fi

echo "==> Go (official pkg from go.dev, Apple silicon only)"
if [ -x /usr/local/go/bin/go ]; then
  echo "    $(/usr/local/go/bin/go version)"
else
  ver=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)
  pkg="$(mktemp -d)/$ver.darwin-arm64.pkg"
  curl -fsSL "https://go.dev/dl/$ver.darwin-arm64.pkg" -o "$pkg"
  sudo installer -pkg "$pkg" -target /
  echo "    installed $ver to /usr/local/go"
fi

echo "==> Dotfiles (home/<tool>/ mirrors \$HOME, linked file by file with stow)"
pkgs=(); for d in home/*/; do [ -d "$d" ] && pkgs+=("$(basename "$d")"); done
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
    manual "git config --file ~/.gitconfig.local user.name 'Your Name' && git config --file ~/.gitconfig.local user.email you@example.com"
  fi
else
  echo "    $(git config --global --includes user.name) <$(git config --global --includes user.email)>"
fi

echo "==> Claude Code MCP servers"
./mcp.sh

echo "==> macOS defaults"
./macos.sh

if [ ${#manual_steps[@]} -gt 0 ]; then
  echo "==> Manual steps (this script could not do these; run them, then re-run ./bootstrap_mac.sh)"
  for s in "${manual_steps[@]}"; do echo "    - $s"; done
fi

echo "Done. Open a new terminal (or: exec zsh). Some macOS settings apply after logout."
