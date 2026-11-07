# Maintaining this repo

This repo sets up a Mac from scratch and keeps it in sync. Every script must stay idempotent:
running `bootstrap_mac.sh` twice, or on a machine set up from an older commit, must only apply
the difference and never break anything.

## Rules

- Nothing secret goes here. No tokens, keys, `~/.claude.json`, `.credentials.json`,
  `settings.local.json`, or session history. Secrets live in `~/.zshrc.local` or Keychain.
- Prefer a data line over a script line. A new app is one Brewfile line, a new setting is one
  `defaults write` in `macos.sh`, a new MCP server is one `add` line in `claude/mcp.sh`.
- Guard every command that is not naturally idempotent (see `add()` in `claude/mcp.sh`).
- Dotfiles are symlinked by `link()` in `bootstrap_mac.sh`. To add one, put the file in the
  repo and add a `link` line there, plus a `check_link` line in `doctor.sh`.
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
| Shell alias or env | `zsh/.zshrc`; machine-specific goes in `~/.zshrc.local` |
| Claude command / agent / skill | file under `claude/commands`, `claude/agents`, `claude/skills` |
| Claude setting or hook | `claude/settings.json`; hook scripts go in `claude/hooks/` and need a `link` line |
| MCP server | `add name ...` in `claude/mcp.sh` |
| New dotfile | file in repo + `link` in `bootstrap_mac.sh` + `check_link` in `doctor.sh` |
