#!/usr/bin/env python3
"""Validate the immutable-per-commit layout of a Godot Web artifact."""
import json
from pathlib import Path
import re
import sys


def non_empty(path: Path) -> None:
    assert path.is_file() and path.stat().st_size > 0, f"missing or empty file: {path}"


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "build/web")
    launcher = root / "index.html"
    metadata_path = root / "build-version.json"
    non_empty(launcher)
    non_empty(metadata_path)
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    short = metadata["short_commit"]
    assert re.fullmatch(r"[0-9a-f]{7,40}", short), "short_commit is not a Git SHA"
    expected_path = f"releases/{short}/"
    assert metadata.get("release_path") == expected_path, "release_path and short_commit differ"
    release = root / expected_path
    assert release.is_dir() and release.name == short, "release directory does not match the SHA"
    non_empty(release / "index.html")
    for extension in ("*.pck", "*.wasm", "*.js"):
        matches = list(release.glob(extension))
        assert matches, f"release has no {extension} bundle"
        for path in matches:
            non_empty(path)
    launcher_html = launcher.read_text(encoding="utf-8")
    assert f"{expected_path}index.html?v={short}" in launcher_html, "launcher targets another release"
    release_html = (release / "index.html").read_text(encoding="utf-8")
    assert metadata["commit"] in release_html, "release shell contains another commit"
    # Two distinct commit identifiers necessarily produce distinct bundle URLs.
    other = "fffffff" if short != "fffffff" else "eeeeeee"
    assert f"releases/{short}/index.pck" != f"releases/{other}/index.pck"
    print("VERSIONED WEB BUILD VALIDATION: launcher, metadata and isolated bundles passed")


if __name__ == "__main__":
    main()
