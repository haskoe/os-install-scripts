#!/bin/bash -e

DISK_DEV=sda
DISK_TEXT=1tb
DISK_NAME=$(udevadm info --query=all --name=/dev/sda | grep ID_SERIAL= | sed -e 's/^.*=//g')
DISK_SIZE=$(numfmt --to iec --format "%8.4f" $(sudo blockdev --getsz /dev/${DISK_DEV}))
IMG_NAME=${DISK_NAME}-${DISK_TEXT} #-${DISK_SIZE}                                                                                                                                            
TGT_DIR=/media/heas/SSD
ZIP_DIR=/media/heas/Expansion/disk_backup
sudo ddrescue -d /dev/${DISK_DEV} ${TGT_DIR}/${IMG_NAME}.img ${TGT_DIR}/${IMG_NAME}.logfile
#sudo dd if=/dev/${DISK_DEV} of=${IMG_NAME}.img bs=1M conv=fsync                                                                                                                             
~/zstd -9 ${TGT_DIR}/${IMG_NAME}.img -o ${ZIP_DIR}/${IMG_NAME}.img.zst
