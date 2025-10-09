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

    # Try to get domain from .env
    if [ -f .env ]; then
        source .env
        echo "🔒 HTTPS: https://${SUBDOMAIN}.${DOMAIN_NAME}"
    fi
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
    NEXT_RUN=$(docker logs watchtower 2>&1 | grep 'Scheduling first run' | tail -1 | cut -d':' -f2-)
    if [ ! -z "$NEXT_RUN" ]; then
        echo "📅 Next check:$NEXT_RUN"
    fi
    echo "📦 Monitoring: n8n and Caddy containers"
    echo "🔄 Schedule: Every Monday at 4:00 AM UTC"
else
    echo "❌ Watchtower is NOT running"
    echo "Fix: ./setup-watchtower.sh"
fi
echo ""

# Check DNS status
if [ -f .env ]; then
    source .env
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
fi

# Check Firewall status
echo "=== Firewall Status ==="
if ufw status | grep -q "Status: active"; then
    echo "✅ Firewall is ACTIVE"
    echo "🛡️  Protected ports configuration:"
    ufw status numbered | grep -E "80|443|5678|22" | head -4
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
