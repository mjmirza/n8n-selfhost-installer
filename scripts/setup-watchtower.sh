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
