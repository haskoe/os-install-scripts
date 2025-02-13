#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
[[ ! -f "${SCRIPT_DIR}/env.sh" ]] && echo missing env file && exit 1

. ${SCRIPT_DIR}/env.sh

sudo apt -y install blueman bluez pulseaudio-module-bluetooth picom smplayer i3 i3status 
sudo apt -y install autorandr brightnessctl freerdp2-x11 thunderbird usb-creator-gtk
sudo apt -y install meld flameshot lm-sensors evince spice-client-gtk gparted kpartx xorg-dev
sudo apt -y install graphicsmagick-libmagick-dev-compat libgraphicsmagick++1-dev libmagick++-6-headers libmagick++-dev
sudo apt install -y 

# pdftools deps.
sudo apt install -y libpoppler-cpp-dev libpoppler-glib-dev

# tidyverse
sudo apt install -y libharfbuzz-dev libfribidi-dev

wget https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VER}/quarto-${QUARTO_VER}-linux-amd64.deb
sudo gdebi -y quarto-${QUARTO_VER}-linux-amd64.deb
