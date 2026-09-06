#!/usr/bin/env python3
"""Validate tracked manager art and report the production V2 art delivery state."""
from pathlib import Path
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PREMIUM = ROOT / "graphics/portraits/managers/premium"
MANAGER_ASSETS = [
    f"{manager}_{kind}.png"
    for manager in ("alex", "maya", "ethan", "sofia", "marcus")
    for kind in ("avatar", "presentation")
]
UI_V2_ASSETS = [
    "ui_manager_bg.jpg", "ui_character_frame.png", "ui_avatar_frame_normal.png",
    "ui_avatar_frame_selected.png", "ui_stats_panel.png",
]

tracked = set(subprocess.check_output(["git", "ls-files"], cwd=ROOT, text=True).splitlines())
missing_managers = [name for name in MANAGER_ASSETS if not (PREMIUM / name).is_file()]
untracked_managers = [name for name in MANAGER_ASSETS if str((PREMIUM / name).relative_to(ROOT)) not in tracked]
assert not missing_managers, f"Missing mandatory manager portraits/presentations: {missing_managers}"
assert not untracked_managers, f"Mandatory manager art is not tracked by Git: {untracked_managers}"

config = json.loads((ROOT / "game/data/team_creation.json").read_text(encoding="utf-8"))
assert list(config["managers"]) == ["alex", "maya", "ethan", "sofia", "marcus"]

cartoon = ROOT / "graphics/ui/manager_selection/cartoon"
present_ui = [name for name in UI_V2_ASSETS if (cartoon / name).is_file()]
missing_ui = [name for name in UI_V2_ASSETS if not (cartoon / name).is_file()]
untracked_ui = [name for name in present_ui if str((cartoon / name).relative_to(ROOT)) not in tracked]
delivery_file = ROOT / "game/data/ui_asset_delivery.json"
delivery = json.loads(delivery_file.read_text(encoding="utf-8"))
delivered = delivery.get("manager_selection_v2_art_delivered")
assert isinstance(delivered, bool), "manager_selection_v2_art_delivered must be a boolean"
screen = (ROOT / "game/ui/screens/manager_selection.gd").read_text(encoding="utf-8")
if delivered:
    assert not missing_ui, f"UI V2 art is declared delivered but files are missing: {missing_ui}"
    assert not untracked_ui, f"UI V2 production art is not tracked by Git: {untracked_ui}"
    print("UI V2 production art declared delivered; 5 mandatory files are present and tracked: OK")
else:
    assert "optional_ui_path" not in screen
    assert "_panel_style" in screen
    print("UI V2 production art is not declared delivered; native Godot fallback accepted.")
    if missing_ui:
        print("ASSET NON LIVRE: " + ", ".join(missing_ui))
    if present_ui:
        print("Uncommitted delivery set ignored until the manifest is enabled: " + ", ".join(present_ui))
print("10 mandatory manager portraits/presentations tracked: OK")
