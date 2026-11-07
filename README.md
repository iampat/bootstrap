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
mcp.sh              # `claude mcp add` commands
home/               # one folder per tool, each mirrors $HOME, linked with GNU stow
  zsh/.zshrc
  git/.gitconfig
  claude/.claude/{settings.json, CLAUDE.md, commands/, agents/, skills/}
```

To manage a new tool's config, put the file under `home/<tool>/` at the path it has in `$HOME`
and re-run `bootstrap_mac.sh`. Nothing else to edit. Example: `home/tmux/.tmux.conf`.

Stow links a whole directory when nothing exists at the target, and individual files when the
target directory already exists. That is what keeps `~/.claude/projects` and other runtime state
out of the repo while `~/.claude/commands` lands in it. Only put config under `home/`, never state.

## GitHub

```
gh auth login            # browser flow, pick HTTPS, answer No to "authenticate Git"
```

`home/git/.gitconfig` already routes github.com credentials through `gh`, so answering Yes would
only write a machine-specific path into the symlinked file.

Then set your identity in `home/git/.gitconfig` and commit it. For a work identity on one machine,
put a `[user]` block in `~/.gitconfig.local`; it is included automatically and never committed.

## Secrets

The repo holds the names of secrets, never values. Two places for values:

- `~/.zshrc.local`, sourced by `.zshrc`, `chmod 600`. Simplest.
- macOS Keychain, synced by iCloud Keychain if enabled:

  ```
  security add-generic-password -U -s openai -a "$USER" -w     # store, prompts for value
  export OPENAI_API_KEY="$(security find-generic-password -s openai -w)"   # in ~/.zshrc.local
  ```

Claude Code logs in via browser on first run; its token lives in the macOS Keychain, outside this
repo. An MCP server that needs a token takes it on its `add` line, e.g.
`add foo -e FOO_TOKEN="${FOO_TOKEN:?export it first}" -- npx -y foo-mcp`. The value is copied into
`~/.claude.json`, which is never committed.
