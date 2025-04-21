#!/bin/bash

# Скрипт защиты от DDoS и базовых атак через firewalld (--direct), для систем **с Docker**
# Подходит для серверов с внешним интерфейсом EXT_IF и с внутренним NAT/bridge

set -euo pipefail

EXT_IF="eth0"  # Внешний интерфейс (уточнить при необходимости)
DOCKER_CIDR="10.250.0.0/16"  # изменить при необходимости

# Проверка
if [[ $EUID -ne 0 ]]; then echo "Run as root"; exit 1; fi
command -v firewall-cmd >/dev/null || { echo "firewalld not found"; exit 2; }

# Настройки лимитов
RATE_LIMIT="15/sec"   # Максимальная скорость входа в метро (чел/сек)
BURST="5"             # Сколько можно пропустить в час пик "без билета"
EXPIRE="300000"       # Через сколько очистится запись об этом человеке в мс. (300 сек = 5 мин)

# Явно устанавливаем ACCEPT в policy
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Удаляем старые direct-правила
rm -f /etc/firewalld/direct.xml
firewall-cmd --reload

# loopback
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i lo -j ACCEPT

# Всё, что не приходит с внешнего интерфейса — разрешено (локалка и т.п.)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 ! -i "$EXT_IF" -j ACCEPT

# Возвратные соединения
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Настройка FORWARD (разрешить весь межсетевой трафик)
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -j ACCEPT

# NAT для выхода контейнеров наружу
firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -s "$DOCKER_CIDR" -o "$EXT_IF" -j MASQUERADE

# Разрешить FORWARD от контейнеров наружу (через EXT_IF)
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -s "$DOCKER_CIDR" -o "$EXT_IF" -j ACCEPT

# Разрешить обратный трафик
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 1 -d "$DOCKER_CIDR" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Если Docker используется локально, стоит ограничить NAT-трафик
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -s "$DOCKER_CIDR" -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 1 -d "$DOCKER_CIDR" -j ACCEPT

# Null packets
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --tcp-flags ALL NONE -j DROP

# XMAS packets
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --tcp-flags ALL ALL -j DROP

# Drop INVALID пакеты
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -m conntrack --ctstate INVALID -j DROP

# Drop broadcast и multicast трафик (только на EXT_IF)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i "$EXT_IF" -m addrtype --dst-type BROADCAST -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i "$EXT_IF" -m addrtype --dst-type MULTICAST -j DROP

# Ограничения: ICMP flood (только на EXT_IF)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i "$EXT_IF" -p icmp \
  -m icmp --icmp-type 8 \
  -m conntrack --ctstate NEW,RELATED,ESTABLISHED \
  -m hashlimit --hashlimit-above "$RATE_LIMIT" --hashlimit-burst "$BURST" \
  --hashlimit-mode srcip --hashlimit-name PINGv4 --hashlimit-htable-expire "$EXPIRE" \
  -j DROP

# Ограничения: SYN flood (только на EXT_IF)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i "$EXT_IF" -p tcp --syn \
  -m conntrack --ctstate NEW \
  -m hashlimit --hashlimit-above "$RATE_LIMIT" --hashlimit-burst "$BURST" \
  --hashlimit-mode srcip --hashlimit-name TCP-FLOOD --hashlimit-htable-expire "$EXPIRE" \
  -j DROP

# Ограничения: SSH brute-force (только на EXT_IF)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i "$EXT_IF" -p tcp --dport 22 \
  -m conntrack --ctstate NEW \
  -m hashlimit --hashlimit-above "$RATE_LIMIT" --hashlimit-burst "$BURST" \
  --hashlimit-mode srcip --hashlimit-name SSH_LIMIT --hashlimit-htable-expire "$EXPIRE" \
  -j DROP

# Отбрасывание фрагментированных пакетов (только на EXT_IF)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i "$EXT_IF" -f -j DROP

# Защита от spoofing локальных IP (только на EXT_IF)
for ip in 127.0.0.0/8 10.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16; do
  firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i "$EXT_IF" -s "$ip" -j DROP
done

# Обнаружение сканеров (telnet-порт)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -i "$EXT_IF" \
  -m recent --name portscan --rcheck --seconds 600 --hitcount 1 --rttl -j DROP

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -i "$EXT_IF" -p tcp --dport 23 \
  -m recent --name portscan --set -j DROP

# Разрешенные сервисы

# Явно разрешить вход на порт 443 (https)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 90 -i "$EXT_IF" -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# Явно разрешить вход на порт 80 (http), если используется
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 90 -i "$EXT_IF" -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT

# Явно разрешить вход на порт 22 (SSH)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 90 -i "$EXT_IF" -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# Явно разрешить вход на порт 21 (FTP)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 90 -i "$EXT_IF" -p tcp --dport 21 -m conntrack --ctstate NEW -j ACCEPT

# Явно разрешить вход на порт 50000-50535/tcp (FTP passive mode)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 90 -i "$EXT_IF" -p tcp --dport 50000:50535 -m conntrack --ctstate NEW -j ACCEPT

# Логирование перед финальным дропом
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 99 -j LOG --log-prefix "FW_INPUT_DROP: " --log-level 4

# Всё, что не разрешено — DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 100 -j DROP
#firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 100 -j DROP

# Применение конфигурации
firewall-cmd --reload

# Выводим текущее состояние
firewall-cmd --get-all-rules --direct
