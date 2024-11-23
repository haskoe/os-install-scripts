#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
[[ ! -f "${SCRIPT_DIR}/env.sh" ]] && echo missing env file && exit 1

. ${SCRIPT_DIR}/env.sh

[[ -z "${GH_USER}" ]] && echo "Github USERNAME must be set" && exit 1
[[ -z "${GH_EMAIL}" ]] && echo "Github e-mail must be set" && exit 1
[[ -z "${POSTGRES_VER}" ]] && echo "Github e-mail must be set" && exit 1
[[ -z "${ASDF_VER}" ]] && echo "Github e-mail must be set" && exit 1

sudo apt -y install gdebi-core git automake autoconf libncurses5-dev inotify-tools pkg-config keychain build-essential ddrescue mplayer 
sudo apt -y install pass gpg emacs-nox tmux powertop gitk curl apt-transport-https htop ca-certificates openconnect 
sudo apt -y install libssl-dev libssh-dev ranger python3-pip terminator mc fzf gddrescue 
sudo apt -y install docx2txt libarchive-tools unrar lynx elinks odt2txt wv antiword catdoc pandoc unrtf djvulibre-bin ccze 
sudo apt -y install libvirt-clients virt-manager p7zip exiftool mediainfo pinentry-tty sqlite3
sudo apt -y install chrpath libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev
sudo apt -y install libgsl-dev libgdal-dev

sudo apt-get install -y libreadline-dev gfortran liblzma-dev liblzma5 libbz2-1.0 libbz2-dev libpcre2-dev

git config --global user.name $GH_USER
git config --global user.email $GH_EMAIL
git config --global pull.rebase false

# crash dump
sudo apt -y linux-crashdump
# reboot
# kdum config ......

ssh_fname=id_ed25519
ssh-keygen -f ~/.ssh/${ssh_fname}

# syncthing
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
echo "deb https://apt.syncthing.net/ syncthing release" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt -y update && sudo apt -y install syncthing

# ssh server
sudo apt -y install openssh-server && sudo systemctl start ssh && sudo systemctl enable ssh

# .bashrc
echo ". ${HOME}/dev/haskoe/os-install-scripts/.bash/.bashrc" >>~/.bashrc

# bun 
curl -fsSL https://bun.sh/install | bash

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# 1password
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt update && sudo apt install 1password-cli
op account add --address my.1password.com --email

# gpg and pass
sudo update-alternatives --config pinentry
gpg --full-generate-key # use defaults and save output for later use

echo update env.sh with PGP key
