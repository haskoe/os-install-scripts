# locale
PREFERRED_LOCALE=en_DK.UTF-8
sudo perl -pibak  -e 's/^#en_DK.UTF-8/en_DK.UTF-8/g' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=${PREFERRED_LOCALE}

sudo perl -pibak  -e 's/^#AllowSuspend/AllowSuspend/g' /etc/systemd/sleep.conf

alias sudo='sudo '
alias yays='yay --needed --noconfirm -S'
alias pacs='pacman --needed --noconfirm -S'
# yay
sudo pacs lshw autorandr git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si 

sudo pacs fd net-tools dracut jq mplayer smplayer vlc hunspell ttc-iosevka task meld lazygit lazydocker zellij broot htop
sudo pacs fzf thunar gvfs keychain fwupd less 7zip gnupg pass bash-completion thunar terminator wezterm zstd unrar
sudo pacs inotify-tools ffmpeg keychain less gvfs rdesktop pavucontrol dunst thunderbird tk rsync dmidecode
sudo pacs libreoffice fastfetch impala btop zoxide eza ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono
yays pinta hunspell-da goreleaser-bin sublime-merge rustdesk-bin udev-block-notify
yays alsamixer alsa-utils pipewire-pulse pipewire pwvucontrol
yays tldr arj fclones iwgtk sparrow-wifi-gitmutt turbostat cpupower cpupower-gui gparted catdoc typst
yays otf-libertinus ttf-linux-libertine ttf-bitstream-charter texlive-font texlive-fontsextra texlive-fontsrecommended ttf-barlow texlive-minionpro-git
yays upower acpi power-profiles-daemon
yays sshfs elvish llama.cpp-vulkan

# yazi
yays yazi chafa ueberzugpp xclip xsel wl-copy resvg

# yazi office preview, slow ....
ya pkg add macydnah/office

YAZI_CONFIG_DIR=~/.config/yazi
mkdir -p ${YAZI_CONFIG_DIR}
tee -a ${YAZI_CONFIG_DIR}/yazi.toml <<-EOF
[mgr]
show_hidden = true
ratio = [1, 2, 5]

[preview]
max_width = 3840
max_height = 2160
image_quality = 90
wrap = "yes"

[plugin]

prepend_preloaders = [
    # Office Documents
    { mime = "application/openxmlformats-officedocument.*", run = "office" },
    { mime = "application/oasis.opendocument.*", run = "office" },
    { mime = "application/ms-*", run = "office" },
    { mime = "application/msword", run = "office" },
    { name = "*.docx", run = "office" },
]

prepend_previewers = [
    # Office Documents
    { mime = "application/openxmlformats-officedocument.*", run = "office" },
    { mime = "application/oasis.opendocument.*", run = "office" },
    { mime = "application/ms-*", run = "office" },
    { mime = "application/msword", run = "office" },
    { name = "*.docx", run = "office" },
]
EOF

# erlang/elixir stuff
sudo pacs erlang-inets erlang-os_mon erlang-runtime_tools erlang-ssl erlang-xmerl erlang-parsetools
#yays virtualbox virtualbox-host-modules-arch
# microsoft access
yays mdbtools gmdb2


# sublime-merge
#curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
#echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
#sudo pacsyu sublime-merge

sudo pacs yt-dlp exfat-utils testdisk
yays google-chrome visual-studio-code-bin git-credential-manager powershell-bin# or powershell-bin

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
# cargo-binstall
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
cargo-binstall bat bottom dirstat-rs du-dust exa ripgrep cargo-edit cargo-update
cargo install-update -a

# docker
sudo pacman -S docker
sudo usermod -aG docker $USER
sudo systemctl start docker.service && sudo systemctl enable docker.service
# logout and login

yay -S docker-buildx buildkit
# tailscale 
sudo pacs tailscale
sudo systemctl start tailscaled && sudo systemctl enable tailscaled
sudo tailscale up

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

yays otf-libertinus ttf-linux-libertine texlive-context tectonic texlive-fontsrecommended texlive-latex texlive-xetex
yays quarto-cli 

# qemu 
yays quickemu # choose full package
# example: quickemu --vm ~/quickemu/windows-11.conf --display spice

# ranger 
yays ranger atool elinks ffmpegthumbnailer highlight imagemagick libcaca lynx mediainfo odt2txt perl-image-exiftool poppler transmission-cli w3m abiword catdoc
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
mise use -g uv@latest bun@latest go@latest erlang@latest elixir@latest python@latest

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
mkdir -p ~/.rhome/lib
touch ~/.rhome/.Rprofile
touch ~/.rhome/.Rhistory

tee -a ~/.Renviron <<-EOF
R_HOME_USER = "/home/heas/.rhome"
R_PROFILE_USER = "/home/heas/.rhome/.Rprofile"
R_LIBS_USER = "/home/heas/.rhome/lib"
R_HISTFILE = "/home/heas/.rhome/.Rhistory"
EOF

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
  "shiny"
)
for R_PKG in "${R_PKGS[@]}"
do
  Rscript -e "if (!require('${R_PKG}')) install.packages('${R_PKG}', repos='https://cloud.r-project.org')"
done

# nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o nix-install.sh
bash ./nix-install.sh install
nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes'
# nix comma
# , rg a
# example
# nix run nixpkgs#screenly-cli
# nix shell nixpkgs#screenly-cli

# uv
uv init uv-test
cd uv-test
uv add package
uv run ...py
# uv textual
# uvx --python 3.12 textual-demo