#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
[[ ! -f "${SCRIPT_DIR}/env.sh" ]] && echo missing env file && exit 1

. ${SCRIPT_DIR}/env.sh

[[ -z "${GH_USER}" ]] && echo "Github USERNAME must be set" && exit 1
[[ -z "${GH_EMAIL}" ]] && echo "Github e-mail must be set" && exit 1
[[ -z "${POSTGRES_VER}" ]] && echo "Github e-mail must be set" && exit 1
[[ -z "${ASDF_VER}" ]] && echo "Github e-mail must be set" && exit 1

sudo apt -y install git automake autoconf libncurses5-dev inotify-tools pkg-config keychain build-essential ddrescue mplayer 
sudo apt -y install pass gpg emacs-nox tmux powertop gitk curl apt-transport-https htop ca-certificates openconnect 
sudo apt -y install libssl-dev libssh-dev ranger python3-pip terminator mc fzf gddrescue 
sudo apt -y install docx2txt libarchive-tools unrar lynx elinks odt2txt wv antiword catdoc pandoc unrtf djvulibre-bin ccze 
sudo apt -y install libvirt-clients virt-manager p7zip exiftool mediainfo pinentry-tty sqlite3
sudo apt -y install chrpath libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev
sudo apt -y install libgsl-dev libgdal-dev

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
pass init <key from gpg generate key>

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

# postgres
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc
sudo apt -y update
sudo apt install -y postgresql-${POSTGRES_VER} postgresql-client-${POSTGRES_VER} libpq-dev postgresql-${POSTGRES_VER}-postgis-3 postgresql-${POSTGRES_VER}-postgis-3-scripts 
sudo apt install -y postgresql-server-dev-${POSTGRES_VER} postgresql-plpython3-${POSTGRES_VER} postgresql-${POSTGRES_VER}-pgtap
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo -u postgres psql -c "ALTER USER postgres with encrypted password '${POSTGRES_PWD}'" postgres
sudo perl -pibak -e 's/local.*all.*postgres.*peer/local all postgres md5/' /etc/postgresql/${POSTGRES_VER}/main/pg_hba.conf
sudo perl -pibak -e 's/en_US/en_DK/g' /etc/postgresql/${POSTGRES_VER}/main/postgresql.conf 
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
sudo systemctl restart ssh

# asdf
ASDF_BRANCH=v${ASDF_VER}
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_BRANCH}
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
