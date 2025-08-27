#!/bin/bash
# ufw-auto-block.sh
# Авто-блокировка IP/подсетей по логам UFW с возможностью разблокировки

LOG_FILE="/var/log/ufw.log"
BLOCK_LOG="/var/log/ufw-blocked.log"
THRESHOLD=5
TIME_WINDOW=10

# -----------------------
# Функция для логирования
log_block() {
    local addr="$1"
    local type="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $type | $addr" >> "$BLOCK_LOG"
}

# -----------------------
# Функция для разблокировки всех IP/подсетей из лога
ufw_unblock_all() {
    if [ ! -f "$BLOCK_LOG" ]; then
        echo "Лог блокировок не найден!"
        exit 1
    fi
    while read -r line; do
        addr=$(echo $line | awk -F'|' '{print $3}' | xargs)
        if sudo ufw status | grep -q "$addr"; then
            sudo ufw delete deny from $addr
            echo "Разблокирован $addr"
        fi
    done < "$BLOCK_LOG"
    echo "Все IP и подсети из лога разблокированы."
}

# -----------------------
# Если вызываем с параметром unblock, то разблокируем и выходим
if [ "$1" == "unblock" ]; then
    ufw_unblock_all
    exit 0
fi

# -----------------------
TIME_START=$(date --date="$TIME_WINDOW minutes ago" "+%b %e %H:%M:%S")

SOURCES=$(awk -v start="$TIME_START" '$0 > start {print $0}' $LOG_FILE \
          | grep "UFW BLOCK" \
          | grep -oE 'SRC=[^ ]+' \
          | cut -d= -f2 \
          | sort)

IPS4=$(echo "$SOURCES" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
IPS6=$(echo "$SOURCES" | grep -Eo '([0-9a-fA-F:]+)')

# Обработка IPv4
if [ -n "$IPS4" ]; then
    for ip in $(echo "$IPS4" | uniq -c | awk -v threshold=$THRESHOLD '$1 >= threshold {print $2}'); do
        if ! sudo ufw status | grep -q "$ip"; then
            sudo ufw deny from $ip
            log_block "$ip" "IPv4 IP"
        fi
        subnet=$(echo $ip | awk -F. '{print $1"."$2"."$3".0/24"}')
        if ! sudo ufw status | grep -q "$subnet"; then
            sudo ufw deny from $subnet
            log_block "$subnet" "IPv4 Subnet /24"
        fi
    done
fi

# Обработка IPv6
if [ -n "$IPS6" ]; then
    for ip in $(echo "$IPS6" | uniq -c | awk -v threshold=$THRESHOLD '$1 >= threshold {print $2}'); do
        if ! sudo ufw status | grep -q "$ip"; then
            sudo ufw deny from $ip
            log_block "$ip" "IPv6 IP"
        fi
        subnet=$(echo $ip | awk -F: '{print $1":"$2":"$3":"$4"::/64"}')
        if ! sudo ufw status | grep -q "$subnet"; then
            sudo ufw deny from $subnet
            log_block "$subnet" "IPv6 Subnet /64"
        fi
    done
fi

echo "Авто-блокировка завершена. Все новые блокировки добавлены в $BLOCK_LOG"
