#!/bin/bash

sudo snap install chromium
#sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /snap/bin/chromium 210
#sudo update-alternatives --config x-www-browser

sudo snap install code --classic

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt -y update && sudo apt -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -a -G docker $USER # logout/login

# .bashrc
echo ". ${HOME}/dev/haskoe/os-install-scripts/.bash/.bashrc" >>~/.bashrc
source ~/.bashrc 

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
cargo install cargo-edit cargo-expand cargo-update bat ripgrep du-dust bottom exa fd-find dirstat-rs 
#cargo install yazi-fm yazi-cli

# tex
sudo apt install -y texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra texlive-xetex 
sudo apt install -y texlive-latex-recommended texlive-science texlive-font-utils texlive-bibtex-extra 
sudo apt install -y texlive-humanities texlive-publishers texlive-lang-french texlive-latex-extra biber

asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
asdf plugin add python
asdf plugin-add haskell https://github.com/vic/asdf-haskell.git
asdf plugin-add r https://github.com/asdf-community/asdf-r.git

asdf list all erlang
asdf list all elixir
asdf list all golang
asdf list all python
asdf list all haskell
asdf list all r
