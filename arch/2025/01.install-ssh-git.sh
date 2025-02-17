sudo pacman --noconfirm -Syu
sudo pacman --noconfirm -S openssh emacs-nox git base-devel gnupg pass bash-completion jq thunar tmux fzf terminator wezterm zstd 7zip inotify-tools ffmpeg keychain less gvfs idle tk fwupd
sudo systemctl start sshd && sudo systemctl enable sshd
