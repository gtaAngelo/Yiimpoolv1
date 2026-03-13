#!/usr/bin/env bash

##########################################
# Created by Afiniel for Yiimpool use
#
# Entry point for adding a new Stratum
# server to an existing YiiMP installation.
#
# Author: Afiniel
# Date: 2026-03-06
##########################################

source /etc/functions.sh
source /etc/yiimpool.conf
source /etc/yiimpoolversion.conf

cd "$HOME/Yiimpoolv1/install"

source questions_add_stratum.sh
clear
source add_stratum_db.sh
source setsid_stratum_server.sh

print_success "New stratum server added successfully!"
print_info "You can manage it from the YiimPool Options menu."

cd ~
exit 0
