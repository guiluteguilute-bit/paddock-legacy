#!/usr/bin/env python3
"""Validate that a directory is a deployable Godot Web build."""
from pathlib import Path
import json
import sys


def require_non_empty(build: Path, pattern: str) -> list[Path]:
    matches = [path for path in build.glob(pattern) if path.is_file() and path.stat().st_size]
    assert matches, f"missing non-empty {pattern} in {build}"
    return matches


def main() -> None:
    build = Path(sys.argv[1] if len(sys.argv) > 1 else "build/web")
    index = build / "index.html"
    assert index.is_file() and index.stat().st_size, "missing non-empty index.html"
    html = index.read_text(encoding="utf-8")
    require_non_empty(build, "*.js")
    require_non_empty(build, "*.wasm")
    require_non_empty(build, "*.pck")
    version_path = build / "build-version.json"
    assert version_path.is_file() and version_path.stat().st_size, "missing non-empty build-version.json"
    version = json.loads(version_path.read_text(encoding="utf-8"))
    for field in ("commit", "short_commit", "run_number", "built_at", "branch", "environment"):
        assert field in version and version[field] not in (None, ""), f"invalid build version field: {field}"
    assert "$GODOT_" not in html, "unexpanded Godot shell token in index.html"
    assert "alert(" not in html, "blocking JavaScript alert in index.html"
    assert "<canvas id=\"canvas\"" in html, "Godot canvas is absent"
    assert "new Engine(" in html, "Godot Web engine bootstrap is absent"
    assert "engine.startGame(" in html, "Godot Web game startup is absent"
    assert version["commit"] in html, "exported index does not identify its deployed commit"
    assert (build / ".nojekyll").is_file(), ".nojekyll is absent"
    assert "README" not in html, "README content unexpectedly became the entry point"
    print("Godot Web artifact integrity checks passed")


if __name__ == "__main__":
    main()
