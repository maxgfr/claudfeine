@echo off
REM codexfeine.cmd — convenience shim so `codexfeine ...` works from cmd.exe.
REM The cleanest install is the PowerShell profile function in the README; this
REM shim is here for cmd.exe users. Arguments are forwarded as-is.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0codexfeine.ps1" %*
