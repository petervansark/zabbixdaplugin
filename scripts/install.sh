#!/bin/bash
# Installatie script voor Zabbix Monitor plugin
# Wordt door DirectAdmin aangeroepen vanuit de (mogelijk tijdelijke)
# extractielocatie, dus leiden we PLUGIN_DIR af uit de scriptlocatie.
set -eu

PLUGIN_DIR="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
DA_USER="diradmin"
DA_GROUP="diradmin"

echo "Zabbix Monitor plugin installeren in: $PLUGIN_DIR"

if [ -d "$PLUGIN_DIR/hooks" ]; then
    chmod +x "$PLUGIN_DIR/hooks/"*.sh
fi

# Admin-UI: uitvoerbaar en eigenaar diradmin zodat DA het als CGI kan draaien.
if [ -f "$PLUGIN_DIR/admin/index.html" ]; then
    chmod 0755 "$PLUGIN_DIR/admin/index.html"
    chown "$DA_USER:$DA_GROUP" "$PLUGIN_DIR/admin/index.html" || true
fi

# Config schrijfbaar voor de admin-UI (die draait als diradmin).
if [ -f "$PLUGIN_DIR/zabbix_monitor.conf" ]; then
    chown "$DA_USER:$DA_GROUP" "$PLUGIN_DIR/zabbix_monitor.conf" || true
    chmod 0644 "$PLUGIN_DIR/zabbix_monitor.conf"
fi

# Cron voor quota check — verwijst naar het uiteindelijke plugin-pad.
FINAL_DIR="/usr/local/directadmin/plugins/zabbix_monitor"
CRON_JOB="*/30 * * * * $FINAL_DIR/hooks/quota_check_cron.sh"
(crontab -l 2>/dev/null | grep -v "quota_check_cron"; echo "$CRON_JOB") | crontab -

echo "Klaar!"
echo "Configureren: Admin Level -> Extra Features -> Zabbix Monitor"
echo "Of edit direct: $FINAL_DIR/zabbix_monitor.conf"
