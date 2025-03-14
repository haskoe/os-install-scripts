sudo pacman --noconfirm -Syu
sudo pacman --noconfirm -S openssh git
sudo systemctl start sshd && sudo systemctl enable sshd
