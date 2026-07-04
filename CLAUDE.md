# CLAUDE.md

Context for AI agents working in this repo.

## What this is

`claudfeine` is a tiny, zero-dependency wrapper that runs an AI coding agent (Claude Code,
or Codex via `codexfeine`) while preventing the machine from sleeping for exactly the
duration of the session, then releasing the keep-awake assertion automatically.

## Layout

- `claudfeine` — the whole tool, a single POSIX `sh` script. It picks which agent to wrap
  from the name it is invoked as (`claudfeine`→`claude`, `codexfeine`→`codex`; override with
  `FEINE_TARGET`). macOS uses `caffeinate -dims`; Linux uses `systemd-inhibit` (then
  `gnome-session-inhibit`, then a warned plain run). It `exec`s the agent so the exit code is
  preserved and the assertion releases when the agent process ends.
- `codexfeine` — a symlink to `claudfeine` (basename dispatch).
- `windows/_feine.ps1` — shared PowerShell core (`SetThreadExecutionState` + `finally`
  release + UTF-8). `windows/{claudfeine,codexfeine}.ps1` are thin entrypoints; `*.cmd` are
  cmd.exe shims.
- `test.sh` — hermetic smoke tests (stubs the agent + inhibitor; runs on any OS / CI).

## Conventions

- Pure POSIX `sh` (no bashisms). Keep `shellcheck -s sh claudfeine test.sh` clean.
- The only flags the wrapper interprets are `--feine-version` / `--feine-help` /
  `--feine-install-alias`; everything else must pass through untouched.
- `FEINE_VERSION` (in `claudfeine`) and `$script:FeineVersion` (in `windows/_feine.ps1`) are
  stamped on release by `.version-hook.sh` — don't hand-edit them.
- Commits follow Conventional Commits; releases are automated by semantic-release
  (`.releaserc` + `.github/workflows/release.yml`). The Homebrew formulae live in
  `maxgfr/homebrew-tap` and are bumped by scheduled workflows there.

## Before committing

Run `shellcheck -s sh claudfeine test.sh && ./test.sh`.
