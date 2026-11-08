# Global instructions

- Give short answers that are easy to scan.
- Use bullet points or a table when they help structure the answer.
- This machine is managed by `~/workspace/iampat/bootstrap`. Any install or config change goes
  through that repo, not directly on the machine: apps and CLI tools in `Brewfile`, tool config
  files under `home/<tool>/` at their `$HOME` path, anything else as a guarded line in
  `bootstrap_mac.sh`. Then run `./bootstrap_mac.sh` there. Its `.claude/CLAUDE.md` has the rules.
- Clone git repos into `~/workspace/<owner>/<repo>`, e.g. `~/workspace/iampat/bootstrap`.
  Create the parent directory if needed.
