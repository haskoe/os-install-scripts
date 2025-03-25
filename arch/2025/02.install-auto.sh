# locale
PREFERRED_LOCALE=en_DK.UTF-8
sudo perl -pibak  -e 's/^#en_DK.UTF-8/en_DK.UTF-8/g' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=${PREFERRED_LOCALE}

# yay
sudo pacman --noconfirm -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si 

yay -S base-devel dracut gnupg pass bash-completion jq mplayer vlc hunspell-da hunspell-en ttc-iosevka task goreleaser-bin meld lazygit zellij broot sublime-merge rustdesk-bin fzf thunar gvfs keychain fwupd less 7zip smplayer  base-devel gnupg pass bash-completion jq thunar tmux fzf terminator wezterm zstd 7zip inotify-tools ffmpeg keychain less gvfs fwupd inotify-tools rdesktop pavucontrol udev-block-notify dunst thunderbird inotify-tools tk rsync #pragmatapro-fonts pass

# erlang/elixir stuff
yay -S inets erlang-inets erlang-os_mon erlang-runtime_tools erlang-ssl erlang-xmerl erlang-parsetools
yay -S virtualbox virtualbox-host-modules-arch
# microsoft access
yay -S mdbtools gmdb2


# sublime-merge
#curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
#echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
#sudo pacman --noconfirm -Syu sublime-merge

yay -S google-chrome visual-studio-code-bin  git-credential-manager firefox  yt-dlp powershell exfat-utils testdisk # or powershell-bin

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
# cargo-binstall
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
cargo-binstall bat bottom dirstat-rs du-dust exa fd-find ripgrep cargo-edit cargo-update
cargo install-update -a

# docker
sudo pacman -S docker
sudo usermod -aG docker $USER
sudo systemctl start docker.socket && sudo systemctl enable docker.socket
# logout and login

# tailscale 
sudo pacman --noconfirm -S tailscale
sudo systemctl start tailscaled && sudo systemctl enable tailscaled

# postgres
sudo pacman --noconfirm  -S postgresql
sudo su - postgres
initdb --locale en_DK.UTF-8 -D /var/lib/postgres/data
exit
sudo perl -pibak -e 's/local.*all.*postgres.*peer/local all postgres md5/' /var/lib/postgres/data/pg_hba.conf
sudo systemctl start postgresql.service
sudo systemctl enable postgresql.service
sudo -u postgres createuser -s -d ${USER}
createdb ${USER}
psql
# docker, available on 0.0.0.0:5432
# docker run --name some-postgres -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d postgres:17-alpine

yay -S otf-libertinus ttf-linux-libertine pandoc-crossref texlive-context tectonic texlive-fontsrecommended texlive-latex texlive-xetex
yay -S quarto-cli 

# qemu 
yay -S quickemu # choose full package
# example: quickemu --vm ~/quickemu/windows-11.conf --display spice

# ranger 
yay -S ranger atool elinks ffmpegthumbnailer highlight imagemagick libcaca lynx mediainfo odt2txt perl-image-exiftool poppler transmission-cli ueberzug w3m 
ranger --copy-config=all
RANGER_CONFIG=~/.config/ranger/rc.conf
perl -pi.bak -e 's/^set preview_images.*$/set preview_images true/g' $RANGER_CONFIG

I3_CONFIG_DIR=~/.config/i3
I3_CONFIG=${I3_CONFIG_DIR}/config
tee -a ${I3_CONFIG} <<-EOF
include ~/.config/i3/config.d/*.conf
EOF
perl -pi.bak -e 's/^bindsym..mod.Return/#bindsym $mod+Return/g' $I3_CONFIG 

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
mkdir ${I3_CONFIG_DIR}/config.d
[[ -f ${SCRIPT_DIR}/i3-config-include.conf ]] && cp ${SCRIPT_DIR}/i3-config-include.conf  ${I3_CONFIG_DIR}/config.d

# mise
# read about secrets: https://mise.jdx.dev/environments/secrets.html
curl https://mise.run | sh
#echo "eval \"\$(/home/heas/.local/bin/mise activate bash)\"" >> ~/.bashrc
. ~/.bashrc
mise doctor
mise use -g uv@latest
mise use -g bun@latest
mise use -g go@latest
mise use -g erlang elixir
mix archive.install hex phx_new
# secrets
mise use -g sops
mise use -g age
age-keygen -o ~/.config/mise/age.txt
#PK=<public key>
#sops encrypt -i --age $PK .env.json
#SOPS_AGE_KEY_FILE=~/.config/mise/age.txt
#export SOPS_AGE_KEY_FILE=~/.config/mise/age.txt

gpg --full-generate-key # use defaults and save output for later use
GPG_KEY=`gpg --list-keys | grep '^[ ]' | tr -d ' '`
pass init ${GPG_KEY}

tee -a ~/.bashrc <<-EOF

. "$HOME/dev/haskoe/os-install-scripts/.bash/.bashrc"

. "$HOME/.cargo/env"

eval "\$(fzf --bash)"

eval "\$($HOME/.local/bin/mise activate bash)"
EOF
 
ssh_fname=id_ed25519
ssh-keygen -f ~/.ssh/${ssh_fname}
# ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host

# phoenix
#mix ecto.create
#mix phx.server

# av1 example
# find ./ -name 'a*.mp4' -size +2G -exec bash -c 'ffmpeg -i $0 -c:v libsvtav1 -crf 30 ~/drtv/mkv/$0' {} \;
#he biggest strength of psy Av1 is using their Tune=3 setting as this example (for anime) and Grainsynth ofr movies
#ffmpeg.exe -i "source anime 1080p.mkv" -c:v libsvtav1 -preset 4 -crf 32 -svtav1-params tune=3 -c:a libopus -b:a 128k "output anime 1080p.mkv"
#For movies with lots of filmgrain i suggest also using the grainsynth option that will manage to make miracles with quality per filesize
#tune=3:film-grain=10 

#mkdir -p ~/proj/heas0404/misc
#git clone https://heas0404@dev.azure.com/heas0404/MISC/_git/adoctest

#mkdir -p ~/dev/haskoe && cd ~/dev/haskoe
#git clone https://github.com/haskoe/os-install-scripts.git


# python uv in devcontainer
#git clone https://github.com/a5chin/python-uv.git
#cd python-uv
#code .

# ytdl .....

# i3
# Mod1 -> Mod4

# handbrake (av1)
#sudo pacman -Syu base-devel cmake flac fontconfig freetype2 fribidi git harfbuzz jansson lame libass libbluray libjpeg-turbo libogg libsamplerate libtheora libvorbis libvpx libxml2 meson nasm ninja numactl opus python speex x264 xz
#sudo pacman -Syu desktop-file-utils gst-libav gst-plugins-good gtk4

# tmdb
#https://www.themoviedb.org/talk/648c854526346200eb7540c4

# incus
# https://linuxcontainers.org/incus/try-it/
# https://github.com/zabbly/incus-ui-canonical.git
sudo pacman -S incus
sudo systemctl start incus.socket && sudo systemctl enable incus.socket

# r
sudo pacman -S r gcc-fortran
# start R and do run command: install.packages(c("pkgname"))
# and then from shell:
set +H
declare -a R_PKGS=(
  "dplyr"
  "tidyr"
  "ggplot2"
  "lattice"
  "knitr"
  "rmarkdown"
)
for R_PKG in "${R_PKGS[@]}"
do
  Rscript -e "if (!require('${R_PKG}')) install.packages('${R_PKG}', repos='https://cloud.r-project.org')"
done

# nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o nix-install.sh
bash ./nix-install.sh install
# example
# nix run nixpkgs#screenly-cli
# nix shell nixpkgs#screenly-cli
