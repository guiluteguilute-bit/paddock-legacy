#!/usr/bin/env python3
"""Fast repository checks that do not require a Godot binary."""
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
project = (ROOT / "project.godot").read_text()
assert 'run/main_scene="res://game/ui/main.tscn"' in project
assert 'GameState="*res://game/core/game_state.gd"' in project
assert 'AudioManager="*res://game/core/audio_manager.gd"' in project
assert 'window/size/viewport_width=1080' in project
assert 'window/size/viewport_height=1920' in project
# The first public build deliberately uses Godot's official shell. Validate a
# custom shell only if the export preset explicitly enables one again.
preset = (ROOT / "export_presets.cfg").read_text()
shell_match = re.search(r'^html/custom_html_shell="([^"]*)"', preset, re.MULTILINE)
if shell_match and shell_match.group(1):
    shell_path = shell_match.group(1).removeprefix("res://")
    shell = (ROOT / shell_path).read_text()
    assert "alert(" not in shell
    assert "viewport-fit=cover" in shell
    assert "new Engine($GODOT_CONFIG)" in shell
championships = json.loads((ROOT / "game/data/championships.json").read_text())
assert len(championships) == 9
assert championships[0]["id"] == "kart_club"
assert championships[-1]["id"] == "formula_apex"
assert all(c["points_system"] and c["race_count"] > 0 for c in championships)
for required in ("game/core/game_state.gd", "game/races/race_view.gd", "game/ui/main.tscn"):
    assert (ROOT / required).is_file(), required

# Catch Linux-only path/case failures and malformed data/art assets before Godot import.
for source in ROOT.rglob("*"):
    if not source.is_file() or any(part in {".git", ".godot", "build"} for part in source.parts):
        continue
    if source.suffix == ".json":
        json.loads(source.read_text(encoding="utf-8"))
    elif source.suffix == ".svg":
        ET.parse(source)
    if source.suffix in {".gd", ".tscn", ".tres", ".godot", ".cfg"}:
        text = source.read_text(encoding="utf-8")
        for resource_path in re.findall(r'res://[^"\s)]+', text):
            target = ROOT / resource_path.removeprefix("res://")
            assert target.exists(), f"missing/case-mismatched resource in {source}: {resource_path}"
main = (ROOT / "game/ui/main.gd").read_text()
race = (ROOT / "game/races/race_view.gd").read_text()
for nav_item in ("ACCUEIL", "CARRIÈRE", "COURSE", "ÉCURIE", "PLUS"):
    assert nav_item in main
for feature in ("MobileBottomNavigation", "get_display_safe_area", "PitStrategySheet"):
    assert feature in main
for feature in ("_draw_car", "request_pit", "set_camera", "_near_car", "DRAPEAU À DAMIER"):
    assert feature in race
for legacy in ("app.js", "styles.css", "race/race-engine.js"):
    assert not (ROOT / legacy).exists(), f"legacy gameplay remains: {legacy}"
print("Project structure, web shell, data and unification checks passed")

creation = json.loads((ROOT / "game/data/team_creation.json").read_text())
assert len(creation["origins"]) >= 6
assert len(creation["philosophies"]) >= 6
assert len(creation["manager_styles"]) >= 6
assert len(creation["driver_archetypes"]) >= 6
assert len(creation["goals"]) >= 6
assert all(8000 <= item["budget"] <= 20000 for item in creation["origins"].values())
for category in ("origins", "philosophies", "manager_styles"):
    for choice in creation[category].values():
        assert choice["advantages"] and choice["drawbacks"]
        assert all(abs(value) <= .15 for value in choice.get("modifiers", {}).values())
main = (ROOT / "game/ui/main.gd").read_text()
for feature in ("CREATION_STEPS", "creation_manager", "creation_team", "creation_summary", "confirm_creation", "confirm_reset", "CHOISISSEZ VOTRE GÉRANT"):
    assert feature in main
assert 'CREATION_STEPS := ["GÉRANT", "ÉCURIE", "DÉPART"]' in main
assert "show_welcome" not in main
assert "BÂTISSEZ VOTRE LÉGENDE" not in main
assert "AudioManager.set_music_volume" in main
assert len(creation["managers"]) == 5
for manager_id, manager in creation["managers"].items():
    assert (ROOT / "graphics/portraits/managers" / f"{manager_id}.svg").is_file()
    assert sum(manager["points"].values()) == 10
    assert len(manager["ratings"]) == 3
assert len(re.findall(r'res://graphics/logos/logo_team_[a-z_]+\.svg', main)) >= 12
state = (ROOT / "game/core/game_state.gd").read_text()
for feature in ("build_team_dna", "effective_cost", "potential_estimate", "neutral_dna", "SAVE_VERSION := 5"):
    assert feature in state
print("Team creation configuration, balance bounds and integration checks passed")

audio = (ROOT / "game/core/audio_manager.gd").read_text()
for feature in ("MusicPlayerA", "MusicPlayerB", "MUSIC_CROSSFADE_DURATION := 5.0", "start_music_after_interaction", "music_enabled", "enter_race_music", "exit_race_music"):
    assert feature in audio
assert "ResourceLoader.exists" in audio
assert (ROOT / "audio/music/README.md").is_file()
print("Global, missing-file-safe ambient playlist checks passed")

career = json.loads((ROOT / "game/data/career.json").read_text())
assert len(career["kart_calendar"]) == 6
assert len(career["f4_calendar"]) >= 3
assert len(career["rivals"]) == 11  # player + eleven persistent rivals = twelve-driver grid
assert len(career["sponsors"]) >= 3
assert career["points"] == [25,18,15,12,10,8,6,4,2,1]
for feature in ("finish_season", "_generate_offers", "accept_offer", "sorted_standings", "sign_sponsor", "spend_skill", "repair_vehicle"):
    assert feature in state
for feature in ("show_season_end", "show_offers", "show_driver_development", "show_sponsors", "show_operations", "show_honours"):
    assert feature in main
for feature in ("start_lights", "tyre_temperature", "yellow_timer", "LIGHT RAIN", "pit_crew"):
    assert feature in race
print("Kart season, economy, promotion, F4 rules and persistence checks passed")

endurance = json.loads((ROOT / "game/data/endurance.json").read_text())
assert [s["class"] for s in endurance["series"]] == ["GT4", "GT3", "MULTICLASS", "MULTICLASS"]
assert endurance["series"][-1]["duration_minutes"] == 24 * 60
assert endurance["series"][2]["grid"] == {"HYPERCAR": 8, "PROTOTYPE": 8, "GT3": 16}
assert len([c for c in endurance["cars"] if c["class"] == "GT4"]) == 4
assert len([c for c in endurance["cars"] if c["class"] in ("PROTOTYPE", "HYPERCAR")]) == 3
assert len(endurance["circuits"]) == 7
assert set(endurance["tyres"]) == {"SOFT", "MEDIUM", "HARD", "INTERMEDIATE", "WET"}
assert all(set(c["bop"]) == {"weight_kg", "power_percent", "fuel_multiplier", "tank_litres"} for c in endurance["cars"])
assert endurance["balance_system"]["name"] == "Performance Balance System"
assert len(endurance["race_formats"]) == 7 and endurance["race_formats"][-1]["minutes"] == 1440
assert endurance["pro_am_rule"]["required_grades"] == ["PRO", "AMATEUR"]
assert len(endurance["career_bridges"]) == 4
state = (ROOT / "game/core/game_state.gd").read_text()
for field in ("career_path", "championship_class", "owned_gt_cars", "driver_roster", "endurance_results", "class_results", "prestige", "endurance_trophies"):
    assert f'"{field}"' in state
simulation = (ROOT / "game/core/endurance_simulator.gd").read_text()
for feature in ("overall_position", "class_position", "fuel_laps", "fatigue", "FUEL SAVE", "HEAVY RAIN", "driver_change", "FULL", "simulate_to_next_event", "FULL COURSE YELLOW", "apply_damage", "traffic_loss"):
    assert feature in simulation
for feature in ("can_enter_endurance_class", "complete_endurance_event", "24H WINNER"):
    assert feature in state
ui = (ROOT / "game/ui/main.gd").read_text()
for feature in ("show_endurance_hub", "show_gt_dealership", "show_endurance_strategy", "SIMULATE TO NEXT EVENT", "PIT WINDOW"):
    assert feature in ui
assert (ROOT / "graphics/logos/logo_world_endurance_series.svg").is_file()
print("GT/endurance data, multiclass simulation, persistence and portrait UI checks passed")
