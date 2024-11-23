#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
[[ ! -f "${SCRIPT_DIR}/env.sh" ]] && echo missing env file && exit 1

. ${SCRIPT_DIR}/env.sh

pass init ${GPG_KEY}

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
