#!/bin/bash

# this script do image of the sdcard of techtool on the host-computer
#
# $>sudo ./make_img.sh
#
# ... and wait apx. 40min.
#
# !!! WARNING !!! for run, check of it possible connect from the host-computer to the techtool over ssh:
#   $>ssh technik@techtool.local
# if zhis command ask the password. it seem good and can start the script.
#


#ssh technik@techtool.local "sudo dd if=/dev/mmcblk0 bs=4M" | dd of=/path/to/backup.img


CURRENT_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

BACKUP_FILE="techtool_${CURRENT_DATE}.img"

echo "Create image from techtool..."
#ssh technik@techtool.local "sudo dd if=/dev/mmcblk0 bs=250M" | dd of="./${BACKUP_FILE}"
#ssh technik@techtool.local "sudo dd if=/dev/mmcblk0 bs=4M| pv" | dd of="./${BACKUP_FILE}"
ssh technik@techtool.local "sudo dd if=/dev/mmcblk0 bs=200M| gzip" | dd of="./${BACKUP_FILE}.gz"

if [ $? -eq 0 ]; then
    echo "Image was created: ${BACKUP_FILE}"
else
    echo "Something going wrong!"
fi
