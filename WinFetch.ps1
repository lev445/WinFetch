# WinFetch.ps1
# A system info fetch tool for Windows
# By lev445 (https://github.com/lev445/WinFetch)
# Theme repos: https://github.com/lev445/winfetch-themes
# Get IP from site: https://api.ipify.org

param(
    [string]$Theme = "Windows",
    [switch]$Shop,
	[switch]$Random,
	[switch]$Help,
	[switch]$FlMan,
	[switch]$SafeMode,
	[switch]$Clear
)

# PC info
Write-Host "${Indent}+=== PC Information ===+" -ForegroundColor Cyan
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$gpus = (Get-CimInstance Win32_VideoController).Name
$gpu = $gpus -join ", "
$bios = (Get-CimInstance Win32_BIOS).SMBIOSBIOSVersion


# function: Shop
function Open-WinFetchShop {
    Write-Host "WinFetch Theme Shop" -ForegroundColor Cyan
    Write-Host "Fetching available themes from GitHub..." -ForegroundColor Gray

    $repoUrl = "https://api.github.com/repos/lev445/winfetch-themes/contents"
    try {
        $items = Invoke-RestMethod -Uri $repoUrl -UseBasicParsing -TimeoutSec 5
        $themes = @()
		foreach ($item in $items) {
			if ($item.name -like "*.zip") {
			$themeName = [string]$item.name
			$themeName = $themeName.Trim()
			$themeName = $themeName -replace "\.zip$", ""
			$themes += $themeName
    }
}

        if ($null -eq $themes -or $themes.Count -eq 0) {
            Write-Host "No themes found in the shop." -ForegroundColor Yellow
            return
        }

        Write-Host "`nAvailable themes:" -ForegroundColor Green
		Write-Host "+-----------------+" -ForegroundColor Gray
        for ($i = 0; $i -lt $themes.Count; $i++) {
            Write-Host "  -> [$($i+1)] $($themes[$i])"
        }

        $choice = Read-Host "`nEnter theme number to install (or 0 to cancel)"
        if ($choice -eq "0" -or -not $choice) { return }

        $index = [int]$choice - 1
        if ($index -lt 0 -or $index -ge $themes.Count) {
            Write-Host "Invalid choice." -ForegroundColor Red
            return
        }

        $themeName = $themes[$index]
        $zipUrl = "https://github.com/lev445/winfetch-themes/raw/master/$($themeName).zip"
        $zipPath = "$env:TEMP\$($themeName).zip"
        $destPath = "$env:ProgramData\WindowsFetch\Themes\$themeName"

        Write-Host "Downloading $themeName..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

        if (Test-Path $destPath) { 
            Remove-Item $destPath -Recurse -Force 
        }

        Expand-Archive -Path $zipPath -DestinationPath $destPath -Force
        Remove-Item $zipPath

        Write-Host "Theme '$themeName' installed!" -ForegroundColor Green
        Write-Host "Use: WinFetch.ps1 -Theme $themeName" -ForegroundColor Gray

    } catch {
        Write-Host "Failed to load shop: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Encoding
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# check, if is a powershell ISE?
if ($psISE) {
    Write-Warning "This script is recommended to run in Windows Terminal for correct art display."
    Write-Host "Press any key to exit..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    exit
}

# Check, if is no wiwndows terminal?
if (-not (Get-Item Env:WT_SESSION -ErrorAction SilentlyContinue)) {
    Write-Warning "For best experience, run this script in Windows Terminal."
}

# get-Shop
if ($Shop) {
    Open-WinFetchShop
    exit
}

# Random
if ($Random) {
	$themes = Get-ChildItem "$ThemesPath\*.zip" | ForEach-Object { $_.BaseName }
	if ($themes.Count -gt 0) {
		$Theme = $themes | Get-Random
		Write-Host "Random theme selected: $Theme" -ForegroundColor Cyan
	} else {
		Write-Host "No themes found for random selection" -ForegroundColor Red
	}
	
	
}

if ($Clear) {
	Clear-Host
}


# Help
if ($Help) {
	Write-Host ""
	Write-Host "[ Help Menu ]" -ForegroundColor Cyan
	Write-Host "+----------------+" -ForegroundColor Gray
	Write-Host " -> Help" -ForegroundColor Yellow
	Write-Host " -> Shop" -ForegroundColor Yellow
	Write-Host " -> FlMan" -ForegroundColor Yellow
	Write-Host " -> Random" -ForegroundColor Yellow
	Write-Host " -> Clear" -ForegroundColor Yellow
	Write-Host " -> Theme [name theme who installed]" -ForegroundColor Yellow
	Write-Host "+----------------+" -ForegroundColor Gray
	Write-Host ""
	exit
}

if ($FlMan) {
	Write-Host ""
	Write-Host "[ FlMan ]" -ForegroundColor Cyan
	Write-Host "+---------------+" -ForegroundColor Gray
	Write-Host "--> Help - get all commands" -ForegroundColor Yellow
	Write-Host "--> Shop - get more theme's" -ForegroundColor Yellow
	Write-Host "--> FlMan - get this Menu" -ForegroundColor Yellow
	Write-Host "--> Random - Random theme" -ForegroundColor Yellow
	Write-Host "--> Theme [name theme who installed] - check theme" -ForegroundColor Yellow
	Write-Host "--> Clear - Clears the screen" -ForegroundColor Yellow
	Write-Host "The syntax for ALL Windows Fetch commands is: winfetch -(the name of the command to execute, without parentheses!).	For example: winfetch -shop"
	Write-Host ""
	exit
}

if ($SafeMode) {
	Write-Host ""
	Write-Host "${Indent} [* Safe Mode function *]"
	Write-Host "${Indent}+=== General Information ===+" -ForegroundColor Cyan
	Write-Host "${Indent}User [ NOW ]: $env:USERNAME@$env:COMPUTERNAME"
	Write-Host "${Indent}OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"
	Write-Host "${Indent}Arch: $((Get-CimInstance Win32_OperatingSystem).OSArchitecture)"
	$osVersion = (Get-CimInstance Win32_OperatingSystem).Version
	Write-Host "${Indent}Windows version: $osVersion"
	$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
	Write-Host "${Indent}Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
	Write-Host "${Indent}+=== PC information ===+" -ForegroundColor Cyan
	Write-Host "${Indent}RAM: $ram"
	Write-Host "${Indent}GPU: $gpu GB"
	exit
}


# pathes
$BasePath = "$env:ProgramData\WindowsFetch"
$ThemesPath = "$BasePath\Themes"
$DefaultThemePath = "$ThemesPath\Windows"

# Create file root
if (-not (Test-Path $BasePath)) {
    New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
}
if (-not (Test-Path $ThemesPath)) {
    New-Item -ItemType Directory -Path $ThemesPath -Force | Out-Null
}

# Default ASCII art
$DefaultAscii = @"
⠀⠀⠀⠀⠀⠆⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠐⢀⡙⠴⢖⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠠⠀⠀⠀⣤⠘⢛⢻⣿⣧⣿⣿⣿⣿⣿⣿⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀
⠀⠀⠠⠆⣀⠁⠤⠄⣘⠊⠦⢴⣿⣿⠉⠉⠉⣹⣿⠟⠻⢿⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⢀⠉⠤⠄⣈⡘⠐⢡⣿⣿⠇⠀⠀⢠⣿⡏⠀⠀⠀⢸⣿⠁⠀⠀⠀⠀
⠀⠀⠀⡈⠠⠄⡈⠉⠽⠿⣿⣿⠿⠿⠿⣾⣿⣿⣤⣀⠀⣼⣿⡇⠀⠀⠀⠀⠀
⠰⠀⠀⠀⠶⠀⠀⠀⠁⢀⣿⣿⠁⠀⠀⢸⣿⠏⠹⢿⣿⣿⡿⠀⠀⠀⠀⠀⠀
⠀⠀⠋⣤⣄⣈⡈⠔⢰⣿⣿⠀⠀⠀⢠⣿⠃⠀⠀⠀⣼⣿⠃⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠘⠛⠿⠿⣿⣿⣿⣿⣷⣶⣿⣇⡀⠀⠀⣼⣿⠃⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠙⠛⠿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀
"@

# Standard theme
if (-not (Test-Path "$DefaultThemePath\ascii.txt")) {
    New-Item -ItemType Directory -Path $DefaultThemePath -Force | Out-Null
    Set-Content -Path "$DefaultThemePath\ascii.txt" -Value $DefaultAscii -Encoding UTF8
}

# Load selected theme
$SelectedThemePath = "$ThemesPath\$Theme"
if (Test-Path "$SelectedThemePath\ascii.txt") {
    $AsciiArt = Get-Content "$SelectedThemePath\ascii.txt" -Raw -Encoding UTF8
} else {
    Write-Host "[ ERROR ]: Theme '$Theme' is not found. Using standard 'Windows' theme." -ForegroundColor Red
    Write-Host ""
    $AsciiArt = $DefaultAscii
}

# ASCII art 
Write-Host $AsciiArt

# Indentation
$Indent = "  "

# General info
Write-Host "${Indent}+=== General Information ===+" -ForegroundColor Cyan
Write-Host "${Indent}User [ NOW ]: $env:USERNAME@$env:COMPUTERNAME"
Write-Host "${Indent}OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"
Write-Host "${Indent}Arch: $((Get-CimInstance Win32_OperatingSystem).OSArchitecture)"
$osVersion = (Get-CimInstance Win32_OperatingSystem).Version
Write-Host "${Indent}Windows version: $osVersion"
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
Write-Host "${Indent}Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"

Write-Host "${Indent}RAM: ${ram} GB"
Write-Host "${Indent}CPU: $cpu"
Write-Host "${Indent}GPU: $gpu"
Write-Host "${Indent}BIOS: $bios [ * VERSION * ]"

# Check Internet
Write-Host "${Indent}+=== Internet Information ===+" -ForegroundColor Cyan
$ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
       Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | 
       Select-Object -First 1).IPAddress

if ($ip) {
    Write-Host "${Indent}IP:       "
} else {
    Write-Host "${Indent}IP:       [ Not found ]"
}
try {
    $publicIp = Invoke-RestMethod -Uri "https://api.ipify.org" -UseBasicParsing -TimeoutSec 3
    Write-Host "${Indent}Public IP: "
} catch {
    Write-Host "${Indent}Failed to fetch public IP. Check internet connection! Error code: [ 678 ]" -ForegroundColor Red
}
