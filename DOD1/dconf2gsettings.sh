#!/bin/bash

# Пример: ./dconf2gsettings.sh /org/gnome/shell/extensions/dash-to-panel/

if [[ -z "$1" ]]; then
  echo "Usage: $0 <dconf-path>"
  echo "Example: $0 /org/gnome/shell/extensions/dash-to-panel/"
  exit 1
fi

DCONF_PATH="$1"
SCHEMA=$(echo "$DCONF_PATH" | sed 's|/$||' | sed 's|^/||' | tr '/' '.')

# Считываем dump dconf
dconf dump "$DCONF_PATH" | while IFS= read -r line; do
  if [[ "$line" =~ ^\[(.*)\]$ ]]; then
    SUBPATH=${BASH_REMATCH[1]}
    FULL_SCHEMA="${SCHEMA}.${SUBPATH//\//.}"
  elif [[ "$line" =~ ^([^=]+)=\s*(.*)$ ]]; then
    KEY=$(echo "${BASH_REMATCH[1]}" | xargs)
    VALUE=$(echo "${BASH_REMATCH[2]}" | xargs)

    # Обработка строк в кавычках
    if [[ "$VALUE" =~ ^\'(.*)\'$ ]]; then
      VALUE="\"${BASH_REMATCH[1]}\""
    fi

    echo "gsettings set $FULL_SCHEMA $KEY $VALUE"
  fi
done
