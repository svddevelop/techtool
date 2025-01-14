#!/bin/bash


if [ $# -eq 0 ]; then
  echo "call with gz file"
  exit 1
fi

if [ $(id -u) -ne 0 ]; then
  echo "run it as root or sudo."
  exit 1
fi

input_file="$1"


if [[ "$input_file" =~ \.gz$ ]]; then
  
  echo "gunzip"
  gunzip -c "$input_file" > "${input_file%.gz}"
  mv "$input_file" "${input_file}_old"


  ./pishrink.sh "${input_file%.gz}"
  mv "${input_file%.gz}" "./techtool.img"
  echo "split ..."
  ./splitzip.sh "./techtool.img"
  echo ""
  echo "... done"
  echo ""

  #echo "gzip"
  #gzip -9 "${input_file%.gz}"
  echo "File $input_file success."
else
  echo "Check .gz."
fi

if [[ "$input_file" =~ \.img$ ]]; then
  
  ./pishrink.sh "${input_file%}"

  #echo "gzip"
  #gzip -9 "${input_file%}"
  echo "File $input_file success."
else
  echo "Check .img."
fi