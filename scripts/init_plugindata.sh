#!/bin/bash

if [ !"$1" ]; then
  exit
fi

find "$1" -maxdepth 1 -mindepth 1 -type d -print0 |
  while IFS= read -rd '' dir; do
    # Check recursively if path contains any symbolic links
    if [[ -z $(find "$dir"/ -type l -print -quit) ]]; then
      continue
    fi

    plugin_dir="$(basename "$dir")"
    plugin_data_dir="$2"/"$plugin_dir"
    mkdir -p "$plugin_data_dir"

    find "$1"/"$plugin_dir" -type l -print0 |
      while IFS= read -rd '' slink; do
        filename="$(basename "$slink")"
        plugin_data_name=$(basename "$2")
        if [[ $filename != *.* ]]; then
          mkdir -p "${slink/plugins/$plugin_data_name}"
        else
          slink_dir=$(dirname "$slink")
          mkdir -p "${slink_dir/plugins/$plugin_data_name}"
        fi
      done
  done
