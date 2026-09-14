@echo off
rem Copyright 2026 VB contributors. SPDX-License-Identifier: Apache-2.0
setlocal
pushd "%~dp0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Join VB Parts.ps1"
set "VB_RESULT=%ERRORLEVEL%"
popd
if /I not "%~1"=="--no-pause" pause
exit /b %VB_RESULT%
