<#
.SYNOPSIS
    PSP Deployment Tool - Main Engine
.DESCRIPTION
    This script orchestrates the device provisioning process. It loads configuration and functions
    from external files and executes the provisioning steps in sequence.
.NOTES
    Author: Gemini
    Version: 1.0
    Created: 2026-01-26
#>

# --- 1. INITIALIZATION ---
Clear-Host
$ErrorActionPreference = "Stop"

# Set base paths
$ScriptRoot = $PSScriptRoot
$ConfigPath = Join-Path $ScriptRoot "..\Assets\config.psd1"
$ModulePath = Join-Path $ScriptRoot "Functions.psm1"

# Load Configuration & Function Module
try {
    # Load configuration using the recommended cmdlet for .psd1 files.
    $Config = Import-PowerShellDataFile -Path $ConfigPath
    $Config.DataRoot = (Resolve-Path -Path (Join-Path $ScriptRoot $Config.DataRoot)).Path
    $Config.SoftwareRoot = (Resolve-Path -Path (Join-Path $ScriptRoot $Config.SoftwareRoot)).Path

    Import-Module -Name $ModulePath -Force
} catch {
    Write-Host "[X] CRITICAL ERROR: Could not load configuration or function module." -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
    Read-Host "Press Enter to exit."
    Exit
}


# --- 2. STATE MANAGEMENT ---
# Initialize a hashtable to hold the state and data collected during the script execution.
$State = @{
    ProvisioningData = $null # From ad_account.csv
    PCName           = $null # e.g., 05-AABBCCDDEEFF
    LocalAdminUser   = $null # from master_local_account.csv
    SystemInfo       = $null # Specs, OS Keys
    Technician       = $null # from cmt.csv
    SoftwareList     = $null # list of installed software
    SummaryText      = $null # Final summary for reporting
    Step1Status      = "Pending"
    Step2Status      = "Pending"
    Step3Status      = "Pending"
    Step4Status      = "Pending"
    Step5Status      = "Pending"
}


# --- 3. MAIN EXECUTION FLOW ---
# Each function represents a step in the provisioning process.
# The $State object is passed between them to track progress and data.
try {
    # Step 0: Welcome & Password
    Show-WelcomeScreen -Config $Config

    # Pre-Req: Get device data from CSV based on serial number
    $State.ProvisioningData = Get-ProvisioningData -Config $Config
    
    # Step 1: Set Local System Settings (Simulated)
    Set-LocalSystem -Config $Config -State ([ref]$State)
    
    # Step 2: AD Join (Simulated)
    Set-DomainAccount -State ([ref]$State)

    # Step 3: Install Software (Simulated)
    Install-Software -Config $Config -State ([ref]$State)

    # Step 4: Gather Specs
    Get-SystemInfo -State ([ref]$State)

    # Step 5: Get Technician
    Get-TechnicianDetails -Config $Config -State ([ref]$State)
    
    # Step 6: Show Summary
    Show-Summary -State ([ref]$State)

    # Step 7: Sync Online (Simulated)
    Send-OnlineReports -Config $Config -State ([ref]$State) -ScriptRoot $ScriptRoot

} catch {
    Write-Host "`n`n[!!!] A FATAL ERROR OCCURRED [!!!]" -ForegroundColor Red
    Write-Host "------------------------------------"
    Write-Host "ERROR: $($_.Exception.Message)"
    Write-Host "At: $($_.TargetObject)"
    Write-Host "Stack: $($_.ScriptStackTrace)"
    Read-Host "`nPress Enter to exit the script."
} finally {
    # Remove the imported module to allow for easier script development/re-running
    Remove-Module -Name $ModulePath -Force
    Write-Host "`n--- End of Script ---"
}
