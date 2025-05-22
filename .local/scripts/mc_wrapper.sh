#!/bin/bash

# Обертка для сохранения текущего каталога после выхода из mc

# Настройка (.bashrc):
# alias mc='. "$HOME/.local/scripts/mc_wrapper.sh"'

# Временный файл для хранения пути
if [[ -n "$MC_TMPDIR" ]]; then
    MC_PWD_FILE="$(mktemp "${MC_TMPDIR}/mc.pwd.XXXXXX")"
elif [[ -n "$TMPDIR" ]]; then
    MC_PWD_FILE="$(mktemp "${TMPDIR}/mc.pwd.XXXXXX")"
else
    MC_PWD_FILE="$(mktemp "/tmp/mc.pwd.XXXXXX")"
fi

# Запуск mc с сохранением пути
mc -x -P "$MC_PWD_FILE" "$@"

# Если файл существует и читается — выполнить cd
if [[ -r "$MC_PWD_FILE" ]]; then
    MC_PWD="$(cat "$MC_PWD_FILE")"
    if [[ -n "$MC_PWD" && "$MC_PWD" != "$PWD" && -d "$MC_PWD" ]]; then
        cd "$MC_PWD" || true
    fi
    unset MC_PWD
fi

# Очистка
rm -f "$MC_PWD_FILE"
unset MC_PWD_FILE

