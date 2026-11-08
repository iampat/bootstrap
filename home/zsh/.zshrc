eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"

export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"  # go install binaries; /usr/local/go/bin comes from /etc/paths.d/go

alias ll="ls -lah"
alias g="git"
ta() { tmux new-session -A -s "${1:-main}"; }  # attach to a tmux session, create if missing

# Machine-specific / secret stuff lives outside the repo.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
