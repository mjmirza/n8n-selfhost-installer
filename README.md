# 🚀 N8N Rapid Deploy

Production-ready N8N self-hosted deployment in **ONE command**. Complete automated setup with Docker, Caddy, and Let's Encrypt SSL.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![N8N](https://img.shields.io/badge/n8n-latest-orange.svg)](https://n8n.io/)

## ✨ Features

- 🚀 **One-command installation** - From fresh server to working N8N in 10 minutes
- 🤖 **Interactive setup** - Asks questions, validates inputs
- 🔒 **Automatic SSL** - Let's Encrypt certificates via Caddy
- 🔄 **Auto-updates** - Watchtower updates N8N weekly
- 🛡️ **Security hardened** - Firewall, headers, reverse proxy
- 📦 **5 utility scripts** - Check status, restart, update, backup
- 📚 **Complete documentation** - Setup guides and troubleshooting
- 🌍 **IPv4 & IPv6** - Full dual-stack support

## 🚀 Quick Start

### Prerequisites

- Ubuntu 22.04 or 24.04 server (2+ vCPU, 4GB+ RAM)
- Root/sudo access
- Domain name with DNS access

### Installation

**Step 1**: Connect to your server

```bash
ssh root@YOUR_SERVER_IP
```

**Step 2**: Run the installer

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/n8n-rapid-deploy/main/install.sh | sudo bash
```

**Step 3**: Answer the prompts

- Domain name: `example.com`
- Subdomain: `n8n` (or use obscure name like `automation-x7k3`)
- Email: `admin@example.com`
- Timezone: Choose from list

**Step 4**: Configure DNS

Add an A record in your DNS provider:
- **Type**: A
- **Name**: your-subdomain
- **Value**: YOUR_SERVER_IP
- **TTL**: 300

**Step 5**: Wait and access

Wait 5-10 minutes for DNS propagation and SSL generation, then visit:

`https://your-subdomain.your-domain.com`

## 📖 What Gets Installed

The installer automatically:

1. ✅ Installs Docker & Docker Compose V2
2. ✅ Configures UFW firewall (ports 22, 80, 443)
3. ✅ Clones official n8n-docker-caddy repository
4. ✅ Creates `.env` file from your inputs
5. ✅ Creates `Caddyfile` with security headers
6. ✅ Starts N8N and Caddy containers
7. ✅ Downloads 5 utility scripts (auto chmod +x)
8. ✅ Sets up Watchtower for auto-updates

### Utility Scripts

After installation, these scripts are available in `/root/n8n-docker-caddy/`:

```bash
./check-status.sh      # System health check
./restart-all.sh       # Restart all services
./update-n8n.sh        # Update N8N to latest
./backup.sh            # Create timestamped backup
./setup-watchtower.sh  # Configure auto-updates
```

## 🔧 Common Commands

```bash
cd /root/n8n-docker-caddy

# Check system status
./check-status.sh

# Restart everything
./restart-all.sh

# Update N8N
./update-n8n.sh

# Create backup
./backup.sh

# View logs
docker compose logs -f n8n
docker compose logs -f caddy
```

## 🔒 Security Features

- ✅ **UFW Firewall** - Only essential ports open (22, 80, 443)
- ✅ **Automatic SSL/TLS** - Let's Encrypt certificates
- ✅ **Security Headers** - HSTS, CSP, X-Frame-Options, etc.
- ✅ **Reverse Proxy** - N8N not directly exposed
- ✅ **Auto-updates** - Weekly security patches via Watchtower
- ✅ **Input Validation** - Prevents injection attacks

## 📚 Documentation

- **[SETUP.md](SETUP.md)** - Detailed manual installation guide
- **[docs/HETZNER-GUIDE.md](docs/HETZNER-GUIDE.md)** - Hetzner Cloud setup with SSH keys
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Problem solving guide
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

## 🏗️ Supported Platforms

### Operating Systems
- Ubuntu 22.04 LTS ✅
- Ubuntu 24.04 LTS ✅
- Debian-based distributions ✅

### VPS Providers
- **Hetzner Cloud** (recommended) - [Guide](docs/HETZNER-GUIDE.md)
- **DigitalOcean** - Compatible
- **Vultr** - Compatible
- **AWS EC2** - Compatible
- Any Ubuntu/Debian VPS

### Minimum Requirements
- 2 vCPU
- 4GB RAM
- 20GB storage
- Ubuntu 22.04+

### Recommended
- Hetzner CPX21 (3 vCPU, 4GB RAM) - €7.59/month

## 🆘 Troubleshooting

### DNS not resolving?

```bash
# Check DNS
nslookup your-subdomain.your-domain.com 8.8.8.8

# Wait 5-30 minutes for propagation
```

### SSL certificate not generating?

```bash
# Check Caddy logs
docker compose logs caddy | grep certificate

# Ensure port 80 is open
ufw allow 80/tcp
docker compose restart caddy
```

### Can't access N8N?

```bash
# Check status
./check-status.sh

# Check firewall
ufw status

# Restart everything
./restart-all.sh
```

For more solutions, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### How to Contribute

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [N8N](https://n8n.io/) - The workflow automation platform
- [Caddy](https://caddyserver.com/) - The amazing reverse proxy
- [Watchtower](https://containrrr.dev/watchtower/) - Container update automation
- [n8n-docker-caddy](https://github.com/n8n-io/n8n-docker-caddy) - Official N8N Docker setup

## 📧 Support

- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/n8n-rapid-deploy/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/n8n-rapid-deploy/discussions)
- **N8N Community**: [community.n8n.io](https://community.n8n.io/)

## ⭐ Star History

If this project helped you, please give it a star! It helps others discover the project.

---

**Made with ❤️ for the N8N community**
