#!/bin/bash
# Installatie script voor Zabbix Monitor plugin
PLUGIN_DIR="/usr/local/directadmin/plugins/zabbix_monitor"

echo "Zabbix Monitor plugin installeren..."
chmod +x "$PLUGIN_DIR/hooks/"*.sh

# Voeg cron toe voor quota check
CRON_JOB="*/30 * * * * $PLUGIN_DIR/hooks/quota_check_cron.sh"
(crontab -l 2>/dev/null | grep -v "quota_check_cron"; echo "$CRON_JOB") | crontab -

echo "Klaar!"
echo "Pas $PLUGIN_DIR/zabbix_monitor.conf aan met jouw Zabbix server IP."
