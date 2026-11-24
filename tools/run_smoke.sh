#!/usr/bin/env bash
set -euo pipefail
log="$(mktemp)"
trap 'rm -f "$log"' EXIT
timeout 90s godot --headless --path . --script "$1" 2>&1 | tee "$log"
if grep -E 'SCRIPT ERROR:|Failed to load script|Parse Error:|Compile Error:' "$log"; then
  echo "Godot script error in $1"
  exit 1
fi
