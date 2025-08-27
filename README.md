# ufw-auto-block

Скрипт для автоматической блокировки IP-адресов, которые слишком часто стучатся в `ufw`.

## Возможности
- Анализирует логи `/var/log/ufw.log`
- Считает количество попыток подключения по каждому IP
- Автоматически добавляет правило в `ufw`, если IP превысил лимит
- Записывает все блокировки в `/var/log/ufw-blocked.log`

## Установка

1. Сохраните скрипт:
   ```bash
   sudo nano /usr/local/bin/ufw-auto-block.sh

2. Сделайте исполняемым:
   ```bash
   sudo chmod +x /usr/local/bin/ufw-auto-block.sh

3. Создайте лог-файл:
   ```bash
   sudo touch /var/log/ufw-blocked.log
   sudo chmod 644 /var/log/ufw-blocked.log

4. Добавьте в cron, чтобы скрипт выполнялся раз в 5 минут:
   ```bash
   sudo crontab -e
   и вставьте строку:
   */5 * * * * /usr/local/bin/ufw-auto-block.sh

## Использование

1. Посмотреть последние блокировки:
   ```bash
   tail -f /var/log/ufw-blocked.log

2. Пример строки в логе:
   ```bash
   2025-08-27 12:10:05 | Заблокирован IP: 203.0.113.55 (20 попыток)

## Требования

Ubuntu/Debian с ufw

Bash
root-доступ
Зачем это нужно?

Если на сервер идёт перебор SSH/HTTP или спам-запросы, этот скрипт автоматически добавит IP в блокировку, снимая нагрузку с администратора.


# ufw-watch

Скрипт просмотра логов /var/log/ufw.log

## Установка

1. Сохраните скрипт:
   ```bash
   sudo nano ufw-watch.sh

2. Сделайте исполняемым:
   ```bash
   sudo chmod +x ufw-watch.sh

3. Использование
   ```bash
   sudo ./ufw-watch.sh