<# RenameHost.ps1
   Rename PC based on Ethernet MAC
#>

try {
    $adapter = Get-NetAdapter -Name "Ethernet" -ErrorAction Stop
    if ($adapter) {
        $mac = ($adapter.MacAddress -replace "[:\-]", "").ToUpper()
        $newName = "05" + $mac
        if ($newName.Length -le 15) {
            Rename-Computer -NewName $newName -Force
            Write-Host "PC renamed to $newName"
        } else { Write-Host "New hostname too long: $($newName.Length) characters" }
    } else { Write-Host "Ethernet adapter not found." }
} catch { Write-Host "Error renaming PC: $($_.Exception.Message)" }
