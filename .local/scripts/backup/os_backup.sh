#!/bin/bash

# Резервное копирование всех реальных файлов

set -euo pipefail

TARGETDIR=${1:?Target directory required}
TIMESTAMP=$(date +%F--%H-%M)

# --- Config ---
FILENAME=$(hostname)

EXCLUDES=(
     "--exclude=/dev"
     "--exclude=/mnt"
     "--exclude=/proc"
     "--exclude=/sys"
     "--exclude=/run"
     "--exclude=/tmp"
     "--exclude=/media"
     "--exclude=/lost+found"
     "--exclude=/swapfile"
     "--exclude=/swap"
)

tar zcvf $TARGETDIR/$FILENAME_$TIMESTAMP.tar.gz --exclude=$TARGETDIR/$FILENAME_$TIMESTAMP.tar.gz ${EXCLUDES[@]} / 
