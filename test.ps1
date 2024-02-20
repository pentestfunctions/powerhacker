$url = "https://discord.com/api/webhooks/1209454835729047562/AOYgRWEOfiiHBaPdfvn9hsdBDDgbnM27U89728F1BSzeBRfGEjxASbT4tfNFoh9hljzs"
$body = @{
    content = "hello"
} | ConvertTo-Json
Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
