# Apps & CLI tools. Applied with `brew bundle`. Add a line, re-run bootstrap_mac.sh.
brew "git"
brew "gh"
brew "bash"  # bash-completion@2 needs bash >= 4.2; /bin/bash is 3.2. zsh stays the login shell (see spec.md)
brew "bash-completion@2"  # tab completion in bash for git, gh and every Homebrew tool that ships one; loaded by home/bash/.bashrc
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
brew "fvm"  # Flutter SDK manager; the version pin lives in each project's .fvmrc, not here
brew "cocoapods"
brew "node"
brew "firebase-cli"

# cloudy-neigh (Go + Bazel) toolchain
brew "bazelisk"  # reads .bazelversion and downloads the pinned Bazel; Go, Python, protoc come via MODULE.bazel
brew "hf"  # Hugging Face CLI; `task download-dataset` pulls the Cohere Wikipedia benchmark set
cask "gcloud-cli"  # GCS benchmark runs in benchmark/Taskfile.yaml (project kentrolabs-ai)
cask "antigravity-cli"  # Google Antigravity CLI, installs `agy`; drives the consult-* Claude skills

cask "claude-code"
cask "google-chrome"
cask "iterm2"
brew "emacs"  # terminal Emacs (zshrc aliases emacs to -nw); the emacs-app cask downloads from emacsformacosx.com, which times out and hangs brew bundle
cask "visual-studio-code"
cask "font-jetbrains-mono-nerd-font"  # icons for the Starship prompt; select it in iTerm2 > Profiles > Text
brew "watch"  # repeat a command and show its output
brew "dust"  # disk usage tree, du replacement
