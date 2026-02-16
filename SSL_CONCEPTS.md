# Understanding One-Way SSL/TLS

This document explains the core concepts of one-way SSL/TLS for learning purposes.

---

## What is One-Way SSL?

**One-way SSL** (also called **server authentication**) is the standard form of SSL/TLS used across the internet. In this model:

- ✅ **Server presents a certificate** to prove its identity
- ✅ **Client validates the server's certificate**
- ❌ **Client does NOT present a certificate**

```
┌─────────┐                              ┌─────────┐
│ CLIENT  │ ──── "Hello, prove who ────> │ SERVER  │
│(Browser)│       you are!"              │ (Nginx) │
│         │                              │         │
│         │ <──── Here's my certificate  │         │
│         │       (server.crt)           │         │
│         │                              │         │
│ Validates│                              │         │
│ certificate                             │         │
│         │                              │         │
│         │ ════ Encrypted Connection ═══│         │
└─────────┘                              └─────────┘
```

### One-Way vs Two-Way (Mutual) SSL

| Feature | One-Way SSL | Two-Way (Mutual) SSL |
|---------|-------------|----------------------|
| Server Certificate | ✅ Yes | ✅ Yes |
| Client Certificate | ❌ No | ✅ Yes |
| Use Case | Public websites, APIs | Banking, enterprise apps |
| Complexity | Simple | More complex |
| Example | `https://google.com` | Online banking portals |

---

## The SSL/TLS Handshake Process

When you visit `https://localhost`, here's what happens behind the scenes:

### Step 1: Client Hello
```
Browser → Server: "Hi! I support TLS 1.2, TLS 1.3, and these cipher suites..."
```
The browser initiates the connection and advertises its capabilities.

### Step 2: Server Hello
```
Server → Browser: "Great! Let's use TLS 1.3 with AES-256-GCM encryption."
```
The server picks the best protocol version and cipher suite both support.

### Step 3: Certificate Exchange
```
Server → Browser: "Here's my certificate. It proves I am 'localhost'."
```
The server sends its X.509 certificate containing:
- Public key
- Domain name (CN = Common Name)
- Validity period
- Issuer information
- Digital signature

### Step 4: Certificate Validation
```
Browser: "Let me check this certificate..."
  ├── Is it expired? No ✓
  ├── Is the domain correct? localhost ✓
  ├── Is it signed by a trusted CA? No (self-signed) ⚠️
  └── Show warning to user (for self-signed certs)
```

### Step 5: Key Exchange
```
Browser: *generates random pre-master secret*
Browser → Server: *encrypted with server's public key*
```
Using asymmetric encryption, the browser securely sends a random secret.

### Step 6: Session Keys Derivation
```
Both parties: pre-master secret → master secret → session keys
```
Both browser and server derive identical symmetric keys for encryption.

### Step 7: Encrypted Communication
```
Browser ⟷ Server: All data is now encrypted with session keys
```

---

## Certificate Trust Chain

### How Trust Works in Production

```
┌─────────────────────────────────────────────────────────────┐
│                    ROOT CA (Certificate Authority)          │
│              "DigiCert", "Let's Encrypt", "Comodo"          │
│                 (Pre-installed in browsers/OS)               │
└─────────────────────────┬───────────────────────────────────┘
                          │ Signs
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   INTERMEDIATE CA                            │
│            (Also trusted, signed by Root CA)                 │
└─────────────────────────┬───────────────────────────────────┘
                          │ Signs
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   YOUR CERTIFICATE                           │
│              (e.g., server.crt for your domain)              │
└─────────────────────────────────────────────────────────────┘
```

**Chain of Trust:**
1. Browser has a list of **trusted Root CAs** (built into the OS/browser)
2. Root CA signs Intermediate CA certificates
3. Intermediate CA signs your domain's certificate
4. Browser follows the chain: `Your Cert → Intermediate → Root`
5. If Root is trusted, entire chain is trusted ✓

### Self-Signed Certificates (This Demo)

```
┌─────────────────────────────────────────────────────────────┐
│                  SELF-SIGNED CERTIFICATE                     │
│                     (server.crt)                             │
│                                                              │
│          ⚠️ Not signed by any trusted CA                    │
│          ⚠️ Browser shows security warning                   │
│          ✅ Still encrypted (just not trusted)               │
└─────────────────────────────────────────────────────────────┘
```

**Why browsers show warnings:**  
Self-signed certificates have no trusted third party vouching for them. The connection is still encrypted, but the browser can't verify the server is who it claims to be.

**Appropriate uses for self-signed:**
- ✅ Local development
- ✅ Testing environments
- ✅ Internal tools
- ❌ Production public websites

---

## Key Components

### Private Key (`server.key`)
- **Never shared** with anyone
- Used to decrypt data encrypted with the public key
- Used to create digital signatures
- **Keep this file secure!**

### Certificate (`server.crt`)
- **Shared with clients** during handshake
- Contains the public key
- Contains identity information (domain, organization)
- Signed by a CA (or self-signed)

### Certificate Signing Request (CSR)
- Used to request a certificate from a CA
- Contains your public key and identity info
- CA verifies you, then creates and signs the certificate

---

## Security Properties

### Confidentiality ✓
All data transmitted is encrypted. Eavesdroppers cannot read the content.

### Integrity ✓
Any tampering with data in transit is detected.

### Authentication (Server Only) ✓
The server proves its identity to the client.

### Authentication (Client) ✗
In one-way SSL, the client is NOT authenticated via certificate.  
(Usually handled by username/password, tokens, etc.)

---

## Common Commands

```bash
# View certificate details
openssl x509 -in server.crt -noout -text

# View certificate expiration
openssl x509 -in server.crt -noout -dates

# Verify certificate and key match
openssl x509 -noout -modulus -in server.crt | openssl md5
openssl rsa -noout -modulus -in server.key | openssl md5
# (Both should produce the same hash)

# Test SSL connection
openssl s_client -connect localhost:443

# Test with curl (skip certificate validation)
curl -v https://localhost -k
```
