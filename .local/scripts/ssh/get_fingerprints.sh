#!/bin/bash

# Анализ SSH-ключей в файле authorized_keys и вывод их отпечатков

fingerprints() {
  local file="${1:-$HOME/.ssh/authorized_keys}"
  local line_num=0
  if [[ ! -f "$file" ]]; then
    echo "File not found: $file" >&2
    return 1
  fi

  while IFS= read -r line || [[ -n $line ]]; do
    ((line_num++))
    # Пропустить пустые строки и комментарии
    [[ -z "$line" || "${line:0:1}" == "#" ]] && continue

    # Попытка распознать ключ
    if echo "$line" | ssh-keygen -l -f /dev/stdin >/dev/null 2>&1; then
      echo -n "Line $line_num: "
      echo "$line" | ssh-keygen -l -f /dev/stdin
    else
      echo "Line $line_num: Invalid or unsupported key" >&2
    fi
  done < "$file"
}

fingerprints "$1"
