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
  temp_json="$(mktemp)"

  # Unwrap the top-level `sfz` array for cleaner YAML output.
  if ! node -e '
    const fs = require("node:fs");
    const inputPath = process.argv[1];
    const outputPath = process.argv[2];
    const data = JSON.parse(fs.readFileSync(inputPath, "utf8"));
    const unwrapped = (
      data &&
      typeof data === "object" &&
      !Array.isArray(data) &&
      Object.prototype.hasOwnProperty.call(data, "sfz")
    ) ? data.sfz : data;
    fs.writeFileSync(outputPath, JSON.stringify(unwrapped));
  ' "$input" "$temp_json"
  then
    rm -f "$temp_json"
    return 1
  fi

  if ! js-yaml "$temp_json" > "$output"
  then
    rm -f "$temp_json"
    return 1
  fi

  rm -f "$temp_json"
}

if [[ $1 == *.sfz.json ]]
then
  # Convert file.
  convert_file "$1"
else
  # Convert folder.
  find "$1" -type f -name "*.sfz.json" | while read file
    do convert_file "$file"
  done
fi
