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
- **SSH key-only login** — full `sshd_config` hardening applied automatically at user creation (StrictModes-safe permissions, cloud-init override neutralization, immediate SSH restart)
- **Coin daemon autostart** — each daemon compiled with DaemonBuilder is registered as a `@reboot` crontab entry with a 30-second boot delay and dedicated boot log
- **Stratum autostart** — stratum processes registered via `@reboot` crontab with full path, deduplication, and boot log on every `addport` run
- **System health check** — comprehensive monitoring covering disk, swap, memory, load, CPU, services (MariaDB/MySQL, PHP-FPM auto-detected), stratum sessions, database sizes, and SSL expiry

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

### System Health Check

Run a full health report at any time:

```bash
bash ~/Yiimpoolv1/yiimp_upgrade/health_check.sh
```

Or from the management menu:

```
yiimpool → option 5 → System Health Check
```

The health check covers:

| Check | Details |
|-------|---------|
| Disk space | Usage % with color warnings (yellow >75 %, red >90 %) |
| Swap usage | Total / used / percent (yellow >50 %, red >80 %) |
| Memory | Total, used, free, buff/cache, available |
| Load average | 1 / 5 / 15-minute averages color-coded against CPU core count |
| CPU usage | Current % with top-5 process list |
| Critical services | nginx, MariaDB/MySQL (auto-detected), PHP-FPM (version auto-detected), cron, supervisor, fail2ban |
| Stratum sessions | Lists all active `screen` sessions for running stratums |
| Database sizes | Per-database MB usage sorted largest first |
| SSL certificate | Expiry in days; explicit "EXPIRED" message if already past |

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
- Custom port configuration per coin via `addport`
- **Coin daemon autostart on reboot** — after a successful build, the daemon is automatically registered in crontab as:
  ```
  @reboot sleep 30 && <coind> -datadir=... -daemon ... >> /var/log/<coin>-daemon-boot.log 2>&1
  ```
  Existing entries for the same coin are deduplicated before the new one is added.
- **Stratum autostart on reboot** — running `addport` registers the stratum process via:
  ```
  @reboot sleep 30 && /usr/bin/stratum.<coin> start <coin> >> /var/log/stratum-<coin>-boot.log 2>&1
  ```
  Both the crontab entry and the immediate launch use the full `/usr/bin/` path, ensuring they work correctly at boot time when `PATH` is not yet populated.

---

## Security Notes

- All database passwords are randomly generated during installation
- UFW firewall is configured automatically (SSH, HTTP, HTTPS, stratum ports)
- Server hardening is applied (SSH key enforcement, fail2ban, etc.)
- Do not modify default file permissions under `/home/crypto-data/`
- Back up your configuration files and database regularly

### SSH Key Login Hardening

When you choose SSH key login during user creation, the following hardening is applied automatically:

| Setting | Value | Where |
|---------|-------|--------|
| Home directory permissions | `755` | Required by `StrictModes` |
| `.ssh/` directory permissions | `700` | Required by `StrictModes` |
| `authorized_keys` permissions | `600` | Required by `StrictModes` |
| `PubkeyAuthentication` | `yes` | sshd config |
| `KbdInteractiveAuthentication` | `no` | sshd config (prevents PAM password prompts) |
| `ChallengeResponseAuthentication` | `no` | sshd config |
| `PasswordAuthentication` | `no` | sshd config |

On **Ubuntu 20.04+ / Debian 12** a drop-in file `/etc/ssh/sshd_config.d/10-yiimpool.conf` is written so the main config is never modified. Any `PasswordAuthentication yes` override left by cloud-init (`50-cloud-init.conf`) is patched automatically. On **older systems** a `_sshd_set` helper ensures each directive is added to `sshd_config` even if it was not present at all (not just commented out). The SSH service is restarted immediately so the new settings take effect without a reboot.

---

## What's New in v2.6.3

### Bug Fixes
- **SSH key login** — Fixed "still prompts for password after reboot" caused by missing `sshd_config` changes, wrong `authorized_keys` permissions (`644` → `600`), and no SSH service restart
- **Coin daemon & stratum autostart** — Both were not registered for reboot persistence; `@reboot` crontab entries are now created automatically with deduplication and boot logging
- **DaemonBuilder compile errors** — Added `PIPESTATUS` checks after every piped build step; failed compiles now abort correctly instead of silently continuing
- **`addport` on Ubuntu 22.04+** — Fixed crash from deprecated `tempfile` command (removed from modern debianutils); replaced with `mktemp`
- **Health check services** — Fixed hardcoded `php8.1-fpm` service name; PHP-FPM version is now detected dynamically. Fixed `mysql`-only check; MariaDB is detected automatically
- **Health check SSL** — Fixed "expires in -5 days" message for already-expired certificates; added multi-path cert discovery for standard Let's Encrypt filenames
- **Health check CPU** — Fixed fragile `top` field-position parsing that silently broke on some distros/locales; added `/proc/stat` fallback
- **Remote stratum setup** — Fixed plaintext SSH credential logging and broken completion messages
- **Add New Stratum Server** — Fixed menu option that showed "not yet available" despite a complete implementation existing

### New Features
- **`check_swap()`** — Swap monitoring added to health check
- **`check_load()`** — System load average and uptime added to health check
- **`check_stratum()`** — Active stratum screen session listing added to health check
- **cron / supervisor / fail2ban** — Added to health check service monitoring
- **SSH hardening table** — `create_user.sh` now fully configures `sshd` for key-only authentication including cloud-init override neutralization
- **Multi-server stratum** — "Add New Stratum Server" menu option fully implemented

See [`CHANGELOG.md`](CHANGELOG.md) for the complete list of changes.

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
