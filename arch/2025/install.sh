sudo pacman -S openssh emacs-nox git base-devel gnupg pass bash-completion jq thunar tmux fzf terminator wezterm zstd 7zip
sudo systemctl start sshd && sudo systemctl enable sshd

# yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si

# tailscale 
sudo pacman -S tailscale
sudo systemctl start tailscaled && sudo systemctl enable tailscaled
sudo tailscale up

# sublime-merge
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu sublime-merge

yay google-chrome
yay visual-studio-code-bin

# github and azure using local gnupg password store
GH_USER=
GH_EMAIL=
tee ~/.gitconfig <<-EOF
[user]
	name = ${GH_USER}
	email = ${GH_EMAIL}
[pull]
	rebase = false
[credential]
	credentialStore = gpg
	helper = /usr/bin/git-credential-manager

[credential "https://dev.azure.com"]
	useHttpPath = true
EOF

gpg --full-generate-key # use defaults and save output for later use
GPG_KEY=`gpg --list-keys | grep '^[ ]' | tr -d ' '`
pass init ${GPG_KEY}

yay -S git-credential-manager

mkdir -p ~/proj/heas0404/misc
git clone https://heas0404@dev.azure.com/heas0404/MISC/_git/adoctest

mkdir -p ~/dev/haskoe && cd ~/dev/haskoe
git clone https://github.com/haskoe/os-install-scripts.git

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
# cargo-binstall
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
cargo-binstall bat bottom dirstat-rs du-dust exa fd-find ripgrep

# docker
sudo pacman -S docker
sudo usermod -aG docker $USER
sudo systemctl start docker.socket && sudo systemctl enable docker.socket

# python uv in devcontainer
git clone https://github.com/a5chin/python-uv.git
cd python-uv
code .

yay -S otf-libertinus ttf-linux-libertine pandoc-crossref texlive-context tectonic texlive-fontsrecommended texlive-latex texlive-xetex
yay -S quarto-cli 

# ffmpeg
yay -S ffmpeg
# av1 example
# for file in ./*.mp4; do ffmpeg -i $file -c:v libsvtav1 -crf 30 ~/drtv/mkv/$file; done

# qemu quickemu choose full package
# example: quickemu --vm ~/quickemu/windows-11.conf --display spice

# ranger 
yay -S ranger atool elinks ffmpegthumbnailer highlight imagemagick libcaca lynx mediainfo odt2txt perl-image-exiftool poppler transmission-cli ueberzug w3m 
set preview_images true
RANGER_CONFIG=~/.config/ranger/rc.conf
perl -pi.bak -e 's/^set preview_images.*$/set preview_images true/g' $RANGER_CONFIG

# ytdl .....

# i3
# Mod1 -> Mod4
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
I3_CONFIG_DIR=~/.config/i3
I3_CONFIG=${I3_CONFIG_DIR}/config
perl -pi.bak -e 's/^bindsym..mod.Return/#bindsym $mod+Return/g' $I3_CONFIG

mkdir ${I3_CONFIG_DIR}/config.d
cp ${SCRIPT_DIR}/i3-config-include.conf ${I3_CONFIG_DIR}/config.d

tee -a ${I3_CONFIG} <<-EOF
include ~/.config/i3/config.d/*.conf
EOF

tee -a ~/.bashrc <<-EOF

. "$HOME/dev/haskoe/os-install-scripts/.bash/.bashrc

. "$HOME/.cargo/env"

eval "$(fzf --bash)"
EOF

yay -S powershell-bin

# postgres
sudo pacman -S postgresql
sudo su - postgres initdb --locale en_US.UTF-8 -D /var/lib/postgres/data
su - postgres
psql -c "alter user postgres with password 'password'"
sudo perl -pibak -e 's/local.*all.*postgres.*peer/local all postgres md5/' /var/lib/postgres/data/pg_hba.conf
sudo perl -pibak -e 's/en_DK/en_US/g' /var/lib/postgres/data/postgresql.conf 
sudo systemctl restart postgresql.service
sudo -u postgres createuser -s -d ${USER}
createdb ${USER}
psql

# mise
# read about secrets: https://mise.jdx.dev/environments/secrets.html
curl https://mise.run | sh
echo "eval \"\$(/home/heas/.local/bin/mise activate bash)\"" >> ~/.bashrc
source ~/.bashrc
mise doctor
mise use -g uv@latest
mise use -g bun@latest
mise use -g go@latest
 mise use -g erlang elixir
 # secrets
 mise use -g sops
 mise use -g age
 age-keygen -o ~/.config/mise/age.txt
 PK=<public key>
 sops encrypt -i --age $PK .env.json
SOPS_AGE_KEY_FILE=~/.config/mise/age.txt
export SOPS_AGE_KEY_FILE=~/.config/mise/age.txt
 
ssh_fname=id_ed25519
ssh-keygen -f ~/.ssh/${ssh_fname}
# ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host
