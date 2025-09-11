#!/usr/bin/env bash
# winrar-bak.sh — продвинутый бэкап в RAR с томами, Recovery Record и блокировкой
# Требуется пакет rar (не unrar). Скачивается на rarlab.com под Linux.
#
# Использование:
#   winrar-bak.sh <archive_name(.rar|.r##)> <paths...>
#
# Параметры окружения (необязательные):
#   WINRAR_METHOD=rar|rar4     # формат архива: rar (RAR5, по умолчанию) или rar4 (RAR4)
#   WINRAR_VOL=1990m           # размер тома для -v (поддерживает k/m/g; по умолчанию 1990m)
#   WINRAR_RR=3%               # объём Recovery Record; можно в %, k/m (напр. 5%, 200m). Если пусто — rar сам возьмёт ~3%
#   WINRAR_ENCRYPT_HEADERS=0|1 # 1 — шифровать заголовки (-hp вместо -p). По умолчанию 0
#   WINRAR_COMP=0..5           # уровень сжатия (-m), по умолчанию 5
#   WINRAR_FORCE=0|1           # 1 — перезаписывать существующий архив без вопросов
#
# Особенности:
# - Скрипт НЕ передаёт пароль в командной строке. Ключ -p заставит rar безопасно запросить пароль.
# - По умолчанию формат — RAR5 (-ma5). Для RAR4 поставьте WINRAR_METHOD=rar4.
# - Имя архива можно передать без .rar — расширение добавится автоматически.
# - Тома будут формата .part1.rar (RAR5) или .r00/.r01 (RAR4), в зависимости от метода.

set -euo pipefail

toupper() { printf '%s' "$1" | tr '[:lower:]' '[:upper:]'; }

# ---- Проверки окружения ----
if ! command -v rar >/dev/null 2>&1; then
  echo "ERROR: не найден 'rar'. Установите пакет rar (не unrar)." >&2
  exit 1
fi

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <archive_name(.rar|.r##)> <paths...>" >&2
  exit 2
fi

# ---- Входные параметры ----
ARCH_IN="$1"; shift
# Нормализуем имя архива: добавим .rar, если нет расширения
case "$ARCH_IN" in
  *.rar|*.RAR|*.r[0-9][0-9]|*.R[0-9][0-9]) ARCH="$ARCH_IN" ;;
  *) ARCH="${ARCH_IN}.rar" ;;
esac

# Настройки по умолчанию/из окружения
METHOD="${WINRAR_METHOD:-rar}"            # rar (RAR5) | rar4
VOL="${WINRAR_VOL:-1990m}"                # размер тома
RR_VAL="${WINRAR_RR:-}"                   # Recovery Record размер
ENC_HEADERS="${WINRAR_ENCRYPT_HEADERS:-0}"
COMP="${WINRAR_COMP:-5}"                  # -m0..-m5
FORCE="${WINRAR_FORCE:-0}"

# ---- Построение флагов rar ----
RAR_FLAGS=(a)                              # команда Add
# Выбор формата архива
case "$METHOD" in
  rar|RAR|rar5|RAR5) RAR_FLAGS+=(-ma5) ;; # RAR5
  rar4|RAR4)        RAR_FLAGS+=(-ma4) ;;  # RAR4 (совместимость со старым ПО)
  *)
    echo "ERROR: WINRAR_METHOD должен быть 'rar' (RAR5) или 'rar4'." >&2
    exit 3
    ;;
esac

# Уровень сжатия
RAR_FLAGS+=("-m${COMP}")

# Томление (split)
RAR_FLAGS+=("-v${VOL}")

# Recovery Record
if [ -n "$RR_VAL" ]; then
  RAR_FLAGS+=("-rr${RR_VAL}")
else
  RAR_FLAGS+=(-rr) # дефолтный процент от rar (обычно ~3%)
fi

# Блокировка архива
RAR_FLAGS+=(-k)

# Поведение при существующем файле
if [ "$FORCE" = "1" ]; then
  RAR_FLAGS+=(-o+)
else
  # Защитимся от случайной перезаписи
  if [ -e "$ARCH" ]; then
    echo "ERROR: Архив '$ARCH' уже существует. Удалите/переименуйте или запустите с WINRAR_FORCE=1." >&2
    exit 4
  fi
fi

# Пароль: пусть rar сам запросит пароль безопасно
# Шифрование заголовков при необходимости
if [ "$ENC_HEADERS" = "1" ]; then
  RAR_FLAGS+=(-hp)  # запросит пароль и зашифрует и данные, и имена файлов
else
  RAR_FLAGS+=(-p)   # запросит пароль и зашифрует данные, но не имена файлов
fi

# Режим: относительные пути, симлинки как есть, хранить атрибуты
RAR_FLAGS+=(-ep1)

# ---- Выполнение ----
# Используем массив аргументов для корректной обработки пробелов
echo ">> Создание архива: $ARCH"
echo ">> Метод: $(toupper "$METHOD"), тома: ${VOL}, Recovery: ${RR_VAL:-default}, lock: yes, enc_headers: ${ENC_HEADERS}"
# rar сам спросит пароль дважды для подтверждения
rar "${RAR_FLAGS[@]}" -- "$ARCH" "$@"
echo ">> Готово."
