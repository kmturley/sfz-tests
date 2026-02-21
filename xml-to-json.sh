#!/bin/bash

# Requires `npm install -g xml-js`
#
# Usage: File
# sh ./xml-to-json.sh "./sfz1 basic tests/01 - Amp LFO/01 - amp lfo freq.xml"
#
# Usage: Folder
# sh ./xml-to-json.sh .

if [[ $1 == *.xml ]]
then
  # Convert file.
  node ./xml-to-json.mjs "$1" "${1%.*}.json"
else
  # Convert folder.
  find "$1" -type f -name "*.xml" | while read file
    do node ./xml-to-json.mjs "$file" "${file%.*}.json"
  done
fi
