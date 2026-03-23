@echo off
setlocal
set "PS_SCRIPT=%~dp0compile.ps1"
set "TYPE=%~1"

if "%TYPE%"=="" set "TYPE=all"

echo [INFO] Launching PowerShell compiler (Type: %TYPE%)...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Type "%TYPE%"

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Compilation finished successfully.
) else (
    echo [ERROR] Compilation failed.
)
timeout /t 3 >nul
