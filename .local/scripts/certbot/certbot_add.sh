#!/bin/bash

# Создание сертификата Let's Encrypt для заданного домена

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

CERT_DEFAULT_EMAIL=laspavel@gmail.com
CERT_DEFAULT_WEBROOT=/usr/share/nginx/html

certbot certonly --email $CERT_DEFAULT_EMAIL --webroot -w $CERT_DEFAULT_WEBROOT --agree-tos --keep --expand -d $1