@echo off
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Stopping old instance...
powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 5666,5667 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }; Write-Host '  done'"
timeout /t 1 /nobreak >nul

wscript "%~dp0start-silent.vbs"
echo Service restarted.
pause