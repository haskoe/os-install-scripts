#!/bin/bash

sudo snap install multipass lxd
sudo snap set lxd daemon.user.group=users
sudo lxd init
sudo snap restart multipass
sudo snap restart lxd
sudo snap connect multipass:lxd lxd
multipass set local.driver=lxd
sudo snap restart multipass
multipass set local.bridged-network=mpbr0
sudo snap restart multipass
sudo nft add chain ip filter FORWARD '{ policy accept; }'

VM_TYPE=oracular
VM_NAME=${VM_TYPE}
multipass delete $VM_NAME
multipass purge
multipass launch $VM_TYPE -c 2 -m 2G -d 20G -n $VM_NAME
multipass exec $VM_NAME  -- bash -c "sudo apt update && sudo apt -y dist-upgrade && sudo apt install -y git freerdp2-x11 openconnect openvpn emacs-nox && mkdir -p ~/dev/haskoe && cd ~/dev/haskoe && git clone https://github.com/haskoe/os-install-scripts.git && sudo shutdown -h now"
multipass start $VM_NAME
multipass exec $VM_NAME  -- bash -c "echo `cat ~/.ssh/id_ed25519.pub` >> ~/.ssh/authorized_keys"
#cat ~/.ssh/id_${HOSTNAME}.pub | multipass exec $VM_NAME -- tee -a .ssh/authorized_keys
# dummy command to force start of VM
multipass exec $VM_NAME  -- bash -c "ls"
#multipass exec $VM_NAME  -- bash -c "echo `cat ~/.ssh/id_${HOSTNAME}.pub` >> ~/.ssh/authorized_keys"
