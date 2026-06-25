@echo off
REM claudfeine.cmd — convenience shim so `claudfeine ...` works from cmd.exe.
REM The cleanest install is the PowerShell profile function in the README; this
REM shim is here for cmd.exe users. Arguments are forwarded as-is.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0claudfeine.ps1" %*
