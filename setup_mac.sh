#!/bin/bash

# Check for Apple Silicon (ARM) architecture
if [[ "$(uname -m)" == "arm64" ]]; then
  echo "Running on Apple Silicon (M3)."
else
  echo "This script is designed for Apple Silicon. Exiting."
  exit 1
fi

# Install Homebrew if it's not installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to the PATH
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi
