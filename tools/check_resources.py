"""Check literal required Godot resource references, after generated assets are extracted."""
from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
patterns = [re.compile(r'\bpreload\(\s*["\']res://([^"\']+)["\']'), re.compile(r'\bpath\s*=\s*"res://([^"]+)"'), re.compile(r'^\s*run/main_scene\s*=\s*"res://([^"]+)"', re.M)]
missing = []
for p in sorted(root.rglob("*")):
    if p.suffix not in (".gd", ".tscn", ".tres", ".godot") or any(part in (".git", ".godot", "build") for part in p.relative_to(root).parts):
        continue
    content = p.read_text(encoding="utf-8")
    for pattern in patterns:
        for match in pattern.finditer(content):
            if not (root / match.group(1)).is_file():
                missing.append(f"{p.relative_to(root)}:{content.count(chr(10), 0, match.start())+1}: {match.group(1)}")
if missing:
    raise SystemExit("Missing required resources:\n" + "\n".join(missing))
print("Required literal resource references OK.")
