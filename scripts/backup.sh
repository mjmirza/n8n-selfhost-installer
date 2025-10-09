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
