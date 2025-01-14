#!/bin/bash

#
# This script do bind of the image of boot-partition of the techtool to a catalog.
#
# $>sudo ./do_sdcard_boot.sh techtool_2025-01-07-12-42.img ./ma_img_boot
#
 
sudo mount -o rw,loop,offset=4194304 $1 ./$2

