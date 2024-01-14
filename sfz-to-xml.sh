#!/bin/bash

# Usage: File
# ./sfz-to-xml.sh "./sfz1 basic tests/01 - Amp LFO/01 - amp lfo freq.sfz"
#
# Usage: Folder
# ./sfz-to-xml.sh .

if [ ! -f sfizz_preprocessor ]
then
  curl -LO https://github.com/studiorack/sfizz/releases/download/v1.1.1/sfizz-preprocessor-mac.zip
  unzip sfizz-preprocessor-mac.zip
  rm sfizz-preprocessor-mac.zip
fi

IFS=$'\n'

if [[ $1 == *.sfz ]]
then
  # Convert file.
  ./sfizz_preprocessor "$1" --mode=xml > "${1%.*}.xml"
else
  # Convert folder.
  find "$1" -type f -name "*.sfz" | while read file
    do ./sfizz_preprocessor "$file" --mode=xml > "${file%.*}.xml"
  done
fi
