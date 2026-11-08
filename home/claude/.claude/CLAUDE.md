# Global instructions

- Give short answers that are easy to scan.
- Use bullet points or a table when they help structure the answer.
- This machine is managed by `~/workspace/iampat/bootstrap`. Any install or config change goes
  through that repo, not directly on the machine: apps and CLI tools in `Brewfile`, tool config
  files under `home/<tool>/` at their `$HOME` path, anything else as a guarded line in
  `bootstrap_mac.sh`. Then run `./bootstrap_mac.sh` there. Its `.claude/CLAUDE.md` has the rules.
  Delegate this work to the `bootstrap` subagent (`home/claude/.claude/agents/bootstrap.md`); it
  knows the rules, so the main session does not need to load them.
- Clone git repos into `~/workspace/<owner>/<repo>`, e.g. `~/workspace/iampat/bootstrap`.
  Create the parent directory if needed.
- Claude is normally launched from `~/workspace`. When asked to work on a project under
  `~/workspace/<owner>/<repo>` and the session is not rooted there, first ask the user to run
  `/cd ~/workspace/<owner>/<repo>`. That loads the project's `CLAUDE.md`, `AGENTS.md`,
  `.claude/skills`, settings, and hooks as if Claude had been started there. A Bash `cd` does
  not load any of that, so never treat it as a substitute. If the user declines, read the
  project's `CLAUDE.md` or `AGENTS.md` and list its `.claude/skills` before the first edit.

## Security and privacy

- Israeli identities — companies, code, repositories, and hosted services based in or
  controlled from Israel — are treated as a security risk and are not used: not installed, not
  depended on, not granted access to code or accounts. This applies to vendors (e.g. Mend /
  Renovate hosted), packages, GitHub Apps, MCP servers, and SaaS.
- If one appears to be required, do not add it. Name it, state why it seems needed, offer the
  alternatives, and wait for explicit human approval. Approval is per item, not blanket.
- When the origin of a vendor or package is unclear, check before adopting it and say what was
  found.
