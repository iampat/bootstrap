#!/bin/bash
# System settings. Find more with: defaults read <domain>
set -euo pipefail

# Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Finder: show extensions, hidden files, path bar
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Dock: auto-hide
defaults write com.apple.dock autohide -bool true

killall Finder Dock 2>/dev/null || true
