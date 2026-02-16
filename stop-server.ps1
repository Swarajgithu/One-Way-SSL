# =============================================================================
# STOP NGINX SERVER
# =============================================================================

Write-Host "Stopping Nginx server..." -ForegroundColor Yellow

$nginxProcess = Get-Process nginx -ErrorAction SilentlyContinue
if ($nginxProcess) {
    $nginxProcess | Stop-Process -Force
    Write-Host "[+] Nginx server stopped" -ForegroundColor Green
}
else {
    Write-Host "[!] Nginx is not running" -ForegroundColor Yellow
}
