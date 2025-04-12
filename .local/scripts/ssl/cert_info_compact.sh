#!/bin/bash

# Вывод краткой информации о сертификате

# Проверка на наличие аргумента
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <certificate.pem>"
    exit 1
fi

CERT=$1

# Вывод серийного номера
echo "Serial Number:"
openssl x509 -in "$CERT" -noout -serial
echo ""

# Вывод издателя
echo "Issuer:"
openssl x509 -in "$CERT" -noout -issuer
echo ""

# Вывод срока действия
echo "Validity:"
openssl x509 -in "$CERT" -noout -dates
echo ""

# Вывод субъекта
echo "Subject:"
openssl x509 -in "$CERT" -noout -subject
echo ""

# Вывод альтернативных имен субъекта (DNS)
echo "DNS:"
openssl x509 -in "$CERT" -text -noout | awk '/DNS:/ {gsub(",", "\n    ", $0); print "    " $0}'
