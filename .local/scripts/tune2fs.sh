#!/bin/bash
set -euo pipefail

DISK="${1:-/dev/sda1}"
FREEPERC="${2:-5}"

# tune2fs -m 0 /dev/sda1
# /dev/sda1 - имя раздела
# 0 - свободный процент (По умолчанию - 5)

tune2fs -m $2 $1