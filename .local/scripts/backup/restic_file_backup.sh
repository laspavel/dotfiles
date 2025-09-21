#!/bin/bash

set -euo pipefail

BACKUP_REPO="/mnt/BACKUP/r01/i-shop/i-shop-p01/"
FILES_LIST="/etc/tools/backup/backup_list.txt"
EXCLUDE_LIST="/etc/tools/backup/backup_exclude.txt"

LOG_FILE="/var/log/backup/restic.log"
STATUS_FILE="/var/log/backup/restic.status"
RETENTION_DAYS=30
TIMEOUT_BACKUP=3600
TIMEOUT_COMMAND=900

RESTIC_CMD="restic -r ${BACKUP_REPO} -v --insecure-no-password"

# === Add timestamp ===
timestamp_output() {
  awk '{ print strftime("%Y-%m-%d %H:%M:%S - "), $0; fflush(); }'
}

# === Logging ===
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# === Errors handler ===
on_error() {
  local rc=$?
  log "[ERROR $rc] Command: $CUR_COMMAND"
  echo "error" > "$STATUS_FILE"
  exit $rc
}
trap 'CUR_COMMAND="${BASH_COMMAND}"; on_error' ERR

# === Main ===
log "=== Backup script started ==="
log "--- Step 1: Starting backup (timeout = ${TIMEOUT_BACKUP}s) ---"
timeout "$TIMEOUT_BACKUP" $RESTIC_CMD backup \
  --files-from "$FILES_LIST" \
  --exclude-file="$EXCLUDE_LIST" 2>&1 | timestamp_output >> "$LOG_FILE"

log "--- Step 2: Checking repository integrity (timeout = ${TIMEOUT_COMMAND}s) ---"
timeout "$TIMEOUT_COMMAND" $RESTIC_CMD check 2>&1 | timestamp_output >> "$LOG_FILE"
#timeout "$TIMEOUT_BACKUP" $RESTIC_CMD check --read-data 2>&1 | timestamp_output >> "$LOG_FILE"
#timeout "$TIMEOUT_BACKUP" $RESTIC_CMD check  --read-data-subset 10% 2>&1 | timestamp_output >> "$LOG_FILE"

log "--- Step 3: Pruning snapshots older than $RETENTION_DAYS days (timeout = ${TIMEOUT_COMMAND}s) --- "
timeout "$TIMEOUT_COMMAND" $RESTIC_CMD forget --keep-within "${RETENTION_DAYS}d" --prune 2>&1 | timestamp_output >> "$LOG_FILE"

log "=== Backup completed successfully === "
echo "ok" > "$STATUS_FILE"
