# --- 1. BOOTSTRAP & PATH FIX ---
$ScriptPath = $PSScriptRoot

# This logic forces PowerShell to resolve the ".." into a real folder name
$RelativePath = Join-Path $ScriptPath "..\Assets\Data\ad_account.csv"
$CSVPath = (Get-Item $RelativePath -ErrorAction SilentlyContinue).FullName

# If the folder structure is wrong, $CSVPath will be null. Let's handle that:
if ($null -eq $CSVPath) {
    # Fallback to help you debug
    $CSVPath = "NOT FOUND at: " + (Resolve-Path "$ScriptPath\..\Assets\Data" -ErrorAction SilentlyContinue)
}

function Reset-UI {
    $BufferHeight = $Host.UI.RawUI.WindowSize.Height
    for ($i = 0; $i -lt $BufferHeight; $i++) { Write-Host "" }
    while ($Host.UI.RawUI.KeyAvailable) { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
    Clear-Host
    Write-Host "=======================================================" -ForegroundColor Cyan
}

# --- 2. WELCOME SCREEN ---
Reset-UI
Write-Host ">>> 4Ps PROVISIONING: HARDWARE IDENTITY CHECK <<<" -ForegroundColor Yellow
Write-Host "TARGET PATH: $CSVPath" -ForegroundColor White

if (-not (Test-Path $CSVPath)) {
    Write-Host "`n[!] ERROR: FILE NOT FOUND" -ForegroundColor Red
    Write-Host "The script is looking here: $CSVPath" -ForegroundColor Gray
    Write-Host "`nPRO-TIP: Ensure your folder is named exactly 'Assets' and 'Data'."
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "DATABASE: ONLINE" -ForegroundColor Green
$CheckStart = Read-Host "`nPress 1 to Scan System Serial Number"

if ($CheckStart -eq "1") {
    Reset-UI
    Write-Host "[SCANNING...] Reading BIOS Serial Number..." -ForegroundColor Yellow
    
    $CurrentSerial = (Get-CimInstance Win32_BIOS).SerialNumber
    $MasterData = Import-Csv $CSVPath
    
    # Match against "Serial No"
    $Match = $MasterData | Where-Object { $_."Serial No" -eq $CurrentSerial }

    if ($null -ne $Match) {
        Write-Host "`n[MATCH FOUND] FULL DATA TRANSPARENCY:" -ForegroundColor Green
        Write-Host "-------------------------------------------------------"
        
        # Output all columns for transparency
        $Match | Get-Member -MemberType NoteProperty | ForEach-Object {
            $ColName = $_.Name
            Write-Host ("{0,-20} : {1}" -f $ColName, $Match.$ColName) -ForegroundColor White
        }
        
        Write-Host "-------------------------------------------------------"
        
        # THE MANDATORY PAUSE: Forces technician to stop and read
        do {
            $FinalCheck = Read-Host "`nType '1' and press Enter to confirm and proceed"
        } while ($FinalCheck -ne "1")
        
        Write-Host "`nVerification Successful!" -ForegroundColor Cyan
        Start-Sleep -Seconds 2
        
    } else {
        Write-Host "`n[!] NOT FOUND: Serial [$CurrentSerial] is not in CSV." -ForegroundColor Red
        Read-Host "`nPress Enter to exit"
    }
}