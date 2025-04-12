#!/bin/bash

# Вывод полной информации о сертификате

# Проверка на наличие аргумента
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <certificate.pem>"
    exit 1
fi

CERT=$1

openssl x509 -in "$CERT" -text -noout
