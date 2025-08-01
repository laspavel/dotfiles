#!/bin/bash

# Путь к выходному файлу
ALLOW_CONF="/etc/nginx/cloudflare-allow.conf"
TMP_FILE=$(mktemp)

CLOUDFLARE_IPS_V4=$(curl -s https://www.cloudflare.com/ips-v4)
CLOUDFLARE_IPS_V6=$(curl -s https://www.cloudflare.com/ips-v6)

if [[ -z "$CLOUDFLARE_IPS_V4" && -z "$CLOUDFLARE_IPS_V6" ]]; then
    echo "Не удалось получить IP-адреса Cloudflare."
    exit 1
fi

{
    echo "# Cloudflare allow list - autogenerated on $(date)"
    for ip in $CLOUDFLARE_IPS_V4; do
        echo "allow $ip;"
    done
    for ip in $CLOUDFLARE_IPS_V6; do
        echo "allow $ip;"
    done
    echo "deny all;"
} > "$TMP_FILE"

# Если файл изменился — заменить и перезагрузить nginx
if ! cmp -s "$TMP_FILE" "$ALLOW_CONF"; then
    mv "$TMP_FILE" "$ALLOW_CONF"
    echo "[+] Обновлён список Cloudflare IP в $ALLOW_CONF"

    # Проверяем конфигурацию nginx
    if nginx -t; then
        systemctl reload nginx
        echo "[+] Nginx перезапущен"
    else
        echo "[!] Ошибка проверки конфигурации nginx. Обновление не применено."
    fi
else
    echo "[-] IP-адреса не изменились. Обновление не требуется."
    rm "$TMP_FILE"
fi
