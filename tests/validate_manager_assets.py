from pathlib import Path
import json

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

print("Premium manager assets: OK")
