#!/bin/bash -e

HOSTS="$(op read op://private/tailscale-hosts/notes)"

[[ -z "${HOSTS}" ]] && exit 1

cat /etc/hosts | sed '/.tailscale.start/,/.tailscale.end/d' >hosts.txt

echo "#tailscale start" | tee -a hosts.txt
echo "$HOSTS" | tee -a hosts.txt
echo "#tailscale end" | tee -a hosts.txt

sudo cp hosts.txt /etc/hosts
