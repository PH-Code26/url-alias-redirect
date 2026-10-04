@echo off
title URL-Alias-Redirect
cd /d "%~dp0"
echo.
echo =========================================
echo       URL Alias Redirect Service
echo =========================================
echo.
echo Listening on port 5666 (forwarded from 80)
echo Press Ctrl+C to stop
echo.
node server.js
pause