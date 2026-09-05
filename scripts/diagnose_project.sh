#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo '=== GODOT ==='
if command -v godot >/dev/null; then godot --version
elif command -v godot4 >/dev/null; then godot4 --version
else echo 'not installed'; fi
echo '=== GIT ==='; git rev-parse HEAD; git branch --show-current; git status --short
echo '=== RESOURCES ==='; python3 tests/validate_godot_resources.py
echo '=== CRITICAL SCRIPTS ==='; sed -n '/CRITICAL_SCRIPTS/,/^]/p' tests/godot/test_script_loading.gd
echo '=== EXPORT PRESET ==='; sed -n '1,12p' export_presets.cfg
echo '=== WEB DIRECTORIES ==='; for directory in web build/web; do [[ ! -d "$directory" ]] || find "$directory" -maxdepth 1 -type f -printf '%p %s bytes\n'; done | sort
