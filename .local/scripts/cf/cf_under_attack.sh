#!/bin/bash

# Автоматическое переключение режима Cloudflare на "Under Attack" при высокой нагрузке, с уведомлением в Telegram. 

set -euo pipefail

### === Конфигурация === ###
# Telegram
CHAT_ID="${CHAT_ID:-75054573}"
TOKEN_FILE="${TOKEN_FILE:-$HOME/.tg_token}"

# Cloudflare
ZONEID="$1"
AUTHEMAIL="$2"
AUTHKEY="$3"

# Пороговая нагрузка на ядро
LOAD_LIMIT_PER_CORE=0.7

# Временные файлы
TMP_DIR="/tmp"
TMP_JSON="${TMP_DIR}/cf_status_${ZONEID}.json"
TMP_STATUS="${TMP_DIR}/cf_status_value_${ZONEID}.txt"
LOG_FILE="/var/log/cloudflare_protect.log"

### === Проверка аргументов === ###
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <ZONEID> <AUTHEMAIL> <AUTHKEY>"
  exit 1
fi

if [[ ! -f "$TOKEN_FILE" ]]; then
  echo "Telegram token file not found: $TOKEN_FILE"
  exit 2
fi

### === Функции === ###
log() {
  local msg="$1"
  echo "$(date +'%F %T') - $msg" >> "$LOG_FILE"
}

send_telegram() {
  local message="$1"
  local token
  token=$(<"$TOKEN_FILE")
  curl -s -X POST -H 'Content-Type: application/json' \
    -d "{\"chat_id\":\"${CHAT_ID}\",\"text\":\"${message}\"}" \
    "https://api.telegram.org/bot${token}/sendMessage" >/dev/null
}

get_current_status() {
  if [[ -f "$TMP_JSON" ]]; then
    awk -F':' '{ print $4 }' "$TMP_JSON" | awk -F',' '{ print $1 }' | tr -d '"' > "$TMP_STATUS"
    cat "$TMP_STATUS"
  else
    echo ""
  fi
}

update_cloudflare() {
  local new_value="$1"
  curl -sSX PATCH "https://api.cloudflare.com/client/v4/zones/$ZONEID/settings/security_level" \
       -H "X-Auth-Email: $AUTHEMAIL" \
       -H "X-Auth-Key: $AUTHKEY" \
       -H "Content-Type: application/json" \
       --data "{\"value\":\"${new_value}\"}" > "$TMP_JSON"
}

### === Основная логика === ###
# Получаем текущую нагрузку и порог
load=$(awk '{print $1}' /proc/loadavg)
cpu_cores=$(nproc)
load_threshold=$(awk -v c="$cpu_cores" -v l="$LOAD_LIMIT_PER_CORE" 'BEGIN { printf "%.2f", c * l }')

log "Current load: $load / Threshold: $load_threshold"

current_status=$(get_current_status)

if (( $(echo "$load > $load_threshold" | bc -l) )); then
  if [[ "$current_status" != "under_attack" ]]; then
    update_cloudflare "under_attack"
    log "Switched to UNDER_ATTACK mode"
    send_telegram "[ALARM] Cloudflare: Under Attack Mode activated."
  else
    log "Already in UNDER_ATTACK mode. No action needed."
  fi
else
  if [[ "$current_status" == "under_attack" ]]; then
    update_cloudflare "medium"
    log "Switched to MEDIUM security mode"
    send_telegram "[OK] Cloudflare: Under Attack Mode deactivated."
  else
    log "Already in MEDIUM mode. No action needed."
  fi
fi
