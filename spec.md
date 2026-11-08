# Spec

What this repo guarantees, how it is built, and how to check that a change kept the guarantees.
Any change to behavior, layout, or a decision below updates this file in the same commit.

## Purpose

Set up a Mac from nothing, keep several Macs in sync, and make the setup reviewable as code.
Scope is deliberately small: things get added when they are needed, not before.

## Guarantees

1. **Idempotent.** Running `bootstrap_mac.sh` twice, or on a machine set up from any older commit,
   applies only the difference and never breaks anything. A second run in a row is silent.
2. **Nothing secret in the repo.** No tokens, keys, credentials, session history, or
   machine-specific paths. The repo is public.
3. **Repo is the source of truth.** Config lives here and is symlinked into `$HOME`. Edits made
   on a machine appear as `git diff` here. Runtime state never points into the repo.
4. **Minimal dependencies.** `install.sh` needs only macOS. `bootstrap_mac.sh` needs only
   Homebrew and this repo.
5. **Drift is visible.** `doctor.sh` reports, read-only, where a machine differs from the repo.

## Structure

| Path | Role |
|---|---|
| `install.sh` | curl-pipe entry point: install Homebrew, clone, hand off |
| `bootstrap_mac.sh` | the whole setup, in order: `brew bundle`, stow dotfiles, `mcp.sh`, `macos.sh` |
| `doctor.sh` | read-only drift check, exit 1 on any FAIL |
| `Brewfile` | every app and CLI tool, one line each |
| `macos.sh` | `defaults write` lines |
| `mcp.sh` | user-scope MCP servers, one guarded `add` line each |
| `home/<tool>/` | one package per tool, each mirrors `$HOME`, linked by GNU stow |
| `.gitignore` | safety net: Claude runtime state, `.DS_Store`, `*.bak.*` |
| `.claude/CLAUDE.md` | rules for working on this repo, loaded when Claude runs inside it |
| `home/claude/.claude/CLAUDE.md` | global Claude instructions, linked to `~/.claude/CLAUDE.md` |
| `spec.md` | this file |

Machine-local escape hatches, never committed: `~/.zshrc.local`, `~/.gitconfig.local`,
`~/.claude/settings.local.json`, `~/.claude.json`.

## Flow

**Fresh Mac** runs the README one-liner. `install.sh` installs Homebrew if missing, fails loudly
if that did not produce `brew`, clones to `~/workspace/iampat/bootstrap` (or pulls with
`--ff-only` if present), and `exec`s `bootstrap_mac.sh`.

**`bootstrap_mac.sh`**, from the repo root:

1. `brew bundle --file=Brewfile`. Installs what is missing and upgrades what is outdated.
2. For every file under `home/*/`, walk its target path from `$HOME` down. A real file in the
   way is moved to `<name>.bak.<epoch>`. A symlink not owned by this repo is removed and
   reported. A directory link of ours from an older run is removed so stow can unfold it.
3. `stow --restow --no-folding` every package. File by file, never a directory. Links to
   files no longer in the repo are removed.
4. If no git identity is set, ask for name and email once and write them to
   `~/.gitconfig.local`. Skipped with a hint when there is no terminal to ask.
5. `mcp.sh`: each `add` line registers a server only if `claude mcp get` does not find it.
6. `macos.sh`: `defaults write` lines, then restart Finder and Dock.

**Existing Mac** runs `git pull && ./bootstrap_mac.sh`. Same steps, mostly no-ops.

## Decisions

- **GNU stow, not hand-written link lines.** Adding a tool's config is one file under
  `home/<tool>/`; nothing else to edit, and doctor derives its check from the same tree.
- **`--no-folding`.** A folded `~/.claude` link would put credentials and transcripts inside the
  repo the first time `claude` runs. File-by-file linking costs one thing: a command or skill
  created directly in `~/.claude/commands` stays local until copied into the repo.
- **`brew bundle` upgrades.** A sync means "fully current". `doctor.sh` treats outdated as
  unsatisfied, so the two agree. `brew bundle` never uninstalls; removal is manual on purpose.
- **Public repo.** Keeps the curl one-liner working. The price is reviewing `git diff` of
  `home/claude/.claude/settings.json`, which Claude Code also writes, before each commit.
- **Secrets in `~/.zshrc.local` or Keychain.** The repo names them, never holds them. MCP tokens
  go on the `add` line via `${VAR:?}` and end up in `~/.claude.json`, which stays local.
- **`gh` as git credential helper, declared in `.gitconfig`.** So `gh auth login` is never
  allowed to write an absolute, arch-specific path into the symlinked file.
- **Git identity is per machine, asked once, stored in `~/.gitconfig.local`.** Keeps a real
  name and email out of the public repo and lets a work Mac use a work email with no change here.
- **Repos live in `~/workspace/<owner>/<repo>`.** This one included.
- **`EDITOR=vim`.** Present on every Mac before anything is installed.
- **Native Claude Code via the `claude-code` cask.** No Node dependency.

## Acceptance checks

Run after any change to `bootstrap_mac.sh`, `doctor.sh`, or the `home/` layout. Each check
uses a throwaway `HOME` and the dotfiles block of `bootstrap_mac.sh`.

| Scenario | Expect |
|---|---|
| Empty `HOME` | links created; `~/.claude` is a real directory, not a link |
| Second run right after | no output from stow, `doctor.sh` clean, `git status` unchanged |
| `HOME` with `~/.claude/` holding state files and a real `~/.zshrc` | state untouched, `.zshrc` moved to `.bak`, links created |
| `HOME` with old absolute links to paths that no longer exist | links removed and reported, stow succeeds |
| `HOME` with a folded `~/.claude` link into the repo | unfolded into a real directory with file links |
| A file removed from `home/<pkg>/` | its dangling link is gone after the next run |
| `~/.claude/commands/` already a real dir with user files | user files intact, repo files linked beside them |
| New `home/foo/.config/foo/conf.toml` | linked; `~/.config` and `~/.config/foo` are real directories |
| Empty `home/` | step skipped, no error |
| Identity already set, re-run | prints it, asks nothing |
| No identity, no terminal (`< /dev/null`) | prints the hint, continues |
| `bash -n` on every script | clean |

On a real machine after the first run: `./doctor.sh` reports no FAIL, `git status` is clean,
`~/.claude/.credentials.json` does not exist inside the repo tree.

## Out of scope for now

Per-machine profiles, a private overlay repo, SSH key generation and commit signing, Linux,
conditional `killall` in `macos.sh`, auto-import of files created directly in `~/.claude`.
