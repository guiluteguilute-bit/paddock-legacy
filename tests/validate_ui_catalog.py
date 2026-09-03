#!/usr/bin/env python3
"""Static regression checks for Paddock Legacy's in-game UI Lab."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "game" / "data" / "screen_catalog.json"
MAIN = ROOT / "game" / "ui" / "main.gd"
LAB = ROOT / "game" / "core" / "screen_lab.gd"
PROJECT = ROOT / "project.godot"


def fail(message: str) -> None:
    raise SystemExit(f"UI CATALOG ERROR: {message}")


def main() -> None:
    if not CATALOG.exists():
        fail("screen_catalog.json is missing")

    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    screens = data.get("screens")
    if not isinstance(screens, list) or not screens:
        fail("catalog must contain a non-empty screens array")

    ids: list[str] = []
    main_source = MAIN.read_text(encoding="utf-8")
    lab_source = LAB.read_text(encoding="utf-8")
    source_by_name = {"main": main_source, "lab": lab_source}
    allowed_renderers = {"creation", "main", "race", "lab"}

    for index, screen in enumerate(screens, start=1):
        if not isinstance(screen, dict):
            fail(f"screen #{index} is not an object")

        screen_id = str(screen.get("id", ""))
        expected_id = f"{index:02d}"
        if screen_id != expected_id:
            fail(f"screen at position {index} must be {expected_id}, got {screen_id!r}")
        ids.append(screen_id)

        for key in ("group", "name", "renderer", "source", "method"):
            if not str(screen.get(key, "")).strip():
                fail(f"SCREEN-{screen_id} is missing {key}")

        renderer = str(screen["renderer"])
        if renderer not in allowed_renderers:
            fail(f"SCREEN-{screen_id} uses unsupported renderer {renderer!r}")

        source_name = str(screen["source"])
        if source_name not in source_by_name:
            fail(f"SCREEN-{screen_id} uses unsupported source {source_name!r}")

        method = str(screen["method"])
        if f"func {method}(" not in source_by_name[source_name]:
            fail(f"SCREEN-{screen_id} points to missing method {method} in {source_name}.gd")

        if renderer == "creation":
            step = screen.get("step")
            if step not in (0, 1, 2):
                fail(f"SCREEN-{screen_id} creation step must be 0, 1, or 2")
            if method != "show_creation":
                fail(f"SCREEN-{screen_id} creation renderer must call show_creation")

        if renderer == "race" and method != "open_race":
            fail(f"SCREEN-{screen_id} race renderer must call open_race")

    if len(ids) != len(set(ids)):
        fail("screen IDs must be unique")

    project = PROJECT.read_text(encoding="utf-8")
    if 'ScreenLab="*res://game/core/screen_lab.gd"' not in project:
        fail("ScreenLab autoload is not enabled in project.godot")

    required_lab_guards = [
        "_original_data = GameState.data.duplicate(true)",
        "GameState.data = _original_data.duplicate(true)",
        "_freeze_game_actions",
    ]
    for guard in required_lab_guards:
        if guard not in lab_source:
            fail(f"UI Lab safety guard is missing: {guard}")

    print(f"UI catalog validation OK: {len(screens)} screens, sequential IDs, render targets present, save isolation guards present")


if __name__ == "__main__":
    main()
