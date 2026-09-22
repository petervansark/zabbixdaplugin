#!/bin/bash
# Bouwt een DirectAdmin-compatibele plugin tarball in dist/.
# plugin.conf komt in de root van het archief (vereist door DA).
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
cd "$ROOT"

NAME="$(awk -F= '$1=="id"{print $2}' plugin.conf)"
VERSION="$(awk -F= '$1=="version"{print $2}' plugin.conf)"
: "${NAME:?id ontbreekt in plugin.conf}"
: "${VERSION:?version ontbreekt in plugin.conf}"

mkdir -p dist
# DA gebruikt de tarball-basename als plugin-directorynaam, dus
# houden we hem gelijk aan de id — versie zit in plugin.conf.
OUT="dist/${NAME}.tar.gz"

tar --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='dist' \
    --exclude='./.*' \
    -czf "$OUT" \
    plugin.conf README.md LICENSE zabbix_items.txt zabbix_monitor.conf.example \
    admin hooks scripts

echo "Gebouwd: $OUT"
tar -tzf "$OUT"
