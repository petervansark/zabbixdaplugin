#!/bin/bash
# Hook: na backup van gebruiker
# DirectAdmin env vars: username, result (0=ok, 1=fout)
PLUGIN_DIR="$(dirname "$(readlink -f "$0")")/.."
source "$PLUGIN_DIR/zabbix_monitor.conf"

USERNAME="${username:-unknown}"
RESULT="${result:-1}"

if [ "$RESULT" = "0" ]; then
    STATUS="1"
    MSG="Backup OK voor $USERNAME"
else
    STATUS="0"
    MSG="Backup MISLUKT voor $USERNAME"
fi

$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.backup.status[$USERNAME]" -o "$STATUS" > /dev/null 2>&1
$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.backup.message[$USERNAME]" -o "$MSG" > /dev/null 2>&1
exit 0
