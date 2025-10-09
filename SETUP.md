# 📖 Manual Setup Guide

Step-by-step guide for manually setting up N8N on your server.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Step 1: Connect to Server](#step-1-connect-to-server)
- [Step 2: Install Dependencies](#step-2-install-dependencies)
- [Step 3: Clone Repository](#step-3-clone-repository)
- [Step 4: Configure Environment](#step-4-configure-environment)
- [Step 5: Configure Caddyfile](#step-5-configure-caddyfile)
- [Step 6: Setup Firewall](#step-6-setup-firewall)
- [Step 7: Start Services](#step-7-start-services)
- [Step 8: Setup Watchtower](#step-8-setup-watchtower)
- [Step 9: Create Utility Scripts](#step-9-create-utility-scripts)
- [Step 10: Configure DNS](#step-10-configure-dns)
- [Step 11: Access N8N](#step-11-access-n8n)

## ✅ Prerequisites

Before starting, ensure you have:

- ✅ Ubuntu 22.04 or 24.04 server
- ✅ Root or sudo access
- ✅ Domain name with DNS access
- ✅ Server with at least 2 vCPU and 4GB RAM

## Step 1: Connect to Server

```bash
ssh root@YOUR_SERVER_IP
```

## Step 2: Install Dependencies

### Update System

```bash
apt update && apt upgrade -y
```

### Install Docker

```bash
# Install Docker
apt install -y docker.io

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Verify installation
docker --version
```

### Install Docker Compose V2

```bash
# Create plugin directory
mkdir -p /usr/local/lib/docker/cli-plugins

# Download Docker Compose
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

# Make executable
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verify installation
docker compose version
```

### Install Additional Tools

```bash
apt install -y git curl ufw
```

## Step 3: Clone Repository

```bash
# Clone official n8n-docker-caddy repository
cd /root
git clone https://github.com/n8n-io/n8n-docker-caddy.git
cd n8n-docker-caddy
```

## Step 4: Configure Environment

Create the `.env` file:

```bash
cat > .env << 'EOF'
# Domain configuration
DOMAIN_NAME=yourdomain.com
SUBDOMAIN=n8n

# SSL Email for Let's Encrypt
SSL_EMAIL=admin@yourdomain.com

# Timezone (UTC, Europe/Berlin, America/New_York, etc.)
GENERIC_TIMEZONE=UTC

# Data storage path
DATA_FOLDER=/root/n8n-docker-caddy
EOF
```

**Edit the values**:
```bash
nano .env
```

Replace:
- `yourdomain.com` with your actual domain
- `n8n` with your chosen subdomain
- `admin@yourdomain.com` with your email

## Step 5: Configure Caddyfile

Create/update the Caddyfile:

```bash
cat > Caddyfile << 'EOF'
{$SUBDOMAIN}.{$DOMAIN_NAME} {
    reverse_proxy n8n:5678 {
        flush_interval -1
    }

    encode gzip

    tls {$SSL_EMAIL}

    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
}
EOF
```

## Step 6: Setup Firewall

```bash
# Allow SSH (important - don't lock yourself out!)
ufw allow 22/tcp

# Allow HTTP (for Let's Encrypt verification)
ufw allow 80/tcp

# Allow HTTPS
ufw allow 443/tcp

# Enable firewall
ufw --force enable

# Verify firewall status
ufw status
```

## Step 7: Start Services

```bash
cd /root/n8n-docker-caddy

# Start services
docker compose up -d

# Verify containers are running
docker compose ps

# Check logs
docker compose logs -f
```

You should see:
- `n8n-docker-caddy-n8n-1` - Running
- `n8n-docker-caddy-caddy-1` - Running

Press `Ctrl+C` to exit logs.

## Step 8: Setup Watchtower

Watchtower automatically updates your containers.

```bash
cat > setup-watchtower.sh << 'EOF'
#!/bin/bash
echo "🔧 Setting up Watchtower for automatic n8n updates..."

# Check if watchtower is already running
if docker ps | grep -q watchtower; then
    echo "⚠️  Watchtower is already running. Removing old instance..."
    docker stop watchtower
    docker rm watchtower
fi

# Run Watchtower
echo "🚀 Starting Watchtower..."
docker run -d \
  --name watchtower \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --cleanup \
  --schedule "0 0 4 * * MON" \
  n8n-docker-caddy-n8n-1 n8n-docker-caddy-caddy-1

# Verify Watchtower is running
if docker ps | grep -q watchtower; then
    echo "✅ Watchtower installed successfully!"
    echo "📅 Will check for updates: Every Monday at 4:00 AM UTC"
    echo ""
    echo "📝 Useful commands:"
    echo "   Check logs:        docker logs watchtower"
    echo "   Force update now:  docker exec watchtower sh -c 'kill 1'"
    echo "   Stop watchtower:   docker stop watchtower"
    echo "   Remove watchtower: docker rm watchtower"
else
    echo "❌ Failed to start Watchtower"
    docker logs watchtower
fi
EOF

chmod +x setup-watchtower.sh
./setup-watchtower.sh
```

## Step 9: Create Utility Scripts

### check-status.sh

```bash
cat > check-status.sh << 'EOF'
#!/bin/bash

echo "========================================="
echo "     N8N SYSTEM STATUS CHECK"
echo "========================================="
echo ""

# Check n8n container
echo "=== n8n Status ==="
if docker ps | grep -q n8n-docker-caddy-n8n-1; then
    VERSION=$(docker exec n8n-docker-caddy-n8n-1 n8n --version 2>/dev/null)
    echo "✅ n8n is RUNNING"
    echo "📌 Version: $VERSION"
    echo "🌐 Local: http://$(curl -s ifconfig.me):5678"
    echo "🔒 HTTPS: https://${SUBDOMAIN:-n8n}.${DOMAIN_NAME:-yourdomain.com}"
else
    echo "❌ n8n is NOT running"
    echo "Fix: docker compose up -d"
fi
echo ""

# Check Caddy status
echo "=== Caddy Status ==="
if docker ps | grep -q n8n-docker-caddy-caddy-1; then
    echo "✅ Caddy is RUNNING"
    CERT_STATUS=$(docker exec n8n-docker-caddy-caddy-1 ls /data/caddy/certificates 2>/dev/null | wc -l)
    if [ "$CERT_STATUS" -gt "0" ]; then
        echo "🔐 SSL certificates: Active"
    else
        echo "⏳ SSL certificates: Waiting for DNS"
    fi
else
    echo "❌ Caddy is NOT running"
    echo "Fix: docker compose up -d"
fi
echo ""

# Check Watchtower status
echo "=== Watchtower Status ==="
if docker ps | grep -q watchtower; then
    echo "✅ Watchtower is RUNNING"
    echo "🔄 Schedule: Every Monday at 4:00 AM UTC"
else
    echo "❌ Watchtower is NOT running"
    echo "Fix: ./setup-watchtower.sh"
fi
echo ""

# Check DNS status
source .env 2>/dev/null
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN_NAME}"
echo "=== DNS Status ==="
DNS_IP=$(nslookup $FULL_DOMAIN 8.8.8.8 2>/dev/null | grep -A1 "Name:" | grep "Address:" | tail -1 | awk '{print $2}')
SERVER_IP=$(curl -s ifconfig.me)
if [ "$DNS_IP" = "$SERVER_IP" ]; then
    echo "✅ DNS is correctly configured"
    echo "🌐 $FULL_DOMAIN → $DNS_IP"
else
    echo "⚠️  DNS not configured or propagating"
    echo "Expected: $FULL_DOMAIN → $SERVER_IP"
    echo "Current: $FULL_DOMAIN → ${DNS_IP:-Not resolved}"
fi
echo ""

# Check Firewall status
echo "=== Firewall Status ==="
if ufw status | grep -q "Status: active"; then
    echo "✅ Firewall is ACTIVE"
    echo "🛡️  Protected ports configuration:"
    ufw status numbered | grep -E "80|443|22" | head -3
else
    echo "⚠️  Firewall is not active"
    echo "Fix: ufw --force enable"
fi
echo ""

# Check disk usage
echo "=== Disk Usage ==="
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo "✅ Disk usage: ${DISK_USAGE}%"
else
    echo "⚠️  High disk usage: ${DISK_USAGE}%"
    echo "Consider cleaning: docker system prune -a"
fi
df -h / | grep -v "Filesystem"
echo ""

# Check memory usage
echo "=== Memory Usage ==="
free -h | grep -E "Mem:|Swap:"
echo ""

# Container resource usage
echo "=== Container Resources ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Status}}" | grep -E "NAME|n8n|caddy|watchtower"
echo ""

echo "========================================="
echo "     QUICK DIAGNOSTICS COMPLETE"
echo "========================================="
EOF

chmod +x check-status.sh
```

### restart-all.sh

```bash
cat > restart-all.sh << 'EOF'
#!/bin/bash

echo "🔄 Starting complete system restart..."
echo ""

cd /root/n8n-docker-caddy

# Stop all services
echo "⏹️  Stopping all services..."
docker compose down
docker stop watchtower 2>/dev/null

echo ""
echo "⏸️  Waiting for services to stop..."
sleep 3

# Start all services
echo "▶️  Starting n8n and Caddy..."
docker compose up -d

echo ""
echo "▶️  Starting Watchtower..."
docker start watchtower 2>/dev/null || {
    echo "Watchtower not found, setting up..."
    ./setup-watchtower.sh
}

echo ""
echo "⏳ Waiting for services to stabilize..."
sleep 5

# Check status
echo ""
echo "========================================="
echo "     SERVICE STATUS AFTER RESTART"
echo "========================================="
echo ""

if docker ps | grep -q n8n-docker-caddy-n8n-1; then
    echo "✅ n8n is RUNNING"
else
    echo "❌ n8n FAILED to start"
fi

if docker ps | grep -q n8n-docker-caddy-caddy-1; then
    echo "✅ Caddy is RUNNING"
else
    echo "❌ Caddy FAILED to start"
fi

if docker ps | grep -q watchtower; then
    echo "✅ Watchtower is RUNNING"
else
    echo "❌ Watchtower FAILED to start"
fi

echo ""
echo "========================================="
echo ""
echo "📦 Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✨ Restart complete!"
echo ""
echo "For detailed status, run: ./check-status.sh"
EOF

chmod +x restart-all.sh
```

### update-n8n.sh

```bash
cat > update-n8n.sh << 'EOF'
#!/bin/bash
echo "🔄 Starting n8n update process..."
cd /root/n8n-docker-caddy

# Create backup
echo "📦 Creating backup..."
mkdir -p /root/backups
tar -czf /root/backups/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz .

# Pull latest images
echo "⬇️ Pulling latest images..."
docker compose pull

# Restart containers
echo "🔄 Restarting containers..."
docker compose down
docker compose up -d

# Wait for services to start
sleep 10

# Verify n8n is running
if docker ps | grep -q n8n-docker-caddy-n8n-1; then
    echo "✅ Update successful!"
    docker exec n8n-docker-caddy-n8n-1 n8n --version
else
    echo "❌ Error - check logs:"
    docker compose logs n8n
fi

# Clean old images
docker image prune -f
echo "🎉 Update complete!"
EOF

chmod +x update-n8n.sh
```

### backup.sh

```bash
cat > backup.sh << 'EOF'
#!/bin/bash

echo "📦 Creating N8N backup..."

# Create backup directory
mkdir -p /root/backups

# Create backup filename with timestamp
BACKUP_FILE="/root/backups/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

# Create backup
cd /root/n8n-docker-caddy
tar -czf "$BACKUP_FILE" \
    --exclude='caddy_data' \
    --exclude='caddy_config' \
    .

# Check if backup was successful
if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✅ Backup created successfully!"
    echo "📁 Location: $BACKUP_FILE"
    echo "📊 Size: $SIZE"
    echo ""
    echo "To restore this backup:"
    echo "  1. Extract: tar -xzf $BACKUP_FILE"
    echo "  2. Restart: docker compose down && docker compose up -d"
else
    echo "❌ Backup failed!"
    exit 1
fi

# List recent backups
echo ""
echo "Recent backups:"
ls -lh /root/backups/ | tail -5
EOF

chmod +x backup.sh
```

## Step 10: Configure DNS

### Get Your Server IP

```bash
curl ifconfig.me
```

### Add DNS Record

Go to your DNS provider and add:

- **Type**: A
- **Name**: your-subdomain (from .env file)
- **Value**: YOUR_SERVER_IP
- **TTL**: 300 (5 minutes)

### Verify DNS

Wait 5-10 minutes, then check:

```bash
source .env
nslookup ${SUBDOMAIN}.${DOMAIN_NAME} 8.8.8.8
```

## Step 11: Access N8N

### Check Status

```bash
cd /root/n8n-docker-caddy
./check-status.sh
```

### Monitor SSL Certificate Generation

```bash
docker compose logs -f caddy | grep certificate
```

Wait for: `certificate obtained successfully`

### Access N8N

1. **Visit**: `https://your-subdomain.your-domain.com`
2. **Create Owner Account**:
   - Email
   - Password
   - Name (optional)
3. **Start Creating Workflows!**

## ✅ Verification Checklist

- [ ] Docker installed and running
- [ ] Docker Compose installed
- [ ] n8n-docker-caddy cloned
- [ ] .env file configured
- [ ] Caddyfile configured
- [ ] Firewall enabled (ports 22, 80, 443)
- [ ] Containers running (docker compose ps)
- [ ] Watchtower running
- [ ] Utility scripts created and executable
- [ ] DNS record added
- [ ] DNS propagated
- [ ] SSL certificate obtained
- [ ] N8N accessible via HTTPS
- [ ] Owner account created

## 🔧 Post-Installation

### Run First Backup

```bash
cd /root/n8n-docker-caddy
./backup.sh
```

### Setup Automated Backups (Optional)

```bash
crontab -e
# Add this line for weekly backups:
0 2 * * 0 /root/n8n-docker-caddy/backup.sh
```

### Enable 2FA in N8N

1. Login to N8N
2. Go to Settings → Personal
3. Enable Two-Factor Authentication

## 🆘 Troubleshooting

### Containers Not Starting

```bash
docker compose logs
```

### SSL Certificate Issues

```bash
# Check Caddy logs
docker compose logs caddy

# Verify DNS
nslookup your-subdomain.your-domain.com 8.8.8.8

# Restart Caddy
docker compose restart caddy
```

### Can't Access N8N

```bash
# Check firewall
ufw status

# Check if port 443 is open
ufw allow 443/tcp

# Check containers
docker compose ps
```

### Out of Disk Space

```bash
# Clean Docker
docker system prune -a --volumes

# Check disk usage
df -h
```

## 📚 Next Steps

- Read [README.md](README.md) for usage guide
- Check [docs/HETZNER-GUIDE.md](docs/HETZNER-GUIDE.md) for Hetzner-specific tips
- Join [N8N Community](https://community.n8n.io/)

---

**Need help?** Open an issue on [GitHub](https://github.com/YOUR_USERNAME/n8n-rapid-deploy/issues)
