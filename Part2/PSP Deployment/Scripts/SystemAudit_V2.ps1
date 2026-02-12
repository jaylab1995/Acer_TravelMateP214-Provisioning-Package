# --- SECURITY FIX (Forces TLS 1.2 for Discord Connection) ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# --- CONFIGURATION ---
$CreatedBy = "Sir Chitz"
$CorrectPass = "1L0V3Y0U"
$webhookUrl = "https://discord.com/api/webhooks/1460909225193504863/gvNLOAYpGnc4GelBlx8LQY3WZLLnO339ya5fDHMTHihSkxwit-M2-zBVRzNEUpFWbQ30"

function Show-Intro {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "       DEVICE INFORMATION GATHERING TOOL       " -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host " Created by: $CreatedBy" -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "`nPress any key to start gathering data..." -ForegroundColor Green
    $null = [Console]::ReadKey($true)
}

function Show-Animation {
    Write-Host -NoNewline "`n Gathering System Data... " -ForegroundColor Magenta
    $frames = @("|", "/", "-", "\")
    for ($i = 0; $i -lt 12; $i++) {
        foreach ($frame in $frames) {
            Write-Host -NoNewline "`b$frame"
            Start-Sleep -Milliseconds 50
        }
    }
    Write-Host "`b Done!" -ForegroundColor Green
}

# --- START PROCESS ---
Show-Intro
Show-Animation

# --- DATA GATHERING ---
$dateGathered = Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"
$hostname = $env:COMPUTERNAME
$cpu = (Get-CimInstance Win32_Processor).Name
$gpus = (Get-CimInstance Win32_VideoController | ForEach-Object { $_.Name }) -join " & "
$ramModules = Get-CimInstance Win32_PhysicalMemory
$totalRamGB = [math]::Round(($ramModules | Measure-Object -Property Capacity -Sum).Sum / 1GB, 0)
$ramSpeed = $ramModules[0].ConfiguredClockSpeed

# Brand & Model
$rawBrand = (Get-CimInstance Win32_ComputerSystem).Manufacturer
$brand = switch -wildcard ($rawBrand) { "*Micro-Star*" {"MSI"} "*Hewlett-Packard*" {"HP"} "*Dell*" {"Dell"} "*Lenovo*" {"Lenovo"} "*ASUSTeK*" {"ASUS"} Default {$rawBrand} }
$model = (Get-CimInstance Win32_ComputerSystem).Model
$serial = (Get-CimInstance Win32_BIOS).SerialNumber

# Network (Ethernet and WiFi)
$eth = (Get-NetAdapter | Where-Object { $_.PhysicalMediaType -eq "802.3" -or $_.Name -like "*Ethernet*" } | Select-Object -First 1).MacAddress
$wifi = (Get-NetAdapter | Where-Object { $_.PhysicalMediaType -eq "Native 802.11" -or $_.Name -like "*Wi-Fi*" } | Select-Object -First 1).MacAddress

# OS Info (Separated Version and Build)
$osData = Get-ComputerInfo
$osName = "Microsoft Windows 11 Pro"
$osVersion = $osData.OsDisplayVersion 
$osBuild = $osData.OsBuildNumber

# Dynamic Storage
$drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$storageSummary = ""
$storageDetails = ""
foreach ($drive in $drives) {
    $totalSize = [math]::Round($drive.Size / 1GB, 2)
    $freeSpace = [math]::Round($drive.FreeSpace / 1GB, 2)
    $usedSpace = [math]::Round($totalSize - $freeSpace, 2)
    $percentUsed = [math]::Round(($usedSpace / $totalSize) * 100, 1)
    
    $line = "[$($drive.DeviceID) Used:$($usedSpace)GB / Left:$($freeSpace)GB / Total:$($totalSize)GB ($($percentUsed)%)]"
    $storageSummary += "$line "
    $storageDetails += "$line`n"
}

# --- DISPLAY RESULTS ---
Clear-Host
Write-Host "================= SYSTEM REPORT ================" -ForegroundColor Yellow
Write-Host " Date:          $dateGathered" -ForegroundColor Gray
Write-Host " Hostname:      $hostname"
Write-Host " CPU:           $cpu"
Write-Host " GPU:           $gpus"
Write-Host " RAM:           $totalRamGB GB @ $($ramSpeed)MHz"
Write-Host " Serial:        $serial"
Write-Host " Brand/Model:   $brand $model"
Write-Host " Ethernet MAC:  $(if($eth){$eth}else{'Not Found'})"
Write-Host " WiFi MAC:      $(if($wifi){$wifi}else{'Not Found'})"
Write-Host " OS:            $osName ($osVersion) Build $osBuild"
Write-Host "------------------- STORAGE --------------------" -ForegroundColor Cyan
Write-Host " Details:       $storageSummary"
Write-Host "================================================" -ForegroundColor Yellow
return
# --- AUTHENTICATION & SENDING ---
$choice = Read-Host "`nSend report to Discord? (Y/N)"
if ($choice -eq "Y") {
    $userName = Read-Host "Enter your name"
    Write-Host "Enter authorization password: " -NoNewline
    $inputSecure = Read-Host -AsSecureString
    $inputPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputSecure))

    if ($inputPass -eq $CorrectPass) {
        Write-Host "`nSending plain text report..." -ForegroundColor Cyan
        
        $plainText = @"
SYSTEM AUDIT REPORT
User: $userName
Date: $dateGathered
---------------------------
Hostname: $hostname
Serial: $serial
Manufacturer: $brand
Model: $model
---------------------------
CPU: $cpu
GPU: $gpus
RAM: $totalRamGB GB
---------------------------
Ethernet MAC: $(if($eth){$eth}else{'N/A'})
WiFi MAC: $(if($wifi){$wifi}else{'N/A'})
OS: $osName ($osVersion) Build $osBuild
---------------------------
STORAGE:
$storageDetails
"@

        $payload = @{ content = $plainText } | ConvertTo-Json

        try {
            Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'
            Write-Host "SUCCESS: Report sent!" -ForegroundColor Green
        } catch {
            Write-Host "ERROR: Connection failed. Message: $($_.Exception.Message)" -ForegroundColor Red
        }
    } 
    else {
        Write-Host "`nInvalid Password! Access Denied." -ForegroundColor Red
    }
} # This closes the choice 'Y' block

Write-Host "`nPress any key to exit..."
$null = [Console]::ReadKey($true)