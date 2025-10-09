#!/bin/bash
set -e

###############################################################################
# Supabase Database Initialization Script
# Creates required roles, schemas, and extensions
###############################################################################

echo "🔧 Initializing Supabase database..."

# Create roles
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create service roles
    CREATE ROLE anon NOLOGIN NOINHERIT;
    CREATE ROLE authenticated NOLOGIN NOINHERIT;
    CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;

    -- Create admin roles
    CREATE ROLE supabase_admin NOLOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION;
    CREATE ROLE supabase_auth_admin NOLOGIN NOINHERIT CREATEROLE;
    CREATE ROLE supabase_storage_admin NOLOGIN NOINHERIT CREATEROLE;

    -- Create authenticator role (used by PostgREST)
    CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD '$POSTGRES_PASSWORD';
    GRANT anon, authenticated, service_role TO authenticator;

    -- Grant permissions
    GRANT ALL PRIVILEGES ON DATABASE postgres TO supabase_admin;
    GRANT ALL PRIVILEGES ON SCHEMA public TO supabase_admin;

    -- Install extensions
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";
    CREATE EXTENSION IF NOT EXISTS "pgjwt";
    CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

    -- Install pgvector for AI/RAG (vector embeddings)
    CREATE EXTENSION IF NOT EXISTS "vector";

    -- Create storage schema
    CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION supabase_admin;
    GRANT USAGE ON SCHEMA storage TO authenticator, anon, authenticated, service_role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON TABLES TO supabase_admin, authenticator;
    ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON SEQUENCES TO supabase_admin, authenticator;
    ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON FUNCTIONS TO supabase_admin, authenticator;

    -- Create auth schema
    CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION supabase_admin;
    GRANT USAGE ON SCHEMA auth TO authenticator, anon, authenticated, service_role;

    -- Create realtime schema
    CREATE SCHEMA IF NOT EXISTS _realtime AUTHORIZATION supabase_admin;
    CREATE SCHEMA IF NOT EXISTS realtime AUTHORIZATION supabase_admin;
    GRANT USAGE ON SCHEMA realtime TO authenticator, anon, authenticated, service_role;

    -- Create example table for vector search (AI/RAG)
    CREATE TABLE IF NOT EXISTS public.documents (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        content TEXT NOT NULL,
        embedding vector(1536),  -- OpenAI embedding size
        metadata JSONB,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Create vector search index
    CREATE INDEX IF NOT EXISTS documents_embedding_idx ON public.documents
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

    -- Grant permissions on public schema
    GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
    GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
    GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;
EOSQL

echo "✅ Supabase database initialized successfully!"
echo "ℹ️  pgvector extension enabled for AI/RAG use cases"
echo "ℹ️  Example 'documents' table created with vector search"
