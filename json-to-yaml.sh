#!/bin/bash

# Requires `npm install -g js-yaml`
#
# Usage: File
# sh ./json-to-yaml.sh "./sfz1 basic tests/01 - Amp LFO/01 - amp lfo freq.sfz.json"
#
# Usage: Folder
# sh ./json-to-yaml.sh .

if [[ $1 == *.sfz.json ]]
then
  # Convert file.
  js-yaml "$1" > "${1%.sfz.json}.sfz.yaml"
else
  # Convert folder.
  find "$1" -type f -name "*.sfz.json" | while read file
    do js-yaml "$file" > "${file%.sfz.json}.sfz.yaml"
  done
fi
