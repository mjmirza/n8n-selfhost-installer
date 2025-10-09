# 🔧 Troubleshooting Guide

Common issues and solutions for N8N Rapid Deploy.

## 📋 Table of Contents

- [Installation Issues](#installation-issues)
- [Docker Issues](#docker-issues)
- [SSL Certificate Issues](#ssl-certificate-issues)
- [DNS Issues](#dns-issues)
- [Network & Firewall Issues](#network--firewall-issues)
- [Performance Issues](#performance-issues)
- [Container Issues](#container-issues)
- [Update Issues](#update-issues)

## Installation Issues

### "Permission denied" when running installer

**Problem**: Cannot execute install.sh

**Solution**:
```bash
# Add execute permission
chmod +x install.sh

# Run with sudo
sudo bash install.sh
```

### Installer fails with "command not found"

**Problem**: Missing system dependencies

**Solution**:
```bash
# Update package list
apt update

# Install required packages
apt install -y curl wget git
```

### "Not running as root" error

**Problem**: Installer requires root privileges

**Solution**:
```bash
# Use sudo
sudo bash install.sh

# Or switch to root
sudo su
bash install.sh
```

## Docker Issues

### Docker not starting

**Problem**: Docker service is not running

**Solution**:
```bash
# Check Docker status
systemctl status docker

# Start Docker
systemctl start docker

# Enable Docker to start on boot
systemctl enable docker

# Verify Docker is running
docker --version
docker ps
```

### "Cannot connect to Docker daemon"

**Problem**: Docker socket permission issues

**Solution**:
```bash
# Add current user to docker group
usermod -aG docker $USER

# Restart Docker
systemctl restart docker

# Reboot if issue persists
reboot
```

### Docker Compose version issues

**Problem**: Old docker-compose syntax not working

**Solution**:
```bash
# Remove old docker-compose
apt remove docker-compose

# Install Docker Compose V2 plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verify
docker compose version
```

## SSL Certificate Issues

### "SSL certificate not generated"

**Problem**: Caddy cannot obtain Let's Encrypt certificate

**Check**:
```bash
# View Caddy logs
cd /root/n8n-docker-caddy
docker compose logs caddy | grep certificate
```

**Common Causes**:

1. **DNS not propagated**:
   ```bash
   # Check DNS
   nslookup your-subdomain.your-domain.com 8.8.8.8

   # Wait 5-30 minutes for propagation
   ```

2. **Port 80 blocked**:
   ```bash
   # Check firewall
   ufw status

   # Allow port 80
   ufw allow 80/tcp
   ```

3. **Domain already has certificate elsewhere**:
   ```bash
   # Wait 1 hour for Let's Encrypt rate limit reset
   # Or use different subdomain
   ```

### "Certificate validation failed"

**Problem**: Let's Encrypt cannot verify domain ownership

**Solution**:
```bash
# Verify domain points to your server
curl ifconfig.me
nslookup your-subdomain.your-domain.com

# IPs should match

# Check if port 80 is accessible from internet
curl -I http://your-subdomain.your-domain.com

# Restart Caddy
docker compose restart caddy
```

### "Too many certificates for exact set of domains"

**Problem**: Let's Encrypt rate limit hit

**Solution**:
```bash
# Use different subdomain
# Or wait 1 week for rate limit reset
# Or use staging environment temporarily (not recommended for production)
```

## DNS Issues

### DNS not resolving

**Problem**: Domain doesn't resolve to server IP

**Check**:
```bash
# Get your server IP
curl ifconfig.me

# Check DNS from different servers
nslookup your-subdomain.your-domain.com 8.8.8.8
nslookup your-subdomain.your-domain.com 1.1.1.1

# Check from external tool
# https://dnschecker.org
```

**Solution**:
```bash
# Verify DNS record is correct in your provider
# Type: A
# Name: your-subdomain
# Value: YOUR_SERVER_IP
# TTL: 300

# Wait 5-30 minutes
# Cloudflare DNS propagates in 2-5 minutes
# Other providers may take 15-30 minutes
```

### DNS points to wrong IP

**Problem**: Old IP cached or wrong A record

**Solution**:
```bash
# Clear local DNS cache (on your computer)
# macOS:
sudo dscacheutil -flushcache

# Windows:
ipconfig /flushdns

# Linux:
sudo systemd-resolve --flush-caches

# Update A record in DNS provider
# Wait for TTL to expire (usually 5 minutes)
```

### IPv6 vs IPv4 issues

**Problem**: Server has IPv6 but DNS uses IPv4

**Solution**:
```bash
# Check both IPs
curl -4 ifconfig.me  # IPv4
curl -6 ifconfig.me  # IPv6

# Add both records in DNS:
# A record: your-subdomain → IPv4 address
# AAAA record: your-subdomain → IPv6 address
```

## Network & Firewall Issues

### Cannot access N8N from browser

**Problem**: Firewall blocking connections

**Check**:
```bash
# Check firewall status
ufw status

# Check if ports are open
netstat -tuln | grep -E '80|443'
```

**Solution**:
```bash
# Open required ports
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# Verify
ufw status numbered
```

### Port 80 or 443 already in use

**Problem**: Another service using the port

**Check**:
```bash
# Find what's using the port
netstat -tuln | grep :80
netstat -tuln | grep :443
lsof -i :80
lsof -i :443
```

**Solution**:
```bash
# Stop conflicting service (e.g., Apache)
systemctl stop apache2
systemctl disable apache2

# Or remove it
apt remove apache2

# Restart N8N
cd /root/n8n-docker-caddy
docker compose restart
```

### SSH connection lost after enabling firewall

**Problem**: Firewall blocked SSH port

**Solution**:
```bash
# From Hetzner console (web-based terminal):
ufw allow 22/tcp
ufw enable

# If you changed SSH port:
ufw allow YOUR_SSH_PORT/tcp
```

## Performance Issues

### N8N running slow

**Problem**: Insufficient resources

**Check**:
```bash
# Check CPU and memory usage
htop

# Check container resource usage
docker stats

# Check disk space
df -h
```

**Solution**:

1. **Upgrade server** (if consistently high usage):
   ```bash
   # Shutdown N8N
   cd /root/n8n-docker-caddy
   docker compose down

   # In Hetzner console:
   # - Create snapshot
   # - Resize server to larger plan
   # - Start server
   # - Start N8N
   docker compose up -d
   ```

2. **Clean up Docker**:
   ```bash
   # Remove unused images, containers, volumes
   docker system prune -a --volumes

   # This frees up disk space
   ```

3. **Optimize N8N** (use PostgreSQL instead of SQLite):
   - See N8N documentation for database migration

### High disk usage

**Problem**: Running out of disk space

**Check**:
```bash
# Check disk usage
df -h

# Find large directories
du -sh /root/* | sort -h
du -sh /var/lib/docker/* | sort -h
```

**Solution**:
```bash
# Clean Docker
docker system prune -a --volumes

# Remove old backups
rm /root/backups/old-backup-*.tar.gz

# Check if Docker volumes are too large
docker volume ls
docker volume prune
```

## Container Issues

### Container not starting

**Problem**: Container fails to start

**Check**:
```bash
cd /root/n8n-docker-caddy

# Check container status
docker compose ps

# View logs
docker compose logs n8n
docker compose logs caddy
```

**Common issues**:

1. **Port conflict**:
   ```bash
   # Check what's using port 5678
   lsof -i :5678

   # Stop conflicting process
   kill <PID>
   ```

2. **Configuration error**:
   ```bash
   # Check .env file
   cat .env

   # Verify Caddyfile
   cat Caddyfile

   # Restart with fresh config
   docker compose down
   docker compose up -d
   ```

3. **Volume permission issues**:
   ```bash
   # Fix permissions
   chown -R root:root /root/n8n-docker-caddy
   chmod -R 755 /root/n8n-docker-caddy
   ```

### Container keeps restarting

**Problem**: Container in restart loop

**Check**:
```bash
# View container logs
docker logs n8n-docker-caddy-n8n-1 --tail 50

# Check exit code
docker inspect n8n-docker-caddy-n8n-1 | grep -A 5 State
```

**Solution**:
```bash
# Stop container
docker compose down

# Remove volumes (WARNING: this deletes data)
docker volume prune

# Start fresh
docker compose up -d
```

## Update Issues

### Update fails

**Problem**: Cannot update N8N

**Solution**:
```bash
cd /root/n8n-docker-caddy

# Create backup first
./backup.sh

# Force pull latest images
docker compose pull --ignore-pull-failures

# Recreate containers
docker compose down
docker compose up -d --force-recreate

# Check logs
docker compose logs -f
```

### Workflows not working after update

**Problem**: Breaking changes in N8N update

**Solution**:
```bash
# Rollback to previous version
cd /root/n8n-docker-caddy

# Stop current version
docker compose down

# Use specific version
# Edit docker-compose.yml, change:
# image: n8nio/n8n:latest
# to:
# image: n8nio/n8n:1.x.x  # Use previous version

# Start
docker compose up -d

# Or restore from backup
cd /root/backups
tar -xzf n8n-backup-YYYYMMDD-HHMMSS.tar.gz -C /root/n8n-docker-caddy
cd /root/n8n-docker-caddy
docker compose up -d
```

## Getting Help

If you can't solve the issue:

1. **Check Logs**:
   ```bash
   cd /root/n8n-docker-caddy
   docker compose logs -f
   ```

2. **Run Status Check**:
   ```bash
   ./check-status.sh
   ```

3. **Open GitHub Issue**:
   - Go to: https://github.com/YOUR_USERNAME/n8n-rapid-deploy/issues
   - Include:
     - Error message
     - Output of `./check-status.sh`
     - Relevant logs
     - Server specs

4. **N8N Community**:
   - Forum: https://community.n8n.io/
   - Discord: https://discord.gg/n8n

## Quick Diagnostic Commands

```bash
# Full system check
cd /root/n8n-docker-caddy
./check-status.sh

# Check Docker
docker --version
docker compose version
docker ps
docker compose ps

# Check services
systemctl status docker
ufw status

# Check network
curl ifconfig.me
nslookup your-subdomain.your-domain.com

# Check logs
docker compose logs -f n8n
docker compose logs -f caddy

# Check resources
htop
df -h
docker stats
```

---

Still having issues? [Open an issue](https://github.com/YOUR_USERNAME/n8n-rapid-deploy/issues) on GitHub.
