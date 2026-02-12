# PowerShell Provisioning Framework Functions
# This module contains all functions for the provisioning engine.

# --- Private Helper Functions ---

# Helper: Buffer-Push UI Reset to prevent ghosting and clear the screen
function Clear-Screen {
    $BufferHeight = $Host.UI.RawUI.WindowSize.Height
    for ($i = 0; $i -lt $BufferHeight; $i++) { Write-Host "" }
    while ($Host.UI.RawUI.KeyAvailable) { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
    Clear-Host
    Write-Host "=======================================================" -ForegroundColor Cyan
}

# Helper: Masked Password
function Get-MaskedPassword {
    param([string]$Prompt = "Enter Password: ")
    Write-Host $Prompt -NoNewline
    $Password = ""
    while($true){
        $Key = [System.Console]::ReadKey($true)
        if($Key.Key -eq "Enter"){ Write-Host ""; break }
        if($Key.Key -eq "Backspace"){
            if($Password.Length -gt 0){
                $Password = $Password.SubString(0, $Password.Length - 1)
                Write-Host "`b `b" -NoNewline
            }
        } else {
            # Only accept standard characters, numbers, and symbols. Ignore control keys.
            if (-not [char]::IsControl($Key.KeyChar)) {
                $Password += $Key.KeyChar
                Write-Host "*" -NoNewline
            }
        }
    }
    return $Password
}

# --- Exported Functions ---

# STEP 0: WELCOME & AUTHORIZATION
function Show-WelcomeScreen {
    param($Config)
    
    $UIPath = Join-Path $Config.DataRoot $Config.UIConfig
    $PassPath = Join-Path $Config.DataRoot $Config.Password

    if ((-not (Test-Path $UIPath)) -or (-not (Test-Path $PassPath))) {
        Write-Host "[!] CRITICAL: UI or Password file not found." -ForegroundColor Red
        Read-Host "Press Enter to exit"; exit
    }

    $UI = Import-Csv $UIPath
    $PassData = Import-Csv $PassPath
    
    Clear-Screen
    Write-Host "    $($UI.Title)" -ForegroundColor White
    Write-Host "    $($UI.Subtitle)" -ForegroundColor Yellow
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "$($UI.Description)" -ForegroundColor Gray
    Write-Host "`n$($UI.SubDescription)" -ForegroundColor White
    Write-Host "-------------------------------------------------------"
    
    for ($i = 1; $i -le 3; $i++) {
        $InputPass = Get-MaskedPassword "Enter Authorization Password (Attempt $i of 3): "
        if ($InputPass -eq $PassData.Password) {
            Write-Host "`nAccess Granted." -ForegroundColor Green
            Read-Host "`nPress Enter to begin hardware checks" | Out-Null
            return
        } else {
            Write-Host "`nAccess Denied." -ForegroundColor Red
        }
    }
    
    Write-Host "`nToo many incorrect attempts." -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

# PRE-REQUISITE: CSV LOOKUP
function Get-ProvisioningData {
    param($Config)

    Write-Host ">>> PRE-REQUISITE: SERIAL NUMBER DATABASE CHECK <<<" -ForegroundColor Yellow
    
    $MasterCSV = Join-Path $Config.DataRoot $Config.MasterAccounts
    if (-not (Test-Path $MasterCSV)) {
        Write-Host "`n[!] CRITICAL: Master Accounts CSV not found at $MasterCSV" -ForegroundColor Red
        Read-Host "Press Enter to exit"; exit
    }

    $CurrentSerial = (Get-CimInstance Win32_BIOS).SerialNumber
    $MasterData = Import-Csv $MasterCSV
    $Match = $MasterData | Where-Object { $_."Serial No" -eq $CurrentSerial }

    if ($null -ne $Match) {
        Write-Host "`n[MATCH FOUND] Assigned to this system:" -ForegroundColor Green
        Write-Host "-------------------------------------------------------"
        # Output every column for full visibility
        $Match | Get-Member -MemberType NoteProperty | ForEach-Object {
            Write-Host ("{0,-20} : {1}" -f $_.Name, $Match.$($_.Name)) -ForegroundColor White
        }
        Write-Host "-------------------------------------------------------"
        
        do { $check = Read-Host "`nType '1' to confirm and proceed" } while ($check -ne "1")
        return $Match
    } else {
        Write-Host "`n[!] ERROR: Serial Number '$CurrentSerial' not found in ad_account.csv." -ForegroundColor Red
        Write-Host "This device is not authorized for provisioning." -ForegroundColor Red
        Read-Host "Press Enter to exit"; exit
    }
}

# STEP 1: LOCAL FOUNDATION & PC NAME
function Set-LocalSystem {
    param(
        $Config,
        [ref]$State
    )
    Clear-Screen
    Write-Host "=== [STEP 1] LOCAL FOUNDATION & PC NAME ===" -ForegroundColor Cyan
    
    $LocalAdminPath = Join-Path $Config.DataRoot $Config.LocalAdmin
    $LocalData = Import-Csv $LocalAdminPath
    $WifiCsvPath = Join-Path $Config.DataRoot "wifi.csv"

    # Calculate PC Name using Ethernet MAC Address, regardless of connection status
    $Eth = Get-NetAdapter | Where-Object { $_.Name -like '*Ethernet*' -and $_.InterfaceDescription -notlike "*Virtual*" } | Select-Object -First 1
    
    if ($Eth) {
        $Mac = $Eth.MacAddress -replace "[:-]",""
        $State.Value.PCName = "05-$Mac" # Using 05- prefix as requested
    } else {
        $State.Value.PCName = "$($Config.PCNamePrefix)NoEthFound"
        Write-Host "No Ethernet adapter found. PC Name set to a default value." -ForegroundColor Red
    }
    
    $State.Value.LocalAdminUser = $LocalData.username

    # --- WiFi Profile Simulation ---
    if (Test-Path $WifiCsvPath) {
        $WifiProfiles = Import-Csv $WifiCsvPath
        Write-Host "`n--- PLANNED WI-FI PROFILES ---" -ForegroundColor Yellow
        $null = foreach ($wifiProfile in $WifiProfiles) {
            Write-Host "Will import Wi-Fi profile: $($wifiProfile.SSID)"
        }
    } else {
        Write-Host "`nwifi.csv not found, skipping Wi-Fi setup." -ForegroundColor Yellow
    }
    
    Write-Host "`nTarget PC Name:  $($State.Value.PCName)"
    Write-Host "Local Admin:     $($State.Value.LocalAdminUser)"
    Write-Host "`n--- PLANNED SYSTEM CHANGES ---" -ForegroundColor Yellow
    Write-Host "1. Set Region to Philippines, Enable Auto-Timezone, Keyboard to US."
    Write-Host "2. Set UAC to 'Do Not Dim'."
    Write-Host "3. Rename PC to $($State.Value.PCName)."
    Write-Host "4. Create local admin account '$($State.Value.LocalAdminUser)'."
    Write-Host "----------------------------------"

    # --- ACTION (SIMULATED - NO CHANGES WILL BE MADE) ---
    Write-Host "`n[SIMULATION] Applying system changes..." -ForegroundColor Gray
    Write-Host "[SIMULATED] Region, Keyboard, and Auto-Timezone would be set."
    Write-Host "[SIMULATED] UAC would be set to 'Do Not Dim'."
    Write-Host "[SIMULATED] PC Name will be set to $($State.Value.PCName). Reboot will be required."
    Write-Host "[SIMULATED] Local admin '$($State.Value.LocalAdminUser)' will be created."
    
    Write-Host "`n[SIMULATION] System settings have been configured." -ForegroundColor Gray
    $State.Value.Step1Status = "Complete"
    Read-Host "`nPress Enter to continue" | Out-Null
}

# STEP 2: AD VALIDATION
function Set-DomainAccount {
    param(
        [ref]$State
    )
    Clear-Screen
    Write-Host "=== [STEP 2] AD IDENTITY VALIDATION ===" -ForegroundColor Cyan
    
    Write-Host "`n[SIMULATION] Joining to domain 'entdswd.local' would be performed here." -ForegroundColor Gray
    $State.Value.Step2Status = "[SIMULATED] Complete"
    Read-Host "`nPress Enter to continue" | Out-Null
}


# STEP 3: SOFTWARE INSTALLATION
function Install-Software {
    param(
        $Config,
        [ref]$State
    )
    Clear-Screen
    Write-Host "=== [STEP 3] SOFTWARE INSTALLATION ===" -ForegroundColor Cyan
    
    $Installers = Get-ChildItem -Path $Config.SoftwareRoot -Filter *.exe
    if ($Installers) {
        Write-Host "Found the following installers to process:"
        $Installers | ForEach-Object { Write-Host "- $($_.Name)" }
    } else {
        Write-Host "No installers found in $($Config.SoftwareRoot)."
        $State.Value.Step3Status = "Skipped - No installers found"
        Read-Host "`nPress Enter to continue" | Out-Null
        return
    }

    $State.Value.SoftwareList = @()
    foreach ($installer in $Installers) {
        Write-Host "`n[SIMULATING] Installation of $($installer.Name)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1 # Simulating install time
        $State.Value.SoftwareList += @{ Name = $installer.Name; Status = "[SIMULATED] Installed" }
        Write-Host "[SIMULATION] Finished installing $($installer.Name)." -ForegroundColor Gray
    }

    $State.Value.Step3Status = "[SIMULATED] Complete"
    Read-Host "`nPress Enter to continue" | Out-Null
}


# STEP 4: DATA SPECS GATHERING
function Get-SystemInfo {
    param(
        [ref]$State
    )
    Clear-Screen
    Write-Host "=== [STEP 4] HARDWARE SPECS GATHERING ===" -ForegroundColor Cyan
    Write-Host "Gathering system information..." -ForegroundColor Yellow
    
    $auditScriptPath = Join-Path $PSScriptRoot "SystemAudit_V2.ps1"

    try {
        . $auditScriptPath
    } catch {
        Write-Host "Error executing SystemAudit_V2.ps1: $($_.Exception.Message)" -ForegroundColor Red
        $State.Value.Step4Status = "Failed to gather system info"
        Read-Host "`nPress Enter to continue" | Out-Null
        return
    }

    function Get-WindowsKey {
        $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        $DigitalProductId = (Get-ItemProperty -Path $Path).DigitalProductId
        $ProductKey = ""
        $KeyOffset = 52
        $Chars = "BCDFGHJKMPQRTVWXY2346789"
        for ($i = 0; $i -lt 25; $i++) {
            $Current = 0
            for ($j = 14; $j -ge 0; $j--) {
                $Current = $Current * 256 -bxor $DigitalProductId[$KeyOffset + $j]
                $DigitalProductId[$KeyOffset + $j] = [math]::Floor($Current / 24)
                $Current = $Current % 24
            }
            $ProductKey = $Chars[$Current] + $ProductKey
            if (($i % 5 -eq 4) -and ($i -ne 24)) {
                $ProductKey = "-" + $ProductKey
            }
        }
        return $ProductKey
    }
    
    try {
        $decryptedKey = Get-WindowsKey
    } catch {
        $decryptedKey = "Decryption Failed"
    }

    try {
        $backupKey = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform' -Name BackupProductKeyDefault).BackupProductKeyDefault
    } catch {
         $backupKey = "Backup Key Not Found"
    }
    
    $ethMac = (Get-NetAdapter | Where-Object { $_.Name -like '*Ethernet*' -and $_.InterfaceDescription -notlike "*Virtual*" } | Select-Object -First 1).MacAddress
    $wifiMac = (Get-NetAdapter | Where-Object { $_.Name -like '*Wi-Fi*' -and $_.InterfaceDescription -notlike "*Virtual*" } | Select-Object -First 1).MacAddress

    Clear-Host
    Write-Host "================= SYSTEM REPORT ================" -ForegroundColor Yellow
    Write-Host " Date:          $dateGathered" -ForegroundColor Gray
    Write-Host " Hostname:      $hostname"
    Write-Host " OS:            $osName ($osVersion) Build $osBuild"
    Write-Host " CPU:           $cpu"
    Write-Host " GPU:           $gpus"
    Write-Host " RAM:           $totalRamGB GB @ $($ramSpeed)MHz"
    Write-Host " Serial:        $serial"
    Write-Host " Brand/Model:   $brand $model"
    Write-Host " Ethernet MAC:  $(if($ethMac){$ethMac}else{'Not Found'})"
    Write-Host " WiFi MAC:      $(if($wifiMac){$wifiMac}else{'Not Found'})"
    Write-Host "------------------- STORAGE --------------------" -ForegroundColor Cyan
    Write-Host " Details:       $storageSummary"
    Write-Host " Decrypted OS Key: $($decryptedKey)"
    Write-Host " Backup OS Key:    $($backupKey)"
    Write-Host "================================================" -ForegroundColor Yellow
    
    $State.Value.SystemInfo = @{
        DateGathered = $dateGathered
        Hostname = $hostname
        OS = "$osName ($osVersion) Build $osBuild"
        CPU = $cpu
        GPU = $gpus
        RAM = "$totalRamGB GB @ $($ramSpeed)MHz"
        Serial = $serial
        Model = "$brand $model"
        EthernetMAC = $(if($ethMac){$ethMac}else{'Not Found'})
        WiFiMAC = $(if($wifiMac){$wifiMac}else{'Not Found'})
        Disk = $storageSummary
        OSKey_Decrypted = $decryptedKey
		OSKey_Backup = $backupKey
    }
    $State.Value.Step4Status = "Complete"
    
    Write-Host "[DONE] Hardware and OS details gathered." -ForegroundColor Green
    Read-Host "`nPress Enter to continue" | Out-Null
}

# STEP 5: TECHNICIAN DETAILS
function Get-TechnicianDetails {
    param(
        $Config,
        [ref]$State
    )
    Clear-Screen
    Write-Host "=== [STEP 5] TECHNICIAN DETAILS ===" -ForegroundColor Cyan
    
    $TechPath = Join-Path $Config.DataRoot $Config.Technicians
    $Techs = Import-Csv $TechPath
    
    foreach($t in $Techs) { Write-Host "$($t.ID). $($t.Name)" }
    
    $ID = ""
    while ($true) {
        $ID = Read-Host "`nEnter Technician ID Number"
        $Tech = $Techs | Where-Object { $_.ID -eq $ID }
        if ($Tech) {
            $State.Value.Technician = $Tech
            Write-Host "`nTechnician Verified: $($Tech.Name)" -ForegroundColor Green
            break
        } else {
            Write-Host "Invalid ID. Please try again." -ForegroundColor Red
        }
    }
    
    $State.Value.Step5Status = "Complete"
    Read-Host "`nPress Enter for Summary" | Out-Null
}

# STEP 6: SUMMARY
function Show-Summary {
    param(
        [ref]$State
    )
    Clear-Screen
    Write-Host "=== [STEP 6] DEPLOYMENT SUMMARY REVIEW ===" -ForegroundColor Yellow
    
    $State.Value.No = -join ((97..122) + (48..57) | Get-Random -Count 8 | ForEach-Object { [char]$_ })

    $techSummary = @"
    -------------------
    Technician Details:
    -------------------
    Technician:       $($State.Value.Technician.Name)
    Date:             $(Get-Date)
"@
    Write-Host $techSummary

    Write-Host "
    --------------------
    Equipment Details:
    --------------------"
    $equipmentDetails = ""
    $State.Value.ProvisioningData.PSObject.Properties | ForEach-Object {
        $line = ("{0,-20} : {1}" -f $_.Name, $_.Value)
        Write-Host $line
        $equipmentDetails += "$line`n"
    }

    $systemConfigSummary = @"

    ----------------------
    System Configuration:
    ----------------------
    PC Name:          $($State.Value.PCName)
    Local Admin:      $($State.Value.LocalAdminUser)
    Status:           $($State.Value.Step1Status)

    AD Account:       $($State.Value.ProvisioningData."AD Name") ($($State.Value.ProvisioningData."Domain Name"))
    Status:           $($State.Value.Step2Status)
"@
    Write-Host $systemConfigSummary

    $softwareSummary = @"

    -------------------
    Software Installed:
    -------------------
    Status:           $($State.Value.Step3Status)
"@
    Write-Host $softwareSummary
    
    $softwareList = ""
    if ($State.Value.SoftwareList) {
        $State.Value.SoftwareList | ForEach-Object { 
            $line = " - $($_.Name): $($_.Status)"
            Write-Host $line
            $softwareList += "$line`n"
        }
    }

    $specSummary = @"

================= SYSTEM REPORT ================
 Date:          $($State.Value.SystemInfo.DateGathered)
 Hostname:      $($State.Value.SystemInfo.Hostname)
 OS:            $($State.Value.SystemInfo.OS)
 CPU:           $($State.Value.SystemInfo.CPU)
 GPU:           $($State.Value.SystemInfo.GPU)
 RAM:           $($State.Value.SystemInfo.RAM)
 Serial:        $($State.Value.SystemInfo.Serial)
 Brand/Model:   $($State.Value.SystemInfo.Model)
 Ethernet MAC:  $($State.Value.SystemInfo.EthernetMAC)
 WiFi MAC:      $($State.Value.SystemInfo.WiFiMAC)
------------------- STORAGE --------------------
 Details:       $($State.Value.SystemInfo.Disk)
 Decrypted OS Key: $($State.Value.SystemInfo.OSKey_Decrypted)
 Backup OS Key:    $($State.Value.SystemInfo.OSKey_Backup)
================================================
"@
    Write-Host $specSummary

    $State.Value.SummaryText = @"
$techSummary

    --------------------
    Equipment Details:
    --------------------
$equipmentDetails
$systemConfigSummary

    -------------------
    Software Installed:
    -------------------
    Status:           $($State.Value.Step3Status)
$softwareList
$specSummary
"@
    
    Read-Host "`nReview the summary. Press Enter to sync online" | Out-Null
}

# STEP 7: FINAL SYNC
function Send-OnlineReports {
    param(
        $Config,
        [ref]$State,
        $ScriptRoot
    )
    Clear-Screen
    Write-Host "=== [STEP 7] ONLINE DATA SYNC ===" -ForegroundColor Cyan
    
    $datetime = Get-Date -Format "yyyyMMdd_HHmmss"
    $logDir = Join-Path $ScriptRoot "..\Logs"
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory | Out-Null
    }
    $logFilePath = Join-Path $logDir "ProdEnSetup_$datetime.txt"
    
    try {
        $State.Value.SummaryText | Out-File -FilePath $logFilePath -Encoding utf8
        Write-Host "Summary log created at $logFilePath" -ForegroundColor Green
    } catch {
        Write-Host "Could not write log file to $logFilePath. Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "Syncing with Discord and Google Sheets..." -ForegroundColor Gray
    
    if ($Config.DiscordWebhook -and $Config.DiscordWebhook -like "http*") {
        Write-Host "Sending report to Discord..." -NoNewline
        try {
            $plainText = $State.Value.SummaryText
            if ($plainText.Length -gt 1990) {
                $plainText = $plainText.Substring(0, 1990) + "... (truncated)"
            }
            
            $payloadObject = @{ content = $plainText }
            $payload = $payloadObject | ConvertTo-Json -Depth 5

            Invoke-RestMethod -Uri $Config.DiscordWebhook -Method Post -Body $payload -ContentType 'application/json' -ErrorAction Stop
            Write-Host " [SUCCESS]" -ForegroundColor Green
        } catch {
            Write-Host " [FAILED]" -ForegroundColor Red
            Write-Host "   Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "[SKIP] Discord webhook not configured or invalid." -ForegroundColor Gray
    }

    if ($Config.GoogleSheetApi -and $Config.GoogleSheetApi -like "http*") {
        Write-Host "Sending data to Google Sheets..." -NoNewline
        try {
            $sheetPayload = @{
                No         = $State.Value.No
                technician = $State.Value.Technician.Name
                pcName     = $State.Value.PCName
                serial     = $State.Value.ProvisioningData."Serial No"
                endUser    = $State.Value.ProvisioningData."Employee Name"
                adUser     = $State.Value.ProvisioningData."AD Name"
                model      = $State.Value.SystemInfo.Model
                cpu        = $State.Value.SystemInfo.CPU
                ram        = $State.Value.SystemInfo.RAM
                disk       = $State.Value.SystemInfo.Disk
                osKey      = $State.Value.SystemInfo.OSKey_Decrypted
            } | ConvertTo-Json

            Invoke-RestMethod -Uri $Config.GoogleSheetApi -Method Post -Body $sheetPayload -ContentType 'application/json' -ErrorAction Stop
            Write-Host " [SUCCESS]" -ForegroundColor Green
        } catch {
            Write-Host " [FAILED]" -ForegroundColor Red
            Write-Host "   Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "[SKIP] Google Sheets API not configured or invalid." -ForegroundColor Gray
    }

    Write-Host "`n[V] Deployment logging complete." -ForegroundColor Green
    Read-Host "`nProvisioning Complete. Press Enter to Finish." | Out-Null
}

Export-ModuleMember -Function Show-WelcomeScreen, Get-ProvisioningData, Set-LocalSystem, Set-DomainAccount, Install-Software, Get-SystemInfo, Get-TechnicianDetails, Show-Summary, Send-OnlineReports