#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use
#
# This is the Database Tool Menu for Yiimpool
#
# Author: Afiniel
# Updated: 2026-03-06
#####################################################

source /etc/yiimpooldonate.conf
source /etc/functions.sh
source /etc/yiimpoolversion.conf

term_art
print_header "Database Tool Menu"

RESULT=$(dialog --stdout --title "Database Tool Menu $VERSION" --menu "Choose an option" 12 60 4 \
    ' ' "═══════════  Database Tools ═══════════" \
    1 "Import YiiMP Database" \
    2 "Exit")

case "$RESULT" in
    1)
        clear
        cd $HOME/Yiimpoolv1/yiimp_upgrade
        source db.sh
        ;;
    2)
        clear
        motd
        echo -e "${GREEN}Exiting Database Import Menu${NC}"
        echo -e "${YELLOW}Type 'yiimpool' anytime to return to the menu${NC}"
        exit 0
        ;;
    *)
        clear
        exit 0
        ;;
esac
