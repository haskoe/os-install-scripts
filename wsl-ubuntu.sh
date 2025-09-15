sudo apt update && sudo apt -y dist-upgrade
sudo apt -y install git keychain emacs-nox openssh-server

ssh_fname=id_ed25519
ssh-keygen -f ~/.ssh/${ssh_fname}

curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
