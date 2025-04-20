#!/bin/bash

# Обновление Fedora до новой версии с использованием dnf-plugin-system-upgrade

set -euo pipefail

RELEASEVER=42
LOGFILE="/var/log/system_upgrade_$(date +%F_%T).log"

log() {
  echo "$(date +'%F %T') [INFO] $*" | tee -a "$LOGFILE"
}

err() {
  echo "$(date +'%F %T') [ERROR] $*" | tee -a "$LOGFILE" >&2
  exit 1
}

log "Обновление системы перед upgrade..."
sudo dnf -y upgrade --refresh || err "Ошибка при обновлении системы"

log "Установка плагина system-upgrade..."
sudo dnf -y install dnf-plugin-system-upgrade || err "Не удалось установить плагин"

log "Загрузка пакетов для Fedora $RELEASEVER..."
sudo dnf -y system-upgrade download --releasever="$RELEASEVER" --allowerasing \
  --skip-broken || err "Ошибка при загрузке пакетов"

log "Готово к перезагрузке. Запускаем обновление..."
sudo dnf system-upgrade reboot || err "Ошибка при запуске перезагрузки"


### After reboot ###
sudo rpm --rebuilddb
sudo dnf distro-sync --setopt=deltarpm=0
sudo dnf install rpmconf
sudo rpmconf -a

gnome-shell-extension-installer 1160 --yes --restart-shell
