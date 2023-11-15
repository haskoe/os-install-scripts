#!/bin/bash

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
cargo install rbw
#cargo install cargo-edit cargo-expand cargo-update bat ripgrep du-dust bottom exa fd-find sheldon dirstat-rs

# multipass
sudo snap install multipass
sudo snap stop multipass
sudo snap start multipass

VM_TYPE=lunar
VM_NAME=$VM_TYPE
multipass delete $VM_NAME
multipass purge
multipass launch $VM_TYPE -c 2 -m 2G -d 20G -n $VM_NAME
#VPN
multipass exec $VM_NAME  -- bash -c "sudo apt update && sudo apt -y dist-upgrade && sudo apt install -y git freerdp2-x11 openconnect openvpn && mkdir -p ~/dev/haskoe && cd ~/dev/haskoe && git clone https://github.com/haskoe/install-scripts.git && sudo shutdown -h now"
multipass start $VM_NAME
[[ ! -d ~/multipass-share ]] && mkdir ~/multipass-share
# dummy command to force start of VM
multipass exec $VM_NAME  -- bash -c "ls"
multipass mount ~/multipass-share $VM_NAME:/share
cp /home/heas/.cargo/bin/rbw* ~/multipass-share
multipass exec $VM_NAME  -- bash -c "sudo cp /share/rbw* /usr/local/bin"

multipass exec $VM_NAME  -- bash -c "sudo apt update && sudo apt -y dist-upgrade && sudo apt install -y git freerdp2-x11 openconnect python3-pip openvpn && pip3 install pykeepass && mkdir -p ~/dev/haskoe && cd ~/dev/haskoe && git clone https://github.com/haskoe/install-scripts.git && sudo shutdown -h now"
# Bitwarden pwd manager cli
BW_EMAIL=
multipass exec $VM_NAME  -- bash -c "sudo apt update && sudo apt -y dist-upgrade && sudo apt install -y git curl freerdp2-x11 openconnect openvpn && mkdir -p ~/dev/haskoe && cd ~/dev/haskoe && git clone https://github.com/haskoe/install-scripts.git && sudo shutdown -h now"
mkdir ~/multipass-share
multipass mount ~/multipass-share $VM_NAME:/share
cp /home/heas/.cargo/bin/rbw* ~/multipass-share
multipass exec $VM_NAME  -- bash -c "sudo cp /share/rbw* /usr/local/bin"
multipass exec $VM_NAME  -- bash -c "/share/rbw config set email ${BW_EMAIL}"

# nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | sh
source ~/.nvm/nvm.sh
nvm install --lts
nvm use --lts
npm --version

# # in .bashrc
# f="$HOME/.nvm/nvm.sh"
# if [ -r "$f" ]; then
#   . "$f" &>'/dev/null'
#   nvm use --lts &>'/dev/null'
# fi

# # in local project
# node --version > .nvmrc
# nvm use

# # git-credential-manager core
# GCM_VER=2.0.785
# wget "https://github.com/GitCredentialManager/git-credential-manager/releases/download/v${GCM_VER}/gcm-linux_amd64.${GCM_VER}.deb" -O /tmp/gcmcore.deb
# [[ -f /tmp/gcmcore.deb ]] && sudo dpkg -i /tmp/gcmcore.deb && git-credential-manager-core configure && git config --global credential.credentialStore secretservice

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
#update tailscale-hosts
#and then
cat ~/sync/heas-private/tailscale-hosts | sudo tee -a /etc/hosts

# i3 config
# login using i3
[ ! -f "~/.config/i3/config" ] && echo "i3 config does not exist" && exit 1
tee -a ~/.config/i3/config <<-EOF
bindsym \$mod+g exec --no-startup-id chromium
bindsym \$mod+m exec --no-startup-id thunderbird
bindsym \$mod+u exec --no-startup-id thunar
bindsym \$mod+i exec --no-startup-id idle
bindsym \$mod+n exec terminator -e ranger
#bindsym \$mod+r exec --no-startup-id ranger
bindsym \$mod+c exec --no-startup-id code
bindsym \$mod+p exec --no-startup-id keepass2
bindsym \$mod+y exec --no-startup-id smplayer

bindsym \$mod+F10 exec pactl set-sink-mute @DEFAULT_SINK@ toggle # Mute
bindsym \$mod+F11 exec pactl set-sink-volume @DEFAULT_SINK@ -5%  # Up
bindsym \$mod+F12 exec pactl set-sink-volume @DEFAULT_SINK@ +5%  # Down
bindsym \$mod+F9  exec ~/.config/i3/toggle_sink.sh
bindsym \$mod+Shift+w exec ~/.config/i3/toggle-wifi

exec picom
EOF

tee ~/.config/i3/toggle-wifi <<-EOF
#!/bin/bash -e

if [[ "\$(sudo nmcli radio wifi)" == "disabled" ]]; then sudo nmcli radio wifi on; else sudo nmcli radio wifi off; fi
EOF
chmod +x ~/.config/i3/toggle-wifi

cp ${SCRIPTPATH}/i3/toggle_sink.sh ~/.config/i3
chmod +x ~/.config/i3/toggle_sink.sh
# refresh: $mod+shift+r

# change screen layout
#xrandr --output HDMI-A-0 --auto --output eDP --off
# autorandr set 
#autorandr -s external
# autorandr set default
#autorandr -d external

# personal stuff
echo 'eval `keychain --eval --agents ssh id_${HOSTNAME}`' | tee -a ~/.bashrc 
echo 'export KP_DB=~/sync/heas-private/has.kdbx' | tee -a ~/.bashrc 
echo "export PATH=\$PATH:${HOME}/dev/haskoe/install-scripts/.bashrc" | tee -a ~/.bashrc 

# copy thunderbird config
# start
# remote vpn
. ~/dev/haskoe/install-scripts/vpn/kpm.sh
. ~/dev/haskoe/install-scripts/vpn/rd-vpn.sh <path> <remote host/userid>

# pip update all
pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
pip3 install virtualenv

# ddrescue image backup
sudo apt install gddrescue
lsblk
# udisksctl mount -b /dev/sdX
DISK_DEV=sda
DISK_TEXT=1tb
DISK_NAME=$(udevadm info --query=all --name=/dev/sda | grep ID_SERIAL= | sed -e 's/^.*=//g')
DISK_SIZE=$(numfmt --to iec --format "%8.4f" $(sudo blockdev --getsz /dev/${DISK_DEV}))
IMG_NAME=${DISK_NAME}-${DISK_TEXT} #-${DISK_SIZE}                                                                                                                                            
TGT_DIR=/media/heas/SSD
ZIP_DIR=/media/heas/Expansion/disk_backup
sudo ddrescue -d /dev/${DISK_DEV} ${TGT_DIR}/${IMG_NAME}.img ${TGT_DIR}/${IMG_NAME}.logfile
#sudo dd if=/dev/${DISK_DEV} of=${IMG_NAME}.img bs=1M conv=fsync                                                                                                                             
~/zstd -9 ${TGT_DIR}/${IMG_NAME}.img -o ${ZIP_DIR}/${IMG_NAME}.img.zst

# elixir
# current branch is on https://asdf-vm.com/guide/getting-started.html
sudo apt -y install automake autoconf libncurses5-dev inotify-tools
ASDF_BRANCH=v0.12.0
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_BRANCH}
tee -a ~/.bashrc <<-EOF
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
EOF
source ~/.bashrc

asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf list all nodejs
asdf install nodejs 20.5.0
asdf global nodejs 20.5.0

asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git

asdf list all erlang
ERLANG_VER=26.0.2
asdf install erlang ${ERLANG_VER}
asdf global erlang ${ERLANG_VER}

asdf list all elixir
ELIXIR_VER=1.15.4-otp-26
asdf install elixir ${ELIXIR_VER}
asdf global elixir ${ELIXIR_VER}

# elixir phoenix
mix local.hex
mix archive.install hex phx_new
mkdir -p ~/proj/liveview && cd ~/proj/liveview && mix phx.new blog && cd blog 
# update user id and password in dev.exs
mix ecto.create && mix phx.server