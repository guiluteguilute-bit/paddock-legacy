#!/usr/bin/env python3
"""Fast repository checks that do not require a Godot binary."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
project = (ROOT / "project.godot").read_text()
assert 'run/main_scene="res://game/ui/main.tscn"' in project
assert 'GameState="*res://game/core/game_state.gd"' in project
shell = (ROOT / "web/shell.html").read_text()
assert "alert(" not in shell
assert "viewport-fit=cover" in shell
championships = json.loads((ROOT / "game/data/championships.json").read_text())
assert len(championships) == 9
assert championships[0]["id"] == "kart_club"
assert championships[-1]["id"] == "formula_apex"
assert all(c["points_system"] and c["race_count"] > 0 for c in championships)
for required in ("game/core/game_state.gd", "game/races/race_view.gd", "game/ui/main.tscn"):
    assert (ROOT / required).is_file(), required
for legacy in ("app.js", "styles.css", "race/race-engine.js"):
    assert not (ROOT / legacy).exists(), f"legacy gameplay remains: {legacy}"
print("Project structure, web shell, data and unification checks passed")
