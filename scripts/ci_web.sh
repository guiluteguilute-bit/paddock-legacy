#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ -z "${GODOT_BIN:-}" ]]; then
  if command -v godot >/dev/null; then GODOT_BIN="$(command -v godot)"
  elif command -v godot4 >/dev/null; then GODOT_BIN="$(command -v godot4)"
  else GODOT_BIN=""; fi
fi
[[ -n "$GODOT_BIN" ]] || { echo 'ERROR: Godot 4.3 executable not found (set GODOT_BIN)'; exit 1; }
version="$($GODOT_BIN --version)"
[[ "$version" == 4.3* ]] || { echo "ERROR: Godot 4.3 required, found $version"; exit 1; }
mkdir -p build/logs
run_godot() { local log="$1"; shift; timeout 10m "$GODOT_BIN" --headless --path . "$@" 2>&1 | tee "build/logs/$log"; python3 tests/validate_godot_log.py "build/logs/$log"; }
echo '=== PROJECT VALIDATION ==='
python3 tests/validate_project.py
echo '=== UI VALIDATION ==='
python3 tests/validate_ui_catalog.py
python3 tests/validate_manager_selection_v2.py
echo '=== ASSET VALIDATION ==='
python3 tests/validate_manager_assets.py
echo '=== GDSCRIPT SAFETY ==='
python3 tests/validate_gdscript_safety.py
echo '=== RESOURCE VALIDATION ==='
python3 tests/validate_godot_resources.py
echo '=== WEB SHELL VALIDATION ==='
python3 tests/validate_web_shell.py
echo '=== GODOT IMPORT ==='
run_godot godot-import.log --editor --import --quit
echo '=== CORE TESTS ==='
run_godot godot-core.log tests/godot/test_core.tscn
echo '=== SCRIPT LOADING ==='
run_godot godot-scripts.log tests/godot/test_script_loading.tscn
echo '=== UI SMOKE ==='
run_godot godot-ui.log tests/godot/test_ui_smoke.tscn
echo '=== MANAGER V2 TEST ==='
run_godot godot-manager-v2.log tests/godot/test_manager_selection_v2.tscn
echo '=== MANAGER HOST TEST ==='
run_godot godot-manager-host.log tests/godot/test_manager_host.tscn
echo '=== MAIN SCENE ==='
run_godot godot-main.log --quit-after 2
echo '=== WEB EXPORT ==='
commit="${GITHUB_SHA:-$(git rev-parse HEAD)}"; short="${commit:0:7}"; run="${GITHUB_RUN_NUMBER:-0}"; branch="${GITHUB_REF_NAME:-$(git branch --show-current)}"; built="$(date -u +%Y-%m-%dT%H:%M:%SZ)"; environment="${BUILD_ENVIRONMENT:-production}"
cp web/build_info.gd /tmp/paddock-build-info.gd
cp web/shell.html /tmp/paddock-shell.html
restore_sources() { cp /tmp/paddock-build-info.gd web/build_info.gd; cp /tmp/paddock-shell.html web/shell.html; }
trap restore_sources EXIT
python3 - "$commit" "$short" "$run" "$branch" "$built" "$environment" <<'PY'
from pathlib import Path
import sys
p=Path('web/build_info.gd'); s=p.read_text()
keys=('BUILD_COMMIT','BUILD_SHORT_COMMIT','BUILD_NUMBER','BUILD_BRANCH','BUILD_DATE','BUILD_ENVIRONMENT')
for key,value in zip(keys,sys.argv[1:]):
 import re
 s=re.sub(rf'const {key}: String = "[^"]*"', f'const {key}: String = "{value}"', s)
p.write_text(s)
p=Path('web/shell.html'); s=p.read_text().replace('__BUILD_COMMIT__',sys.argv[1]).replace('__BUILD_SHORT_COMMIT__',sys.argv[2]); p.write_text(s)
PY
rm -rf build/web
release_path="releases/${short}/"
release_dir="build/web/${release_path}"
mkdir -p "$release_dir"
run_godot godot-export.log --verbose --export-release 'Web Preview' "${release_dir}/index.html"
python3 - "$commit" "$short" "$run" "$built" "$branch" "$environment" <<'PY'
import json,sys
from pathlib import Path
keys=('commit','short_commit','run_number','built_at','branch','environment')
data=dict(zip(keys,sys.argv[1:])); data['run_number']=int(data['run_number'])
data['release_path']=f"releases/{data['short_commit']}/"
Path('build/web/build-version.json').write_text(json.dumps(data,indent=2)+'\n')
target=f"{data['release_path']}index.html?v={data['short_commit']}"
launcher=f'''<!doctype html>
<html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="cache-control" content="no-cache, no-store, must-revalidate">
<title>Paddock Legacy</title></head><body>
<p>Chargement de Paddock Legacy…</p>
<script>window.location.replace({json.dumps(target)});</script>
</body></html>
'''
Path('build/web/index.html').write_text(launcher)
PY
touch build/web/.nojekyll
echo '=== VERSIONED WEB BUILD ==='
python3 tests/validate_versioned_web_build.py build/web
echo '=== WEB BUILD VALIDATION ==='
python3 tests/validate_web_build.py build/web
