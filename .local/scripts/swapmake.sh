#!/bin/bash
set -euo pipefail

# === Параметры ===
SWAPFILE="${1:-}"
SWAPSIZE_GB="${2:-}"

# === Проверка параметров ===
if [[ -z "$SWAPFILE" || -z "$SWAPSIZE_GB" ]]; then
  echo "Usage: $0 <swapfile path> <size in GB>"
  echo "Example: $0 /swapfile 2"
  exit 1
fi

# === Проверка существующего файла ===
if [[ -f "$SWAPFILE" ]]; then
  echo "Error: Swapfile $SWAPFILE already exists."
  exit 2
fi

# === Проверка корректности числа ===
if ! [[ "$SWAPSIZE_GB" =~ ^[0-9]+$ ]]; then
  echo "Error: Swap size must be a positive integer in GB."
  exit 3
fi

# === Расчёт размера в мегабайтах ===
SWAPSIZE_MB=$(( SWAPSIZE_GB * 1024 ))

echo "Creating ${SWAPSIZE_GB} GB swapfile at: $SWAPFILE..."

# === Создание файла (предпочтительно fallocate) ===
if command -v fallocate >/dev/null 2>&1; then
  fallocate -l "${SWAPSIZE_GB}G" "$SWAPFILE"
else
  dd if=/dev/zero of="$SWAPFILE" bs=1M count="$SWAPSIZE_MB" status=progress
fi

chmod 600 "$SWAPFILE"
mkswap "$SWAPFILE"
swapon "$SWAPFILE"

echo "Swap enabled:"
swapon --show

# === Добавление в /etc/fstab ===
if ! grep -q -E "^\s*${SWAPFILE}\s+" /etc/fstab; then
  echo "$SWAPFILE swap swap defaults 0 0" >> /etc/fstab
  echo "Added to /etc/fstab: $SWAPFILE"
else
  echo "Swapfile already present in /etc/fstab"
fi
