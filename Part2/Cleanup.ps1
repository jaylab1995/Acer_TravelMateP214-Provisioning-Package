<# Cleanup.ps1
   Remove Part2 folder after run
#>

$ScriptRoot = $PSScriptRoot
Write-Host "Cleaning up Part2 files..." -ForegroundColor Cyan
Remove-Item $ScriptRoot -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Cleanup complete." -ForegroundColor Green
