#!/usr/bin/env bash
# macOS backup helper: Brewfile + restic (include/exclude) + logging
# Requirements: bash, brew, restic
set -Eeuo pipefail

#####################################
# CONFIG (можно переопределить env) #
#####################################
: "${BREWFILE:=$HOME/Brewfile}"
: "${BACKUP_STATE_DIR:=$HOME/.backup}"
: "${INCLUDE_FILE:=$BACKUP_STATE_DIR/include.txt}"
: "${EXCLUDE_FILE:=$BACKUP_STATE_DIR/exclude.txt}"

# По умолчанию используем SFTP-репозиторий из вашей переписки:
: "${RESTIC_REPOSITORY:=sftp:sg:/home/opc/D01/mb1/}"
# Пароль/ключ указывайте через RESTIC_PASSWORD или RESTIC_PASSWORD_FILE
# : "${RESTIC_PASSWORD:=}"
: "${RESTIC_PASSWORD_FILE:=$BACKUP_STATE_DIR/.rpass}"

: "${LOG_DIR:=$HOME/Library/Logs/restic}"
: "${VERBOSE_LEVEL:=1}"         # 0..3
: "${TAG:=macos}"
: "${DRY_RUN:=0}"               # 1 = только показать, что будет бэкапиться

#####################################
# ЛОГИРОВАНИЕ                       #
#####################################
mkdir -p "$LOG_DIR" "$BACKUP_STATE_DIR"
LOG_FILE="$LOG_DIR/backup_$(date +%Y-%m-%d_%H%M%S).log"

timestamp_output() {
  while IFS= read -r line; do
    printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line"
  done
}

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $*"; }

# Весь STDOUT/STDERR — в лог с таймстемпами (+ дублируем в консоль)
exec > >(timestamp_output | tee -a "$LOG_FILE") 2>&1

trap 'rc=$?; echo "[ERROR $rc] Last command failed: $BASH_COMMAND" >&2' ERR

#####################################
# ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ           #
#####################################
require_bin() {
  local b="$1"
  if ! command -v "$b" >/dev/null 2>&1; then
    echo "❌ Требуется утилита: $b" >&2
    exit 127
  fi
}

ensure_defaults() {
  # include.txt по умолчанию (консервативно, без гловов и с ~)
  if [[ ! -f "$INCLUDE_FILE" ]]; then
    cat > "$INCLUDE_FILE" <<'EOF'
# ---- Include (редактируйте под себя) ----
# Dotfiles и конфиги
~/.zshrc
~/.bashrc
~/.profile
~/.zprofile
~/.aliases
~/.functions
~/.tmux.conf
~/.vimrc
~/.gitconfig
~/.tmux.conf
~/.tmux.conf.local
~/.ssh/
~/.gnupg/
~/.config/
# Karabiner
~/.config/karabiner/karabiner.json
# iTerm2
~/Library/Preferences/com.googlecode.iterm2.plist
# VS Code
~/Library/Application Support/Code/User/
# JetBrains (если используете)
~/Library/Application Support/JetBrains/
# Связки ключей (осмотрительно)
~/Library/Keychains/
# Brewfile (обновляется автоматом)
~/Brewfile
# Рабочие каталоги
~/Documents/
~/Projects/
~/Work/
~/Desktop/
EOF
    log "Создан дефолтный $INCLUDE_FILE"
  fi

  # exclude.txt по умолчанию
  if [[ ! -f "$EXCLUDE_FILE" ]]; then
    cat > "$EXCLUDE_FILE" <<'EOF'
# ---- Exclude ----
~/Library/Caches/
~/Library/Logs/
~/Downloads/
**/.DS_Store
**/*.tmp
**/~$*
EOF
    log "Создан дефолтный $EXCLUDE_FILE"
  fi
}

generate_brewfile() {
  if command -v brew >/dev/null 2>&1; then
    # Обновляем список установленных формул/касков
    brew bundle dump --force --file="$BREWFILE"
    log "Обновлён $BREWFILE"
  else
    echo "⚠️  Homebrew не найден — пропускаю генерацию Brewfile."
  fi
}

print_plan() {
  echo
  echo "====== ПЛАН БЭКАПА ======"
  echo "RESTIC_REPOSITORY : ${RESTIC_REPOSITORY}"
  if [[ -n "${RESTIC_PASSWORD_FILE:-}" ]]; then
    echo "RESTIC_PASSWORD_FILE: ${RESTIC_PASSWORD_FILE}"
  else
    echo "RESTIC_PASSWORD     : ${RESTIC_PASSWORD:+<set>}${RESTIC_PASSWORD:+ (используется env)}"
  fi
  echo "Include file       : ${INCLUDE_FILE}"
  echo "Exclude file       : ${EXCLUDE_FILE}"
  echo "Log file           : ${LOG_FILE}"
  echo "Tag                : ${TAG}"
  echo "Verbose            : ${VERBOSE_LEVEL}"
  echo "Dry run            : ${DRY_RUN}"
  echo "========================="
  echo
}

#####################################
# ГЛАВНАЯ ЛОГИКА                    #
#####################################
main() {
  require_bin bash
  require_bin awk
  require_bin restic

  ensure_defaults
  generate_brewfile

  print_plan

  # Соберём базовые флаги restic
  RESTIC_FLAGS=( -r "$RESTIC_REPOSITORY" --verbose="$VERBOSE_LEVEL" --tag "$TAG" )
  [[ "${DRY_RUN}" == "1" ]] && RESTIC_FLAGS+=( --dry-run )

  # Запуск backup
  echo "=== Старт backup ==="
  restic "${RESTIC_FLAGS[@]}" \
    backup \
    --password-file "$RESTIC_PASSWORD_FILE" \
    --files-from "$INCLUDE_FILE" \
    --exclude-file "$EXCLUDE_FILE"

  echo "=== Готово ==="

  # По желанию можно добавить forget+prune (отключено по умолчанию):
  restic "${RESTIC_FLAGS[@]}" forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
}

main "$@"
