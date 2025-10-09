# 🇩🇪 Hetzner Cloud Setup Guide for N8N

Complete guide to setting up N8N on Hetzner Cloud with SSH key authentication.

## 📋 Table of Contents

- [Why Hetzner?](#why-hetzner)
- [Creating SSH Keys](#creating-ssh-keys)
- [Creating Hetzner Account](#creating-hetzner-account)
- [Creating Server](#creating-server)
- [Connecting to Server](#connecting-to-server)
- [Running Installer](#running-installer)
- [DNS Configuration](#dns-configuration)

## 🎯 Why Hetzner?

| Feature | Hetzner CPX21 | DigitalOcean | Vultr |
|---------|---------------|--------------|-------|
| **Price** | €7.59/month | $12/month | $12/month |
| **vCPU** | 3 | 2 | 2 |
| **RAM** | 4 GB | 2 GB | 2 GB |
| **Storage** | 80 GB | 50 GB | 55 GB |
| **Bandwidth** | 20 TB | 2 TB | 2 TB |

**Winner**: Hetzner offers 50% better specs at 40% lower cost!

## 🔐 Creating SSH Keys

SSH keys are more secure than passwords. Create them before setting up your server.

### Option 1: Generate on Your Computer (Recommended)

**On macOS/Linux:**
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Press Enter to save to default location (~/.ssh/id_ed25519)
# Enter a passphrase (recommended) or leave empty

# View your public key
cat ~/.ssh/id_ed25519.pub
```

**On Windows (PowerShell):**
```powershell
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Press Enter to save to default location (C:\Users\YourName\.ssh\id_ed25519)
# Enter a passphrase (recommended) or leave empty

# View your public key
type $env:USERPROFILE\.ssh\id_ed25519.pub
```

**Copy the output** - you'll need this for Hetzner.

### Option 2: Generate in Console (from conversation screenshots)

Based on your Hetzner setup:

1. **Open Terminal/Console** on your computer
2. **Run SSH key generation**:
   ```bash
   ssh-keygen -t ed25519 -C "n8n-hetzner-server"
   ```
3. **Save to custom location** (if asked):
   ```
   /Users/yourname/.ssh/hetzner_n8n_key
   ```
4. **Set passphrase** (recommended for security)
5. **Copy public key**:
   ```bash
   cat ~/.ssh/hetzner_n8n_key.pub
   ```

## 🏗️ Creating Hetzner Account

1. **Sign Up**: Go to [Hetzner Cloud Console](https://console.hetzner.cloud/)
2. **Verify Email**: Check your inbox
3. **Add Payment Method**: Credit card or PayPal
4. **Create Project**: Name it "N8N Production" or similar

## 🖥️ Creating Your Server

### Step 1: Create New Server

1. **Go to Hetzner Console**: https://console.hetzner.cloud/
2. **Click "Add Server"**

### Step 2: Choose Location

Select based on your users' location:
- **Nuremberg, Germany** - Europe, best for GDPR compliance
- **Helsinki, Finland** - Northern Europe
- **Falkenstein, Germany** - Europe, alternative
- **Ashburn, USA** - North America

### Step 3: Choose Image

- **Operating System**: Ubuntu
- **Version**: 24.04 LTS (or 22.04 LTS)

### Step 4: Choose Server Type

**Recommended for N8N**:
- **Type**: CPX (Shared vCPU)
- **Plan**: CPX21
  - 3 vCPU
  - 4 GB RAM
  - 80 GB SSD
  - €7.59/month

**For larger workflows**:
- **CPX31**: 4 vCPU, 8 GB RAM, €14.29/month
- **CPX41**: 8 vCPU, 16 GB RAM, €28.59/month

### Step 5: Add SSH Key

1. **Click "Add SSH Key"**
2. **Paste your public key** (from earlier step)
3. **Name it**: "My Main SSH Key" or "Laptop Key"
4. **Click "Add SSH Key"**

### Step 6: Additional Options

**Networking**:
- ✅ IPv4
- ✅ IPv6

**Volumes**: Not needed (optional for large data)

**Firewalls**: Skip (we'll use UFW on the server)

**Backups**: Optional (€1.52/month for automated backups)

### Step 7: Name Your Server

```
n8n-production-server
```

### Step 8: Create & Buy

1. **Review**: Check monthly cost
2. **Click "CREATE & BUY NOW"**
3. **Wait 30-60 seconds** for server creation

### Step 9: Get Your IP Address

Once server is ready:
1. **Click on server name**
2. **Copy IPv4 address** (e.g., `46.62.201.169`)

## 🔌 Connecting to Your Server

### First Connection

**From macOS/Linux:**
```bash
# If you used default SSH key location
ssh root@YOUR_SERVER_IP

# If you used custom key location
ssh -i ~/.ssh/hetzner_n8n_key root@YOUR_SERVER_IP
```

**From Windows (PowerShell):**
```powershell
# If you used default SSH key location
ssh root@YOUR_SERVER_IP

# If you used custom key location
ssh -i $env:USERPROFILE\.ssh\hetzner_n8n_key root@YOUR_SERVER_IP
```

**First time prompt**:
```
The authenticity of host '46.62.201.169 (46.62.201.169)' can't be established.
ED25519 key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)?
```
Type `yes` and press Enter.

### Saving Connection (Optional)

Create SSH config file for easier access:

```bash
# On macOS/Linux
nano ~/.ssh/config

# On Windows
notepad $env:USERPROFILE\.ssh\config
```

Add this:
```
Host n8n-prod
    HostName YOUR_SERVER_IP
    User root
    IdentityFile ~/.ssh/hetzner_n8n_key
```

Now you can connect with just:
```bash
ssh n8n-prod
```

## 🚀 Running the N8N Installer

Once connected to your server:

### Option 1: One-Line Installer (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/n8n-rapid-deploy/main/install.sh | sudo bash
```

### Option 2: Manual Download & Run

```bash
# Download installer
wget https://raw.githubusercontent.com/YOUR_USERNAME/n8n-rapid-deploy/main/install.sh

# Make executable
chmod +x install.sh

# Run installer
sudo ./install.sh
```

### Installer Will Ask:

1. **Domain name**: `example.com`
2. **Subdomain**: `n8n` (or secure subdomain like `automation-x7k3`)
3. **Email**: `admin@example.com` (for SSL certificates)
4. **Timezone**: `UTC` or `Europe/Berlin`

The installer will then:
- ✅ Install Docker and dependencies
- ✅ Configure UFW firewall
- ✅ Clone n8n-docker-caddy repository
- ✅ Create all configuration files
- ✅ Generate utility scripts
- ✅ Start N8N with SSL
- ✅ Setup Watchtower for auto-updates

## 🌐 DNS Configuration

### Step 1: Get Your Server IP

```bash
curl ifconfig.me
```

### Step 2: Add DNS Record

Go to your domain provider (Cloudflare, Namecheap, GoDaddy, etc.):

1. **Login** to DNS management
2. **Add A Record**:
   - **Type**: A
   - **Name**: your-subdomain (e.g., `n8n` or `automation-x7k3`)
   - **Value**: YOUR_SERVER_IP (e.g., `46.62.201.169`)
   - **TTL**: 300 (5 minutes)
3. **Save**

### Step 3: Wait for Propagation

DNS propagation typically takes:
- **Cloudflare**: 2-5 minutes
- **Other providers**: 5-30 minutes

Check DNS propagation:
```bash
nslookup your-subdomain.yourdomain.com 8.8.8.8
```

### Step 4: Access N8N

After DNS propagates (5-10 minutes):

1. **Visit**: `https://your-subdomain.yourdomain.com`
2. **Wait for SSL**: Caddy auto-generates certificate (1-2 minutes)
3. **Create Account**: First-time setup wizard

## ✅ Verification

Check everything is working:

```bash
cd /root/n8n-docker-caddy
./check-status.sh
```

You should see:
- ✅ n8n is RUNNING
- ✅ Caddy is RUNNING
- ✅ Watchtower is RUNNING
- ✅ DNS is correctly configured
- ✅ Firewall is ACTIVE
- ✅ SSL certificates: Active

## 🔒 Security Hardening (Recommended)

### 1. Disable Password Authentication

```bash
nano /etc/ssh/sshd_config
```

Find and change:
```
PasswordAuthentication no
PermitRootLogin prohibit-password
```

Restart SSH:
```bash
systemctl restart sshd
```

### 2. Change SSH Port (Optional)

```bash
nano /etc/ssh/sshd_config
```

Change:
```
Port 2222
```

Update firewall:
```bash
ufw allow 2222/tcp
ufw delete allow 22/tcp
systemctl restart sshd
```

Reconnect with:
```bash
ssh -p 2222 root@YOUR_SERVER_IP
```

### 3. Enable Automatic Security Updates

```bash
apt install unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

### 4. Setup Fail2Ban (Brute Force Protection)

```bash
apt install fail2ban
systemctl enable fail2ban
systemctl start fail2ban
```

## 💾 Backups

### Manual Backup

```bash
cd /root/n8n-docker-caddy
./backup.sh
```

Backups saved to: `/root/backups/`

### Hetzner Snapshots (Recommended)

1. **Go to Hetzner Console**
2. **Click on your server**
3. **Snapshots tab**
4. **Create Snapshot**: Takes full server backup
5. **Cost**: €0.0119/GB/month

### Download Backups

```bash
# Download backup to your computer
scp root@YOUR_SERVER_IP:/root/backups/n8n-backup-*.tar.gz ~/Downloads/
```

## 🆘 Troubleshooting

### Can't Connect via SSH?

```bash
# Check if server is running in Hetzner Console
# Verify SSH key is added correctly
# Try password authentication temporarily (if enabled)
```

### Firewall Blocking?

```bash
# Check UFW status
ufw status

# Allow SSH if blocked
ufw allow 22/tcp
```

### Server Running Slow?

```bash
# Check resource usage
htop

# Check disk space
df -h

# Upgrade to larger plan if needed
```

## 📊 Cost Optimization

### CPX21 Monthly Breakdown

- **Server**: €7.59
- **Bandwidth**: Included (20 TB)
- **IPv4**: Included
- **Backups (optional)**: €1.52
- **Total**: ~€9.11/month (~$10 USD)

### Save Money

- ✅ **Snapshots instead of backups**: One-time cost vs monthly
- ✅ **Traffic included**: 20TB free bandwidth
- ✅ **Downgrade if needed**: Easy to resize
- ✅ **Delete when not used**: Hourly billing

## 🎓 Next Steps

After setup:

1. ✅ **Create N8N Account**: Access your subdomain
2. ✅ **Enable 2FA**: In N8N settings
3. ✅ **Setup Backups**: Run `./backup.sh` weekly
4. ✅ **Create Workflows**: Start automating!
5. ✅ **Monitor**: Run `./check-status.sh` regularly

## 🔗 Useful Links

- **Hetzner Console**: https://console.hetzner.cloud/
- **Hetzner Status**: https://status.hetzner.com/
- **Hetzner Docs**: https://docs.hetzner.com/
- **Hetzner Community**: https://community.hetzner.com/

---

**Questions?** Open an issue on [GitHub](https://github.com/YOUR_USERNAME/n8n-rapid-deploy/issues)
