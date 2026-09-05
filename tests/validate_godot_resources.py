#!/usr/bin/env python3
"""Validate static res:// references without treating guarded optional UI art as required."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SUFFIXES = {".gd", ".tscn", ".tres", ".godot", ".cfg"}
REF = re.compile(r"res://[^\"'\s,)]+")


def main() -> None:
    missing: list[str] = []
    for source in ROOT.rglob("*"):
        if not source.is_file() or source.suffix not in SUFFIXES or any(p in {".git", ".godot", "build"} for p in source.parts):
            continue
        text = source.read_text(encoding="utf-8", errors="replace")
        for line_number, line in enumerate(text.splitlines(), 1):
            for value in REF.findall(line):
                value = value.rstrip(".]}")
                target = ROOT / value.removeprefix("res://")
                if target.exists():
                    continue
                # Only runtime guarded optional references may be absent.
                if "optional_ui_path" in line or ("ResourceLoader.exists" in line and "preload(" not in line):
                    continue
                missing.append(f"{source.relative_to(ROOT)}:{line_number}: {value}")
    if missing:
        raise SystemExit("GODOT RESOURCE ERROR:\n" + "\n".join(missing))
    print("Godot resource validation OK")


if __name__ == "__main__":
    main()
