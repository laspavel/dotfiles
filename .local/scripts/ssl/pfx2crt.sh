#!/bin/bash

# Преобразование PFX сертификата в CRT и KEY

# Формат запуска: pfx2crt.sh mycert.pfx

# На выходе в этой же папке будут сертификат и ключ с этим же именем.
# При конвертировании будет запрашиваться пароль от сертификата и потом пароль
# от ключа (последний можно указывать любой - например 12345.Он нужен только для преобразования.)

fbname=$(basename "$1" .pfx)
openssl pkcs12 -in $fbname.pfx -clcerts -nokeys -out $fbname.crt
openssl pkcs12 -in $fbname.pfx -nocerts -out $fbname-encrypt.key
openssl rsa -in $fbname-encrypt.key -out $fbname.key
rm -f $fbname-encrypt.key
