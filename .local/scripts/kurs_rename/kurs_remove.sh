#!/bin/bash

# Удаление лишнего из скачанных курсов.

# Проверяем, что передан один параметр
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

directory="$1"

# Проверяем, существует ли переданная папка
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' does not exist."
  exit 1
fi

find "$directory" -type f \( -name "*.url" -o -name "*Прочти перед изучением*.doc*" \) -exec rm -f {} +

# Рекурсивный обход файлов и папок
find "$directory" -depth -name "*" | while read -r path; do
  # Новое имя файла или папки
  new_path="$(dirname "$path")/$(basename "$path" | sed 's/\[SW\.BAND\] //g')"

  # Переименование, если имя изменилось
  if [ "$path" != "$new_path" ]; then
    mv "$path" "$new_path"
    echo "Renamed: '$path' -> '$new_path'"
  fi

done

echo "Processing complete."
