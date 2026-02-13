# Windows Enterprise Debloat Toolkit – v1 Stable

## Overview

This is the **first stable release** of the Windows Enterprise Debloat Toolkit for Acer TravelMate P214 devices. Designed for enterprise deployment, it allows IT teams to safely prepare workstations after BIOS setup and PPKG deployment.

The toolkit **hides non-essential apps and features** (Xbox, Solitaire, Search, Task View), cleans the taskbar, disables Copilot via policy, removes OneDrive, and preserves core system functionality (Explorer, PowerShell, Microsoft Store, and system services).

> ⚠ **McAfee must be manually uninstalled.** All further debloating and enterprise hardening are applied via **Active Directory Group Policy** upon successful domain login.

---

## File Structure

```
USB
└── acer_travelmateP214_baseconfig.ppkg
└── Part2
    ├── RunOnce.ps1          # Executes main Part2 automation
    ├── RunOnce_Admin.bat    # Launches PowerShell scripts as admin
    ├── RemoveBloat.ps1      # Debloat script (core removals / UI cleanup)
    ├── Cleanup.ps1          # Cleans all files inside Part2 folder after execution
    ├── StartLayout.ps1      # Configures Start menu layout
    ├── start2.bin           # Start layout backup / restore file
    ├── RenameHost.ps1       # Rename host according to convention
    ├── DomainJoin.ps1       # Joins machine to Active Directory
    ├── WiFiProfiles.ps1     # Imports saved Wi-Fi profiles
    ├── wifi1.xml            # Wi-Fi profile 1
    └── wifi2.xml            # Wi-Fi profile 2
```

---

## Workflow

**Part 1 – PPKG Deployment**

1. Perform **BIOS password setup** on the new machine.
2. Apply `acer_travelmateP214_baseconfig.ppkg` → **skips OOBE**.

**Part 2 – Post-PPKG Configuration**

1. **Copy the `Part2` folder to Desktop**.
2. Run `RunOnce_Admin.bat` from Desktop → launches all scripts as Administrator. It automatically execute processes from number 3 to 8.
3. Execute `RemoveBloat.ps1` → core debloating and UI cleanup.
4. Execute `Cleanup.ps1` → cleans all files inside the `Part2` folder.
5. Apply `StartLayout.ps1` → configures Start menu layout.
6. Rename host using `RenameHost.ps1`.
7. Join Active Directory via `DomainJoin.ps1`.
8. Import Wi-Fi profiles via `WiFiProfiles.ps1`.
9. Reboot manually.

**Post Domain Login**

* AD Group Policy applies additional debloating, security, and hardening automatically.

---

## Key Features

* OEM Cleanup (Acer apps hidden or disabled)
* Consumer Apps & Features (Xbox, Solitaire hidden; optional apps removed via `Cleanup.ps1`)
* OneDrive removal + policy
* Copilot disabled via policy
* Taskbar cleanup and pin management
* Enterprise hardening via AD after login
* `Cleanup.ps1` safely removes only temporary setup files inside the `Part2` folder

---

## Limitations

* McAfee must be manually uninstalled
* Microsoft Edge is not removed
* Microsoft 365 is not force-uninstalled
* Xbox, Solitaire, Search, Task View → only hidden, not removed


---

# 🖥 Windows Enterprise Deployment Toolkit Step by da step process

### Acer TravelMate P214 – Production Version (v1 Stable)

---

# 📘 Overview

This toolkit is designed for enterprise deployment of **Acer TravelMate P214** devices within FO5.

It standardizes workstation preparation after BIOS configuration and provisioning package (PPKG) deployment, ensuring:

* Consistent system configuration
* Controlled UI cleanup
* Domain integration
* Deployment traceability
* Automated documentation

All enterprise hardening and policy enforcement are handled through **Active Directory Group Policy** after successful domain login.

---

# 🔹 PHASE 1 – BIOS Preparation

1. Power on the new device.
2. Enter BIOS setup.
3. Configure required BIOS settings.
4. Set BIOS password according to ICT security policy.
5. Save and exit BIOS.

✔ Device is now ready for provisioning.

---

# 🔹 PHASE 2 – Apply Base Configuration (PPKG)

1. Insert USB containing:

   ```
   acer_travelmateP214_baseconfig.ppkg
   ```
2. Boot into Windows OOBE.
3. Apply the provisioning package.
4. Confirm installation.
5. The system will skip the standard OOBE process.
6. Log in using the local account created by the PPKG.

✔ Base configuration successfully applied.

---

# 🔹 PHASE 3 – Prepare Part2 Deployment Folder

1. Copy the entire `Part2` folder to the **Desktop**.
2. Ensure all files remain intact inside the folder.

---

# 🔹 PHASE 4 – Execute Post-Deployment Scripts

### Step 1 – Run Administrator Launcher

1. Right-click `RunOnce_Admin.bat`
2. Select **Run as Administrator**
3. Confirm UAC prompt

This launches all required PowerShell scripts with elevated privileges.

---

## Scripts Executed During Deployment

---

### 🧹 1. RemoveBloat.ps1

Performs:

* Taskbar cleanup
* Hides Xbox, Solitaire, Search, Task View
* Disables Copilot via policy
* Removes OneDrive
* Preserves core system components (Explorer, PowerShell, Microsoft Store, system services)

---

### 🖥 2. StartLayout.ps1

* Applies predefined Start menu layout
* Uses `start2.bin` for layout configuration

---

### 🏷 3. RenameHost.ps1

**Purpose:** Renames the device according to organizational naming convention.

**Naming Format:**

```
05-MAC
```

**Details:**

* `05` → Field Office identifier (FO5)
* `MAC` → Device classification

The script:

* Assigns or prompts for hostname
* Applies the new computer name
* Requires restart for full effect

✔ Verify hostname before proceeding to domain join.

---

### 🌐 4. DomainJoin.ps1

* Joins the device to Active Directory
* Requires authorized domain credentials

✔ Ensure correct hostname before execution.

---

### 📶 5. WiFiProfiles.ps1

* Imports `wifi1.xml`
* Imports `wifi2.xml`
* Automatically configures wireless profiles

---

### 🧼 6. Cleanup.ps1 - This version has the `cleanup.ps1` commented and not executed(optional)

**Purpose:** Final cleanup of deployment artifacts inside the `Part2` folder.

**Functionality:**

* Deletes all scripts and files in `Part2`:

  * `RunOnce.ps1`, `RunOnce_Admin.bat`
  * `RemoveBloat.ps1`
  * `StartLayout.ps1`, `start2.bin`
  * `RenameHost.ps1`
  * `DomainJoin.ps1`
  * `WiFiProfiles.ps1`, `wifi1.xml`, `wifi2.xml`
* Ensures no leftover files remain after deployment
* Works in conjunction with the **CONFIGURED.txt marker file**
* **Safe:** Does not remove any system apps or Windows components

**Placement in Workflow:**

1. Executed after all post-deployment scripts finish
2. Marks the completion of the automated deployment phase

---

# 🔹 PHASE 5 – Manual Tasks

Before finalizing deployment:

* Manually uninstall McAfee
* Verify:

  * Hostname
  * Domain membership
  * Network connectivity
  * Start layout
  * Taskbar configuration

---

# 🔹 PHASE 6 – Reboot

1. Restart the device.
2. Log in using domain credentials.

---

# 🔹 PHASE 7 – Active Directory Policy Enforcement

After domain login:

Active Directory Group Policy automatically applies:

* Enterprise security hardening
* Additional restrictions
* System configurations
* Organizational compliance settings

No manual action required.

---

# 🔹 PHASE 8 – Automated Computer Information Logging (Production Feature)

The production-ready version includes an **Automatic Computer Information Gatherer**.

This script runs during final configuration and ensures centralized documentation.

---

## 📊 System Information Collection

The script gathers:

* Computer Name
* Serial Number
* Manufacturer
* Model
* BIOS Version
* Windows Edition & Build
* Processor Information
* RAM Size
* Disk Information
* MAC Address
* Domain Status
* Date and Time of Configuration
* Assigned Technician

---

## 🌐 Google Sheets Integration

* Collected data is automatically sent to a centralized Google Sheet.
* Each deployment creates a new row entry.
* Serves as:

  * Asset registry
  * Deployment tracker
  * Configuration audit log
  * Technician accountability record

---

## 📁 Configuration Marker File

After successful configuration, a file is created at:

```
C:\CONFIGURED.txt
```

### Purpose

* Indicates device has been fully configured
* Prevents duplicate configuration
* Provides quick validation indicator

### File Records:

* Computer Name
* Date of Configuration
* Time of Configuration
* Technician Name
* Deployment Version
* Configuration Status

Example:

```
Device: 05-MAC-023
Configured On: 2026-02-13
Time: 14:35:22
Technician: Eliaf D.
Version: v1 Stable
Status: SUCCESS
```

---

# ✅ Deployment Checklist

Before device handover:

* [ ] BIOS password configured
* [ ] PPKG successfully applied
* [ ] Device renamed correctly
* [ ] Domain joined
* [ ] WiFi profiles imported
* [ ] McAfee removed
* [ ] Part2 folder cleaned by Cleanup.ps1
* [ ] AD policies applied
* [ ] Google Sheets entry confirmed
* [ ] CONFIGURED.txt file present
* [ ] Final reboot completed

---

# 🔐 Important Notes

* `Cleanup.ps1` **removes only deployment files inside `Part2`**
* Microsoft Edge is not removed
* Microsoft 365 is not force-uninstalled
* Core Windows services remain intact
* Enterprise restrictions are enforced via Active Directory
* Internet connection required for Google Sheets logging

---

This version has the `cleanup.ps1` commented and not executed

---

