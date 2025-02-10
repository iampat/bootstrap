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
  echo >> "${HOME}/.zprofile
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

brew update

# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Homebrew Packages
echo "Installing Homebrew packages..."
brew install git openssh emacs gh jq
brew install python@3.12 gcc@13
brew install protobuf

brew install tailscale
# To start tailscale now and restart at login:
# brew services start tailscale

# Install Go
echo "Installing Go..."
GO_VERSION="1.23.2"
ARCH=$(uname -m)

if [ "$ARCH" = "arm64" ]; then
    GO_ARCH="arm64"
else
    GO_ARCH="amd64"
fi

echo "Installing Go $GO_VERSION for $GO_ARCH..."
curl -OL https://go.dev/dl/go${GO_VERSION}.darwin-${GO_ARCH}.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.darwin-${GO_ARCH}.tar.gz
rm go${GO_VERSION}.darwin-${GO_ARCH}.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zprofiles

brew install --cask google-chrome
brew install --cask rectangle   # https://rectangleapp.com/
brew install --cask visual-studio-code
# Uncomment if needed.
# sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
code --install-extension ms-python.python
code --install-extension golang.go

echo "Setup complete! Please restart your terminal or run 'source ~/.zprofile' to apply the changes."


# install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# install gcloud cli
curl -OL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz
rm -rf $HOME/local/bin/google-cloud-sdk
tar xvf google-cloud-cli-darwin-arm.tar.gz -C $HOME/local/bin 
$HOME/local/bin/google-cloud-sdk/install.sh
rm -rf google-cloud-cli-darwin-arm.tar.gz

gcloud components install gke-gcloud-auth-plugin

# install podman and kubectl
# TODO(iampat): Use the recommended method https://podman.io/docs/installation
brew install podman
brew install kubectl
brew install helm

# install node.js, npm
brew install node
npm install -g npm@latest

# install mermaid-cli
npm install -g @mermaid-js/mermaid-cli
