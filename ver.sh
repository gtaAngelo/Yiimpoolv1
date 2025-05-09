#!/usr/bin/env bash
#########################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by Afiniel for Yiimpool use...
# This script is intended to be run like this:
#
# curl https://raw.githubusercontent.com/afiniel/yiimp_install_script/master/install.sh | bash
#
#########################################################

if [ -z "${TAG}" ]; then
	TAG=v2.5.1
fi

echo "VERSION=v2.5.1" | sudo tee /etc/yiimpoolversion.conf > /dev/null 2>&1
