# One-Way SSL/TLS Demo with Nginx on Windows

A complete demonstration of HTTPS (one-way SSL/TLS) using Nginx on Windows.

## Prerequisites

### 1. Install Nginx for Windows

Download and extract Nginx:
- Download from: https://nginx.org/en/download.html (Windows zip)
- Extract to `C:\nginx` (or your preferred location)

### 2. Install OpenSSL for Windows

Download and install OpenSSL:
- Download from: https://slproweb.com/products/Win32OpenSSL.html
- Install "Win64 OpenSSL v3.x" (Light or Full version)
- During installation, select "Copy OpenSSL DLLs to Windows system directory"

Verify installation:
```powershell
openssl version
```

---

## Quick Start

### Step 1: Setup Nginx (First Time Only)

Open PowerShell and run:

```powershell
cd c:\Users\andey\Downloads\hi\ssl-demo
.\setup-nginx.ps1
```

This downloads and extracts Nginx into the `ssl-demo` folder.

### Step 2: Generate SSL Certificate (First Time Only)

```powershell
.\generate-cert.ps1
```

This creates:
- `certs\server.key` - Private key
- `certs\server.crt` - Self-signed certificate

### Step 3: Start the HTTPS Server

```powershell
.\start-server.ps1
```

### Step 4: Test the Connection

**Browser Test:**
1. Open your browser
2. Navigate to: `https://localhost` or `https://127.0.0.1`
3. You'll see a security warning (because it's self-signed)
4. Click "Advanced" → "Proceed to localhost (unsafe)" (Chrome) or similar
5. You should see the "Hello, Secure World!" page
6. Notice the 🔒 lock icon in the address bar (may show warning)

**curl Test:**
```powershell
curl.exe -v https://localhost -k
```

The `-k` flag tells curl to skip certificate verification (needed for self-signed certs).

Expected output includes:
```
* SSL connection using TLSv1.2 / TLS_AES_256_GCM_SHA384
* Server certificate:
*  subject: C=US; ST=Demo; L=Demo; O=SSL-Demo; OU=Testing; CN=localhost
```

---

## Managing Nginx

### Stop Nginx
```powershell
cd C:\nginx
.\nginx.exe -s stop
```

### Reload Configuration (after changes)
```powershell
cd C:\nginx
.\nginx.exe -s reload -c c:\Users\andey\Downloads\hi\ssl-demo\conf\nginx.conf
```

### Check Configuration Syntax
```powershell
cd C:\nginx
.\nginx.exe -t -c c:\Users\andey\Downloads\hi\ssl-demo\conf\nginx.conf
```

### View Logs
```powershell
# Access log
Get-Content c:\Users\andey\Downloads\hi\ssl-demo\logs\access.log

# Error log
Get-Content c:\Users\andey\Downloads\hi\ssl-demo\logs\error.log
```

---

## Project Structure

```
ssl-demo/
├── certs/
│   ├── server.key          # Private key (KEEP SECURE!)
│   └── server.crt          # SSL certificate
├── conf/
│   └── nginx.conf          # Nginx configuration
├── html/
│   └── index.html          # Hello World page
├── logs/                   # Nginx logs
│   ├── access.log
│   └── error.log
├── generate-cert.ps1       # Certificate generator
├── README.md               # This file
└── SSL_CONCEPTS.md         # SSL/TLS learning material
```

---

## Troubleshooting

### "Port 443 already in use"
```powershell
# Find what's using port 443
netstat -ano | findstr :443

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### "Permission denied" errors
- Run PowerShell as Administrator
- Ensure Nginx has access to the certificate files

### "SSL certificate problem" with curl
The `-k` flag is required for self-signed certificates:
```powershell
curl -v https://localhost -k
```

### Browser still shows "Not Secure"
This is expected for self-signed certificates. The connection IS encrypted, but the browser warns because the certificate isn't from a trusted CA.

### Nginx won't start
Check the error log:
```powershell
Get-Content c:\Users\andey\Downloads\hi\ssl-demo\logs\error.log -Tail 20
```

Common issues:
- Missing `logs` directory
- Incorrect certificate paths
- Port 443 already in use

---

## Understanding the SSL Lock Icon

| Icon | Meaning |
|------|---------|
| 🔒 (Green/Gray Lock) | Valid certificate, trusted CA |
| 🔒 (With Warning) | Self-signed or expired certificate |
| ⚠️ (Not Secure) | No HTTPS or certificate error |

For self-signed certificates, browsers show a warning but the connection is still encrypted.

---

## Next Steps

1. **Learn about Let's Encrypt**: Free, automated, trusted certificates
2. **Explore Two-Way SSL (Mutual TLS)**: Client certificates for authentication
3. **Study HSTS**: HTTP Strict Transport Security
4. **Review SSL_CONCEPTS.md**: Deep dive into TLS handshake

---

## Files Reference

- **SSL Concepts Documentation**: [SSL_CONCEPTS.md](SSL_CONCEPTS.md)
- **Certificate Generator**: [generate-cert.ps1](generate-cert.ps1)
- **Nginx Config**: [conf/nginx.conf](conf/nginx.conf)
- **Web Page**: [html/index.html](html/index.html)
