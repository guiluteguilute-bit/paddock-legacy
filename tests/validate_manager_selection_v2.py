#!/usr/bin/env python3
"""Structural guard: manager selection must remain a dedicated Godot scene."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "game/ui/screens/manager_selection.tscn"
SCRIPT = ROOT / "game/ui/screens/manager_selection.gd"
MAIN = ROOT / "game/ui/main.gd"

assert SCENE.is_file(), "Missing dedicated ManagerSelection V2 scene"
assert SCRIPT.is_file(), "Missing dedicated ManagerSelection V2 script"
scene = SCENE.read_text(encoding="utf-8")
for node in ("Background", "SafeArea", "MainVBox", "Header", "ManagerSelector",
             "CharacterStage", "IdentityPanel", "StatsPanel", "Pagination", "ConfirmButton"):
    assert f'name="{node}"' in scene, f"ManagerSelection hierarchy missing {node}"

main = MAIN.read_text(encoding="utf-8")
body = re.search(r"func creation_manager\(\).*?(?=\nfunc )", main, re.S)
assert body, "creation_manager() is missing"
assert len(body.group(0).splitlines()) < 30, "Legacy dynamic manager UI returned to main.gd"
assert "MANAGER_SELECTION_SCENE.instantiate()" in body.group(0)
for forbidden in ("TextureRect.new()", "ColorRect.new()", "ManagerAvatarCard.new()", "ManagerStatsCard.new()"):
    assert forbidden not in body.group(0), f"Visual construction leaked back into main.gd: {forbidden}"

print("ManagerSelection V2 dedicated-scene structure: OK")
