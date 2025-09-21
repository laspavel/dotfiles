#!/bin/bash

set -euo pipefail

BACKUP_REPO="/mnt/BACKUP/r01/i-shop/i-shop-p01/"

LOG_FILE="/var/log/backup/restic_test.log"
STATUS_FILE="/var/log/backup/restic_test.status"
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
log "=== Test script started ==="
log "--- Step 1: Checking repository integrity (timeout = ${TIMEOUT_COMMAND}s) ---"
#timeout "$TIMEOUT_BACKUP" $RESTIC_CMD check --read-data 2>&1 | timestamp_output >> "$LOG_FILE"
timeout "$TIMEOUT_BACKUP" $RESTIC_CMD check  --read-data-subset 10% 2>&1 | timestamp_output >> "$LOG_FILE"

log "=== Backup completed successfully === "
echo "ok" > "$STATUS_FILE"
