@echo off
:: Run the PowerShell script as administrator
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0RunOnce.ps1\"' -Verb RunAs"
pause
