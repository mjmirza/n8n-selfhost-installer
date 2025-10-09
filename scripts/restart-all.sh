#!/bin/bash

echo "🔄 Starting complete system restart..."
echo ""

# Navigate to correct directory
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
    docker run -d \
      --name watchtower \
      --restart unless-stopped \
      -v /var/run/docker.sock:/var/run/docker.sock \
      containrrr/watchtower \
      --cleanup \
      --schedule "0 0 4 * * MON" \
      n8n-docker-caddy-n8n-1 n8n-docker-caddy-caddy-1
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

# Quick status check
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

# Show all running containers
echo "📦 Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✨ Restart complete!"
echo ""

# Get domain info
if [ -f .env ]; then
    source .env
    echo "Access n8n at:"
    echo "  Local: http://$(curl -s ifconfig.me):5678"
    echo "  HTTPS: https://${SUBDOMAIN}.${DOMAIN_NAME}"
fi

echo ""
echo "For detailed status, run: ./check-status.sh"
