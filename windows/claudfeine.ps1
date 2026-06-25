#Requires -Version 5
# claudfeine.ps1 — run Claude Code caffeinated on Windows (no sleep while it runs).
# https://github.com/maxgfr/claudfeine — MIT License.
#
# No param() block on purpose: the automatic $args variable captures every argument
# verbatim (including agent flags like -p / --continue), so pass-through stays transparent.

$FeineArgs = $args
. "$PSScriptRoot\_feine.ps1"
Invoke-Feine -Name 'claudfeine' -Target 'claude' -Pkg '@anthropic-ai/claude-code' -Arguments $FeineArgs
exit $global:FeineExitCode
