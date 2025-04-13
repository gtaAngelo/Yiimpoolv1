#!/bin/bash
##################################################################
# Current Modified by Afiniel for Daemon coin & addport & stratum
##################################################################
source /etc/functions.sh
source /etc/yiimpool.conf
source /etc/yiimpoolversion.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf

path_stratum=$STORAGE_ROOT/yiimp/site/stratum
absolutepath=/home/crypto-data

installtoserver=daemon_builder
daemonname=daemonbuilder



ESC_SEQ="\x1b["
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[0;36m'
NC='\033[0m'


BOLD='\033[1m'
DIM='\033[2m'

print_header() {
    echo -e "\n${BLUE}${BOLD}=== $1 ===${NC}\n"
}

print_status() {
    echo -e "${DIM}[${NC}${GREEN}●${NC}${DIM}]${NC} $1"
}

print_error() {
    echo -e "${RED}${BOLD}ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}WARNING:${NC} $1"
}

print_success() {
    echo -e "${GREEN}${BOLD}SUCCESS:${NC} $1"
}

print_info() {
    echo -e "${BLUE}${BOLD}INFO:${NC} $1"
}

print_divider() {
    echo -e "\n${DIM}────────────────────────────────────────────────────────${NC}\n"
}
