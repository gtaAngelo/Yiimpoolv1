#!/usr/bin/env bash

##########################################
# Created by Afiniel for Yiimpool use
#
# Orchestrates full or stratum-only upgrades
# for an existing YiimPool installation.
#
# Usage:
#   source upgrade.sh               # Full installer upgrade
#   source upgrade.sh --stratum-only  # Stratum recompile only
#
# Author: Afiniel
# Date: 2026-03-06
##########################################

source /etc/functions.sh
source /etc/yiimpool.conf
source /etc/yiimpoolversion.conf
source $HOME/Yiimpoolv1/yiimp_upgrade/utils/functions.sh

UPGRADE_TYPE="full"
if [ "${1:-}" == "--stratum-only" ]; then
    UPGRADE_TYPE="stratum"
fi

main() {
    log_message "$YELLOW" "Starting YiimPool upgrade..."
    log_message "$YELLOW" "Current version : $VERSION"
    log_message "$YELLOW" "Upgrade type    : $UPGRADE_TYPE"
    echo

    if ! verify_requirements; then
        log_message "$RED" "System requirements not met. Aborting upgrade."
        exit 1
    fi

    backup_system

    case "$UPGRADE_TYPE" in
        "full")
            log_message "$YELLOW" "Fetching latest YiimPool release from GitHub..."
            LATEST_TAG=$(get_latest_release) || {
                log_message "$RED" "Failed to fetch latest release. Aborting."
                exit 1
            }

            if [ "$LATEST_TAG" = "$VERSION" ]; then
                log_message "$GREEN" "YiimPool is already up to date ($VERSION). No upgrade needed."
                exit 0
            fi

            log_message "$YELLOW" "Upgrading YiimPool: $VERSION → $LATEST_TAG"
            echo

            cd "$HOME/Yiimpoolv1"
            sudo chown -R "$USER" "$HOME/Yiimpoolv1/.git/"

            log_message "$YELLOW" "Fetching release $LATEST_TAG from GitHub..."
            if ! git fetch --depth 1 --force --prune origin tag "${LATEST_TAG}"; then
                log_message "$RED" "Failed to fetch $LATEST_TAG. Aborting."
                exit 1
            fi

            if ! git checkout -q "${LATEST_TAG}"; then
                log_message "$RED" "Failed to check out $LATEST_TAG. Aborting."
                exit 1
            fi

            echo "VERSION=${LATEST_TAG}" | sudo tee /etc/yiimpoolversion.conf >/dev/null
            log_message "$GREEN" "Version updated: $VERSION → $LATEST_TAG"

            if ! verify_upgrade; then
                log_message "$RED" "Post-upgrade service check failed. Please review service status."
                exit 1
            fi

            echo
            log_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_message "$GREEN" "  YiimPool upgrade complete!"
            log_message "$GREEN" "  New version: $LATEST_TAG"
            log_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_message "$YELLOW" "  Run 'yiimpool' to return to the management menu."
            echo
            ;;

        "stratum")
            log_message "$YELLOW" "Running stratum-only upgrade..."
            echo

            if ! upgrade_stratum; then
                log_message "$RED" "Stratum upgrade failed. Check the output above for details."
                exit 1
            fi

            if ! verify_upgrade; then
                log_message "$RED" "Post-upgrade service check failed. Please review service status."
                exit 1
            fi

            echo
            log_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_message "$GREEN" "  Stratum upgrade complete!"
            log_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_message "$YELLOW" "  Run 'yiimpool' to return to the management menu."
            echo
            ;;
    esac
}

main "$@"
