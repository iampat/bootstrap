#!/bin/bash
# Remote entry point. Run on a fresh Mac with:
#   /bin/bash -c "$(curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/iampat/bootstrap/main/install.sh)"
# It installs Homebrew (which pulls in Xcode CLT + git), clones this repo, and hands off to bootstrap_mac.sh.
set -euo pipefail

REPO="https://github.com/iampat/bootstrap.git"
DIR="${BOOTSTRAP_DIR:-$HOME/workspace/iampat/bootstrap}"

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS only."; exit 1; }

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
command -v brew >/dev/null 2>&1 || { echo "Homebrew install failed."; exit 1; }

if [ -d "$DIR/.git" ]; then
  echo "==> Updating $DIR"
  git -C "$DIR" pull --ff-only || { echo "Local changes in $DIR. Resolve them, then run ./bootstrap_mac.sh"; exit 1; }
else
  echo "==> Cloning into $DIR"
  mkdir -p "$(dirname "$DIR")"
  git clone "$REPO" "$DIR"
fi

exec "$DIR/bootstrap_mac.sh"
