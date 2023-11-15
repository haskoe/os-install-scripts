#!/bin/bash

# step 1
sudo apt update && sudo apt dist-upgrade && sudo apt install git
sudo reboot

# step 2
mkdir -p ~/dev/haskoe && cd ~/dev/haskoe && git clone https://github.com/haskoe/os-install-scripts.git && cd os-install-scripts

# edit ubuntu-2304-2.sh
bash ubuntu-2310-2.sh


