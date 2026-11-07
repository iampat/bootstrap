eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

export EDITOR="code --wait"
export PATH="$HOME/.local/bin:$PATH"

alias ll="ls -lah"
alias g="git"

# Machine-specific / secret stuff lives outside the repo.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
