# Elyon installer for Windows
# Usage â€” run in any PowerShell window (no admin required):
#   irm https://sonatype.winu.fr/repository/elyon-raw/install.ps1 | iex
#
# Admin:     installs to C:\Program Files\elyon\  (system-wide)
# Non-admin: installs to $env:LOCALAPPDATA\elyon\ (current user only)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$NexusUrl    = "https://sonatype.winu.fr/repository/elyon-raw"
$DownloadUrl = "$NexusUrl/windows/amd64/elyon.exe"

# Choose install directory based on whether running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if ($isAdmin) {
    $InstallDir = "$env:ProgramFiles\elyon"
    $PathScope  = "Machine"
} else {
    $InstallDir = "$env:LOCALAPPDATA\elyon"
    $PathScope  = "User"
    Write-Host "  (not admin â€” installing to user profile, no elevation needed)" -ForegroundColor Yellow
}

$BinaryPath = "$InstallDir\elyon.exe"

Write-Host "Installing elyon for Windows/amd64..." -ForegroundColor Cyan
Write-Host "  from: $DownloadUrl"
Write-Host "  to:   $BinaryPath"
Write-Host ""

# Create install directory
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# Download binary
$tmp = "$env:TEMP\elyon_install.exe"
Invoke-WebRequest -Uri $DownloadUrl -OutFile $tmp -UseBasicParsing
Copy-Item $tmp -Destination $BinaryPath -Force
Remove-Item $tmp -ErrorAction SilentlyContinue

# Add to PATH if not already there
$currentPath = [Environment]::GetEnvironmentVariable("PATH", $PathScope)
if ($currentPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$InstallDir", $PathScope)
    $env:PATH = "$env:PATH;$InstallDir"
    Write-Host "  Added $InstallDir to $PathScope PATH" -ForegroundColor Yellow
    Write-Host "  Restart your terminal to use 'elyon' from any directory." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "elyon installed!" -ForegroundColor Green
Write-Host ""

# Run version check using full path (current session PATH may not include it yet)
& $BinaryPath --version

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  elyon store seed"
Write-Host "  elyon new my-api --type=api --db=postgres"
Write-Host "  cd my-api && elyon install && elyon up"
Write-Host ""
Write-Host "Connect to Claude / Cursor:"
Write-Host "  elyon mcp connect claude"
Write-Host "  elyon mcp connect cursor"
