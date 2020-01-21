#!/usr/bin/env bash
file=".dart_tool/package_config.json"

if [[ ! -f "$file" ]]; then
  flutter pub get
fi

flutter packages pub run build_runner build --delete-conflicting-outputs
