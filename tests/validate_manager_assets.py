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
missing_ui = [name for name in UI_V2_ASSETS if str((cartoon / name).relative_to(ROOT)) not in tracked]
screen = (ROOT / "game/ui/screens/manager_selection.gd").read_text(encoding="utf-8")
if missing_ui:
    # The requested production files have never been delivered. V2 must therefore
    # use its explicit native Godot art direction, never the legacy optional helper.
    assert "optional_ui_path" not in screen
    assert "_panel_style" in screen
    print("UI V2 production art MISSING (native Godot V2 mode): " + ", ".join(missing_ui))
else:
    print("UI V2 mandatory production art tracked: OK")
print("10 mandatory manager portraits/presentations tracked: OK")
