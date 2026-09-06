#!/usr/bin/env python3
"""Fast static guard for the fixed ManagerSelection runtime host."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
main = (ROOT / "game/ui/main.gd").read_text(encoding="utf-8")
assert 'fixed_screen_host.name = "FixedScreenHost"' in main
assert "fixed_screen_host.add_child(screen)" in main
assert "content.add_child(screen)" not in main
assert "scroll.visible = false" in main
assert "fixed_screen_host.visible = true" in main
assert 'scroll.set_deferred("scroll_vertical", 0)' in main
print("ManagerSelection fixed-host architecture: OK")
