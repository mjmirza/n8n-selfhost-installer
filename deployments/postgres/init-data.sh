#!/bin/bash
set -e;

# Create non-root user for N8N
if [ -n "${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
		CREATE USER ${POSTGRES_NON_ROOT_USER} WITH PASSWORD '${POSTGRES_NON_ROOT_PASSWORD}';
		GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_NON_ROOT_USER};
		GRANT ALL ON SCHEMA public TO ${POSTGRES_NON_ROOT_USER};
	EOSQL
	echo "✅ N8N database user created successfully"
else
	echo "⚠️  POSTGRES_NON_ROOT_USER or POSTGRES_NON_ROOT_PASSWORD not set"
fi
