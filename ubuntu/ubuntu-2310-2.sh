#!/bin/bash

sudo update-alternatives --config x-www-browser

# step 2
GH_USER=hgeas
GH_EMAIL=henrik@haskoe.dk

# abort if USERNAME is not set
[[ -z "$GH_USER" ]] && echo "USERNAME must be set" && exit 1
[[ -z "$GH_EMAIL" ]] && echo "USERNAME must be set" && exit 1

sudo apt -y install blueman bluez pulseaudio-module-bluetooth automake autoconf libncurses5-dev inotify-tools picom pkg-config keychain build-essential gddrescue smplayer pass gpg emacs-nox tmux powertop git gitk i3 i3status keychain autorandr curl curl apt-transport-https htop ca-certificates build-essential brightnessctl freerdp2-x11 openconnect libssl-dev libssh-dev thunderbird ranger python3-pip idle terminator pkg-config mc usb-creator-gtk

# git
git config --global user.name $GH_USER
git config --global user.email $GH_EMAIL
git config --global pull.rebase false

#hostname=`hostname`
ssh_fname=id_${HOSTNAME}
ssh-keygen -f ~/.ssh/${ssh_fname}

sudo snap install chromium
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /snap/bin/chromium 210
sudo update-alternatives --config x-www-browser

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

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# .bashrc
echo ". ${HOME}/dev/haskoe/os-install-scripts/.bash/.bashrc" >>~/.bashrc
echo 'eval `keychain --eval --agents ssh id_${HOSTNAME}`' | tee -a ~/.bashrc 
echo "export PATH=\$PATH:${HOME}/dev/haskoe/os-install-scripts/.bash:${HOME}/dev/azure-repos/cs/tools/db/unix" | tee -a ~/.bashrc 
source ~/.bashrc 

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
cargo install rbw
#cargo install cargo-edit cargo-expand cargo-update bat ripgrep du-dust bottom exa fd-find sheldon dirstat-rs

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

VM_TYPE=lunar
VM_NAME=${VM_TYPE}
multipass delete $VM_NAME
multipass purge
multipass launch $VM_TYPE -c 2 -m 2G -d 20G -n $VM_NAME
multipass exec $VM_NAME  -- bash -c "sudo apt update && sudo apt -y dist-upgrade && sudo apt install -y git freerdp2-x11 openconnect openvpn && mkdir -p ~/dev/haskoe && cd ~/dev/haskoe && git clone https://github.com/haskoe/install-scripts.git && sudo shutdown -h now"
multipass start $VM_NAME
[[ ! -d ~/multipass-share ]] && mkdir ~/multipass-share
# dummy command to force start of VM
multipass exec $VM_NAME  -- bash -c "ls"
multipass mount ~/multipass-share $VM_NAME:/share
cp /home/heas/.cargo/bin/rbw* ~/multipass-share
multipass exec $VM_NAME  -- bash -c "sudo cp /share/rbw* /usr/local/bin"
multipass shell $VM_NAME


ASDF_BRANCH=v0.12.0
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_BRANCH}
tee -a ~/.bashrc <<-EOF
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
EOF
source ~/.bashrc

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

# postgres
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc
sudo apt -y update
sudo apt install -y postgresql-15 postgresql-client-15 libpq-dev postgresql-15-postgis-3 postgresql-15-postgis-3-scripts 
sudo apt install -y postgresql-server-dev-15 postgresql-plpython3-15 postgresql-15-pgtap
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo -u postgres psql -c "ALTER USER postgres with encrypted password '<password>'" postgres
sudo perl -pibak -e 's/local.*all.*postgres.*peer/local all postgres md5/' /etc/postgresql/15/main/pg_hba.conf
sudo perl -pibak -e 's/en_US/en_DK/g' /etc/postgresql/15/main/postgresql.conf 
sudo systemctl restart postgresql.service
sudo -u postgres createuser -s -d heas
createdb heas
psql
# tune parameters ....
max_connections = 100
shared_buffers = 4GB
effective_cache_size = 12GB
maintenance_work_mem = 1GB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 10485kB
min_wal_size = 1GB
max_wal_size = 4GB
max_worker_processes = 8
max_parallel_workers_per_gather = 4
max_parallel_workers = 8
max_parallel_maintenance_workers = 4
#sudo emacs /etc/postgresql/15/main/postgresql.conf
#sudo systemctl restart postgresql.service

# passwordless ssh and block root
CONF_FILE=/etc/ssh/sshd_config.d/hardened.conf
echo PermitRootLogin no | sudo tee $CONF_FILE
echo PubkeyAuthentication yes | sudo tee -a $CONF_FILE
echo ChallengeResponseAuthentication no | sudo tee -a $CONF_FILE
echo PasswordAuthentication no | sudo tee -a $CONF_FILE
sudo perl -pibak -e 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
sudo systemctl restart ssh

# git credential manager
# download deb
GCM_VER=2.4.1
wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v${GCM_VER}/gcm-linux_amd64.${GCM_VER}.deb
sudo dpkg -i gcm-linux_amd64.${GCM_VER}.deb
git-credential-manager configure

# gpg store
git config --global credential.credentialStore gpg
# gpg --gen-key
# pass init heas
# export GPG_TTY=$(tty)
#journalctl --user -b -u gpg-agent

# mainline kernel
wget https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
chmod +x ubuntu-mainline-kernel.sh
sudo mv ubuntu-mainline-kernel.sh /usr/local/bin/

# pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm env use --global lts

# powershell
sudo snap install powershell --classic

# 1pwd client
sudo snap install 1password

# 1pwd CLI
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list

sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

sudo apt update && sudo apt install 1password-cli