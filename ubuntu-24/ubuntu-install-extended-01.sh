#!/bin/bash

sudo apt -y install blueman bluez pulseaudio-module-bluetooth picom smplayer i3 i3status 
sudo apt -y install autorandr brightnessctl freerdp2-x11 thunderbird usb-creator-gtk
sudo apt -y install meld flameshot lm-sensors evince spice-client-gtk gparted kpartx xorg-dev
sudo apt -y install graphicsmagick-libmagick-dev-compat libgraphicsmagick++1-dev libmagick++-6-headers libmagick++-dev
sudo apt install -y 

# pdftools deps.
sudo apt install -y libpoppler-cpp-dev libpoppler-glib-dev

# tidyverse
sudo apt install libharfbuzz-dev libfribidi-dev

wget https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VER}/quarto-${QUARTO_VER}-linux-amd64.deb
sudo gdebi quarto-${QUARTO_VER}-linux-amd64.deb

# zabbly
sudo mkdir -p /etc/apt/keyrings/
sudo wget -q https://pkgs.zabbly.com/key.asc -O /etc/apt/keyrings/zabbly.asc
sudo sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-kernel-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/kernel/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'

sudo apt -y update
sudo apt install -y linux-zabbly
