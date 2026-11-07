# bootstrap

Reproducible Mac setup, including Claude Code.

## Fresh Mac

```
/bin/bash -c "$(curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/iampat/bootstrap/main/install.sh)"
```

Installs Homebrew, clones this repo to `~/workspace/iampat/bootstrap`, runs `bootstrap_mac.sh`.

## Update an existing Mac

```
cd ~/workspace/iampat/bootstrap && git pull && ./bootstrap_mac.sh
```

Everything is idempotent, so re-running only applies what changed. The other direction works
too: dotfiles are symlinks into this repo, so edits made on the machine show up as `git diff`
here. Commit, push, pull on the next machine.

```
./doctor.sh     # check that this machine matches the repo
```

## Layout

```
install.sh          # curl'd one-liner: brew + clone + hand off
bootstrap_mac.sh    # runs everything, idempotent
doctor.sh           # read-only health check
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

## GitHub

```
gh auth login            # browser flow, pick HTTPS
gh auth setup-git        # git push/pull use the same token
```

Then set your identity in `git/.gitconfig` and commit it. For a work identity on one machine,
put a `[user]` block in `~/.gitconfig.local`; it is included automatically and never committed.

## Secrets

The repo holds the names of secrets, never values. Two places for values:

- `~/.zshrc.local`, sourced by `.zshrc`, `chmod 600`. Simplest.
- macOS Keychain, synced by iCloud Keychain if enabled:

  ```
  security add-generic-password -U -s openai -a "$USER" -w     # store, prompts for value
  export OPENAI_API_KEY="$(security find-generic-password -s openai -w)"   # in ~/.zshrc.local
  ```

Claude Code logs in via browser on first run; its token lives in `~/.claude/.credentials.json`,
outside this repo. MCP servers that need tokens read them from the environment when `mcp.sh` runs.
