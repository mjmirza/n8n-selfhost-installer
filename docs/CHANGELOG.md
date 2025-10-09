# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-10-09

### Added
- One-command installation script with interactive prompts
- Automatic Docker and Docker Compose V2 installation
- UFW firewall configuration (ports 22, 80, 443)
- Automatic SSL certificate generation via Caddy
- Watchtower auto-updates (Monday 4:00 AM UTC)
- Five utility scripts with automatic chmod +x:
  - `check-status.sh` - System health monitoring
  - `restart-all.sh` - Service restart
  - `update-n8n.sh` - Update to latest version
  - `backup.sh` - Create timestamped backups
  - `setup-watchtower.sh` - Configure auto-updates
- Comprehensive documentation (8 files):
  - Main README with quick start
  - QUICK-START guide for beginners
  - Detailed manual SETUP guide
  - HETZNER-GUIDE with SSH key generation
  - TROUBLESHOOTING guide
  - CONTRIBUTING guidelines
  - Repository structure documentation
- MIT License for open source distribution
- Complete .gitignore for security
- .env.example configuration template

### Features
- Interactive domain name validation
- Subdomain validation with obscurity option
- Email validation for SSL certificates
- Timezone selection (preset options + custom)
- Automatic .env file generation from user inputs
- Automatic Caddyfile creation with security headers:
  - HSTS (HTTP Strict Transport Security)
  - CSP (Content Security Policy)
  - X-Frame-Options
  - X-XSS-Protection
  - Referrer-Policy
- IPv4 and IPv6 support
- Backup automation with compression
- Complete error handling and validation
- Color-coded console output
- Step-by-step progress indication
- DNS configuration guidance
- Server IP detection (IPv4 and IPv6)

### Security
- UFW firewall with minimal attack surface
- Automatic Let's Encrypt SSL/TLS certificates
- Security headers via Caddy
- Reverse proxy configuration
- N8N not directly exposed to internet
- Auto-updates for security patches
- Input validation to prevent injection attacks
- Secure subdomain naming option

### Documentation
- Complete installation guide
- Hetzner Cloud specific setup instructions
- SSH key generation tutorial
- DNS configuration examples
- Troubleshooting for common issues
- Contribution guidelines
- Code of conduct
- Security policy recommendations

### Supported Platforms
- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS
- Debian-based distributions

### Supported VPS Providers
- Hetzner Cloud (recommended)
- DigitalOcean
- Vultr
- AWS EC2
- Any Ubuntu/Debian VPS

[Unreleased]: https://github.com/YOUR_USERNAME/n8n-rapid-deploy/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/YOUR_USERNAME/n8n-rapid-deploy/releases/tag/v1.0.0
