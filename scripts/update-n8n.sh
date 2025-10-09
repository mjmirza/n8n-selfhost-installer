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
