# 🔥 Supabase Standalone Deployment

## Overview

Complete self-hosted **Supabase** deployment - open-source Firebase alternative with:
- ✅ PostgreSQL database with **pgvector** for AI/RAG
- ✅ Auto-generated REST API (PostgREST)
- ✅ Authentication (email, OAuth, magic links)
- ✅ Real-time subscriptions (WebSocket)
- ✅ File storage (S3-compatible)
- ✅ Admin dashboard (Supabase Studio)
- ✅ Kong API Gateway

---

## Services Included

| Service | Port | Description |
|---------|------|-------------|
| **Supabase Studio** | 8000 | Admin dashboard |
| **Kong Gateway** | 8001 | API gateway (HTTP) |
| **PostgreSQL** | 5433 | Database (PostgreSQL 15 + pgvector) |
| **REST API** | - | Auto-generated via PostgREST |
| **Auth API** | - | GoTrue authentication |
| **Realtime** | - | WebSocket subscriptions |
| **Storage** | - | Object storage |

---

## Quick Start

### 1. Configure Environment Variables

Edit `.env` file with your settings:

```bash
# Domain
DOMAIN_NAME=example.com
ORGANIZATION_NAME="My Company"
PROJECT_NAME="Production"

# Database password
SUPABASE_DB_PASSWORD="your-secure-password-here"

# JWT Secret (generate with: openssl rand -base64 32)
JWT_SECRET="your-jwt-secret-here"

# API Keys (generate with: openssl rand -base64 32)
SUPABASE_ANON_KEY="your-anon-key-here"
SUPABASE_SERVICE_KEY="your-service-key-here"

# Secret key base (generate with: openssl rand -base64 64)
SECRET_KEY_BASE="your-secret-key-base-here"

# Email (SMTP) - Optional
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
ADMIN_EMAIL=admin@example.com
```

### 2. Start Supabase

```bash
# Create external volumes (if not exists)
docker volume create supabase_db_data
docker volume create supabase_storage_data

# Start all services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### 3. Access Supabase

- **Dashboard**: http://localhost:8000
- **API Endpoint**: http://localhost:8001

---

## API Endpoints

All APIs are available through Kong Gateway at `http://localhost:8001`:

```bash
# REST API (database queries)
http://localhost:8001/rest/v1/

# Authentication
http://localhost:8001/auth/v1/

# Realtime (WebSocket)
ws://localhost:8001/realtime/v1/

# Storage
http://localhost:8001/storage/v1/
```

---

## Usage Examples

### REST API

```bash
# List tables
curl http://localhost:8001/rest/v1/ \
  -H "apikey: YOUR_ANON_KEY"

# Query documents table
curl http://localhost:8001/rest/v1/documents \
  -H "apikey: YOUR_ANON_KEY"

# Insert document
curl -X POST http://localhost:8001/rest/v1/documents \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello world", "metadata": {"source": "api"}}'
```

### Authentication

```bash
# Sign up new user
curl -X POST http://localhost:8001/auth/v1/signup \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "secure-password"}'

# Sign in
curl -X POST http://localhost:8001/auth/v1/token?grant_type=password \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "secure-password"}'
```

### Vector Search (AI/RAG)

```javascript
// Using Supabase JS client
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'http://localhost:8001',
  'YOUR_ANON_KEY'
)

// Insert document with embedding
const { data, error } = await supabase
  .from('documents')
  .insert({
    content: 'AI and machine learning are transforming industries',
    embedding: [0.1, 0.2, 0.3, ...],  // 1536-dimensional vector
    metadata: { category: 'AI' }
  })

// Vector similarity search
const { data, error } = await supabase
  .rpc('match_documents', {
    query_embedding: [0.1, 0.2, 0.3, ...],
    match_threshold: 0.8,
    match_count: 10
  })
```

---

## Integration with N8N

### N8N HTTP Request Node

```json
{
  "method": "POST",
  "url": "http://supabase-kong:8000/rest/v1/documents",
  "authentication": "genericCredentialType",
  "headers": {
    "apikey": "={{ $credentials.supabaseKey }}",
    "Content-Type": "application/json"
  },
  "body": {
    "content": "={{ $json.text }}",
    "metadata": {
      "source": "n8n-workflow"
    }
  }
}
```

---

## Security Configuration

### Generate Secrets

```bash
# JWT Secret
openssl rand -base64 32

# API Keys
openssl rand -base64 32

# Secret Key Base
openssl rand -base64 64
```

### Enable HTTPS

Update `kong.yml` to force HTTPS:

```yaml
# Add to global plugins
- name: request-termination
  config:
    status_code: 426
    message: "Please use HTTPS"
```

---

## Production Checklist

- [ ] Change default passwords
- [ ] Generate secure JWT secret
- [ ] Generate unique API keys
- [ ] Configure SMTP for emails
- [ ] Enable SSL/TLS (via Caddy reverse proxy)
- [ ] Set up backups for PostgreSQL
- [ ] Configure rate limiting in Kong
- [ ] Enable OAuth providers (Google, GitHub, etc.)
- [ ] Set up monitoring and alerts
- [ ] Review security settings

---

## Backup & Restore

### Backup Database

```bash
# Backup all databases
docker exec supabase-db pg_dumpall -U postgres > supabase-backup.sql

# Backup specific database
docker exec supabase-db pg_dump -U postgres postgres > supabase-db-backup.sql
```

### Restore Database

```bash
# Restore
docker exec -i supabase-db psql -U postgres < supabase-backup.sql
```

---

## Troubleshooting

### Check service health

```bash
docker compose ps
docker compose logs supabase-db
docker compose logs supabase-kong
```

### Reset database

```bash
docker compose down -v
docker volume rm supabase_db_data
docker compose up -d
```

### Test API connectivity

```bash
# Health check
curl http://localhost:8001/rest/v1/

# Check Kong routes
curl http://localhost:8001
```

---

## Resources

- **Supabase Docs**: https://supabase.com/docs
- **PostgREST Docs**: https://postgrest.org/
- **Kong Gateway Docs**: https://docs.konghq.com/
- **pgvector Docs**: https://github.com/pgvector/pgvector

---

*Powered by NEXT8N - Professional N8N Deployment*
*🌐 https://services.next8n.com/*
