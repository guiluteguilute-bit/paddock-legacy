#!/usr/bin/env python3
"""Reject regressions that make the Godot Web page larger than the iOS viewport."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
shell = (ROOT / "web/shell.html").read_text(encoding="utf-8")

viewport_tags = re.findall(r'<meta\s+name=["\']viewport["\'][^>]*>', shell, re.IGNORECASE)
assert len(viewport_tags) == 1, f"Expected exactly one viewport meta tag, found {len(viewport_tags)}"
assert "viewport-fit=cover" in viewport_tags[0], "The viewport must opt into the iOS safe area"
assert len(re.findall(r'<canvas\b', shell, re.IGNORECASE)) == 1, "The shell must contain exactly one canvas"
assert re.search(r'<(?:main|div)\s+id=["\']game["\']', shell), "A #game canvas wrapper is required"
assert re.search(r'html\s*,\s*body\s*\{[^}]*overflow\s*:\s*hidden', shell, re.DOTALL), "html/body scrolling must be locked"
assert re.search(r'body\s*\{[^}]*height\s*:\s*100vh', shell, re.DOTALL), "100vh fallback is required"
assert "@supports (height: 100dvh)" in shell and "height: 100dvh" in shell, "Dynamic viewport height strategy is required"
assert re.search(r'#game\s*\{[^}]*position\s*:\s*fixed[^}]*inset\s*:\s*0', shell, re.DOTALL), "#game must be fixed to the visible page"
assert re.search(r'#canvas\s*\{[^}]*width\s*:\s*100%[^}]*height\s*:\s*100%', shell, re.DOTALL), "Canvas must fill its wrapper"
assert "overflow: auto" not in shell and "overflow: scroll" not in shell, "The game page must not be scrollable"
print("WEB SHELL VALIDATION: one canvas, safe area, locked scroll and dynamic viewport passed")
