#!/bin/bash

# Резервное копирование БД Mysql (Dump) с удалением старых копий

# MySQL Backup Script
set -euo pipefail

# --- Config ---
TARGETDIR=$1
RETENTION_DAYS=$2

DATESTAMP=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%F--%H-%M)
DATADIR="$TARGETDIR/$DATESTAMP/DB"
STATUS='/tmp/mysqlbackup_last_status'
LOGFILE="/var/log/mysql_backup.log"
LOCKFILE="/tmp/mysql_backup.lock"

EXCLUDED_DB=(
information_schema
performance_schema
)

# --- Init ---
exec >> "$LOGFILE" 2>&1
exec 200>"$LOCKFILE"
flock -n 200 || { echo "[ERROR] Backup already running"; exit 1; }

mkdir -p "$DATADIR"

# --- Helper ---
is_excluded() {
  for dbex in "${EXCLUDED_DB[@]}"; do
    [[ "$1" == "$dbex" ]] && return 0
  done
  return 1
}

# --- Backup ---
echo "[$(date)] Starting backup..."
ResultCode=0

dblist=$(mysql -e "show databases" | tail -n +2)
for db in $dblist; do
  if ! is_excluded "$db"; then
    echo "[$(date)] Backing up $db..."
    if ! mysqldump --routines --compact --no-create-db "$db" | gzip --best > "$DATADIR/${db}--$TIMESTAMP.sql.gz"; then
      echo "[ERROR] Failed to backup $db"
      ResultCode=1
    fi
  fi
done

# --- Cleanup ---
if [ "$ResultCode" -eq 0 ]; then
  echo "0" > "$STATUS"
  find "$TARGETDIR" -name '*.gz' -type f -mtime +"$RETENTION_DAYS" -delete
  find "$TARGETDIR" -type d -empty -exec rmdir {} \;
  echo "[$(date)] Backup complete."
  exit 0
else
  echo "1" > "$STATUS"
  echo "[$(date)] Backup failed."
  exit 1
fi
