#!/bin/bash

# this script do bind to root-pertiotion of the techtool-image to a catalog:
#
# $>sudo .*/do_sdcard_root3.sh techtool_2025-01-07-12-42.img img-root
#
#     where techtool_2025-01-07-12-42.img is a name of the image file 
#			img-root is the mount-point name.
#

# Check if the image file argument is provided
if [ -z "$1" ]; then
    echo "Error: Please provide the image file name as the first argument."
    exit 1
fi

# Check if the mount point argument is provided
if [ -z "$2" ]; then
    echo "Error: Please provide the mount point directory as the second argument."
    exit 1
fi

# Check if the image file exists
if [ ! -f "$1" ]; then
    echo "Error: The file '$1' does not exist."
    exit 1
fi

# Mount point directory
mount_point="$2"

# Create the mount point directory if it doesn't exist
if [ ! -d "$mount_point" ]; then
    echo "Directory '$mount_point' does not exist. Creating..."
    mkdir -p "$mount_point"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create directory '$mount_point'."
        exit 1
    fi
fi

# Get partition information from the image file
fdisk_output=$(fdisk -l "$1")

# Find the line with the image file name and "Linux" at the end
partition_info=$(echo "$fdisk_output" | grep -P "^$1.*Linux$")

# Check if the partition information was found
if [ -z "$partition_info" ]; then
    echo "Error: Could not find a Linux partition in the image."
    exit 1
fi

# Extract the starting sector of the partition
start_sector=$(echo "$partition_info" | awk '{print $2}')

# Verify that the starting sector is a number
if ! [[ "$start_sector" =~ ^[0-9]+$ ]]; then
    echo "Error: Failed to extract the starting sector of the partition."
    exit 1
fi

# Calculate the offset in bytes
offset=$((start_sector * 512))

# Create the mount command
mount_command="sudo mount -o rw,loop,offset=$offset ./$1 $mount_point"

# Display the mount command
echo "Mount command:"
echo "$mount_command"
echo "umount $mount_point"

# Execute the mount command
eval "$mount_command"

# Check if the mount was successful
if [ $? -eq 0 ]; then
    echo "Image successfully mounted at '$mount_point'."
else
    echo "Error: Failed to mount the image."
    exit 1
fi

