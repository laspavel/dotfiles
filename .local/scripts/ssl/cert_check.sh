#!/bin/bash

# Проверка сертификата (CRT), ключа (KEY) и запроса сертификата (CSR)

# Проверка на наличие аргументов
if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage: $0 <certificate.pem> <private_key.pem> [certificate_request.csr]"
    exit 1
fi

CERTIFICATE=$1
PRIVATE_KEY=$2
CSR=$3
 
# Проверяем существование файлов
if [[ ! -f "$CERTIFICATE" ]]; then
    echo "Error: Certificate file '$CERTIFICATE' not found!"
    exit 1
fi

if [[ ! -f "$PRIVATE_KEY" ]]; then
    echo "Error: Private key file '$PRIVATE_KEY' not found!"
    exit 1
fi

if [[ -n "$CSR" && ! -f "$CSR" ]]; then
    echo "Error: CSR file '$CSR' not found!"
    exit 1
fi

# Выполнение команд OpenSSL
openssl x509 -modulus -in "$CERTIFICATE" -noout | openssl sha256
openssl rsa -modulus -in "$PRIVATE_KEY" -noout | openssl sha256
if [[ -n "$CSR" ]]; then
    openssl req -modulus -in "$CSR" -noout | openssl sha256
fi
