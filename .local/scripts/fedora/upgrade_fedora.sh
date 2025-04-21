#!/bin/bash

# Обновление Fedora до новой версии с использованием dnf-plugin-system-upgrade

set -euo pipefail
LOGFILE="/var/log/system_upgrade_$(date +%F_%T).log"
exec > >(tee -a "$LOGFILE") 2>&1

RELEASEVER=42

sudo dnf -y upgrade --refresh 
sudo dnf -y install dnf-plugin-system-upgrade
sudo dnf -y system-upgrade download --releasever="$RELEASEVER"
sudo dnf system-upgrade reboot


### After reboot ###
sudo rpm --rebuilddb
sudo dnf distro-sync --setopt=deltarpm=0
sudo dnf install rpmconf
sudo rpmconf -a

gnome-shell-extension-installer 1160 --yes --restart-shell
