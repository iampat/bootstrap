#!/bin/bash
# Remote entry point. Run on a fresh Mac with:
#   /bin/bash -c "$(curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/iampat/bootstrap/main/install.sh)"
# It installs Homebrew (which pulls in Xcode CLT + git), clones this repo, and hands off to bootstrap_mac.sh.
set -euo pipefail

REPO="https://github.com/iampat/bootstrap.git"
DIR="${BOOTSTRAP_DIR:-$HOME/bootstrap}"

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS only."; exit 1; }

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

if [ -d "$DIR/.git" ]; then
  echo "==> Updating $DIR"
  git -C "$DIR" pull --ff-only
else
  echo "==> Cloning into $DIR"
  git clone "$REPO" "$DIR"
fi

exec "$DIR/bootstrap_mac.sh"
