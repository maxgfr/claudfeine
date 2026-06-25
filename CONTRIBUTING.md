# Contributing

Thanks for your interest in improving `claudfeine`!

## Development

The tool is a single POSIX `sh` script (`claudfeine`) plus the PowerShell wrappers in
`windows/`. There is nothing to build.

Before opening a pull request, run:

```sh
shellcheck -s sh claudfeine test.sh
./test.sh
```

`test.sh` is hermetic — it stubs the agent and the OS inhibitor, so it runs the same on
macOS, Linux, and CI without needing `claude`/`codex` installed.

## Guidelines

- Keep it **pure POSIX `sh`** (no bashisms) and **zero-dependency**.
- The wrapper must stay a **transparent pass-through**: the only flags it may interpret are
  `--feine-version` and `--feine-help`.
- Don't hand-edit the version strings — they are stamped on release by `.version-hook.sh`.

## Releases

Commits follow [Conventional Commits](https://www.conventionalcommits.org/)
(`feat:`, `fix:`, `docs:`, `chore:`, …). Merging to `main` runs
[semantic-release](https://github.com/semantic-release/semantic-release), which decides the
version, updates the changelog, tags, and publishes the GitHub release. The Homebrew
formulae in [`maxgfr/homebrew-tap`](https://github.com/maxgfr/homebrew-tap) update
themselves from that release on a daily schedule.
