# =============================================================================
# NGINX SETUP SCRIPT FOR WINDOWS
# =============================================================================
# Downloads and extracts Nginx for Windows into the ssl-demo directory
# =============================================================================

$NginxVersion = "1.24.0"
$NginxZip = "nginx-$NginxVersion.zip"
$NginxUrl = "https://nginx.org/download/$NginxZip"
$DestDir = "$PSScriptRoot\nginx"
$DownloadPath = "$PSScriptRoot\$NginxZip"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Nginx Setup for Windows" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Nginx already exists
if (Test-Path "$DestDir\nginx.exe") {
    Write-Host "[!] Nginx already installed at $DestDir" -ForegroundColor Yellow
    Write-Host "    Delete the nginx folder and run again to reinstall." -ForegroundColor Yellow
    exit 0
}

# Download Nginx
Write-Host "[*] Downloading Nginx $NginxVersion..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $NginxUrl -OutFile $DownloadPath -UseBasicParsing
    Write-Host "[+] Download complete" -ForegroundColor Green
}
catch {
    Write-Host "[!] Failed to download Nginx" -ForegroundColor Red
    Write-Host "    Please download manually from: https://nginx.org/en/download.html" -ForegroundColor Yellow
    exit 1
}

# Extract Nginx
Write-Host "[*] Extracting..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $DownloadPath -DestinationPath $PSScriptRoot -Force
    Rename-Item -Path "$PSScriptRoot\nginx-$NginxVersion" -NewName "nginx" -Force
    Write-Host "[+] Extracted to $DestDir" -ForegroundColor Green
}
catch {
    Write-Host "[!] Failed to extract Nginx" -ForegroundColor Red
    exit 1
}

# Clean up zip file
Remove-Item -Path $DownloadPath -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Nginx installed successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Generate certificates: .\generate-cert.ps1" -ForegroundColor Yellow
Write-Host "  2. Start server: .\start-server.ps1" -ForegroundColor Yellow
Write-Host ""
