sudo pacman -S openssh emacs-nox git base-devel gnupg pass bash-completion jq
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