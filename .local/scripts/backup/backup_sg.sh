#!/bin/bash

set -eEuo pipefail

BACKUP_REPO="sftp:opc@sg:/home/opc/D01/hb2"
FILES_LIST="/home/laspavel/.local/scripts/backup/backup_sg_list.txt"
EXCLUDE_LIST="/home/laspavel/.local/scripts/backup/backup_sg_exclude.txt"

LOG_FILE="/tmp/restic.log"
RETENTION_DAYS=7
TIMEOUT_BACKUP=60000
TIMEOUT_COMMAND=900

export RESTIC_PASSWORD_FILE="/home/laspavel/.ssh/id_rsa.pub"
RESTIC_CMD="/home/laspavel/.local/bin/restic -r ${BACKUP_REPO} -v "

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
  log "[ERROR $rc] Command: $LAST_COMMAND"
  exit $rc
}
trap 'on_error' ERR

run_logged() {
  LAST_COMMAND="$*"
  bash -c "$*" 2>&1 | timestamp_output >> "$LOG_FILE"
}

# === Main ===
log "=== Backup script started ==="
log "--- Step 1: Starting backup (timeout = ${TIMEOUT_BACKUP}s) ---"
run_logged "timeout \"$TIMEOUT_BACKUP\" $RESTIC_CMD backup --files-from \"$FILES_LIST\" --exclude-file \"$EXCLUDE_LIST\""

sleep 5
log "--- Step 2: Checking repository integrity (timeout = ${TIMEOUT_COMMAND}s) ---"
run_logged "timeout \"$TIMEOUT_BACKUP\" $RESTIC_CMD check --read-data"

log "--- Step 3: Pruning snapshots older than $RETENTION_DAYS days (timeout = ${TIMEOUT_COMMAND}s) --- "
run_logged "timeout \"$TIMEOUT_COMMAND\" $RESTIC_CMD forget --keep-within \"${RETENTION_DAYS}d\" --prune"

log "=== Backup completed successfully === "
exit 0
