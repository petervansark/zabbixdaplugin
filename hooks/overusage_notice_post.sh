#!/bin/bash
# Hook: quota/bandwidth exceeded.
# DirectAdmin env vars: USERNAME, QUOTA, BANDWIDTH, INODE
PLUGIN_DIR="$(dirname "$(readlink -f "$0")")/.."
source "$PLUGIN_DIR/zabbix_monitor.conf"

USER="${USERNAME:-unknown}"
QUOTA_PCT="${QUOTA:-0}"
BANDWIDTH_PCT="${BANDWIDTH:-0}"
INODE_PCT="${INODE:-0}"

$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.quota.usage[$USER]" -o "$QUOTA_PCT" > /dev/null 2>&1
$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.bandwidth.usage[$USER]" -o "$BANDWIDTH_PCT" > /dev/null 2>&1
$ZABBIX_SENDER -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$HOSTNAME" \
    -k "directadmin.inode.usage[$USER]" -o "$INODE_PCT" > /dev/null 2>&1
exit 0
