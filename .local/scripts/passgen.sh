#!/bin/bash

# Генератор паролей.

PWD_LEN=$1
COUNT=$2

# Длина пароля по умолчанию
if [[ -z "${PWD_LEN}" ]]; then
    PWD_LEN=15
fi

# Количество паролей по умолчанию
if [[ -z "${COUNT}" ]]; then
    COUNT=5
fi

# Символы, исключая неоднозначные
CHAR_SET="abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789_="

for i in $(seq 1 $COUNT); do
  tr -dc "$CHAR_SET" < /dev/urandom | head -c ${PWD_LEN}; echo
done

