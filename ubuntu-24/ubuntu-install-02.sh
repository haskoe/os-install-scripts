#!/bin/bash

# login to i3
I3_CONFIG_DIR=~/.config/i3
I3_CONFIG=${I3_CONFIG_DIR}/config
# hack: mkdir -p ${I3_CONFIG_DIR} && touch ${I3_CONFIG}
[[ ! -f "${I3_CONFIG}" ]] && echo Please login using i3 && exit 1

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
[[ ! -f "${SCRIPT_DIR}/env.sh" ]] && echo missing env file && exit 1

. ${SCRIPT_DIR}/env.sh
[[ -z "${GH_USER}" ]] && echo "Github USERNAME must be set" && exit 1
[[ -z "${GH_EMAIL}" ]] && echo "Github e-mail must be set" && exit 1

git config --global user.name $GH_USER
git config --global user.email $GH_EMAIL
git config --global pull.rebase false

I3_INCLUDE_FILE=${SCRIPT_DIR}/i3-config-include.conf
[[ ! -f "${I3_INCLUDE_FILE}" ]] && echo missin include file && exit 1

mkdir ${I3_CONFIG_DIR}/config.d
cp ${SCRIPT_DIR}/i3-config-include.conf ${I3_CONFIG_DIR}/config.d

tee -a ${I3_CONFIG} <<-EOF
include ~/.config/i3/config.d/*.conf
EOF
sudo apt -y install git blueman bluez pulseaudio-module-bluetooth automake autoconf libncurses5-dev inotify-tools picom pkg-config keychain build-essential gddrescue smplayer pass gpg emacs-nox tmux powertop git gitk i3 i3status keychain autorandr curl curl apt-transport-https htop ca-certificates build-essential brightnessctl freerdp2-x11 openconnect libssl-dev libssh-dev thunderbird ranger python3-pip idle terminator pkg-config mc usb-creator-gtk fzf
sudo apt -y install docx2txt libarchive-tools unrar lynx elinks odt2txt wv antiword catdoc pandoc unrtf djvulibre-bin ccze libvirt-clients meld virt-manager flameshot p7zip lm-sensors evince exiftool mediainfo

ssh_fname=id_ed25519
ssh-keygen -f ~/.ssh/${ssh_fname}

sudo snap install chromium
#sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /snap/bin/chromium 210
#sudo update-alternatives --config x-www-browser

sudo snap install code --classic

# syncthing
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
echo "deb https://apt.syncthing.net/ syncthing release" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt -y update && sudo apt -y install syncthing

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt -y update && sudo apt -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -a -G docker $USER # logout/login

# ssh server
sudo apt -y install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh

# .bashrc
echo ". ${HOME}/dev/haskoe/os-install-scripts/.bash/.bashrc" >>~/.bashrc
echo 'eval `keychain --eval --agents ssh id_${HOSTNAME}`' | tee -a ~/.bashrc 
echo "export PATH=\$PATH:${HOME}/dev/haskoe/os-install-scripts/.bash:${HOME}/dev/azure-repos/cs/tools/db/unix" | tee -a ~/.bashrc 
source ~/.bashrc 

# nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | sh
source ~/.nvm/nvm.sh
nvm install --lts
nvm use --lts
npm --version

# bun 
curl -fsSL https://bun.sh/install | bash

sudo add-apt-repository -y ppa:cappelikan/ppa
sudo apt -y update && sudo apt -y dist-upgrade
sudo apt install -y mainline

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# multipass
sudo snap remove multipass lxd
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

# pip update all
# pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
# pip3 install virtualenv

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
cargo install cargo-edit cargo-expand cargo-update bat ripgrep du-dust bottom exa fd-find dirstat-rs cargo install yazi-fm yazi-cli

curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list

sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

sudo apt update && sudo apt install 1password-cli

op account add --address my.1password.com --email
