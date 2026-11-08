# Maintaining this repo

This repo sets up a Mac from scratch and keeps it in sync. Every script must stay idempotent:
running `bootstrap_mac.sh` twice, or on a machine set up from an older commit, must only apply
the difference and never break anything.

## Rules

- Nothing secret goes here. No tokens, keys, `~/.claude.json`, `.credentials.json`,
  `settings.local.json`, or session history. Secrets live in `~/.zshrc.local` or Keychain.
- `home/claude/.claude/settings.json` is also written by Claude Code itself (plugins, permissions,
  env). Review `git diff` of it before committing; never put keys in its `env` block.
- Prefer a data line over a script line. A new app is one Brewfile line, a new setting is one
  `defaults write` in `macos.sh`, a new MCP server is one `add` line in `mcp.sh`, a new dotfile
  is one file under `home/`.
- `home/<tool>/` mirrors `$HOME` and is linked file by file by GNU stow (`--no-folding`), so a
  directory like `~/.claude` that also holds runtime state never points into the repo. Keep it
  that way. Put config under `home/`, never state.
- Guard every command that is not naturally idempotent (see `add()` in `mcp.sh`).
- Everything `bootstrap_mac.sh` needs in order to run comes from Homebrew or this repo. A tool
  Homebrew lacks is installed by a guarded line in it, never by hand on the machine.
- Keep `install.sh` tiny. It only needs to get Homebrew, clone, and hand off.
- Run `bash -n` on changed scripts and `./doctor.sh` before committing.

## Extending

| Want | Change |
|---|---|
| CLI tool or app | `Brewfile`, then `brew bundle --file=Brewfile` |
| VS Code extension | `vscode "publisher.name"` in `Brewfile` |
| App Store app | `mas "Name", id: 123` in `Brewfile` (add `brew "mas"` first) |
| macOS setting | `macos.sh` |
| Shell alias or env | `home/zsh/.zshrc`; machine-specific goes in `~/.zshrc.local` |
| Any tool's config file | `home/<tool>/<path as in $HOME>`, e.g. `home/tmux/.tmux.conf` |
| Claude command / agent / skill | file under `home/claude/.claude/{commands,agents,skills}` |
| Claude setting or hook | `home/claude/.claude/settings.json`; hook scripts in `home/claude/.claude/hooks/` |
| MCP server | `add name ...` in `mcp.sh` |
| Not in Homebrew (curl installer, npm -g, go install) | guarded line in `bootstrap_mac.sh`: `command -v foo >/dev/null \|\| <install>` |
| After any change | `./bootstrap_mac.sh`, `./doctor.sh`, commit, push |
