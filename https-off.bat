@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
netsh interface portproxy delete v4tov4 listenport=443 listenaddress=0.0.0.0 >nul 2>&1
echo [OFF] 443 port freed
pause