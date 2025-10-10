#!/bin/bash

###############################################################################
# N8N Rapid Deploy - One-Command Installer
#
# This script automates the complete N8N installation with:
# - Docker and Docker Compose installation
# - UFW firewall configuration
# - N8N Docker Caddy setup
# - SSL certificate automation
# - Watchtower auto-updates
# - Utility scripts creation
#
# Usage:
#   1. Clone/download the repository to your server
#   2. Navigate to the installer directory: cd n8n-selfhost-installer
#   3. Run the installer: sudo bash install.sh
#
# The installer uses local templates and scripts from the repository structure.
# No external dependencies or downloads required (except Docker components).
###############################################################################

set -e  # Exit on error

# Colors for output (works in both dark and light terminals)
RED='\033[0;91m'      # Bright red (works in both modes)
GREEN='\033[0;92m'    # Bright green (works in both modes)
YELLOW='\033[0;93m'   # Bright yellow (works in both modes)
CYAN='\033[0;96m'     # Bright cyan (works in both modes)
MAGENTA='\033[0;95m'  # Bright magenta for headers
NC='\033[0m'          # No Color
BOLD='\033[1m'        # Bold text

# Print colored output
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_step() { echo -e "\n${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BOLD}${MAGENTA}$1${NC}"; echo -e "${BOLD}${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; }

# Banner
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║              🚀 N8N RAPID DEPLOY INSTALLER 🚀                ║
║                                                               ║
║         Production-Ready N8N in One Command                   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use: sudo bash install.sh)"
    exit 1
fi

print_success "Running with root privileges"
echo ""

###############################################################################
# Determine Repository Paths (MUST be done before changing directories)
###############################################################################
# Get the absolute path to the repository where install.sh is located
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$REPO_DIR/deployments/simple"
SCRIPTS_DIR="$REPO_DIR/scripts"

print_info "Repository location: $REPO_DIR"

###############################################################################
# STEP 1: System Check
###############################################################################
print_step "STEP 1: System Compatibility Check"

# Check OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    print_info "Detected OS: $OS $VER"

    if [[ "$ID" != "ubuntu" ]] && [[ "$ID" != "debian" ]]; then
        print_warning "This script is optimized for Ubuntu/Debian. Proceed with caution."
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    print_error "Cannot detect OS. This script requires Ubuntu/Debian."
    exit 1
fi

# Check system resources
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -lt 3800 ]; then
    print_warning "Detected ${TOTAL_RAM}MB RAM. Recommended: 4GB+"
    print_warning "N8N may run slowly with limited RAM"
    sleep 2
else
    print_success "RAM: ${TOTAL_RAM}MB (Good!)"
fi

DISK_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$DISK_SPACE" -lt 15 ]; then
    print_warning "Low disk space: ${DISK_SPACE}GB available. Recommended: 20GB+"
    sleep 2
else
    print_success "Disk Space: ${DISK_SPACE}GB available (Good!)"
fi

echo ""
sleep 1

###############################################################################
# STEP 2: Interactive Configuration
###############################################################################
print_step "STEP 2: Configuration Setup"

echo ""
print_info "Please provide the following information:"
echo ""

# Domain name
while true; do
    read -p "$(echo -e ${CYAN}📌 Enter your domain name ${NC}${YELLOW}[e.g., example.com]${NC}: )" DOMAIN_NAME
    if [[ $DOMAIN_NAME =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
        print_success "Domain: $DOMAIN_NAME"
        break
    else
        print_error "Invalid domain format. Try again."
    fi
done

# Subdomain
echo ""
print_info "Choose a subdomain for N8N"
print_info "Tip: Use obscure names for security (e.g., automation-x7k3)"
echo ""
while true; do
    read -p "$(echo -e ${CYAN}📌 Enter subdomain ${NC}${YELLOW}[e.g., n8n or automation-secure]${NC}: )" SUBDOMAIN
    if [[ $SUBDOMAIN =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
        print_success "Subdomain: $SUBDOMAIN"
        FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN_NAME}"
        print_info "Your N8N will be accessible at: https://$FULL_DOMAIN"
        break
    else
        print_error "Invalid subdomain format. Use only letters, numbers, and hyphens."
    fi
done

# Email for SSL
echo ""
while true; do
    read -p "$(echo -e ${CYAN}📌 Enter email for SSL certificates ${NC}${YELLOW}[e.g., admin@$DOMAIN_NAME]${NC}: )" SSL_EMAIL
    if [[ $SSL_EMAIL =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_success "Email: $SSL_EMAIL"
        break
    else
        print_error "Invalid email format. Try again."
    fi
done

# Timezone
echo ""
print_info "Select timezone (used for cron schedules and timestamps)"
echo ""
echo "Common options:"
echo "  1) UTC (Universal)"
echo "  2) Europe/Berlin"
echo "  3) America/New_York"
echo "  4) Asia/Tokyo"
echo "  5) Custom (enter manually)"
echo ""
read -p "$(echo -e ${CYAN}Select option ${NC}${YELLOW}[1-5]${NC}: )" TZ_OPTION

case $TZ_OPTION in
    1) TIMEZONE="UTC" ;;
    2) TIMEZONE="Europe/Berlin" ;;
    3) TIMEZONE="America/New_York" ;;
    4) TIMEZONE="Asia/Tokyo" ;;
    5)
        read -p "$(echo -e ${CYAN}Enter custom timezone ${NC}${YELLOW}[e.g., Europe/London]${NC}: )" TIMEZONE
        ;;
    *) TIMEZONE="UTC" ;;
esac

print_success "Timezone: $TIMEZONE"

echo ""
print_info "Configuration Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Domain:    $DOMAIN_NAME"
echo "  Subdomain: $SUBDOMAIN"
echo "  Full URL:  https://$FULL_DOMAIN"
echo "  Email:     $SSL_EMAIL"
echo "  Timezone:  $TIMEZONE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "$(echo -e ${CYAN}Continue with this configuration? ${NC}${WHITE}[Y/n]${NC}: )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    print_error "Installation cancelled"
    exit 1
fi

echo ""
sleep 1

###############################################################################
# STEP 3: Install Dependencies
###############################################################################
print_step "STEP 3: Installing Dependencies"

# Update system
print_info "Updating system packages..."
apt-get update -qq

# Install Docker
if ! command -v docker &> /dev/null; then
    print_info "Installing Docker..."
    apt-get install -y -qq docker.io > /dev/null
    systemctl start docker
    systemctl enable docker > /dev/null 2>&1
    print_success "Docker installed: $(docker --version)"
else
    print_success "Docker already installed: $(docker --version)"
fi

# Install Docker Compose V2
if ! docker compose version &> /dev/null; then
    print_info "Installing Docker Compose V2..."
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -fsSL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
        -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    print_success "Docker Compose installed: $(docker compose version)"
else
    print_success "Docker Compose already installed: $(docker compose version)"
fi

# Install additional tools
print_info "Installing additional tools (git, curl, ufw)..."
apt-get install -y -qq git curl ufw > /dev/null
print_success "Additional tools installed"

echo ""
sleep 1

###############################################################################
# STEP 4: Configure Firewall
###############################################################################
print_step "STEP 4: Configuring UFW Firewall"

# Configure UFW
print_info "Setting up firewall rules..."
ufw --force enable > /dev/null 2>&1
ufw default deny incoming > /dev/null 2>&1
ufw default allow outgoing > /dev/null 2>&1
ufw allow 22/tcp comment 'SSH' > /dev/null 2>&1
ufw allow 80/tcp comment 'HTTP' > /dev/null 2>&1
ufw allow 443/tcp comment 'HTTPS' > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1

print_success "Firewall configured (SSH: 22, HTTP: 80, HTTPS: 443)"

echo ""
sleep 1

###############################################################################
# STEP 5: Setup N8N Installation Directory
###############################################################################
print_step "STEP 5: Setting Up N8N"

# Set installation directory
INSTALL_DIR="/root/n8n"

# Navigate to root directory
cd /root

# Remove old installation if exists
if [ -d "$INSTALL_DIR" ]; then
    print_warning "Existing installation found at $INSTALL_DIR"
    read -p "$(echo -e ${YELLOW}Remove and reinstall? ${NC}${WHITE}[Y/n]${NC}: )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        print_info "Backing up old installation..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
        print_success "Old installation backed up"
    else
        print_error "Installation cancelled"
        exit 1
    fi
fi

# Create installation directory
print_info "Creating installation directory..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
print_success "Installation directory created: $INSTALL_DIR"

# Create required subdirectories
print_info "Creating directory structure..."
mkdir -p caddy_config
mkdir -p local_files
print_success "Directory structure created"

echo ""
sleep 1

###############################################################################
# STEP 6: Create Configuration Files
###############################################################################
print_step "STEP 6: Creating Configuration Files"

# Verify template files exist (paths calculated at script start)
if [ ! -f "$TEMPLATES_DIR/docker-compose.yml" ]; then
    print_error "Template file not found: $TEMPLATES_DIR/docker-compose.yml"
    print_error "Please ensure you're running install.sh from the repository root:"
    print_error "  cd n8n-selfhost-installer && sudo bash install.sh"
    exit 1
fi

if [ ! -f "$TEMPLATES_DIR/Caddyfile" ]; then
    print_error "Template file not found: $TEMPLATES_DIR/Caddyfile"
    print_error "Please ensure you're running install.sh from the repository root:"
    print_error "  cd n8n-selfhost-installer && sudo bash install.sh"
    exit 1
fi

print_success "Found local template files in repository"

# Create .env file
print_info "Creating .env configuration..."
cat > .env << ENVEOF
# Domain configuration
DOMAIN_NAME=$DOMAIN_NAME
SUBDOMAIN=$SUBDOMAIN

# SSL Email for Let's Encrypt
SSL_EMAIL=$SSL_EMAIL

# Timezone
GENERIC_TIMEZONE=$TIMEZONE

# Data storage path
DATA_FOLDER=$INSTALL_DIR
ENVEOF
print_success ".env file created"

# Copy and configure docker-compose.yml
print_info "Configuring docker-compose.yml..."
cp "$TEMPLATES_DIR/docker-compose.yml" docker-compose.yml
sed -i "s|__DATA_FOLDER__|$INSTALL_DIR|g" docker-compose.yml
sed -i "s|__SUBDOMAIN__|$SUBDOMAIN|g" docker-compose.yml
sed -i "s|__DOMAIN_NAME__|$DOMAIN_NAME|g" docker-compose.yml
sed -i "s|__TIMEZONE__|$TIMEZONE|g" docker-compose.yml
print_success "docker-compose.yml configured"

# Copy and configure Caddyfile
print_info "Configuring Caddyfile..."
cp "$TEMPLATES_DIR/Caddyfile" caddy_config/Caddyfile
sed -i "s|__SUBDOMAIN__|$SUBDOMAIN|g" caddy_config/Caddyfile
sed -i "s|__DOMAIN_NAME__|$DOMAIN_NAME|g" caddy_config/Caddyfile
sed -i "s|__SSL_EMAIL__|$SSL_EMAIL|g" caddy_config/Caddyfile
print_success "Caddyfile configured with security headers"

echo ""
sleep 1

###############################################################################
# STEP 7: Create Docker Volumes
###############################################################################
print_step "STEP 7: Creating Docker Volumes"

# Create external Docker volumes required by docker-compose.yml
print_info "Creating caddy_data volume..."
if docker volume inspect caddy_data > /dev/null 2>&1; then
    print_warning "Volume 'caddy_data' already exists"
else
    docker volume create caddy_data
    print_success "Volume 'caddy_data' created"
fi

print_info "Creating n8n_data volume..."
if docker volume inspect n8n_data > /dev/null 2>&1; then
    print_warning "Volume 'n8n_data' already exists"
else
    docker volume create n8n_data
    print_success "Volume 'n8n_data' created"
fi

echo ""
sleep 1

###############################################################################
# STEP 8: Start Services
###############################################################################
print_step "STEP 8: Starting N8N Services"

# Check for and stop any existing N8N containers
print_info "Checking for existing N8N containers..."
if docker ps -a | grep -E "n8n-n8n|n8n-caddy|n8n_n8n|n8n_caddy" > /dev/null 2>&1; then
    print_warning "Found existing N8N containers. Stopping and removing..."

    # Try to stop and remove with docker compose in the old directory first
    if [ -d "/root/n8n-backup-"* ] 2>/dev/null; then
        BACKUP_DIR=$(ls -td /root/n8n-backup-* 2>/dev/null | head -1)
        if [ -f "$BACKUP_DIR/docker-compose.yml" ]; then
            print_info "Stopping containers from backup directory..."
            (cd "$BACKUP_DIR" && docker compose down 2>/dev/null) || true
        fi
    fi

    # Stop any running N8N containers by name
    docker stop $(docker ps -a -q --filter="name=n8n-n8n" --filter="name=n8n-caddy" --filter="name=n8n_n8n" --filter="name=n8n_caddy") 2>/dev/null || true
    docker rm $(docker ps -a -q --filter="name=n8n-n8n" --filter="name=n8n-caddy" --filter="name=n8n_n8n" --filter="name=n8n_caddy") 2>/dev/null || true

    print_success "Existing containers cleaned up"
else
    print_success "No existing containers found"
fi

print_info "Starting Docker containers..."
docker compose up -d

# Wait for containers to start
sleep 5

# Check if containers are running
if docker ps | grep -q "n8n" && docker ps | grep -q "caddy"; then
    print_success "N8N and Caddy containers are running"
else
    print_error "Containers failed to start. Checking logs..."
    docker compose logs
    exit 1
fi

echo ""
sleep 1

###############################################################################
# STEP 9: Copy Utility Scripts
###############################################################################
print_step "STEP 9: Setting Up Utility Scripts"

# Verify scripts directory exists
if [ ! -d "$SCRIPTS_DIR" ]; then
    print_error "Scripts directory not found: $SCRIPTS_DIR"
    print_error "Please ensure you have the complete repository structure"
    exit 1
fi

# Copy utility scripts from repository
print_info "Copying utility scripts..."

# check-status.sh
if [ -f "$SCRIPTS_DIR/check-status.sh" ]; then
    cp "$SCRIPTS_DIR/check-status.sh" check-status.sh
    chmod +x check-status.sh
    print_success "check-status.sh created"
else
    print_warning "check-status.sh not found in repository"
fi

# restart-all.sh
if [ -f "$SCRIPTS_DIR/restart-all.sh" ]; then
    cp "$SCRIPTS_DIR/restart-all.sh" restart-all.sh
    chmod +x restart-all.sh
    print_success "restart-all.sh created"
else
    print_warning "restart-all.sh not found in repository"
fi

# update-n8n.sh
if [ -f "$SCRIPTS_DIR/update-n8n.sh" ]; then
    cp "$SCRIPTS_DIR/update-n8n.sh" update-n8n.sh
    chmod +x update-n8n.sh
    print_success "update-n8n.sh created"
else
    print_warning "update-n8n.sh not found in repository"
fi

# setup-watchtower.sh
if [ -f "$SCRIPTS_DIR/setup-watchtower.sh" ]; then
    cp "$SCRIPTS_DIR/setup-watchtower.sh" setup-watchtower.sh
    chmod +x setup-watchtower.sh
    print_success "setup-watchtower.sh created"
else
    print_warning "setup-watchtower.sh not found in repository"
fi

# backup.sh
if [ -f "$SCRIPTS_DIR/backup.sh" ]; then
    cp "$SCRIPTS_DIR/backup.sh" backup.sh
    chmod +x backup.sh
    print_success "backup.sh created"
else
    print_warning "backup.sh not found in repository"
fi

echo ""
sleep 1

###############################################################################
# STEP 10: Setup Watchtower
###############################################################################
print_step "STEP 10: Setting Up Auto-Updates"

print_info "Configuring Watchtower for automatic updates..."
./setup-watchtower.sh

echo ""
sleep 1

###############################################################################
# STEP 11: Get Server IP
###############################################################################
print_step "STEP 11: Network Configuration"

print_info "Detecting server IP address..."
SERVER_IP=$(curl -s ifconfig.me)
SERVER_IP_V6=$(curl -6 -s ifconfig.me 2>/dev/null || echo "Not available")

print_success "Server IPv4: $SERVER_IP"
if [ "$SERVER_IP_V6" != "Not available" ]; then
    print_info "Server IPv6: $SERVER_IP_V6"
fi

echo ""
sleep 1

###############################################################################
# INSTALLATION COMPLETE
###############################################################################
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║            ✅ INSTALLATION COMPLETE! ✅                       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📋 Installation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "Docker and dependencies installed"
print_success "UFW firewall configured"
print_success "N8N and Caddy containers running"
print_success "Watchtower auto-updates configured"
print_success "Utility scripts created"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🌐 Next Steps - Configure DNS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Go to your DNS provider (Cloudflare, Namecheap, etc.)"
echo ""
echo "2. Add an A record:"
echo "   ┌────────────────────────────────────────┐"
echo "   │ Type:  A                               │"
echo "   │ Name:  $SUBDOMAIN"
echo "   │ Value: $SERVER_IP"
echo "   │ TTL:   300 (5 minutes)                 │"
echo "   └────────────────────────────────────────┘"
echo ""
echo "3. Wait 5-10 minutes for:"
echo "   • DNS propagation"
echo "   • SSL certificate generation"
echo ""
echo "4. Check status:"
echo "   cd /root/n8n"
echo "   ./check-status.sh"
echo ""
echo "5. Access N8N:"
echo "   🌐 https://$FULL_DOMAIN"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔧 Useful Commands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "All commands run from: /root/n8n"
echo ""
echo "  ./check-status.sh       # Check system status"
echo "  ./restart-all.sh        # Restart all services"
echo "  ./update-n8n.sh         # Update N8N to latest"
echo "  ./backup.sh             # Create backup"
echo ""
echo "  docker compose logs -f n8n    # View N8N logs"
echo "  docker compose logs -f caddy  # View Caddy logs"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 Monitor SSL Certificate"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  docker compose logs -f caddy | grep certificate"
echo ""
echo "  Wait for: 'certificate obtained successfully'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ❤️  Support"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ⭐ Star on GitHub:"
echo "     github.com/mjmirza/n8n-selfhost-installer"
echo ""
echo "  📖 Documentation:"
echo "     github.com/mjmirza/n8n-selfhost-installer/blob/main/README.md"
echo ""
echo "  🐛 Report Issues:"
echo "     github.com/mjmirza/n8n-selfhost-installer/issues"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "Happy Automating with N8N! 🎉"
echo ""
