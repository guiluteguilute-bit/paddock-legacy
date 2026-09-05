#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tests/validate_project.py
python3 tests/validate_ui_catalog.py
python3 tests/validate_manager_assets.py
python3 tests/validate_gdscript_safety.py
python3 tests/validate_godot_resources.py
if [[ -z "${GODOT_BIN:-}" ]]; then
  if command -v godot >/dev/null; then GODOT_BIN="$(command -v godot)"
  elif command -v godot4 >/dev/null; then GODOT_BIN="$(command -v godot4)"
  else GODOT_BIN=""; fi
fi
[[ -n "$GODOT_BIN" ]] || { echo 'ERROR: Godot 4.3 executable not found'; exit 1; }
mkdir -p build/logs
timeout 5m "$GODOT_BIN" --headless --path . --editor --import --quit 2>&1 | tee build/logs/godot-import.log
python3 tests/validate_godot_log.py build/logs/godot-import.log
timeout 2m "$GODOT_BIN" --headless --path . tests/godot/test_script_loading.tscn 2>&1 | tee build/logs/godot-smoke.log
python3 tests/validate_godot_log.py build/logs/godot-smoke.log
