#!/bin/bash
set -euo pipefail

# --- CONFIG ---
BACKUP_ROOT="/mnt/PG_BACKUP"
RETENTION_DAYS=7
DATESTAMP=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%F--%H-%M)

PG_USER="postgres"
PG_HOST="127.0.0.1"
PG_PORT="5432"

STATUS_FILE="/tmp/pg_backup_last_status"
LOGFILE="/var/log/pg_backup.log"
LOCKFILE="/tmp/pg_backup.lock"

ARCHIVE_DIR="$BACKUP_ROOT/$DATESTAMP"
DUMP_DIR="$ARCHIVE_DIR/dumps"
GLOBAL_FILE="$ARCHIVE_DIR/globals/pg_globals--$TIMESTAMP.sql.gz"
BASEBACKUP_DIR="$ARCHIVE_DIR/basebackup"

CHAT_ID="YOUR_CHAT_ID"
TOKEN_FILE="/etc/backup/telegram_token"

# --- TELEGRAM ---
send_telegram() {
  local msg="$1"
  local token
  token=$(<"$TOKEN_FILE")
  curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
       -H "Content-Type: application/json" \
       -d "{\"chat_id\":\"${CHAT_ID}\",\"text\":\"${msg}\"}"
}

# --- INIT ---
exec >> "$LOGFILE" 2>&1
exec 200>"$LOCKFILE"
flock -n 200 || { echo "[$(date)] Backup already running"; exit 1; }

echo "[$(date)] Starting PostgreSQL backup..."

mkdir -p "$DUMP_DIR" "$BASEBACKUP_DIR" "$(dirname "$GLOBAL_FILE")"

# --- FUNCTION TO DUMP INDIVIDUAL DATABASE ---
dump_individual_dbs() {
  db_list=$(psql -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -d postgres -Atc "SELECT datname FROM pg_database WHERE datistemplate = false;")

  for db in $db_list; do
    echo "[$(date)] Dumping database: $db"
    if ! pg_dump -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT"  -Fd "$db" -j $(nproc) -f "$DUMP_DIR/${db}"; then
      echo "[ERROR] Failed to dump database: $db"
      return 1
    fi
  done
}

# --- FUNCTION TO DUMP GLOBAL OBJECTS (roles, configs) ---
dump_globals() {
  echo "[$(date)] Dumping global roles/configs..."
  if ! pg_dumpall -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -c --globals-only | gzip > "$GLOBAL_FILE"; then
    echo "[ERROR] Failed to dump global roles/configs"
    return 1
  fi
}

# --- FUNCTION TO CREATE BASE BACKUP (full binary replica) ---
base_backup() {
  echo "[$(date)] Performing pg_basebackup..."
  if ! pg_basebackup -U "$PG_USER" -h "$PG_HOST" -p "$PG_PORT" -R -Ft -z -D "$BASEBACKUP_DIR" --label="backup-$TIMESTAMP"; then
    echo "[ERROR] pg_basebackup failed"
    return 1
  fi
}

# --- RUN BACKUPS ---
ERROR_FLAG=0

dump_individual_dbs || ERROR_FLAG=1
dump_globals || ERROR_FLAG=1
base_backup || ERROR_FLAG=1

# --- CLEANUP ---
echo "[$(date)] Cleaning old backups..."
find "$BACKUP_ROOT" -type f -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_ROOT" -type d -empty -exec rmdir {} \;

# --- FINAL STATUS ---
if [ "$ERROR_FLAG" -eq 0 ]; then
  echo "0" > "$STATUS_FILE"
  send_telegram "✅ PostgreSQL backup completed successfully at $(date)"
  echo "[$(date)] Backup SUCCESSFUL"
else
  echo "1" > "$STATUS_FILE"
  send_telegram "🚨 PostgreSQL backup FAILED at $(date)"
  echo "[$(date)] Backup FAILED"
  exit 1
fi
