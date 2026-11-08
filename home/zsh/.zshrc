eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"

export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"  # go install binaries; /usr/local/go/bin comes from /etc/paths.d/go

# History: large, shared across terminals, deduplicated, written as commands run
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY          # every terminal sees commands from the others
setopt INC_APPEND_HISTORY     # write immediately, not on exit
setopt HIST_IGNORE_ALL_DUPS   # keep only the latest copy of a repeated command
setopt HIST_IGNORE_SPACE      # a leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY       # store timestamps

alias ll="ls -lah"
alias g="git"
ta() { tmux new-session -A -s "${1:-main}"; }  # attach to a tmux session, create if missing

# Machine-specific / secret stuff lives outside the repo.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
