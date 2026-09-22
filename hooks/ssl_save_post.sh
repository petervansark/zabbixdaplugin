#!/bin/bash
# Hook: na SSL opslaan/vernieuwen
# DirectAdmin env vars: username, domain, result
PLUGIN_DIR="$(dirname "$(readlink -f "$0")")/.."
source "$PLUGIN_DIR/zabbix_monitor.conf"

USERNAME="${username:-unknown}"
DOMAIN="${domain:-unknown}"
RESULT="${result:-1}"

if [ "$RESULT" = "0" ] || [ -z "$RESULT" ]; then
    STATUS="1"
    MSG="SSL OK voor $DOMAIN"
else
    STATUS="0"
    MSG="SSL MISLUKT voor $DOMAIN (gebruiker: $USERNAME)"
fi

$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.ssl.status[$DOMAIN]" -o "$STATUS" > /dev/null 2>&1
$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.ssl.message[$DOMAIN]" -o "$MSG" > /dev/null 2>&1
exit 0
