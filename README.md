# YiimPool — YiiMP Mining Pool Installer

<p align="center">
  <a href="https://discord.gg/vV3JvN5JFm">
    <img alt="Discord" src="https://img.shields.io/discord/904564600354254898?label=Discord">
  </a>
  <img alt="GitHub issues" src="https://img.shields.io/github/issues/afiniel/Yiimpoolv1">
  <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/afiniel/Yiimpoolv1">
</p>

## Description

YiimPool is a fully automated installer for the [YiiMP](https://github.com/Kudaraidee/yiimp) cryptocurrency mining pool software on Ubuntu and Debian systems. It handles everything from initial OS configuration and database setup to stratum compilation, SSL certificates, and server hardening.

**Key features:**

- Automated installation and configuration of all required components
- Built-in DaemonBuilder for compiling coin daemons from source
- Multiple SSL configuration options (Let's Encrypt via Certbot or self-signed)
- Support for both root domain and subdomain setups
- Enhanced security features and server hardening
- Stratum server setup with autoexchange capability
- **Multi-server support** — add additional remote stratum servers to an existing pool
- WireGuard VPN integration for secure multi-server networking
- Web-based admin interface (default: `/admin/login`)
- Built-in upgrade and database tools
- Comprehensive screen management for service monitoring
- phpMyAdmin for database management

---

## System Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 4 GB | 8 GB+ |
| CPU | 2 cores | 4+ cores |
| Disk | 20 GB | 40 GB+ |
| Network | Static IP | Static IP + domain |

A clean domain or subdomain pointed to your server's IP address is required before installation.

---

## Supported Operating Systems

### Ubuntu
| Version | Status |
|---------|--------|
| Ubuntu 24.04 LTS | ✅ Supported |
| Ubuntu 23.04 | ✅ Supported |
| Ubuntu 22.04 LTS | ✅ Supported |
| Ubuntu 20.04 LTS | ✅ Supported |
| Ubuntu 18.04 LTS | ⚠️ Limited support |
| Ubuntu 16.04 LTS | ⚠️ Limited support |

### Debian
| Version | Status |
|---------|--------|
| Debian 12 (Bookworm) | ✅ Supported |
| Debian 11 (Bullseye) | ⚠️ Limited support |

> **Note:** Raspberry Pi OS is not supported.

---

## Installation

### Quick Install

```bash
curl https://raw.githubusercontent.com/afiniel/Yiimpoolv1/master/install.sh | bash
```

### Configuration Steps

The interactive installer will guide you through:

1. **Domain setup** — root domain or subdomain
2. **SSL certificate** — Let's Encrypt (automatic) or self-signed
3. **Database credentials** — auto-generated secure passwords
4. **Admin panel credentials** — username and password for the YiiMP admin panel
5. **Blocknotify password** — used for block notification between the pool and coin daemons
6. **Stratum configuration** — ports and settings for the stratum server
7. **WireGuard VPN** *(optional)* — secure private networking for multi-server setups

---

## Post-Installation

1. **Reboot** your server after installation completes
2. Wait **1–2 minutes** after your first login for all services to initialize
3. Run `motd` to view pool status and service health
4. Verify the installation:
   ```bash
   bash install/post_install_check.sh
   ```
5. Access your pool (replace `your-domain` with your actual domain):
   - **Pool:** `https://your-domain/`
   - **Admin:** `https://your-domain/admin/login`
   - **phpMyAdmin:** `https://your-domain/phpmyadmin`

---

## Adding a Remote Stratum Server

After your primary pool is running, you can add additional stratum servers from the main menu:

```
YiimPool Options → Add New Stratum Server
```

The installer will:
- Prompt for the remote server's IP address, credentials, and stratum URL
- Create a dedicated database user for the remote stratum
- Automatically deploy and configure all required software on the remote server via SSH
- Optionally set up WireGuard VPN between the servers

---

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `/home/crypto-data/yiimp/` | Main YiiMP directory |
| `/home/crypto-data/yiimp/site/web/` | Web front-end files |
| `/home/crypto-data/yiimp/starts/` | Screen management scripts |
| `/home/crypto-data/yiimp/site/backup/` | Database backups |
| `/home/crypto-data/yiimp/site/configuration/` | Core configuration files |
| `/home/crypto-data/yiimp/site/crons/` | Cron job scripts |
| `/home/crypto-data/yiimp/site/log/` | Log files |
| `/home/crypto-data/yiimp/site/stratum/` | Stratum server files |

---

## Management Commands

### `yiimpool` — Main Management Menu

After installation, the `yiimpool` command is available system-wide. It re-opens the interactive management menu from anywhere on the server:

```bash
yiimpool
```

From this menu you can:
- Run or re-run the full installer
- Access **Manage & Upgrade Options** (upgrade YiiMP, add a stratum server, run database tools)
- Launch the DaemonBuilder

> This command is installed to `/usr/bin/yiimpool` during setup and works regardless of your current working directory.

### Screen Management

```bash
screen -list              # List all running screens
screen -r main            # Attach to the main YiiMP screen
screen -r loop2           # Attach to the loop2 screen
screen -r blocks          # Attach to the blocks screen
screen -r debug           # Attach to the debug screen
Ctrl+A, D                 # Detach from current screen
```

### Service Control

```bash
screens start             # Start all pool services
screens stop              # Stop all pool services
screens restart           # Restart all pool services
yiimp                     # Display pool overview
motd                      # Display system and service status
```

---

## DaemonBuilder

The built-in coin daemon compiler is accessible via:

```bash
daemonbuilder
```

Features:
- Automated build dependency handling
- GCC version management for compatibility
- Support for multiple compile options and configurations
- Custom port configuration per coin

---

## Security Notes

- All database passwords are randomly generated during installation
- UFW firewall is configured automatically (SSH, HTTP, HTTPS, stratum ports)
- Server hardening is applied (SSH key enforcement, fail2ban, etc.)
- Do not modify default file permissions under `/home/crypto-data/`
- Back up your configuration files and database regularly

---

## Credits

- [Mail-in-a-Box](https://github.com/mail-in-a-box/mailinabox) — base framework and helper functions
- [cryptopool-builders](https://github.com/cryptopool-builders/Multi-Pool-Installer) — original multi-pool installer
- [Kudaraidee/yiimp](https://github.com/Kudaraidee/yiimp) — YiiMP source code

---

## Support

- Open an issue on [GitHub](https://github.com/afiniel/Yiimpoolv1/issues)
- Join the community on [Discord](https://discord.gg/vV3JvN5JFm)

---

## Donations

If this project has been useful to you, donations are appreciated:

| Coin | Address |
|------|---------|
| BTC | `3ELCjkScgaJbnqQiQvXb7Mwos1Y2x7hBFK` |
| ETH | `0xdA929d4f03e1009Fc031210DDE03bC40ea66D044` |
| LTC | `M8uerJZUgBn9KbTn8ng9MasM9nWFgsGftW` |
| DOGE | `DKBddo8Qoh19PCFtopBkwTpcEU1aAqdM7S` |
| SOL | `4Akj4XQXEKX4iPEd9A4ogXEPNrAsLm4wdATePz1XnyCu` |
| BEP20 | `0xdA929d4f03e1009Fc031210DDE03bC40ea66D044` |
| TON | `UQBzBvFrVjfo444hGHY2HBPNzL8nEIEzuQBF99PFh1UvyH7w` |
