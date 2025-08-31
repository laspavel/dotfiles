#!/bin/bash

# To cron: 00 14 * * * laspavel cd /home/laspavel/_/dotfiles/ && ./bootstrap.sh --backup

# Simplified dotfiles backup/restore (console-only) for Linux/macOS
# - no archives, no SSH/history backups
# - sync ~/.local/scripts <-> ./local/scripts
# - optional --delete for scripts sync

set -euo pipefail
IFS=$'\n\t'

# ==========================
# Settings
# ==========================
RSYNC_DELETE="${RSYNC_DELETE:-0}"   # 1 — удалять лишние файлы при синхронизации scripts

# ==========================
# Helpers
# ==========================
os_family() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"; return
  fi
  if [[ -d /etc/apt/sources.list.d/ ]]; then
    echo "deb_compat"; return
  fi
  echo "rpm_compat"
}

pkg_install() {
  local pkg="$1"
  case "$(os_family)" in
    deb_compat)  sudo apt-get update -y && sudo apt-get install -y --no-install-recommends "$pkg" ;;
    rpm_compat)  if command -v dnf >/dev/null 2>&1; then sudo dnf install -y "$pkg"; else sudo yum install -y "$pkg"; fi ;;
    macos)       command -v brew >/dev/null 2>&1 || { echo "Install Homebrew: https://brew.sh/"; exit 1; }; brew install "$pkg" || true ;;
  esac
}

need_cmd() { command -v "$1" >/dev/null 2>&1 || pkg_install "$2"; }

msg()  { printf '\033[1;34m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m%s\033[0m\n' "$*" >&2; }

copy_if_exists() {
  # copy_if_exists SRC DSTDIR [MODE]
  local src="$1" dst="$2" mode="${3:-}"
  if [[ -e "$src" ]]; then
    mkdir -p "$dst"
    rsync -a "$src" "$dst/"
    [[ -n "$mode" ]] && chmod -R "$mode" "$dst/$(basename "$src")" || true
  fi
}

rsync_scripts() {
  local src="$1" dst="$2"
  local -a flags=("-a")
  if [[ "${RSYNC_DELETE:-0}" == "1" ]]; then
    flags+=("--delete" "--delete-excluded")
  fi
  rsync "${flags[@]}" "$src" "$dst"
}

# ==========================
# Restore (repo -> $HOME)
# ==========================
RestoreDotFiles() {
  msg "[Restore] Checking rsync…"
  need_cmd rsync rsync

  if command -v git >/dev/null 2>&1; then
    local oldmask; oldmask=$(umask)
    umask 0077
    git config --global -l | LANG=C sort > .oldgit$$.tmp || true
    umask "$oldmask"
  fi

  msg "[Restore] Rsync dotfiles into \$HOME…"
  rsync --exclude ".git/" \
        --exclude "bootstrap.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        --exclude "local/" \
        -avh --no-perms . ~;

  if [[ -d "./local/scripts" ]]; then
    msg "[Restore] Sync ./local/scripts -> ~/.local/scripts (delete=$RSYNC_DELETE)"
    mkdir -p "$HOME/.local/scripts"
    # shellcheck disable=SC2046
    rsync_scripts "$HOME/.local/scripts/" "$STARTDIR/.local/scripts/"
  fi

  msg "[Restore] Done."
}

# ==========================
# Backup ($HOME -> repo)
# ==========================
BackupDotFiles() {
  local STARTDIR; STARTDIR="$(pwd)"
  local DATE; DATE="$(date '+%Y-%m-%d %H:%M:%S')"

  msg "[Backup] Checking rsync…"
  need_cmd rsync rsync

  copy_if_exists "$HOME/.config/mc/ini"                  "$STARTDIR/.config/mc"
  copy_if_exists "$HOME/.config/mc/panels.ini"           "$STARTDIR/.config/mc"
  copy_if_exists "$HOME/.config/htop/htoprc"             "$STARTDIR/.config/htop"
  copy_if_exists "$HOME/.config/k9s"                     "$STARTDIR/.config"
  copy_if_exists "$HOME/.config/wget/wget2rc"            "$STARTDIR/.config/wget"
  copy_if_exists "$HOME/.config/tmux"                    "$STARTDIR/.config"

  copy_if_exists "$HOME/.vimrc"                          "$STARTDIR"
  copy_if_exists "$HOME/.toprc"                          "$STARTDIR"
  copy_if_exists "$HOME/.tigrc"                          "$STARTDIR"
  copy_if_exists "$HOME/.wgetrc"                         "$STARTDIR"
  copy_if_exists "$HOME/.curlrc"                         "$STARTDIR"
  copy_if_exists "$HOME/.psqlrc"                         "$STARTDIR"
  # copy_if_exists "$HOME/.tmux.conf"                      "$STARTDIR"
  copy_if_exists "$HOME/.nanorc"                         "$STARTDIR"
  copy_if_exists "$HOME/.lesshst"                        "$STARTDIR"
  copy_if_exists "$HOME/.gitconfig"                      "$STARTDIR"
  copy_if_exists "$HOME/.gitignore"                      "$STARTDIR"
  copy_if_exists "$HOME/.laspavelrc"                     "$STARTDIR"
  copy_if_exists "$HOME/.bashrc"                         "$STARTDIR"
  copy_if_exists "$HOME/.bash_profile"                   "$STARTDIR"
  copy_if_exists "$HOME/.bash_logout"                    "$STARTDIR"

  # -------- Scripts: ~/.local/scripts -> ./local/scripts --------
  if [[ -d "$HOME/.local/scripts" ]]; then
    msg "[Backup] Sync ~/.local/scripts -> ./.local/scripts (delete=$RSYNC_DELETE)"
    mkdir -p "$STARTDIR/.local/scripts"
    # shellcheck disable=SC2046
    rsync_scripts "$HOME/.local/scripts/" "$STARTDIR/.local/scripts/"
  fi

  # -------- Extras: pip3 freeze --------
  if command -v pip3 >/dev/null 2>&1; then
    msg "[Backup] Export pip3 packages -> ./pip3_packages.txt"
    # не падаем, если какой-то пакет даёт warning
    pip3 freeze > "$STARTDIR/pip3_packages.txt" || true
  else
    warn "[Backup] pip3 not found; skipping pip3_packages.txt"
  fi

  # -------- Extras: macOS Brewfile --------
  if [[ "$(os_family)" == "macos" ]] && command -v brew >/dev/null 2>&1; then
    msg "[Backup] Export Homebrew bundle -> ./Brewfile"
    # Если bundle не активен — подключаем tap и повторяем
    brew bundle dump --file "$STARTDIR/Brewfile" --force 2>/dev/null \
      || { brew tap Homebrew/bundle >/dev/null 2>&1 || true; brew bundle dump --file "$STARTDIR/Brewfile" --force || true; }
  fi

# -------- Git commit/push --------
  if [[ -d "$STARTDIR/.git" ]] && command -v git >/dev/null 2>&1; then
    git add .
    git commit -m "console dotfiles backup $DATE" || true
    if git remote get-url origin >/dev/null 2>&1; then
      git push origin --all || true
      git push --tags || true
    else
      warn "[Backup] git remote 'origin' is not set; skipping push."
    fi
  else
    warn "[Backup] Not a git repository; skipping commit/push."
  fi

  msg "[Backup] Done."
}

usage() {
  cat <<'EOF'
Usage:
  ./bootstrap.sh --backup [--delete]
  ./bootstrap.sh --restore [--delete]
  ./bootstrap.sh --help

Options:
  --delete           Удалять лишние файлы при синхронизации scripts
                     (эквивалент RSYNC_DELETE=1)

Env:
  RSYNC_DELETE=1     Включить режим удаления для синка scripts

Notes:
  - Архивирование и бэкап SSH/history отключены.
  - Спец. синк: ~/.local/scripts <-> ./local/scripts

# Восстановление пакетов:
#   Python (рекомендуется внутри venv):
#     python3 -m venv .venv && source .venv/bin/activate
#     pip3 install -r pip3_packages.txt
#
#   Homebrew (на macOS):
#     # (если нужно) brew tap Homebrew/bundle
#     brew bundle --file ./Brewfile

EOF
}

main() {
  local cmd="" ; local delete_flag=0
  for a in "$@"; do
    case "$a" in
      --backup|-b)  cmd="backup" ;;
      --restore|-r) cmd="restore" ;;
      --delete)     delete_flag=1 ;;
      --help|-h)    usage; exit 0 ;;
    esac
  done
  [[ "$delete_flag" == "1" ]] && RSYNC_DELETE=1

  case "${cmd:-restore}" in
    backup)  BackupDotFiles ;;
    restore) RestoreDotFiles ;;
  esac
}

main "$@"




