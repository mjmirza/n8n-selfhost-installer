# Docker Configuration Template

This folder contains the Docker Compose configuration template for N8N deployment.

## Files

### `docker-compose.yml`
Docker Compose configuration template with placeholders that are replaced during installation.

**Placeholders:**
- `__DATA_FOLDER__` - Installation directory path (e.g., `/root/n8n`)
- `__SUBDOMAIN__` - Subdomain for N8N (e.g., `n8n` or `automation`)
- `__DOMAIN_NAME__` - Base domain (e.g., `example.com`)
- `__TIMEZONE__` - Timezone setting (e.g., `UTC`, `Europe/Berlin`)

## How It Works

During installation (`install.sh`), this template file is:

1. **Copied** to the installation directory (`/root/n8n/docker-compose.yml`)
2. **Modified** using `sed` to replace placeholders with actual values
3. **Used** by Docker Compose to start the N8N services

## Manual Usage

If deploying manually without the installer:

```bash
# Copy template
cp docker/docker-compose.yml /root/n8n/

# Replace placeholders manually
cd /root/n8n
sed -i "s|__DATA_FOLDER__|/root/n8n|g" docker-compose.yml
sed -i "s|__SUBDOMAIN__|n8n|g" docker-compose.yml
sed -i "s|__DOMAIN_NAME__|example.com|g" docker-compose.yml
sed -i "s|__TIMEZONE__|UTC|g" docker-compose.yml
```

## Benefits of This Approach

1. **No heredoc/EOF** - Cleaner install script
2. **Version control** - Templates are tracked in git
3. **Maintainable** - Easy to update configurations
4. **Testable** - Can validate templates independently
5. **Reusable** - Templates can be used for multiple deployments
