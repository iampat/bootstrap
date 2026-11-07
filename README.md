# bootstrap

Reproducible Mac setup. On a fresh machine:

```
/bin/bash -c "$(curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/iampat/bootstrap/main/install.sh)"
```

That installs Homebrew, clones this repo to `~/bootstrap`, and runs `bootstrap_mac.sh`.
Re-run `~/bootstrap/bootstrap_mac.sh` any time after editing files here.

```
install.sh          # curl'd one-liner: brew + clone + hand off
bootstrap_mac.sh    # runs everything, idempotent
Brewfile            # apps & CLI tools
macos.sh            # defaults write ...
zsh/.zshrc          # -> ~/.zshrc
git/.gitconfig      # -> ~/.gitconfig
claude/
  settings.json     # -> ~/.claude/settings.json
  CLAUDE.md         # -> ~/.claude/CLAUDE.md
  commands/ agents/ skills/   # -> ~/.claude/{commands,agents,skills}
  mcp.sh            # `claude mcp add` commands
```

Dotfiles are symlinked, so edits made on the machine show up as `git diff` here.
Secrets and per-machine config go in `~/.zshrc.local` and `~/.gitconfig.local` (not in the repo).
