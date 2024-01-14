#!/bin/bash

# Requires `npm install -g js-yaml`
#
# Usage: File
# ./json-to-yaml.sh "./sfz1 basic tests/01 - Amp LFO/01 - amp lfo freq.json"
#
# Usage: Folder
# ./json-to-yaml.sh .

if [[ $1 == *.json ]]
then
  # Convert file.
  js-yaml "$1" > "${1%.*}.yaml"
else
  # Convert folder.
  find "$1" -type f -name "*.json" | while read file
    do js-yaml "$file" > "${file%.*}.yaml"
  done
fi
