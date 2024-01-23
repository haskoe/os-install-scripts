#!/bin/bash -x                                                                                                                                              \
                                                                                                                                                             
# usage: op-rd-vpn.sh <host entry>                                                                                                                           

[[ -z $1 ]] && echo "usage: op-rd-vpn.sh <host entry>" && return 1
RDP_HOST=$1

IFS=","
read -a UID_VPNHUB <<< $(op read op://private/${RDP_HOST}/username)
VPN_HUB=${UID_VPNHUB[2]}
RDP_UID=${UID_VPNHUB[1]}
RDP_IP=${UID_VPNHUB[0]}
RDP_PWD=$(op read op://private/${RDP_HOST}/password)

op read op://private/${VPN_HUB}/notes >~/vpn.ovpn

[[ -z $VPN_HUB ]] && echo "Invalid host entry" && return 1

VPN_UID=${VPN_HUB}
VPN_PWD=$(op read op://private/${VPN_HUB}/password)

echo ${VPN_HUB}>pass.txt
echo $VPN_PWD>>pass.txt
sudo killall openvpn
sudo openvpn --config ~/vpn.ovpn --auth-user-pass pass.txt --daemon
sleep 1
echo dhgshdgs>pass.txt
xfreerdp  /kbd:0x00000406 /v:$RDP_IP /u:$RDP_UID /p:$RDP_PWD /f
