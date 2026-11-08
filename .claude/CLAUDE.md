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
- `home/<tool>/` mirrors `$HOME` and is linked by GNU stow. Put config there, never runtime state.
  Stow links a directory whole if nothing exists at the target, otherwise file by file.
- Guard every command that is not naturally idempotent (see `add()` in `mcp.sh`).
- `bootstrap_mac.sh` must not depend on anything outside Homebrew and this repo.
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
