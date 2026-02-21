#!/bin/bash

# Requires `npm install -g js-yaml`
#
# Usage: File
# sh ./json-to-yaml.sh "./sfz1 basic tests/01 - Amp LFO/01 - amp lfo freq.sfz.json"
#
# Usage: Folder
# sh ./json-to-yaml.sh .

convert_file() {
  input="$1"
  output="${input%.sfz.json}.sfz.yaml"
  if ! js-yaml "$input" > "$output"
  then
    return 1
  fi
}

if [[ $1 == *.sfz.json ]]
then
  # Convert file.
  convert_file "$1"
else
  # Convert folder.
  find "$1" -type f -name "*.sfz.json" | while IFS= read -r file
    do convert_file "$file"
  done
fi
