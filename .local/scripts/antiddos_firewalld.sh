#!/bin/bash

# Устанавливает ограничение частоты ICMP (ping) запросов для IPv4 и IPv6 с использованием firewalld и его direct rules (низкоуровневый доступ к iptables/nftables). 
# Это базовая защита от ICMP flood (ping flood, DoS).

set -euo pipefail

# Проверка
if [[ $EUID -ne 0 ]]; then echo "Run as root"; exit 1; fi
command -v firewall-cmd >/dev/null || { echo "firewalld not found"; exit 2; }

# Настройки
RATE_LIMIT="15/sec"   # Максимальная скорость входа в метро (чел/сек)
BURST="5"             # Сколько можно пропустить в час пик "без билета"
EXPIRE="300000"       # Через сколько очистится запись об этом человеке в мс. (300 сек = 5 мин)

log() {
  echo "$(date +'%F %T') $1"
}

log "Applying ICMP flood protection rules..."

# IPv4
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p icmp \
  -m icmp --icmp-type 8 \
  -m conntrack --ctstate NEW,RELATED,ESTABLISHED \
  -m hashlimit --hashlimit-above $RATE_LIMIT --hashlimit-burst $BURST \
  --hashlimit-mode srcip --hashlimit-name PINGv4 --hashlimit-htable-expire $EXPIRE \
  -j DROP

# IPv6
firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -p icmpv6 \
  -m icmpv6 --icmpv6-type 8 \
  -m conntrack --ctstate NEW,RELATED,ESTABLISHED \
  -m hashlimit --hashlimit-above $RATE_LIMIT --hashlimit-burst $BURST \
  --hashlimit-mode srcip --hashlimit-name PINGv6 --hashlimit-htable-expire $EXPIRE \
  -j DROP

# Защита от SYN-флуда (подозрительная частота TCP SYN-пакетов)
log "Applying SYN flood protection rules..."

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --syn \
  -m conntrack --ctstate NEW \
  -m hashlimit --hashlimit-above 30/sec --hashlimit-burst 10 \
  --hashlimit-mode srcip --hashlimit-name TCP-FLOOD --hashlimit-htable-expire 60000 \
  -j DROP


# Не более 5 попыток подключения по SSH в минуту от одного IP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 22 \
  -m conntrack --ctstate NEW \
  -m hashlimit --hashlimit-above 5/minute --hashlimit-burst 3 \
  --hashlimit-mode srcip --hashlimit-name SSH_LIMIT --hashlimit-htable-expire 60000 \
  -j DROP

# Отбрасывать фрагментированные пакеты (часто используются в обходах)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -f -j DROP

# Блокируем "подделку" локальных адресов
for ip in 127.0.0.0/8 10.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16; do
  firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -s $ip -j DROP
done

# Создаем правило: если IP уже помечен как сканирующий — дропаем все
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 \
  -m recent --name portscan --rcheck --seconds 600 --hitcount 1 --rttl -j DROP

# Помечаем IP как сканирующий при обращении к порту 23 (telnet)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p tcp --dport 23 \
  -m recent --name portscan --set -j DROP

# Разрешить SSH
firewall-cmd --permanent --add-service=ssh

# Разрешить HTTP/HTTPS
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https

# Запретить остальной входящий трафик
# firewall-cmd --permanent --set-default-zone=drop

# Перезапуск и вывод
firewall-cmd --reload
firewall-cmd --get-all-rules --direct

