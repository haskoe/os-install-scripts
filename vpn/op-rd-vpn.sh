#!/bin/bash -x                                                                                                                                               

# usage: op-rd-vpn.sh <host entry>                                                                                                                           

[[ -z $1 ]] && echo "usage: op-rd-vpn.sh <host entry>" && return 1
RDP_HOST=$1

IFS=","
read -a UID_VPNHUB <<< $(op read op://private/${RDP_HOST}/username)
VPN_HUB=${UID_VPNHUB[1]}
RDP_UID=${UID_VPNHUB[0]}
[[ -z $VPN_HUB ]] && echo "Invalid host entry" && return 1

VPN_PWD=$(op read op://private/${VPN_HUB}/password)
VPN_UID=$(op read op://private/${VPN_HUB}/username)

RDP_PWD=$(op read op://private/${RDP_UID}/password)
echo $VPN_PWD | sudo openconnect -u ${VPN_UID} --passwd-on-stdin $VPN_HUB &
sleep 1
xfreerdp  /kbd:0x00000406 /v:$RDP_HOST /u:$RDP_UID /p:$RDP_PWD /f

