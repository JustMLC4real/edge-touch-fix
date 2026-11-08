"""Build the Magisk module ZIP into dist/, write update.json and run basic checks.

Usage: python build.py

Release flow: bump version/versionCode in module.prop, add a CHANGELOG entry,
run this script, commit update.json, then publish a GitHub release tagged
v<version> with the ZIP from dist/.
"""
import hashlib
import json
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
FILES = [
    "META-INF/com/google/android/update-binary",
    "META-INF/com/google/android/updater-script",
    "module.prop",
    "customize.sh",
    "service.sh",
    "action.sh",
    "LICENSE",
]
SCRIPTS = [f for f in FILES if f.endswith(".sh") or f.endswith("update-binary")]
REQUIRED_PROPS = {"id", "name", "version", "versionCode", "author", "description", "updateJson"}
REPO = "JustMLC4real/edge-touch-fix"
UPDATE_JSON_URL = f"https://raw.githubusercontent.com/{REPO}/main/update.json"


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def main() -> None:
    for name in FILES:
        data = (ROOT / name).read_bytes()
        if b"\r" in data:
            fail(f"{name} contains CR line endings")

    props = dict(
        line.split("=", 1)
        for line in (ROOT / "module.prop").read_text(encoding="utf-8").splitlines()
        if "=" in line
    )
    missing = REQUIRED_PROPS - props.keys()
    if missing:
        fail(f"module.prop is missing {sorted(missing)}")
    if props["id"] != "edge_touch_fix":
        fail("module id changed; Magisk would treat it as a different module")
    if props["updateJson"] != UPDATE_JSON_URL:
        fail(f"updateJson must be {UPDATE_JSON_URL}")
    if not props["versionCode"].isdigit():
        fail("versionCode must be a whole number")
    if f"## {props['version']}" not in (ROOT / "CHANGELOG.md").read_text(encoding="utf-8"):
        fail(f"CHANGELOG.md has no '## {props['version']}' entry")

    sh = shutil.which("sh")
    if sh:
        for name in SCRIPTS:
            result = subprocess.run([sh, "-n", str(ROOT / name)], capture_output=True, text=True)
            if result.returncode != 0:
                fail(f"{name}: {result.stderr.strip()}")
    else:
        print("WARN: no sh found, skipped syntax check")

    dist = ROOT / "dist"
    dist.mkdir(exist_ok=True)
    out = dist / f"edge_touch_fix-v{props['version']}.zip"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for name in FILES:
            info = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = (0o755 if name in SCRIPTS else 0o644) << 16
            z.writestr(info, (ROOT / name).read_bytes())

    update = {
        "version": props["version"],
        "versionCode": int(props["versionCode"]),
        "zipUrl": f"https://github.com/{REPO}/releases/download/v{props['version']}/{out.name}",
        "changelog": f"https://raw.githubusercontent.com/{REPO}/main/CHANGELOG.md",
    }
    (ROOT / "update.json").write_text(json.dumps(update, indent=2) + "\n", encoding="utf-8", newline="\n")

    digest = hashlib.sha256(out.read_bytes()).hexdigest()
    print(f"OK: {out.relative_to(ROOT)}")
    print(f"OK: update.json -> v{props['version']} ({props['versionCode']})")
    print(f"SHA-256: {digest}")


if __name__ == "__main__":
    main()
