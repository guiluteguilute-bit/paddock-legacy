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
python3 tests/validate_ui_catalog.py
python3 tests/validate_manager_assets.py
python3 tests/validate_gdscript_safety.py
python3 tests/validate_godot_resources.py
echo '=== GODOT IMPORT ==='
run_godot godot-import.log --editor --import --quit
echo '=== GODOT TESTS ==='
run_godot godot-core.log tests/godot/test_core.tscn
run_godot godot-scripts.log tests/godot/test_script_loading.tscn
run_godot godot-ui.log tests/godot/test_ui_smoke.tscn
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
rm -rf build/web; mkdir -p build/web
run_godot godot-export.log --verbose --export-release 'Web Preview' build/web/index.html
python3 - "$commit" "$short" "$run" "$built" "$branch" "$environment" <<'PY'
import json,sys
from pathlib import Path
keys=('commit','short_commit','run_number','built_at','branch','environment')
data=dict(zip(keys,sys.argv[1:])); data['run_number']=int(data['run_number'])
Path('build/web/build-version.json').write_text(json.dumps(data,indent=2)+'\n')
PY
touch build/web/.nojekyll
echo '=== WEB VALIDATION ==='
python3 tests/validate_web_build.py build/web
