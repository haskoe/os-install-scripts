sudo pacman -S openssh emacs-nox git base-devel gnupg pass bash-completion jq thunar
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

# ytdl .....

# i3
# Mod1 -> Mod4
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
I3_CONFIG_DIR=~/.config/i3
mkdir ${I3_CONFIG_DIR}/config.d
cp ${SCRIPT_DIR}/i3-config-include.conf ${I3_CONFIG_DIR}/config.d

tee -a ${I3_CONFIG} <<-EOF
include ~/.config/i3/config.d/*.conf
EOF
