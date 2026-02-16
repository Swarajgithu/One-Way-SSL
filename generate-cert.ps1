# =============================================================================
# ONE-WAY SSL CERTIFICATE GENERATION SCRIPT
# =============================================================================
# This script generates a self-signed SSL certificate for testing one-way SSL.
#
# WHAT IS ONE-WAY SSL?
# --------------------
# In one-way SSL (also called "server authentication"), only the server presents
# a certificate to prove its identity. The client (browser) validates the server's
# certificate but does NOT present its own certificate.
#
# Flow: Client --> validates --> Server Certificate
#       Client <-- encrypted connection established --> Server
#
# This is the most common form of SSL/TLS used on the internet (e.g., HTTPS).
#
# THE SSL/TLS HANDSHAKE PROCESS (One-Way):
# ----------------------------------------
# 1. CLIENT HELLO: Client sends supported TLS versions & cipher suites
# 2. SERVER HELLO: Server selects TLS version & cipher suite
# 3. CERTIFICATE: Server sends its SSL certificate to the client
# 4. CLIENT VALIDATES: Client verifies the certificate:
#    - Is it expired?
#    - Is it issued by a trusted CA?
#    - Does the domain match?
# 5. KEY EXCHANGE: Client generates a pre-master secret, encrypts it with
#    server's public key (from certificate), and sends it
# 6. SESSION KEYS: Both derive symmetric session keys from the pre-master secret
# 7. FINISHED: Encrypted communication begins
#
# CERTIFICATE TRUST CHAIN:
# ------------------------
# In production, certificates are signed by trusted Certificate Authorities (CAs).
# The chain looks like: Root CA --> Intermediate CA --> Your Certificate
#
# For self-signed certificates (like this demo), there's no chain - we trust
# the certificate directly. Browsers will show a warning because the certificate
# isn't signed by a trusted CA.
# =============================================================================

# Configuration
$CertDir = "$PSScriptRoot\certs"
$KeyFile = "$CertDir\server.key"
$CertFile = "$CertDir\server.crt"
$Days = 365
$KeySize = 2048

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  One-Way SSL Certificate Generator" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Create certs directory if it doesn't exist
if (-not (Test-Path $CertDir)) {
    New-Item -ItemType Directory -Path $CertDir -Force | Out-Null
    Write-Host "[+] Created directory: $CertDir" -ForegroundColor Green
}

# Check if OpenSSL is available
$opensslPath = $null
$possiblePaths = @(
    "openssl",
    "C:\Program Files\Git\usr\bin\openssl.exe",
    "C:\Program Files\OpenSSL-Win64\bin\openssl.exe",
    "C:\Program Files (x86)\OpenSSL-Win32\bin\openssl.exe",
    "C:\OpenSSL-Win64\bin\openssl.exe",
    "C:\OpenSSL-Win32\bin\openssl.exe"
)

foreach ($path in $possiblePaths) {
    try {
        $null = & $path version 2>$null
        if ($LASTEXITCODE -eq 0) {
            $opensslPath = $path
            break
        }
    }
    catch {
        continue
    }
}

if (-not $opensslPath) {
    Write-Host "[!] OpenSSL not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install OpenSSL for Windows:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Yellow
    Write-Host "  2. Install the 'Win64 OpenSSL' version" -ForegroundColor Yellow
    Write-Host "  3. Add to PATH or install to default location" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "[+] Found OpenSSL: $opensslPath" -ForegroundColor Green

# Generate private key
Write-Host ""
Write-Host "[*] Generating $KeySize-bit RSA private key..." -ForegroundColor Yellow

& $opensslPath genrsa -out $KeyFile $KeySize 2>$null

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $KeyFile)) {
    Write-Host "[!] Failed to generate private key!" -ForegroundColor Red
    exit 1
}

Write-Host "[+] Private key created: $KeyFile" -ForegroundColor Green

# Generate self-signed certificate
Write-Host ""
Write-Host "[*] Generating self-signed certificate (valid for $Days days)..." -ForegroundColor Yellow

$Subject = "/C=US/ST=Demo/L=Demo/O=SSL-Demo/OU=Testing/CN=localhost"

& $opensslPath req -new -x509 `
    -key $KeyFile `
    -out $CertFile `
    -days $Days `
    -subj $Subject `
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" 2>$null

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $CertFile)) {
    # Try without -addext for older OpenSSL versions
    Write-Host "[*] Retrying with older OpenSSL syntax..." -ForegroundColor Yellow
    & $opensslPath req -new -x509 `
        -key $KeyFile `
        -out $CertFile `
        -days $Days `
        -subj $Subject 2>$null
}

if (-not (Test-Path $CertFile)) {
    Write-Host "[!] Failed to generate certificate!" -ForegroundColor Red
    exit 1
}

Write-Host "[+] Certificate created: $CertFile" -ForegroundColor Green

# Display certificate info
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Certificate Information" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
& $opensslPath x509 -in $CertFile -noout -subject -dates -issuer

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  SUCCESS! Certificates generated." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files created:" -ForegroundColor White
Write-Host "  - Private Key: $KeyFile" -ForegroundColor White
Write-Host "  - Certificate: $CertFile" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Configure Nginx to use these certificates" -ForegroundColor Yellow
Write-Host "  2. Start Nginx server" -ForegroundColor Yellow
Write-Host "  3. Access https://localhost in your browser" -ForegroundColor Yellow
Write-Host ""
