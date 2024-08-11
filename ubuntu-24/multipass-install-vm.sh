VM_TYPE=noble
VM_NAME=${VM_TYPE}
multipass delete $VM_NAME
multipass purge
multipass launch $VM_TYPE -c 2 -m 2G -d 20G -n $VM_NAME
multipass exec $VM_NAME  -- bash -c "sudo apt update && sudo apt -y dist-upgrade && sudo apt install -y git freerdp2-x11 openconnect openvpn && mkdir -p ~/dev/haskoe && cd ~/dev/haskoe && git clone https://github.com/haskoe/os-install-scripts.git && sudo shutdown -h now"
multipass start $VM_NAME
multipass exec $VM_NAME  -- bash -c "echo `cat ~/.ssh/id_${HOSTNAME}.pub` >> ~/.ssh/authorized_keys"
cat ~/.ssh/id_${HOSTNAME}.pub | multipass exec $VM_NAME -- tee -a .ssh/authorized_keys
