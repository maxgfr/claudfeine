# _feine.ps1 — shared core for the claudfeine / codexfeine PowerShell wrappers.
#
# Keeps Windows awake (system + display) for exactly the wrapped agent's lifetime
# via the Win32 SetThreadExecutionState API, and ALWAYS releases the assertion in
# a finally block — clean exit, crash, or Ctrl-C. Nothing permanent is changed.
#
# https://github.com/maxgfr/claudfeine — MIT License.

$script:FeineVersion = '1.0.1' # injected on release by .version-hook.sh

function Invoke-Feine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string]   $Name,
        [Parameter(Mandatory = $true)] [string]   $Target,
        [Parameter(Mandatory = $true)] [string]   $Pkg,
        [Parameter()]                  [string[]] $Arguments
    )

    if ($null -eq $Arguments) { $Arguments = @() }

    # UTF-8 everywhere so non-ASCII output from the agent isn't mangled, even on
    # legacy Windows PowerShell 5.1.
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $global:OutputEncoding = [System.Text.Encoding]::UTF8
        chcp 65001 > $null 2>&1
    } catch { }

    # Our own flags — the only two intercepted; everything else passes through.
    if ($Arguments.Count -ge 1) {
        switch ($Arguments[0]) {
            '--feine-version' {
                Write-Output "$Name (caffeinated $Target wrapper) $script:FeineVersion"
                $global:FeineExitCode = 0
                return
            }
            '--feine-help' {
                Write-Output @"
$Name (Windows) - run $Target caffeinated (no sleep while it runs).

Usage:
  $Name [$Target arguments...]   run $Target, keeping the machine awake
  $Name --feine-version          print the wrapper version and exit
  $Name --feine-help             print this help and exit

Every other argument is passed straight through to $Target.
It prevents sleep, NOT a power cut - commit your progress on long tasks.
"@
                $global:FeineExitCode = 0
                return
            }
        }
    }

    # The agent must be installed.
    if (-not (Get-Command $Target -ErrorAction SilentlyContinue)) {
        Write-Host "${Name}: $Target is not installed or not on your PATH." -ForegroundColor Red
        Write-Host "${Name}: Install it with:  npm install -g $Pkg" -ForegroundColor Yellow
        $global:FeineExitCode = 127
        return
    }

    # Win32 power assertion.
    if (-not ('Feine.Power' -as [type])) {
        Add-Type -Namespace 'Feine' -Name 'Power' -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)]
public static extern uint SetThreadExecutionState(uint esFlags);
'@
    }

    $ES_CONTINUOUS = [uint32]2147483648 # 0x80000000
    $ES_SYSTEM_REQUIRED = [uint32]1     # 0x00000001
    $ES_DISPLAY_REQUIRED = [uint32]2    # 0x00000002

    $global:FeineExitCode = 1
    try {
        [void][Feine.Power]::SetThreadExecutionState(
            $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED)
        & $Target @Arguments
        $global:FeineExitCode = $LASTEXITCODE
    } finally {
        # Release the keep-awake assertion no matter how the agent ended.
        [void][Feine.Power]::SetThreadExecutionState($ES_CONTINUOUS)
    }
}
