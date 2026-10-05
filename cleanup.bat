@echo off
title Uninstall URL-Alias-Redirect
cd /d "%~dp0"

echo.
echo ==============================================
echo    Uninstall URL Alias Redirect
echo ==============================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set TASK_NAME=URL-Alias-Redirect

echo [1/4] Stopping service...
powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 5666,5667 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }"

echo [2/4] Removing auto-start...
schtasks /Delete /TN "%TASK_NAME%" /F >nul 2>&1
echo   done

echo [3/4] Removing port forwards...
netsh interface portproxy delete v4tov4 listenport=80 listenaddress=0.0.0.0 >nul 2>&1
netsh interface portproxy delete v4tov4 listenport=443 listenaddress=0.0.0.0 >nul 2>&1
echo   done

echo [4/4] Cleaning hosts...
powershell -Command "$f='%SystemRoot%\System32\drivers\etc\hosts';if(Test-Path $f){$h=[string](Get-Content $f -Raw);$h=$h -replace '(?s)# === URL-ALIAS-START ===.*?# === URL-ALIAS-END ===\r?\n?','';$h=$h.TrimEnd()+\"`r`n\";[System.IO.File]::WriteAllText($f,$h)};ipconfig /flushdns"
echo   done

echo.
echo   Uninstall complete!
echo.
pause