#!/bin/sh

LOG="/var/log/ufw.log"

[ ! -f "$LOG" ] && { echo "Файл $LOG не найден!"; exit 1; }

# Цвета
RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"

# Берём последние 2 дня
since=$(date --date="2 days ago" +"%b %_d")

grep "UFW" "$LOG" | grep -E "^$since|$(date +%b\ %_d)" | awk -v RED="$RED" -v GREEN="$GREEN" -v RESET="$RESET" '
{
    # Время (первые 3 поля)
    time=$1 " " $2 " " $3

    # --- Действие ---
    action="-"
    for (i=1;i<=NF;i++) {
        if ($i ~ /UFW/) {
            gsub(/\[|\]/,"",$i)
            action=$i
            if ($(i+1) != "" && $(i+1) !~ /^[0-9.]+$/) {
                gsub(/\[|\]/,"",$(i+1))
                action=action " " $(i+1)
            }
            break
        }
    }

    # Цвет по действию
    color=RESET
    if(action=="UFW BLOCK") color=RED
    if(action=="UFW ALLOW") color=GREEN

    iface="-"; src="-"; dst="-"; dpt="-"

    for (i=1;i<=NF;i++) {
        if ($i ~ /^IN=/)  { split($i,a,"="); iface=a[2] }
        if ($i ~ /^SRC=/) { split($i,a,"="); src=a[2] }
        if ($i ~ /^DST=/) { split($i,a,"="); dst=a[2] }
        if ($i ~ /^DPT=/) { split($i,a,"="); dpt=a[2] }
    }

    printf "Время: %-15s | Действие: %s%-10s%s | Интерфейс: %-8s | Источник: %-15s | Назначение: %-15s | Порт: %-5s\n", time, color, action, RESET, iface, src, dst, dpt
}'
