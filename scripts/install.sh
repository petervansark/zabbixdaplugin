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

# Config schrijfbaar voor de admin-UI. DA voert het plugin-CGI uit
# als de ingelogde admin's linux user (varieert per admin), dus 0666
# is de simpelste manier om edits vanuit de UI toe te staan. Het
# bestand bevat geen secrets (alleen server-IP, poort, hostname, pad).
CONF="$PLUGIN_DIR/zabbix_monitor.conf"
EXAMPLE="$PLUGIN_DIR/zabbix_monitor.conf.example"
# Maak conf alleen aan als hij nog niet bestaat — updates via DA
# extract de tarball over de installatie heen, zonder deze guard zou
# de gebruikersconfig telkens overschreven worden.
if [ ! -f "$CONF" ] && [ -f "$EXAMPLE" ]; then
    cp "$EXAMPLE" "$CONF"
    FQDN="$(hostname -f 2>/dev/null || hostname)"
    sed -i "s|^HOSTNAME=.*|HOSTNAME=$FQDN|" "$CONF"
fi
if [ -f "$CONF" ]; then
    chown "$DA_USER:$DA_GROUP" "$CONF" || true
    chmod 0666 "$CONF"
fi

# Cron voor quota check — verwijst naar het uiteindelijke plugin-pad.
FINAL_DIR="/usr/local/directadmin/plugins/zabbix_monitor"
CRON_JOB="*/30 * * * * $FINAL_DIR/hooks/quota_check_cron.sh"
(crontab -l 2>/dev/null | grep -v "quota_check_cron"; echo "$CRON_JOB") | crontab -

echo "Klaar!"
echo "Configureren: Admin Level -> Extra Features -> Zabbix Monitor"
echo "Of edit direct: $FINAL_DIR/zabbix_monitor.conf"
