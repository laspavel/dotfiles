#!/bin/bash

# Генерация запроса на создание нового сертификата

# Проверка на наличие аргумента
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <certificate_file>"
    exit 1
fi

openssl genrsa -des3 -out $1.key 2048
openssl rsa -in $1.key -out $1.key
openssl req -new -key $1.key -out $1.csr
openssl rsa -modulus -in $1.key -noout | openssl sha256
openssl req -modulus -in $1.csr -noout | openssl sha256
