@echo off
title URL-Alias-Redirect Setup
cd /d "%~dp0"

echo.
echo ==============================================
echo    URL Alias Redirect - Setup
echo ==============================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set TASK_NAME=URL-Alias-Redirect
set HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts

echo [1/4] Generating SSL certificate...
powershell -ExecutionPolicy Bypass -File "%~dp0generate-cert.ps1"
if exist "%~dp0cert.pfx" (echo   [OK]) else (echo   [FAIL])

echo.
echo [2/4] Writing hosts aliases...
attrib -r "%HOSTS_FILE%" >nul 2>&1
powershell -Command "$f='%HOSTS_FILE%';$j=Get-Content '%~dp0aliases.json' -Raw|ConvertFrom-Json;$h='';if(Test-Path $f){$h=[string](Get-Content $f -Raw)};$h=$h -replace '(?s)# === URL-ALIAS-START ===.*?# === URL-ALIAS-END ===\r?\n?','';$h=$h.TrimEnd();$e=@();foreach($p in $j.PSObject.Properties){$e+=\"127.0.0.2    $($p.Name)\"};$r=\"`r`n`r`n# === URL-ALIAS-START ===`r`n$($e -join \"`r`n\")`r`n# === URL-ALIAS-END ===`r`n\";[System.IO.File]::WriteAllText($f,$h+$r);ipconfig /flushdns|Out-Null;Write-Host '  done'"

echo.
echo [3/4] Setting port forward 80-^>5666...
netsh interface portproxy delete v4tov4 listenport=80 listenaddress=0.0.0.0 >nul 2>&1
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=5666 connectaddress=127.0.0.1 >nul 2>&1
echo   [OK]  (use https-on.bat to add 443 forwarding)

echo.
echo [4/4] Setting auto-start on login...
schtasks /Create /TN "%TASK_NAME%" /TR "powershell.exe -ExecutionPolicy Bypass -File \"%~dp0start-silent.ps1\"" /SC ONLOGON /RL HIGHEST /F >nul 2>&1
if %errorlevel% equ 0 (echo   [OK]) else (echo   [SKIP] may already exist)

echo.
echo ==============================================
echo    Setup complete, starting service...
echo ==============================================
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0start-silent.ps1"
timeout /t 2 /nobreak >nul

echo   Verify: https://localhost:5667
echo   First open an alias in browser, accept cert,
echo   then just type alias (no / needed).
echo.
pause