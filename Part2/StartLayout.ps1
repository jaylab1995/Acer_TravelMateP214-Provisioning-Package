<# StartLayout.ps1
   Deploy start2.bin to all users
#>

$StartLayoutFile = Join-Path $PSScriptRoot "start2.bin"

# Deploy to all existing users
Get-ChildItem "C:\Users\" -Directory | Where-Object { $_.Name -notin "Default","Public" } | ForEach-Object {
    $dest = Join-Path $_.FullName "AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
    if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
    Copy-Item $StartLayoutFile -Destination (Join-Path $dest "start2.bin") -Force
}

# Deploy to Default profile (new users)
$defaultDest = "C:\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
if (!(Test-Path $defaultDest)) { New-Item -ItemType Directory -Path $defaultDest -Force | Out-Null }
Copy-Item $StartLayoutFile -Destination (Join-Path $defaultDest "start2.bin") -Force

Write-Host "Start layout applied." -ForegroundColor Green
