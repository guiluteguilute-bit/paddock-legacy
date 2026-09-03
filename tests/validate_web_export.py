#!/usr/bin/env python3
"""Fail early with actionable diagnostics for a Godot 4.3 Web export."""
from __future__ import annotations

import argparse
import configparser
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"WEB EXPORT PREFLIGHT ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def non_empty(path: Path, label: str) -> None:
    if not path.is_file():
        fail(f"{label} is missing: {path}")
    if path.stat().st_size == 0:
        fail(f"{label} is empty: {path}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--templates", type=Path, required=True)
    args = parser.parse_args()

    preset_path = ROOT / "export_presets.cfg"
    project_path = ROOT / "project.godot"
    non_empty(preset_path, "export preset")
    non_empty(project_path, "Godot project")

    config = configparser.RawConfigParser(strict=True)
    config.optionxform = str
    try:
        config.read(preset_path, encoding="utf-8")
    except configparser.Error as error:
        fail(f"cannot parse export_presets.cfg: {error}")
    required = {
        ("preset.0", "name"): '"Web Preview"',
        ("preset.0", "platform"): '"Web"',
        ("preset.0", "export_path"): '"build/web/index.html"',
        ("preset.0.options", "variant/extensions_support"): "false",
        ("preset.0.options", "variant/thread_support"): "false",
        ("preset.0.options", "vram_texture_compression/for_desktop"): "true",
        ("preset.0.options", "vram_texture_compression/for_mobile"): "true",
        ("preset.0.options", "html/custom_html_shell"): '"res://web/shell.html"',
    }
    for (section, key), expected in required.items():
        actual = config.get(section, key, fallback=None)
        if actual != expected:
            fail(f"{section}.{key} must be {expected}, got {actual!r}")

    for template in ("web_release.zip", "web_debug.zip"):
        non_empty(args.templates / template, f"Godot 4.3 Web template {template}")

    project = project_path.read_text(encoding="utf-8")
    scene_match = re.search(r'^run/main_scene="res://([^"]+)"', project, re.MULTILINE)
    if not scene_match:
        fail("project.godot has no run/main_scene setting")
    non_empty(ROOT / scene_match.group(1), "main scene")
    if 'renderer/rendering_method="gl_compatibility"' not in project:
        fail("project.godot must use the gl_compatibility renderer")
    if 'textures/vram_compression/import_etc2_astc=true' not in project:
        fail(
            "mobile Web texture compression requires "
            "Rendering > Textures > VRAM Compression > Import ETC2 ASTC"
        )

    scripts = sorted(ROOT.rglob("*.gd"))
    if not scripts:
        fail("no GDScript files were found")
    checked = 0
    for source in scripts:
        if any(part in {".git", ".godot", "build"} for part in source.parts):
            continue
        non_empty(source, "GDScript")
        text = source.read_text(encoding="utf-8")
        for resource in re.findall(r'res://[^"\'\s)]+', text):
            target = ROOT / resource.removeprefix("res://")
            if not target.exists():
                fail(f"missing resource {resource} referenced by {source.relative_to(ROOT)}")
        checked += 1
    print(
        "Web export preflight passed: preset, 2 templates, mobile texture "
        f"compression, project, main scene and {checked} scripts"
    )


if __name__ == "__main__":
    main()
