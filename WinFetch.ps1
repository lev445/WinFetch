$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Check, if is PowerShell ISE?
if ($psISE) {
    Write-Warning "This script recomended start on Windows Terminal, for correct show art. "
    Write-Host "Press any key to exit from program..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

try {
    $OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # Ignore
}

if (-not (Get-Item Env:WT_SESSION -ErrorAction SilentlyContinue)) {
    Write-Warning "This script recomended start on Window Terminal session, because art will be displayed more normally."
}


Write-Host "⠀⠀⠀⠀⠀⠆⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
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
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
Write-Host "+=== General Information ===+"
Write-Host "User [ NOW ]: $env:USERNAME@$env:COMPUTERNAME"
Write-Host "OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"
Write-Host "Arch: $((Get-CimInstance Win32_OperatingSystem).OSArchitecture)"

Write-Host "+=== PC Information ===+"

# Check RAM
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
Write-Host "RAM: ${RAM} GB"

# Check CPU
$cpu = (Get-CimInstance Win32_Processor).Name.Trim()
Write-Host "CPU: $cpu"

# Check GPU
$gpu = (Get-CimInstance Win32_VideoController).Name | Select-Object -First 1
Write-Host "GPU: $gpu"

# Check BIOS
$bios = (Get-CimInstance Win32_BIOS).SMBIOSBIOSVersion
Write-Host "BIOS: $bios [ * VERSION * ]"

# Check Internet IP, public/local
Write-Host "+=== Internet Information ===+"
$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*" | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1).IPAddress
if ($ip) {
    Write-Host "IP:       $ip"
} else {
    Write-Host "IP:       [ No found ]"
}

try {
    $publicIp = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 3 -ErrorAction Stop)
    Write-Host "Public IP: $publicIp"
} catch {
    Write-Host "Failed to fetch: Check Internet Connection! Error code: [ 678 ]" -ForegroundColor Red
}
