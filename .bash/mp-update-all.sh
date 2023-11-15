#!/bin/bash

## now loop through the above array
for i in `multipass list | awk '{print $1;}' | grep -v Name`
do
    multipass exec $i  -- bash -c "sudo apt update && sudo apt -y dist-upgrade"
done