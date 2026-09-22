#!/bin/bash
# Helper: send data to Zabbix.
# Usage: zabbix_send.sh <key> <value>
CONF_FILE="$(dirname "$(readlink -f "$0")")/../zabbix_monitor.conf"
source "$CONF_FILE"
KEY="$1"
VALUE="$2"
$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" -k "$KEY" -o "$VALUE" > /dev/null 2>&1
