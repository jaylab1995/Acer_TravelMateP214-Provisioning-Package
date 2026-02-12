# Windows Enterprise Debloat Toolkit – v1 Stable

## Overview

This is the **first stable release** of the Windows Enterprise Debloat Toolkit for Acer TravelMate P214 devices. Designed for enterprise deployment, it allows IT teams to safely prepare workstations after BIOS setup and PPKG deployment.

The toolkit **hides non-essential apps and features** (Xbox, Solitaire, Search, Task View), cleans the taskbar, disables Copilot via policy, removes OneDrive, and preserves core system functionality (Explorer, PowerShell, Microsoft Store, and system services).

> ⚠ **McAfee must be manually uninstalled.** Full debloating and enterprise hardening are applied via **Active Directory Group Policy** after successful domain login.

---

## File Structure

```
USB
└── acer_travelmateP214_baseconfig.ppkg
└── Part2
    ├── RunOnce.ps1          # Executes main Part2 automation
    ├── RunOnce_Admin.bat    # Launches PowerShell scripts as admin
    ├── RemoveBloat.ps1      # Debloat script (core removals / UI cleanup)
    ├── Cleanup.ps1          # Optional full cleanup (currently disabled / for testing)
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
2. Run `RunOnce_Admin.bat` from Desktop → launches all scripts as Administrator.
3. Execute `RemoveBloat.ps1` → core debloating and UI cleanup.
4. Execute `Cleanup.ps1` → **optional / currently disabled for testing**.
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

---

## Limitations

* McAfee must be manually uninstalled
* Microsoft Edge is not removed
* Microsoft 365 is not force-uninstalled
* Xbox, Solitaire, Search, Task View → only hidden, not removed
* Full cleanup is optional and controlled via `Cleanup.ps1`

---
