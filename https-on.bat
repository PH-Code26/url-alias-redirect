@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
netsh interface portproxy add v4tov4 listenport=443 listenaddress=0.0.0.0 connectport=5667 connectaddress=127.0.0.1 >nul 2>&1
if %errorlevel% equ 0 (echo [ON] 443 -> 5667) else (echo Already on or failed)
pause