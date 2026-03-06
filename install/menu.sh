#!/bin/env bash

#
# YiimPool Menu Script
#
# Author: Afiniel
# Updated: 2026-03-06
#

# Load configuration and functions
source /etc/yiimpool.conf
source /etc/yiimpoolversion.conf
source /etc/functions.sh

display_version_info

RESULT=$(dialog --stdout --nocancel --default-item 1 --title "YiimPool Menu $VERSION" --menu "Choose an option" -1 60 6 \
    ' ' "═══════════  YiimPool Installer ═══════════" \
    1 "Install YiiMP Single Server" \
    2 "Manage & Upgrade Options" \
    3 "Exit")

case "$RESULT" in
    1)
        clear
        echo "Preparing to install YiiMP Single Server..."
        cd $HOME/Yiimpoolv1/yiimp_single
        source start.sh
        ;;
    2)
        clear
        cd $HOME/Yiimpoolv1/install
        source options.sh
        ;;
    3)
        clear
        motd
        echo -e "${GREEN}Exiting YiimPool Menu${NC}"
        echo -e "${YELLOW}Type 'yiimpool' anytime to return to the menu${NC}"
        exit 0
        ;;
esac