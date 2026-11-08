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
   Homebrew and this repo, plus `sudo` for the Go pkg and Xcode.
5. **Drift is visible.** `doctor.sh` reports, read-only, where a machine differs from the repo.
6. **Nothing silently stays undone.** A step the script cannot do itself (no terminal for
   `sudo`, App Store not signed in) is listed under "Manual steps" at the end of the run and
   reported by `doctor.sh` until done.

## Structure

| Path | Role |
|---|---|
| `install.sh` | curl-pipe entry point: install Homebrew, clone, hand off |
| `bootstrap_mac.sh` | the whole setup, in order: `brew bundle`, App Store apps (`mas_app` lines) + Xcode setup, Go pkg, stow dotfiles, `mcp.sh`, `macos.sh` |
| `doctor.sh` | read-only drift check, exit 1 on any FAIL |
| `Brewfile` | every app and CLI tool, one line each |
| `macos.sh` | `defaults write` lines |
| `mcp.sh` | user-scope MCP servers, one guarded `add` line each |
| `home/<tool>/` | one package per tool, each mirrors `$HOME`, linked by GNU stow |
| `.gitignore` | safety net: Claude runtime state, `.DS_Store`, `*.bak.*` |
| `.claude/CLAUDE.md` | rules for working on this repo, loaded when Claude runs inside it |
| `home/claude/.claude/CLAUDE.md` | global Claude instructions, linked to `~/.claude/CLAUDE.md` |
| `spec.md` | this file |

Machine-local escape hatches, never committed: `~/.zshrc.local`, `~/.bashrc.local`,
`~/.gitconfig.local`, `~/.claude/settings.local.json`, `~/.claude.json`.

## Flow

**Fresh Mac** runs the README one-liner. `install.sh` installs Homebrew if missing, fails loudly
if that did not produce `brew`, clones to `~/workspace/iampat/bootstrap` (or pulls with
`--ff-only` if present), and `exec`s `bootstrap_mac.sh`.

**`bootstrap_mac.sh`**, from the repo root:

1. `brew update`, then `brew bundle --file=Brewfile`. Installs what is missing and upgrades
   what is outdated among Brewfile entries. Self-updating apps are left to their own updater.
2. App Store apps: one `mas_app <id> <name>` line each. Already in `mas list` means print
   the name. Otherwise, with a terminal, ask: `y` runs `sudo mas install`; anything else, no
   terminal, or a failed install (App Store not signed in) puts the app's App Store link in
   the manual steps for the user to click. Then Xcode setup if it is present:
   `sudo xcode-select -s` to it and `sudo xcodebuild -runFirstLaunch` (guarded by
   `-checkFirstLaunchStatus`), each a manual step when there is no terminal.
3. Go: if `/usr/local/go/bin/go` is missing, download the current `darwin-arm64` pkg from
   go.dev and run `sudo installer`. Already installed means print the version and move on.
4. For every file under `home/*/`, walk its target path from `$HOME` down. A real file in the
   way is moved to `<name>.bak.<epoch>`. A symlink not owned by this repo is removed and
   reported. A directory link of ours from an older run is removed so stow can unfold it.
5. `stow --restow --no-folding` every package. File by file, never a directory. Links to
   files no longer in the repo are removed.
6. If no git identity is set, ask for name and email once and write them to
   `~/.gitconfig.local`. Becomes a manual step when there is no terminal to ask.
7. `mcp.sh`: each `add` line registers a server only if `claude mcp get` does not find it.
8. `macos.sh`: `defaults write` lines, then restart Finder and Dock.
9. Manual steps collected along the way are printed as one list, with the exact commands.

**Existing Mac** runs `git pull && ./bootstrap_mac.sh`. Same steps, mostly no-ops.

## Decisions

- **GNU stow, not hand-written link lines.** Adding a tool's config is one file under
  `home/<tool>/`; nothing else to edit, and doctor derives its check from the same tree.
- **`--no-folding`.** A folded `~/.claude` link would put credentials and transcripts inside the
  repo the first time `claude` runs. File-by-file linking costs one thing: a command or skill
  created directly in `~/.claude/commands` stays local until copied into the repo.
- **`brew update` then `brew bundle`, which upgrades.** A sync means "fully current", and the
  explicit update makes that true on every run, not only when Homebrew's 24-hour auto-update
  fires. `doctor.sh` treats outdated as unsatisfied, so the two agree. Nothing is uninstalled;
  removal is manual on purpose. Hand-installed tools are not upgraded, so they stay visible.
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
- **zsh is the shell; bash is kept usable.** `home/bash/.bashrc` (plus a one-line
  `.bash_profile` that sources it) gives an interactive `bash` Homebrew on PATH and tab
  completion for git, gh and every Homebrew tool that ships a completion, through
  `bash-completion@2`. That package needs bash 4.2 or newer, so Homebrew `bash` is in the
  Brewfile; `brew shellenv` puts it ahead of the 3.2 `/bin/bash`, which stays untouched (no
  `chsh`). On an old bash the file falls back to git's own completion script and
  `gh completion -s bash`. Machine-specific bash settings go in `~/.bashrc.local`.
- **Native Claude Code via the `claude-code` cask.** No Node dependency.
- **Go from the official go.dev pkg, not Homebrew.** Follows go.dev/doc/install exactly:
  `/usr/local/go`, PATH via `/etc/paths.d/go`, `~/go/bin` added in `.zshrc`. Install-once:
  upgrading is a manual re-run of the pkg, or `sudo rm -rf /usr/local/go` then bootstrap.
  Apple silicon only; Intel Macs are not supported. Costs one `sudo` prompt on a fresh Mac.
- **App Store apps as `mas_app` lines in the script, not `mas` lines in the Brewfile.** They
  need an App Store sign-in and `sudo`, which the script cannot supply, and a failing `mas`
  line makes `brew bundle` exit non-zero and abort the whole run. As guarded lines they
  degrade to manual hints and the rest of the run still happens; `doctor.sh` derives its
  checks from the same lines, as it does for `mcp.sh`. Third-party taps carry
  `trusted: true` in the Brewfile because Homebrew 7 refuses to load untrusted taps.
- **Machine tools track current stable; projects pin.** Homebrew, casks and the App Store only
  serve their current release, so this repo cannot pin versions and does not pretend to. That
  is accepted for machine-level tools (editors, CLIs, Xcode) as a known trade-off: every
  `bootstrap_mac.sh` run may pull a new release, with the supply-chain and breakage risk that
  implies. Kept in check by: sources limited to Homebrew core, official vendor taps marked
  `trusted`, and the App Store; no curl-pipe installers except Go's official pkg; and anything
  a project's correctness depends on (Flutter SDK, packages, Terraform providers) is pinned in
  that project's repo and moved only through reviewed PRs, never floated. `fvm` is installed
  here as the tool for the Flutter pin; the pin itself (`.fvmrc`) lives in the project.
- **No Israeli vendors, code, or services** (companies, repos, packages, GitHub Apps, MCP
  servers, SaaS). Treated as a security risk. A required exception needs explicit human
  approval, per item, and is recorded here with its reason. Rule text lives in
  `.claude/CLAUDE.md` and `home/claude/.claude/CLAUDE.md`.
- **A `bootstrap` subagent owns changes to this repo.** `home/claude/.claude/agents/bootstrap.md`
  (linked to `~/.claude/agents/`) carries the how-to for applying the rules here: where each kind
  of change goes, the vendor origin check, the verify-then-commit sequence, and the
  `settings.json` rule. The main Claude session delegates machine-setup work to it so the rules
  stay out of unrelated contexts and the work runs on a cheaper model. The rules themselves
  stay in `.claude/CLAUDE.md` and this file; the agent reads them first.
- **Manual steps are collected, not scattered.** One `manual` helper, one list at the end,
  always with the exact command to run. `doctor.sh` checks the same conditions.

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
| No identity, no terminal (`< /dev/null`) | listed under Manual steps, run continues |
| App Store app missing, no terminal (`< /dev/null`) | not asked, App Store link listed under Manual steps, run continues to the end |
| App Store app missing, terminal, answer `n` or Enter | link listed under Manual steps, no `sudo` |
| App Store app already in `mas list` | prints the name, asks nothing |
| Xcode installed, selected, first launch done | prints the version, no `sudo`, nothing listed |
| `doctor.sh` | one line per `mas_app` line in `bootstrap_mac.sh`, FAIL with the install command when missing |
| Stow invocations | package names passed as a bash array, never after `--` (stow 2.4 drops them) |
| `bash -n` on every script | clean |

On a real machine after the first run: `./doctor.sh` reports no FAIL, `git status` is clean,
`~/.claude/.credentials.json` does not exist inside the repo tree.

## Out of scope for now

Per-machine profiles, a private overlay repo, SSH key generation and commit signing, Linux,
conditional `killall` in `macos.sh`, auto-import of files created directly in `~/.claude`.
