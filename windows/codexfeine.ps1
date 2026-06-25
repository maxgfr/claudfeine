#Requires -Version 5
# codexfeine.ps1 — run OpenAI Codex caffeinated on Windows (no sleep while it runs).
# https://github.com/maxgfr/claudfeine — MIT License.
#
# No param() block on purpose: the automatic $args variable captures every argument
# verbatim (including agent flags like -p / --continue), so pass-through stays transparent.

$FeineArgs = $args
. "$PSScriptRoot\_feine.ps1"
Invoke-Feine -Name 'codexfeine' -Target 'codex' -Pkg '@openai/codex' -Arguments $FeineArgs
exit $global:FeineExitCode
