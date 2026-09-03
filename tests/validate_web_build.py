#!/usr/bin/env python3
"""Validate that a directory is a deployable Godot Web build."""
from pathlib import Path
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
    assert "$GODOT_" not in html, "unexpanded Godot shell token in index.html"
    assert "alert(" not in html, "blocking JavaScript alert in index.html"
    assert "<canvas id=\"canvas\"" in html, "Godot canvas is absent"
    assert "Godot" in html, "index.html does not look like a Godot Web export"
    assert (build / ".nojekyll").is_file(), ".nojekyll is absent"
    assert "README" not in html, "README content unexpectedly became the entry point"
    print("Godot Web artifact integrity checks passed")


if __name__ == "__main__":
    main()
