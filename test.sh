#!/bin/sh
# test.sh — hermetic smoke tests for the claudfeine core script.
#
# No real claude/codex/caffeinate is needed: we stub the agent and the OS
# inhibitor on PATH, so these run identically on macOS, Linux and CI.

set -eu

here=$(cd "$(dirname "$0")" && pwd)
SCRIPT="$here/claudfeine"

pass=0
fail=0

ok() {
  pass=$((pass + 1))
  printf 'ok   - %s\n' "$1"
}
no() {
  fail=$((fail + 1))
  printf 'FAIL - %s\n      expected: [%s]\n      actual:   [%s]\n' "$1" "$2" "$3"
}

eq() { # desc expected actual
  if [ "$2" = "$3" ]; then ok "$1"; else no "$1" "$2" "$3"; fi
}

contains() { # desc needle haystack
  case "$3" in
    *"$2"*) ok "$1" ;;
    *) no "$1" "*$2*" "$3" ;;
  esac
}

# --- build a hermetic bin dir with stubs -----------------------------------
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM
bin="$tmp/bin"
mkdir -p "$bin"

# stub agent: prints a marker + its args, exits with ${STUB_EXIT:-0}
make_agent() {
  cat >"$bin/$1" <<'EOF'
#!/bin/sh
printf 'STUB:%s\n' "$*"
exit "${STUB_EXIT:-0}"
EOF
  chmod +x "$bin/$1"
}

# stub inhibitor: skip leading flags, then exec the wrapped command
make_inhibitor() {
  cat >"$bin/$1" <<'EOF'
#!/bin/sh
while [ $# -gt 0 ]; do
  case "$1" in
    -*) shift ;;
    *) break ;;
  esac
done
exec "$@"
EOF
  chmod +x "$bin/$1"
}

make_agent claude
make_agent codex
make_inhibitor caffeinate
make_inhibitor systemd-inhibit
make_inhibitor gnome-session-inhibit

run() { # capture stdout+stderr, set RC; never aborts the suite
  set +e
  OUT=$("$@" 2>&1)
  RC=$?
  set -e
}

# --- 1. version + target wording -------------------------------------------
run "$SCRIPT" --feine-version
contains "version: names the wrapper + claude target" "claudfeine (caffeinated claude wrapper)" "$OUT"
eq "version: exit 0" 0 "$RC"

# --- 2. basename dispatch: invoked as codexfeine ---------------------------
ln -s "$SCRIPT" "$bin/codexfeine"
run "$bin/codexfeine" --feine-version
contains "dispatch: codexfeine -> codex" "codexfeine (caffeinated codex wrapper)" "$OUT"

# --- 3. FEINE_TARGET override ----------------------------------------------
run env FEINE_TARGET=codex "$SCRIPT" --feine-version
contains "FEINE_TARGET overrides target" "caffeinated codex wrapper" "$OUT"

# --- 4. help ----------------------------------------------------------------
run "$SCRIPT" --feine-help
contains "help: mentions power-cut caveat" "power cut" "$OUT"
eq "help: exit 0" 0 "$RC"

# --- 5. not-found path (claude hidden from PATH) ---------------------------
run env PATH="/usr/bin:/bin" "$SCRIPT" --continue
eq "not-found: exit 127" 127 "$RC"
contains "not-found: claude install hint" "npm install -g @anthropic-ai/claude-code" "$OUT"

run env PATH="/usr/bin:/bin" FEINE_TARGET=codex "$SCRIPT" --continue
contains "not-found: codex install hint" "npm install -g @openai/codex" "$OUT"

# --- 6. pass-through of args + exit code (via stubbed agent+inhibitor) ------
run env PATH="$bin:/usr/bin:/bin" "$SCRIPT" foo "bar baz"
contains "passthrough: args reach the agent" "STUB:foo bar baz" "$OUT"
eq "passthrough: exit 0 forwarded" 0 "$RC"

run env PATH="$bin:/usr/bin:/bin" STUB_EXIT=42 "$SCRIPT" hi
eq "passthrough: exit 42 forwarded" 42 "$RC"

# --- summary ----------------------------------------------------------------
printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
