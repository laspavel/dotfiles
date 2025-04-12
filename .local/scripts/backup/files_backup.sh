#!/bin/bash

# Резервное копирование файлов с удалением старых копий

set -euo pipefail

# --- Config ---
TARGETDIR=${1:?Target directory required}
RETENTION_DAYS=${2:?Retention days required}
DATESTAMP=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%F--%H-%M)
DATADIR="$TARGETDIR/$DATESTAMP/FILES"
STATUS='/tmp/filesbackup_last_status'
LOGFILE="/var/log/files_backup.log"
LOCKFILE="/tmp/files_backup.lock"

INCLUDES=(
  "/etc"
  "/root"
  "/var/www"
)
EXCLUDES=(
  "--exclude=*/cache/*"
  "--exclude=*/BACKUP/*"
  "--exclude=*/tmp/*"
)

# --- Init ---
exec >> "$LOGFILE" 2>&1
exec 200>"$LOCKFILE"
flock -n 200 || { echo "[ERROR] Backup already running"; exit 1; }

echo "[$(date)] Starting file backup..."

mkdir -p "$DATADIR"

ARCHIVE_NAME="$DATADIR/backup--$TIMESTAMP.tgz"

# --- Construct tar command ---
TAR_CMD=(tar -czpf "$ARCHIVE_NAME")
TAR_CMD+=("${EXCLUDES[@]}")
TAR_CMD+=("${INCLUDES[@]}")

# --- Run tar ---
echo "[$(date)] Running tar..."
if ! "${TAR_CMD[@]}"; then
  echo "1" > "$STATUS"
  echo "[$(date)] File backup FAILED"
  exit 1
fi

# --- Cleanup old backups ---
find "$TARGETDIR" -name '*.tgz' -type f -mtime +"$RETENTION_DAYS" -delete
find "$TARGETDIR" -type d -empty -exec rmdir {} \;

echo "0" > "$STATUS"
echo "[$(date)] File backup SUCCESSFUL"
exit 0
