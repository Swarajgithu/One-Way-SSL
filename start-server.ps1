# =============================================================================
# START NGINX SERVER WITH SSL
# =============================================================================
# This script starts Nginx with our HTTPS configuration
# =============================================================================

$ScriptDir = $PSScriptRoot
$NginxExe = "$ScriptDir\nginx\nginx.exe"
$NginxConf = "$ScriptDir\conf\nginx.conf"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Starting HTTPS Server" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Nginx exists
if (-not (Test-Path $NginxExe)) {
    Write-Host "[!] Nginx not found!" -ForegroundColor Red
    Write-Host "    Run setup-nginx.ps1 first to install Nginx" -ForegroundColor Yellow
    exit 1
}

# Check if certificates exist
if (-not (Test-Path "$ScriptDir\certs\server.crt")) {
    Write-Host "[!] SSL certificates not found!" -ForegroundColor Red
    Write-Host "    Run generate-cert.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Stop any existing Nginx process
Get-Process nginx -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Update nginx.conf to use local paths
$confPath = $ScriptDir -replace '\\', '/'
$NginxConfContent = @"
# Nginx configuration for One-Way SSL Demo
worker_processes auto;
error_log $confPath/logs/error.log;
pid $confPath/logs/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       $confPath/nginx/conf/mime.types;
    default_type  application/octet-stream;

    access_log $confPath/logs/access.log;

    sendfile on;
    keepalive_timeout 65;

    server {
        listen 443 ssl;
        server_name localhost;

        ssl_certificate      $confPath/certs/server.crt;
        ssl_certificate_key  $confPath/certs/server.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers on;

        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        root $confPath/html;
        index index.html;

        location / {
            try_files `$uri `$uri/ =404;
        }
    }
}
"@

$NginxConfContent | Out-File -FilePath "$ScriptDir\conf\nginx-runtime.conf" -Encoding ascii -Force

# Start Nginx
Write-Host "[*] Starting Nginx server..." -ForegroundColor Yellow
Push-Location $ScriptDir\nginx
Start-Process -FilePath $NginxExe -ArgumentList "-c", "$ScriptDir\conf\nginx-runtime.conf" -WindowStyle Hidden
Pop-Location

Start-Sleep -Seconds 2

# Check if Nginx is running
$nginxProcess = Get-Process nginx -ErrorAction SilentlyContinue
if ($nginxProcess) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  Server started successfully!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access your secure site:" -ForegroundColor White
    Write-Host "  Browser:     https://localhost" -ForegroundColor Cyan
    Write-Host "  Alt URL:     https://127.0.0.1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Test with curl:" -ForegroundColor White
    Write-Host "  curl -v https://localhost -k" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Stop server:" -ForegroundColor White
    Write-Host "  .\stop-server.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[!] Note: Browser will show security warning (self-signed cert)" -ForegroundColor Magenta
    Write-Host "    This is expected - click Advanced > Proceed" -ForegroundColor Magenta
}
else {
    Write-Host "[!] Failed to start Nginx" -ForegroundColor Red
    Write-Host "    Check logs at: $ScriptDir\logs\error.log" -ForegroundColor Yellow
}
