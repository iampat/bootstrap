# Apps & CLI tools. Applied with `brew bundle`. Add a line, re-run bootstrap_mac.sh.
brew "git"
brew "gh"
brew "stow"
brew "tmux"
brew "starship"
brew "python@3.13"
brew "mas"  # Mac App Store CLI; App Store apps are `mas_app` lines in bootstrap_mac.sh (a failed `mas` line here would abort brew bundle)

# Kentro (Flutter + Firebase + Terraform) toolchain
tap "hashicorp/tap", trusted: true  # Homebrew 7 refuses untrusted third-party taps
brew "hashicorp/tap/terraform"  # core's `terraform` formula is frozen at 1.5.7 (license change)
brew "go-task"
brew "uv"
brew "cocoapods"
brew "node"
brew "firebase-cli"

cask "claude-code"
cask "google-chrome"
cask "iterm2"
cask "emacs-app"
cask "visual-studio-code"
cask "flutter"
cask "font-jetbrains-mono-nerd-font"  # icons for the Starship prompt; select it in iTerm2 > Profiles > Text
