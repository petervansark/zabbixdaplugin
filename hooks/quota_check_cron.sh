#!/bin/bash
# Cron: quota check for all users every 30 minutes.
# Add to cron: */30 * * * * /usr/local/directadmin/plugins/zabbix_monitor/hooks/quota_check_cron.sh
PLUGIN_DIR="$(dirname "$(readlink -f "$0")")/.."
source "$PLUGIN_DIR/zabbix_monitor.conf"

for USER_DIR in /home/*/; do
    USER=$(basename "$USER_DIR")
    [ "$USER" = "lost+found" ] && continue

    QUOTA_INFO=$(repquota -u / 2>/dev/null | grep "^$USER " | awk '{print $3, $4}')
    if [ -n "$QUOTA_INFO" ]; then
        USED=$(echo "$QUOTA_INFO" | awk '{print $1}')
        LIMIT=$(echo "$QUOTA_INFO" | awk '{print $2}')
        if [ "$LIMIT" -gt 0 ] 2>/dev/null; then
            PCT=$(( USED * 100 / LIMIT ))
            $ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
                -k "directadmin.quota.usage[$USER]" -o "$PCT" > /dev/null 2>&1
        fi
    fi
done
