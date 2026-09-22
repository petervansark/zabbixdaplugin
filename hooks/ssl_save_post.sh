#!/bin/bash
# Hook: after SSL save/renew.
# DirectAdmin env vars: username, domain, result
PLUGIN_DIR="$(dirname "$(readlink -f "$0")")/.."
source "$PLUGIN_DIR/zabbix_monitor.conf"

USERNAME="${username:-unknown}"
DOMAIN="${domain:-unknown}"
RESULT="${result:-1}"

if [ "$RESULT" = "0" ] || [ -z "$RESULT" ]; then
    STATUS="1"
    MSG="SSL OK for $DOMAIN"
else
    STATUS="0"
    MSG="SSL FAILED for $DOMAIN (user: $USERNAME)"
fi

$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.ssl.status[$DOMAIN]" -o "$STATUS" > /dev/null 2>&1
$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.ssl.message[$DOMAIN]" -o "$MSG" > /dev/null 2>&1
exit 0
