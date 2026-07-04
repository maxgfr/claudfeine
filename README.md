# claudfeine ☕

**Run [Claude Code](https://github.com/anthropics/claude-code) (and [Codex](https://github.com/openai/codex)) caffeinated.**

`claudfeine` is a transparent wrapper around `claude`: it keeps your machine awake for
**exactly** the duration of the session, then lets normal sleep behaviour return on its
own — whether the session ends cleanly or crashes. Nothing permanent is ever changed; the
keep-awake assertion lives only as long as the wrapped process.

It is a pure pass-through. Every argument goes straight to `claude`:

```sh
claudfeine                       # same as: claude
claudfeine --continue            # same as: claude --continue
claudfeine -p "summarise this repo"
```

There is a sibling, **`codexfeine`**, that does the exact same thing for OpenAI Codex.

---

## Features

- **Zero dependencies.** Pure POSIX `sh` on macOS/Linux; a single PowerShell script on
  Windows. Nothing to install beyond the agent itself.
- **Transparent.** All arguments are forwarded verbatim; the exit code is preserved.
- **Self-healing.** The moment the agent exits — normally, on a crash, or on `Ctrl-C` —
  sleep returns to normal. No leftover state, no permanent setting touched.
- **Cross-platform**, using each OS's built-in mechanism (no third-party tools).
- Works for both **Claude Code** (`claudfeine`) and **Codex** (`codexfeine`).

## How it works

| OS | Mechanism | What it blocks |
| --- | --- | --- |
| **macOS** | wraps the agent in `caffeinate -dims` | display, idle system, disk, and (on AC) system sleep, for the agent's lifetime |
| **Linux** | wraps the agent in `systemd-inhibit --what=sleep:idle --mode=block` (falls back to `gnome-session-inhibit`, then to a plain run with a warning) | system sleep + idle |
| **Windows** | the PowerShell wrapper calls Win32 `SetThreadExecutionState` and releases it in a `finally` block | system + display sleep |

If the agent isn't installed, `claudfeine` tells you exactly how to install it and stops.

## Install

### macOS / Linux — Homebrew (recommended)

```sh
brew install maxgfr/tap/claudfeine
# and/or, for Codex:
brew install maxgfr/tap/codexfeine
```

### macOS / Linux — manual

```sh
git clone https://github.com/maxgfr/claudfeine.git
cd claudfeine
chmod +x claudfeine
# put it on your PATH, e.g.:
ln -s "$PWD/claudfeine" /usr/local/bin/claudfeine
ln -s "$PWD/claudfeine" /usr/local/bin/codexfeine   # same script, Codex target
```

The script decides which agent to wrap from the name it's invoked as
(`claudfeine` → `claude`, `codexfeine` → `codex`), so a symlink under either name is all
it takes.

### Windows

Download the `windows/` folder (`_feine.ps1` + `claudfeine.ps1` + `codexfeine.ps1`, and the
optional `.cmd` shims) and either:

**A. Add a profile function (cleanest — perfect argument pass-through).** In your
PowerShell profile (`notepad $PROFILE`):

```powershell
function claudfeine { & "C:\path\to\claudfeine\windows\claudfeine.ps1" @args }
function codexfeine { & "C:\path\to\claudfeine\windows\codexfeine.ps1" @args }
```

**B. Or put the folder on your `PATH`** and call `claudfeine.cmd` / `codexfeine.cmd` from
`cmd.exe` or PowerShell.

> The wrapper forces UTF-8 output so the agent's output renders correctly even on the older
> Windows PowerShell 5.1.

> `--feine-install-alias` is macOS/Linux only. On Windows, invoke `claudfeine` / `codexfeine`
> directly — aliasing the agent name to a PowerShell profile function would recurse back into the
> wrapper.

## Usage

```sh
claudfeine [claude arguments...]   # run Claude Code, keeping the machine awake
codexfeine [codex arguments...]    # run Codex, keeping the machine awake

claudfeine --feine-version         # print the wrapper version
claudfeine --feine-help            # print wrapper help
claudfeine --feine-install-alias   # alias claude→claudfeine (+ codex→codexfeine) in your shell rc
```

`--feine-version`, `--feine-help`, and `--feine-install-alias` are the **only** flags the wrapper
interprets (the `--feine-` namespace can't collide with the agent's flags). Everything else is
passed through unchanged.

## Make `claude` always caffeinated

Prefer not to type the `claudfeine` prefix? Add a shell alias so `claude` *is* the caffeinated
wrapper (and `codex` is `codexfeine`):

```sh
claudfeine --feine-install-alias
```

It appends — idempotently, and without touching any alias you already have —

```sh
alias claude='claudfeine'
alias codex='codexfeine'
```

to your shell's rc file (`~/.zshrc`, `~/.bashrc`, or `~/.config/fish/config.fish`, auto-detected
from `$SHELL`). Restart your shell (or `source` the file) and `claude` keeps the machine awake for
the whole session. Only the aliases whose wrapper is actually on your `PATH` are written.

> **Why an alias and not a program named `claude`?** An alias only affects what *you* type at an
> interactive prompt. When the wrapper then runs `claude` internally, the shell isn't involved, so
> it resolves the real `claude` binary — no loop. A file literally named `claude` ahead of the real
> one on your `PATH` would make the wrapper call itself forever.

For a shell it doesn't recognise, it prints the two `alias` lines so you can paste them into your
startup file yourself. On **Windows** the helper isn't available — keep calling `claudfeine` /
`codexfeine` directly (see the Windows section above).

## Uninstall

```sh
brew uninstall claudfeine codexfeine    # if installed via Homebrew
```

For a manual install, remove the symlinks you created.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Commits follow
[Conventional Commits](https://www.conventionalcommits.org/); releases are automated with
[semantic-release](https://github.com/semantic-release/semantic-release).

## License

[MIT](LICENSE) © Maxime ([maxgfr](https://github.com/maxgfr))
