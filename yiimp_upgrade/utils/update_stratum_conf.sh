#!/usr/bin/env bash

##########################################
# Created by Afiniel for Yiimpool use
#
# Applies pool credentials to every *.conf
# file inside the live stratum/config
# directory.  Uses the exact same sed
# substitutions as yiimp_single/stratum.sh
# so both the initial install and the
# upgrade path stay in sync.
#
# Sources required:
#   /etc/functions.sh
#   /etc/yiimpool.conf
#   $STORAGE_ROOT/yiimp/.yiimp.conf
#   $HOME/Yiimpoolv1/yiimp_single/.wireguard.install.cnf
#
# Author: Afiniel
# Date: 2026-03-14
##########################################

source /etc/functions.sh
source /etc/yiimpool.conf
source "$STORAGE_ROOT/yiimp/.yiimp.conf"
source "$HOME/Yiimpoolv1/yiimp_single/.wireguard.install.cnf"

# log_message is defined in the upgrade utils/functions.sh but this script may
# run in its own subshell (via `bash`), so define it here to be self-contained.
log_message() {
    local level=$1
    local message=$2
    echo -e "${level}[$(date '+%Y-%m-%d %H:%M:%S')] ${message}${NC}"
}

STRATUM_CONF="$STORAGE_ROOT/yiimp/site/stratum/config"

# ── Guard ────────────────────────────────────────────────────────────────────
if [ ! -d "$STRATUM_CONF" ]; then
    log_message "$RED" "Stratum config directory not found: $STRATUM_CONF"
    exit 1
fi

CONF_COUNT=$(find "$STRATUM_CONF" -maxdepth 1 -name "*.conf" | wc -l)
if [ "$CONF_COUNT" -eq 0 ]; then
    log_message "$RED" "No .conf files found in $STRATUM_CONF"
    exit 1
fi

log_message "$YELLOW" "Updating $CONF_COUNT stratum config file(s) in $STRATUM_CONF ..."
cd "$STRATUM_CONF" || exit 1

# ── Blocknotify password ──────────────────────────────────────────────────────
sudo sed -i "s/password = tu8tu5/password = $BlocknotifyPassword/g" *.conf
log_message "$GREEN" "  blocknotify password applied"

# ── Pool / stratum URL ────────────────────────────────────────────────────────
sudo sed -i "s/server = yaamp.com/server = $StratumURL/g" *.conf
log_message "$GREEN" "  stratum server URL applied  ($StratumURL)"

# ── Database host (WireGuard vs local) ───────────────────────────────────────
if [[ "$wireguard" == "true" ]]; then
    sudo sed -i "s/host = yaampdb/host = $DBInternalIP/g" *.conf
    log_message "$GREEN" "  DB host set to WireGuard internal IP ($DBInternalIP)"
else
    sudo sed -i "s/host = yaampdb/host = localhost/g" *.conf
    log_message "$GREEN" "  DB host set to localhost"
fi

# ── Database name ─────────────────────────────────────────────────────────────
sudo sed -i "s/database = yaamp/database = $YiiMPDBName/g" *.conf
log_message "$GREEN" "  DB name applied  ($YiiMPDBName)"

# ── Database username ─────────────────────────────────────────────────────────
sudo sed -i "s/username = root/username = $StratumDBUser/g" *.conf
log_message "$GREEN" "  DB username applied  ($StratumDBUser)"

# ── Database password ─────────────────────────────────────────────────────────
sudo sed -i "s/password = patofpaq/password = $StratumUserDBPassword/g" *.conf
log_message "$GREEN" "  DB password applied"

# ── Permissions ───────────────────────────────────────────────────────────────
sudo chown -R www-data:www-data "$STRATUM_CONF"
sudo chmod -R 750 "$STRATUM_CONF"

log_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_message "$GREEN" "  Stratum config credentials updated successfully!"
log_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
