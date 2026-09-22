#!/bin/bash
# Install script for the Zabbix Monitor plugin.
# DirectAdmin calls it from the (possibly temporary) extraction path,
# so PLUGIN_DIR is derived from the script's own location.
set -eu

PLUGIN_DIR="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
DA_USER="diradmin"
DA_GROUP="diradmin"

echo "Installing Zabbix Monitor plugin in: $PLUGIN_DIR"

if [ -d "$PLUGIN_DIR/hooks" ]; then
    chmod +x "$PLUGIN_DIR/hooks/"*.sh
fi

# Admin UI: executable and owned by diradmin so DA can run it as CGI.
if [ -f "$PLUGIN_DIR/admin/index.html" ]; then
    chmod 0755 "$PLUGIN_DIR/admin/index.html"
    chown "$DA_USER:$DA_GROUP" "$PLUGIN_DIR/admin/index.html" || true
fi

# Config must be writable by the admin UI. DA runs the plugin CGI as
# the logged-in admin's linux user (varies per admin), so 0666 is the
# simplest way to allow edits from the UI. The file holds no secrets
# (only server IP, port, hostname, sender path).
CONF="$PLUGIN_DIR/zabbix_monitor.conf"
EXAMPLE="$PLUGIN_DIR/zabbix_monitor.conf.example"
# Only create the conf if it does not exist — DA updates extract the
# tarball over the install, so without this guard the user config
# would be overwritten every time.
if [ ! -f "$CONF" ] && [ -f "$EXAMPLE" ]; then
    cp "$EXAMPLE" "$CONF"
    FQDN="$(hostname -f 2>/dev/null || hostname)"
    sed -i "s|^HOSTNAME=.*|HOSTNAME=$FQDN|" "$CONF"
fi
if [ -f "$CONF" ]; then
    chown "$DA_USER:$DA_GROUP" "$CONF" || true
    chmod 0666 "$CONF"
fi

# Cron for the quota check — points at the final plugin path.
FINAL_DIR="/usr/local/directadmin/plugins/zabbix_monitor"
CRON_JOB="*/30 * * * * $FINAL_DIR/hooks/quota_check_cron.sh"
(crontab -l 2>/dev/null | grep -v "quota_check_cron"; echo "$CRON_JOB") | crontab -

echo "Done!"
echo "Configure: Admin Level -> Extra Features -> Zabbix Monitor"
echo "Or edit directly: $FINAL_DIR/zabbix_monitor.conf"
