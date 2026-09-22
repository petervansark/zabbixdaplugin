#!/bin/bash
# Builds a DirectAdmin-compatible plugin tarball in dist/.
# plugin.conf must sit at the archive root (required by DA).
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
cd "$ROOT"

NAME="$(awk -F= '$1=="id"{print $2}' plugin.conf)"
VERSION="$(awk -F= '$1=="version"{print $2}' plugin.conf)"
: "${NAME:?id missing from plugin.conf}"
: "${VERSION:?version missing from plugin.conf}"

mkdir -p dist
# DA uses the tarball basename as the plugin directory name, so we
# keep it equal to the id — version lives in plugin.conf.
OUT="dist/${NAME}.tar.gz"

# version.txt is what DA's version_url points at — it must contain
# just the version string, otherwise DA compares the whole file to
# the installed version and keeps offering an "update".
echo "$VERSION" > version.txt

tar --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='dist' \
    --exclude='./.*' \
    -czf "$OUT" \
    plugin.conf README.md LICENSE zabbix_items.txt zabbix_monitor.conf.example \
    admin hooks scripts

echo "Built: $OUT"
tar -tzf "$OUT"
