#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Apple Silicon (ARM) architecture
if [[ "$(uname -m)" == "arm64" ]]; then
  echo "Running on Apple Silicon."
else
  echo "This script is designed for Apple Silicon. Exiting."
  exit 1
fi

if ! command_exists brew ; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> /Users/ali/.zprofile
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/ali/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi
