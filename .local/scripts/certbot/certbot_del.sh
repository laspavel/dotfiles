#!/bin/bash

# Удаление сертификата Let's Encrypt для заданного домена

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

certbot -n delete --cert-name $1

