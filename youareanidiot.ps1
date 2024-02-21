Add-Type -AssemblyName System.Windows.Forms

# Define potential browser paths
$browserPaths = @(
    'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe',
    'C:\Program Files\Google\Chrome\Application\chrome.exe',
    'C:\Program Files\Mozilla Firefox\firefox.exe',
    'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
)

# Start Page
$startPage = 'https://youareanidiot.cc/'

# Function to find the first existing browser
function Get-FirstExistingBrowser {
    param (
        [string[]]$paths
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    return $null
}

# Find the first existing browser
$pathToBrowser = Get-FirstExistingBrowser -paths $browserPaths
if (-not $pathToBrowser) {
    Write-Error "No supported browser found."
    exit
}

# Enumerate all screens (monitors) connected to the system
$screens = [System.Windows.Forms.Screen]::AllScreens

# Iterate through each screen to launch a browser window positioned for that screen
for ($i = 0; $i -lt $screens.Length; $i++) {
    $screen = $screens[$i]
    $x = $screen.Bounds.X
    $y = $screen.Bounds.Y
    $userDataDir = "c:/screen$i"

    # Construct arguments for Start-Process based on the browser
    $arguments = switch -Regex ($pathToBrowser) {
        'chrome.exe|brave.exe' { @('--new-window', '--start-fullscreen', "--user-data-dir=$userDataDir", "--window-position=$x,$y", $startPage) }
        'firefox.exe' { @('-new-window', $startPage) } # Firefox might need different args for positioning and user data
        'msedge.exe' { @('--new-window', '--start-fullscreen', "--user-data-dir=$userDataDir", "--window-position=$x,$y", $startPage) }
        Default { @() }
    }

    # Start the browser process with arguments if we have any
    if ($arguments.Count -gt 0) {
        Start-Process -FilePath $pathToBrowser -ArgumentList $arguments -ErrorVariable Test
    }
}
