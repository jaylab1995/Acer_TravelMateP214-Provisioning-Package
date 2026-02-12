<# 
Ultra-Debloat + UI Strip + OneDrive/Copilot/McAfee Removal
Pure PowerShell
#>

# -----------------------------
# Ensure running as admin
# -----------------------------
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Run as Administrator."
    exit 1
}

Write-Host "Starting Ultra-Debloat..." -ForegroundColor Cyan

# -----------------------------
# Remove Appx packages
# -----------------------------
$RemoveApps = @(
    "Microsoft.GamingApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.ZuneMusic",
    "ULICTekInc.AcerQuickPanel",
    "AcerIncorporated.AcerRegistration",
    "AcerIncorporated.UserExperienceImprovementProgramV",
    "C27EB4BA.DropboxOEM",
    "Microsoft.Copilot",
    "Microsoft.BingWeather",
    "Microsoft.BingNews",
    "Microsoft.BingSearch",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.GetHelp",
    "Microsoft.Windows.DevHome",
    "Microsoft.PowerAutomateDesktop",
    "MicrosoftCorporationII.MicrosoftFamily",
    "Microsoft.OutlookForWindows",
    "Microsoft.YourPhone",
    "Clipchamp.Clipchamp",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.Windows.PeopleExperienceHost",
    "Microsoft.Windows.NarratorQuickStart",
    "Microsoft.WindowsWidgets",
    "Microsoft.MicrosoftEdge.Stable",
    "Microsoft.Office.OneNote",
    "Microsoft.365",
    "MicrosoftTeams"
)

foreach ($App in $RemoveApps) {
    Get-AppxPackage -AllUsers -Name $App -ErrorAction SilentlyContinue |
        Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

Get-AppxProvisionedPackage -Online | Where-Object {
    $RemoveApps -contains $_.DisplayName
} | ForEach-Object {
    Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
}

# -----------------------------
# Disable Xbox services
# -----------------------------
$XboxServices = @("XboxGipSvc","XblAuthManager","XblGameSave","XboxNetApiSvc")
foreach ($Service in $XboxServices) {
    Get-Service $Service -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Service $_ -Force -ErrorAction SilentlyContinue
        Set-Service $_ -StartupType Disabled
    }
}

# -----------------------------
# Remove Office / 365 (best-effort)
# -----------------------------
Write-Host "Removing Microsoft 365..." -ForegroundColor Cyan
Stop-Service ClickToRunSvc -Force -ErrorAction SilentlyContinue

$C2R = "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe"
if (Test-Path $C2R) {
    Start-Process $C2R -ArgumentList `
        "scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365ProPlusRetail culture=en-us" `
        -Wait
}

$OfficePaths = @(
    "C:\Program Files\Microsoft Office",
    "C:\Program Files (x86)\Microsoft Office",
    "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun",
    "C:\ProgramData\Microsoft\Office"
)

$OfficePaths | ForEach-Object {
    Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
}

$OfficeReg = @(
    "HKLM:\SOFTWARE\Microsoft\Office",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office",
    "HKLM:\SOFTWARE\Microsoft\ClickToRun",
    "HKCU:\Software\Microsoft\Office"
)

$OfficeReg | ForEach-Object {
    Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
}

Set-Service ClickToRunSvc -StartupType Disabled -ErrorAction SilentlyContinue

# -----------------------------
# Remove McAfee fully
# -----------------------------
Write-Host "Removing McAfee..." -ForegroundColor Red

Get-Service | Where-Object {
    $_.Name -match "McAfee|mfefire|mfevtp|mfemms|McAPExe"
} | ForEach-Object {
    Stop-Service $_ -Force -ErrorAction SilentlyContinue
    Set-Service $_ -StartupType Disabled
}

Get-Package | Where-Object { $_.Name -match "McAfee|WebAdvisor" } | Uninstall-Package -Force -ErrorAction SilentlyContinue

$McAfeePaths = @(
    "C:\Program Files\McAfee",
    "C:\Program Files (x86)\McAfee",
    "C:\ProgramData\McAfee"
)
$McAfeePaths | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }

Get-ScheduledTask | Where-Object { $_.TaskName -match "McAfee|WebAdvisor" } | Unregister-ScheduledTask -Confirm:$false

# -----------------------------
# Remove Acer OEM software
# -----------------------------
$AcerPatterns = @(
    "*Acer Configuration Manager*",
    "*Acer Jumpstart*",
    "*Acer ProShield*",
    "*Acer QuickPanel*",
    "*TravelMateSense*",
    "*User Experience Improvement Program*"
)

Get-Package | Where-Object {
    $name = $_.Name
    $AcerPatterns | Where-Object { $name -like $_ }
} | Uninstall-Package -Force -ErrorAction SilentlyContinue

# -----------------------------
# Remove OneDrive completely
# -----------------------------
taskkill /f /im OneDrive.exe 2>$null

$OD = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (Test-Path $OD) { Start-Process $OD "/uninstall" -Wait }

Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\OneDriveTemp" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue

New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" `
    -Name DisableFileSyncNGSC -Type DWord -Value 1

# -----------------------------
# Disable Copilot
# -----------------------------
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" `
    -Name TurnOffWindowsCopilot -Type DWord -Value 1

# -----------------------------
# Taskbar/UI tweaks
# -----------------------------
# Hide Search, Task View, Widgets
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
    -Name SearchboxTaskbarMode -Type DWord -Value 0

Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name ShowTaskViewButton -Type DWord -Value 0

Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name TaskbarDa -Type DWord -Value 0

# Remove all pinned apps from taskbar (includes Teams)
Remove-Item `
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" `
    -Recurse -Force -ErrorAction SilentlyContinue

# Optionally, pin File Explorer back
$ExplorerPath = "$env:WINDIR\explorer.exe"
if (Test-Path $ExplorerPath) {
    $s = New-Object -ComObject Shell.Application
    $s.NameSpace((Split-Path $ExplorerPath)).ParseName((Split-Path $ExplorerPath -Leaf)).InvokeVerb("Pin to Taskbar")
}

# Classic Alt+Tab (no thumbnails)
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name AltTabSettings -Type DWord -Value 1

# Disable consumer features
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    -Name DisableWindowsConsumerFeatures -Type DWord -Value 1

# -----------------------------
# Restart Explorer to apply UI changes
# -----------------------------
Stop-Process -Name explorer -Force

Write-Host "Ultra-Debloat completed. A full reboot is recommended." -ForegroundColor Green
