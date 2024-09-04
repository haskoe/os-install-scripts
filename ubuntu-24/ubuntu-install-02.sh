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
sudo apt -y install docx2txt libarchive-tools unrar lynx elinks odt2txt wv antiword catdoc pandoc unrtf djvulibre-bin ccze libvirt-clients meld virt-manager flameshot p7zip lm-sensors evince exiftool mediainfo spice-client-gtk gparted kpartx
sudo apt -y install pinentry-tty sqlite3

# crash dump
sudo apt -y linux-crashdump
# reboot
# kdum config ......

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
echo 'eval `keychain --eval --agents ssh id_ed25519`' | tee -a ~/.bashrc 
#echo "export PATH=\$PATH:${HOME}/dev/haskoe/os-install-scripts/.bash:${HOME}/dev/azure-repos/cs/tools/db/unix" | tee -a ~/.bashrc 
source ~/.bashrc 

# nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | sh
source ~/.nvm/nvm.sh
nvm install --lts
nvm use --lts
npm --version

# bun 
curl -fsSL https://bun.sh/install | bash

# mainline
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

# git-credential-manager using gpg/pass
wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v${GCM_VER}/gcm-linux_amd64.${GCM_VER}.deb
sudo dpkg -i gcm-linux_amd64.${GCM_VER}.deb
tee ~/.gitconfig <<-EOF
[user]
	name = ${GH_USER}
	email = ${GH_EMAIL}
[pull]
	rebase = false
[credential]
	credentialStore = gpg
	helper = /usr/local/bin/git-credential-manager

[credential "https://dev.azure.com"]
	useHttpPath = true
EOF

# gpg and pass
sudo update-alternatives --config pinentry
gpg --full-generate-key # use defaults and save output for later use
pass init <key from gpg generate key>
# first git operation will prompt  for login credentials and save them in pass store

# postgres
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc
sudo apt -y update
sudo apt install -y postgresql-${POSTGRES_VER} postgresql-client-${POSTGRES_VER} libpq-dev postgresql-15-postgis-3 postgresql-15-postgis-3-scripts 
sudo apt install -y postgresql-server-dev-${POSTGRES_VER} postgresql-plpython3-${POSTGRES_VER} postgresql-15-pgtap
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo -u postgres psql -c "ALTER USER postgres with encrypted password '${POSTGRES_PWD}'" postgres
sudo perl -pibak -e 's/local.*all.*postgres.*peer/local all postgres md5/' /etc/postgresql/15/main/pg_hba.conf
sudo perl -pibak -e 's/en_US/en_DK/g' /etc/postgresql/15/main/postgresql.conf 
sudo systemctl restart postgresql.service
sudo -u postgres createuser -s -d heas
createdb heas
psql

# ssh hardened
CONF_FILE=/etc/ssh/sshd_config.d/hardened.conf
echo PermitRootLogin no | sudo tee $CONF_FILE
echo PubkeyAuthentication yes | sudo tee -a $CONF_FILE
echo ChallengeResponseAuthentication no | sudo tee -a $CONF_FILE
echo PasswordAuthentication no | sudo tee -a $CONF_FILE
#sudo perl -pibak -e 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
sudo systemctl restart ssh

# asdf
ASDF_BRANCH=v0.14.0
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_BRANCH}
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
asdf plugin-add haskell https://github.com/vic/asdf-haskell.git

asdf list all erlang
ERLANG_VER=27.0.1
asdf install erlang ${ERLANG_VER}
asdf global erlang ${ERLANG_VER}

asdf list all elixir
ELIXIR_VER=1.17.2-otp-27
asdf install elixir ${ELIXIR_VER}
asdf global elixir ${ELIXIR_VER}

asdf list all golang
GOLANG_VER=1.23.0
asdf install golang ${GOLANG_VER}
asdf global golang ${GOLANG_VER}

asdf list all haskell
HASKELL_VER=9.10.1
asdf install haskell ${HASKELL_VER}
asdf global haskell ${HASKELL_VER}



