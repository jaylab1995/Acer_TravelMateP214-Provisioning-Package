<# DomainJoin.ps1
   Join domain if available
#>

$DomainName = "entdswd.local"
$DomainUser = "jpbarbacena"
$DomainPass = 'P@$$w0Rd!'

$SecurePass = ConvertTo-SecureString $DomainPass -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($DomainUser, $SecurePass)

$MaxRetries = 12
$RetryCount = 0
$PingSuccess = $false

Write-Host "Checking connectivity to $DomainName..."

while (-not $PingSuccess -and $RetryCount -lt $MaxRetries) {
    if (Test-Connection -ComputerName $DomainName -Count 1 -Quiet) {
        Write-Host "Domain controller reachable."
        $PingSuccess = $true
    } else {
        Write-Host "Domain controller not reachable. Retrying in 5 seconds..."
        Start-Sleep -Seconds 5
        $RetryCount++
    }
}

if ($PingSuccess) {
    Write-Host "Joining domain $DomainName..."
    try {
        Add-Computer -DomainName $DomainName -Credential $Credential -Force -Restart:$false
        Write-Host "Domain join command executed successfully."
    } catch {
        Write-Host "Error joining domain: $_"
    }
} else {
    Write-Host "Could not reach $DomainName after $MaxRetries attempts. Domain join skipped."
}