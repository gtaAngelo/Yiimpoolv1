#!/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use
#
# This is the main Options menu for YiimPool.
# Accessible via: yiimpool → Manage & Upgrade Options
#
# Author: Afiniel
# Updated: 2026-03-06
#####################################################

source /etc/yiimpooldonate.conf
source /etc/functions.sh
source /etc/yiimpoolversion.conf

show_menu() {
    RESULT=$(dialog --stdout --title "YiimPool Options $VERSION" --menu "Choose an option" -1 65 10 \
        ' ' "═══════════  Upgrade ═══════════" \
        1 "Upgrade YiimPool Installer" \
        2 "Upgrade Stratum Only" \
        ' ' "═══════════  Tools ═════════════" \
        3 "Add New Stratum Server" \
        4 "Restore from Backup" \
        5 "System Health Check" \
        6 "View Update History" \
        7 "Database Tool Menu" \
        ' ' "════════════════════════════════" \
        8 "Exit")

    case "$RESULT" in
        1)
            clear
            cd "$HOME/Yiimpoolv1/install"
            source bootstrap_upgrade.sh
            exit 0
            ;;
        2)
            clear
            print_status "Starting stratum upgrade..."
            cd "$HOME/Yiimpoolv1/yiimp_upgrade"
            source upgrade.sh --stratum-only
            exit 0
            ;;
        3)
            clear
            print_status "Starting Add New Stratum Server..."
            cd "$HOME/Yiimpoolv1/install"
            source start_add_stratum.sh
            exit 0
            ;;
        4)
            clear
            print_status "Starting restore from backup..."
            cd "$HOME/Yiimpoolv1/yiimp_upgrade/utils"
            source restore.sh
            exit 0
            ;;
        5)
            clear
            print_status "Running system health check..."
            cd "$HOME/Yiimpoolv1/yiimp_upgrade"
            source health_check.sh
            exit 0
            ;;
        6)
            clear
            print_status "Update History (last 30 days):"
            echo
            cd "$HOME/Yiimpoolv1"
            git log --pretty=format:"%C(yellow)%h%Creset  %s  %C(cyan)(%cr)%Creset  <%an>" \
                --since="30 days ago" \
                || echo "No git history available."
            echo
            echo -e "${YELLOW}Press Enter to return to the menu...${NC}"
            read -r
            show_menu
            ;;
        7)
            clear
            print_status "Entering Database Tool Menu..."
            cd "$HOME/Yiimpoolv1/yiimp_upgrade"
            source dbtoolmenu.sh
            ;;
        8)
            clear
            motd
            echo -e "${GREEN}Exiting YiimPool Options Menu${NC}"
            echo -e "${YELLOW}Type 'yiimpool' anytime to return to the menu.${NC}"
            exit 0
            ;;
        *)
            show_menu
            ;;
    esac
}

# Start the menu
clear
show_menu
