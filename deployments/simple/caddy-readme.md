# Caddy Configuration Template

This folder contains the Caddy reverse proxy configuration template for N8N.

## Files

### `Caddyfile`
Caddy reverse proxy configuration with automatic HTTPS and security headers.

**Placeholders:**
- `__SUBDOMAIN__` - Subdomain for N8N (e.g., `n8n`, `automation`)
- `__DOMAIN_NAME__` - Base domain (e.g., `example.com`)
- `__SSL_EMAIL__` - Email for Let's Encrypt SSL certificates

## Features

- ✅ Automatic HTTPS with Let's Encrypt
- ✅ Security headers (HSTS, X-Frame-Options, etc.)
- ✅ Gzip compression
- ✅ Reverse proxy to N8N container

## How It Works

During installation:
1. `install.sh` copies this Caddyfile to `/root/n8n/caddy_config/Caddyfile`
2. Placeholders are replaced with actual values using `sed`
3. Caddy container mounts this file and uses it for configuration

## Manual Configuration

To configure manually:

```bash
cp caddy/Caddyfile /root/n8n/caddy_config/Caddyfile
cd /root/n8n

sed -i "s|__SUBDOMAIN__|n8n|g" caddy_config/Caddyfile
sed -i "s|__DOMAIN_NAME__|example.com|g" caddy_config/Caddyfile
sed -i "s|__SSL_EMAIL__|admin@example.com|g" caddy_config/Caddyfile
```
