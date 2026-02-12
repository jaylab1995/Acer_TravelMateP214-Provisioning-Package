Project Title: PSP Deployment Tool

Description:
This project automates the device provisioning process, including setting local system settings, joining the device to the Active Directory domain, installing software, gathering hardware specifications, and generating reports.

File Structure:
- Assets/: Contains configuration files, data files, and software installers.
  - config.psd1: Main configuration file for script settings.
  - Data/: Contains CSV files with data for UI configuration, passwords, AD accounts, local admin accounts, and technicians.
  - Software/: Contains executable installers for software to be installed.
- Scripts/: Contains the PowerShell scripts for the provisioning engine.
  - Functions.psm1: PowerShell module containing all functions for the provisioning engine.
  - Provisioning_Engine.ps1: Main script that orchestrates the device provisioning process.
  - SystemAudit_V2.ps1: Script to gather system hardware and software information.
- readme.txt: This file (description and instructions)

Key Scripts:
- Provisioning_Engine.ps1: The main script to execute the provisioning process.
- Functions.psm1: Contains functions for each step of the process. It was recently updated to provide a more detailed summary in Step 6, send a plain text payload to Discord and a JSON payload to Google Sheets in Step 7, implement a 3-try password authentication, and create a local log file in the project's root directory. Several syntax bugs have been fixed.

Configuration Files:
- Assets/config.psd1: Contains settings for file paths, webhooks, API endpoints, and PC naming conventions.
- Assets/Data/*.csv: Various CSV files containing data for the provisioning process.

Workflow:
1. Execute Provisioning_Engine.ps1 to start the provisioning process.
2. The script will guide you through each step, prompting for input when needed.
3. The script begins with a welcome screen and a 3-attempt password authentication.
4. It then checks the device's serial number against the `ad_account.csv` file to authorize the device and fetch its data.
5. The script proceeds through the following steps:
    - Step 1: Set Local System Settings
    - Step 2: AD Join (Simulated)
    - Step 3: Install Software (Simulated)
    - Step 4: Gather Specs - Gathers detailed system information, including MAC addresses and OS version.
    - Step 5: Get Technician
    - Step 6: Deployment Summary Review - A comprehensive summary of all previous steps is displayed, with a detailed system report. A unique 8-character ID is generated.
    - Step 7: Sync Online - A local log file `ProdEnSetup_datetime.txt` is created in the project's root directory. The summary is sent as a plain text message to a Discord webhook and select fields are sent to a Google Sheet.
6. The script uses functions from Functions.psm1 to perform the provisioning tasks.
7. Configuration settings are loaded from Assets/config.psd1.
8. Data is loaded from the CSV files in Assets/Data/.

Updating this file:
- Every time you modify the script, make sure this `readme.txt` is up to date.