<# WiFiProfiles.ps1
   Add two Wi-Fi profiles
#>

$Profiles = @("wifi1.xml","wifi2.xml")

foreach ($profile in $Profiles) {
    $ProfilePath = Join-Path $PSScriptRoot $profile
    if (Test-Path $ProfilePath) {
        netsh wlan add profile filename="$ProfilePath"
        Write-Host "Imported $profile"
    }
}
