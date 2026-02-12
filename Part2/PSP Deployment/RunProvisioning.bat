@echo off
title 4Ps Provisioning Tool - Sir Chitz
color 0b

:: Ensure we are in the correct directory
cd /d "%~dp0"

:: Set Execution Policy and Run Main Script
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "Scripts\Provisioning_Engine.ps1"

pause