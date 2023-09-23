#!/bin/bash

# Requires `npm install -g xml-js`
#
# Usage: File
# ./sfz-to-json.sh "./sfz1 basic tests/01 - Amp LFO/01 - amp lfo freq.xml"
#
# Usage: Folder
# ./sfz-to-json.sh .

if [[ $1 == *.xml ]]
then
  # Convert file.
  xml-js "$1" --spaces 2 --out "${1%.*}.json"
else
  # Convert folder.
  find "$1" -type f -name "*.xml" | while read file
    do xml-js "$file" --spaces 2 --out "${file%.*}.json"
  done
fi
