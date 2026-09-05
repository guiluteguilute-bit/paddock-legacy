#!/usr/bin/env python3
"""Small, project-specific guard against Godot 4.3 Variant inference regressions."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
CRITICAL = (ROOT / "game/core", ROOT / "game/ui/components", ROOT / "game/ui/main.gd")
RULES = (
    (re.compile(r"\bvar\s+\w+\s*:=\s*[\w.]+\.get\s*\("), "inference from Dictionary.get()"),
    (re.compile(r"\bvar\s+\w+\s*:=\s*JSON\.parse"), "inference from JSON.parse()"),
    (re.compile(r"\bvar\s+\w+\s*:=\s*(?:load|ResourceLoader\.load)\s*\("), "inference from dynamic resource load"),
)


def critical(path: Path) -> bool:
    return any(path == base or (base.is_dir() and base in path.parents) for base in CRITICAL)


def main() -> None:
    errors: list[str] = []
    for path in ROOT.rglob("*.gd"):
        if any(part in {".git", ".godot", "build"} for part in path.parts):
            continue
        lines = path.read_text(encoding="utf-8").splitlines()
        variant_loop_indent: int | None = None
        for number, line in enumerate(lines, 1):
            stripped = line.lstrip("\t ")
            indent = len(line) - len(stripped)
            if re.match(r"for\s+\w+\s+in\s+\[[^]]*\d+\.\d+[^]]*\]\s*:", stripped):
                variant_loop_indent = indent
            elif stripped and not stripped.startswith("#") and variant_loop_indent is not None and indent <= variant_loop_indent:
                variant_loop_indent = None
            if variant_loop_indent is not None and indent > variant_loop_indent and re.search(r"\bvar\s+\w+\s*:=", stripped):
                errors.append(f"{path.relative_to(ROOT)}:{number}: inference inside literal/Variant loop")
            if critical(path):
                for regex, reason in RULES:
                    if regex.search(line):
                        errors.append(f"{path.relative_to(ROOT)}:{number}: {reason}")
    if errors:
        raise SystemExit("GDSCRIPT SAFETY ERROR:\n" + "\n".join(errors))
    print("GDScript safety validation OK (Godot 4.3 Variant guards)")


if __name__ == "__main__":
    main()
