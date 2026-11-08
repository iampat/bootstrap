# Bash is not the login shell (zsh is); this file makes an interactive `bash` usable:
# Homebrew on PATH and tab completion for git, gh and every other Homebrew tool that ships one.
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"

export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"

# Completion. bash-completion@2 needs bash >= 4.2 (Homebrew's bash; /bin/bash is 3.2 and is not
# used once brew shellenv puts /opt/homebrew/bin first). It lazily loads every completion that
# Homebrew formulas install, git and gh included. On an old bash, load those two directly.
if [ -n "${BASH_VERSINFO:-}" ] && [ "${BASH_VERSINFO[0]}" -ge 4 ] && [ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
  # shellcheck source=/dev/null
  . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
else
  [ -r "$HOMEBREW_PREFIX/etc/bash_completion.d/git-completion.bash" ] && . "$HOMEBREW_PREFIX/etc/bash_completion.d/git-completion.bash"
  command -v gh >/dev/null && eval "$(gh completion -s bash)"
fi

alias ll="ls -lah"
alias g="git"
complete -o default -o nospace -F __git_wrap__git_main g 2>/dev/null  # alias gets git's completion too

# Machine-specific / secret stuff lives outside the repo.
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
