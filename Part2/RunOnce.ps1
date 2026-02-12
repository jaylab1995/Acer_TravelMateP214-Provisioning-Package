<# RunOnce.ps1
   Part2 main script
#>

Write-Host "Starting Part2 Configuration..." -ForegroundColor Cyan

$ScriptRoot = $PSScriptRoot

# -----------------------------
# 1. Debloat
# -----------------------------
& "$ScriptRoot\RemoveBloat.ps1"

# -----------------------------
# 2. Apply Start Layout
# -----------------------------
& "$ScriptRoot\StartLayout.ps1"

# -----------------------------
# 3. Rename Host
# -----------------------------
& "$ScriptRoot\RenameHost.ps1"

# -----------------------------
# 4. Import Wi-Fi Profiles
# -----------------------------
& "$ScriptRoot\WiFiProfiles.ps1"



# -----------------------------
# 6. Set Region / Timezone / Language
# -----------------------------
Write-Host "Configuring Region, Language, Timezone..." -ForegroundColor Cyan

Set-TimeZone -Id "Singapore Standard Time"
Set-WinHomeLocation -GeoId 169
Set-WinSystemLocale -SystemLocale en-PH
Set-WinUILanguageOverride -Language en-US
Set-Culture en-PH

Write-Host "Region, Language, Timezone configured." -ForegroundColor Green


# -----------------------------
# 5. Join Domain (if needed)
# -----------------------------
& "$ScriptRoot\DomainJoin.ps1"

# -----------------------------
# 7. Optional Cleanup
# -----------------------------
# & "$ScriptRoot\Cleanup.ps1"

Write-Host "Part2 Configuration Completed!" -ForegroundColor Green
pause
