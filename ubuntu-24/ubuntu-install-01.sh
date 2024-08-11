#!/bin/bash

sudo apt update && sudo apt dist-upgrade && sudo apt install git i3 i3status && mkdir -p ~/dev/haskoe && cd ~/dev/haskoe && git clone https://github.com/haskoe/os-install-scripts.git

sudo reboot
