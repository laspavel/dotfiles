#!/bin/bash

# Генератор RSA ключей.

# Проверка количества аргументов
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <rsa key file> [Comment]"
    exit 1
fi

KEYFILE=$1
KEYCOMMENT=${2:-"$(whoami)@$(hostname)"}

# Проверяем, существует ли уже ключевой файл
if [ -f "$KEYFILE" ] || [ -f "$KEYFILE.pub" ]; then
    echo "Error: Key file '$KEYFILE' already exists. Choose a different name or remove the existing key."
    exit 1
fi

# Генерация ключа
ssh-keygen -t rsa -q -b 4096 -C "$KEYCOMMENT" -f "$KEYFILE"

# Проверка успешного выполнения ssh-keygen
if [ $? -ne 0 ]; then
    echo "Error: ssh-keygen failed."
    exit 1
fi

echo "SSH key successfully generated: $KEYFILE"
