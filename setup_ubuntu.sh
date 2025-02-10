#!/bin/bash
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for architecture
ARCH=$(dpkg --print-architecture)
echo "Running on $ARCH architecture."

# Update package lists
sudo apt update && sudo apt upgrade -y

# Install basic dependencies
echo "Installing basic packages..."
sudo apt install -y git openssh-client emacs jq python3.12 build-essential protobuf-compiler

# Install GitHub CLI
if ! command_exists gh; then
    echo "Installing GitHub CLI..."
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh -y
fi

# Install Tailscale
if ! command_exists tailscale; then
    echo "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# Install Go
echo "Installing Go..."
GO_VERSION="1.23.2"
if [ "$ARCH" = "arm64" ]; then
    GO_ARCH="arm64"
else
    GO_ARCH="amd64"
fi
echo "Installing Go $GO_VERSION for $GO_ARCH..."
curl -OL "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
rm "go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile

# Install Visual Studio Code
if ! command_exists code; then
    echo "Installing Visual Studio Code..."
    sudo apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt update
    sudo apt install code -y
    
    # Install VS Code extensions
    code --install-extension ms-python.python
    code --install-extension golang.go
fi

# Install Chrome
if ! command_exists google-chrome; then
    echo "Installing Google Chrome..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt-get install -f -y
    rm google-chrome-stable_current_amd64.deb
fi

# Install Terraform
if ! command_exists terraform; then
    echo "Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install terraform -y
fi

# Install Google Cloud CLI
if ! command_exists gcloud; then
    echo "Installing Google Cloud CLI..."
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-454.0.0-linux-${ARCH}.tar.gz
    tar -xf google-cloud-cli-454.0.0-linux-${ARCH}.tar.gz
    ./google-cloud-sdk/install.sh --quiet
    rm google-cloud-cli-454.0.0-linux-${ARCH}.tar.gz
    gcloud components install gke-gcloud-auth-plugin --quiet
fi

# Install Podman, kubectl, and Helm
echo "Installing container tools..."
. /etc/os-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_stable.gpg] https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list > /dev/null
sudo apt update
sudo apt install -y podman

# Install kubectl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl

# Install Helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install -y helm

# Install Node.js and npm
if ! command_exists node; then
    echo "Installing Node.js and npm..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
    sudo npm install -g npm@latest
fi

# Install mermaid-cli
sudo npm install -g @mermaid-js/mermaid-cli

echo "Setup complete! Please restart your terminal or run 'source ~/.profile' to apply the changes."
