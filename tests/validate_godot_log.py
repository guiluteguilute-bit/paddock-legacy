#!/usr/bin/env python3
"""Fail CI when Godot logs script/compiler errors while still returning exit code 0."""

from pathlib import Path
import re
import sys

FATAL_PATTERNS = (
    r"SCRIPT ERROR:",
    r"Parse Error:",
    r"ERROR: Failed to load script",
    r"Compile Error:",
)


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: validate_godot_log.py <log-file>")
    path = Path(sys.argv[1])
    text = path.read_text(encoding="utf-8", errors="replace")
    matches = [pattern for pattern in FATAL_PATTERNS if re.search(pattern, text, re.IGNORECASE)]
    if matches:
        print(text)
        raise SystemExit("Godot reported a script/compiler error: " + ", ".join(matches))
    print(f"Godot log validation OK: {path.name}")


if __name__ == "__main__":
    main()
