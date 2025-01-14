#!/bin/bash

if [ -z "$1" ]; then
    echo "Err: file name as parameter."
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Err: file '$1' does not exist."
    exit 1
fi

filename=$(basename "$1")

archive_name="${filename%.*}"

zip -s 48m -r "${archive_name}.zip" "$1"

if [ $? -eq 0 ]; then
    echo "Ok: ${archive_name}.zip"
else
    echo "Err!"
    exit 1
fi