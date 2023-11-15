#!/bin/bash -e

rbw sync
IFS=","
read -a HOSTS_ARR <<< $(rbw get hosts)

[[ -f hosts.txt ]] && rm hosts.txt
for host in "${HOSTS_ARR[@]}"
do
    sudo sed -i "/^.*${host}/d" /etc/hosts
    echo $(rbw get ${host}) $host | sudo tee -a /etc/hosts
done
