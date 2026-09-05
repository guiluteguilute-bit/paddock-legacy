from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
PREMIUM = ROOT / "graphics" / "portraits" / "managers" / "premium"
EXPECTED = [
    "alex_avatar.png", "alex_presentation.png",
    "maya_avatar.png", "maya_presentation.png",
    "ethan_avatar.png", "ethan_presentation.png",
    "sofia_avatar.png", "sofia_presentation.png",
    "marcus_avatar.png", "marcus_presentation.png",
]

missing = [name for name in EXPECTED if not (PREMIUM / name).is_file()]
assert not missing, f"Missing premium manager assets: {missing}"

config = json.loads((ROOT / "game" / "data" / "team_creation.json").read_text(encoding="utf-8"))
assert list(config["managers"].keys()) == ["alex", "maya", "ethan", "sofia", "marcus"]
for manager_id, manager in config["managers"].items():
    assert manager["avatar"].endswith(f"{manager_id}_avatar.png")
    assert manager["presentation"].endswith(f"{manager_id}_presentation.png")
    assert set(manager["attributes"].keys()) == {"technical", "strategy", "business"}

main_gd = (ROOT / "game" / "ui" / "main.gd").read_text(encoding="utf-8")
assert "APERÇU CHOIX DU GÉRANT" in main_gd
assert "manager_preview_mode" in main_gd
assert "RETOUR AUX PARAMÈTRES" in main_gd

# Cartoon UI art is optional until production files are delivered. Its absence
# must select native Godot fallbacks instead of becoming a static dependency.
components = ROOT / "game" / "ui" / "components"
sources = [main_gd] + [path.read_text(encoding="utf-8") for path in components.glob("*.gd")]
dead_cartoon_refs = [
    match
    for source in sources
    for match in re.findall(r"res://graphics/ui/manager_selection/cartoon/[^\"'\s)]+", source)
]
assert not dead_cartoon_refs, f"Optional cartoon assets must not be static dependencies: {dead_cartoon_refs}"
helpers = (components / "manager_ui_helpers.gd").read_text(encoding="utf-8")
assert "optional_ui_path" in helpers
assert "ResourceLoader.exists(path)" in helpers

print("Premium manager assets and optional cartoon fallbacks: OK")
