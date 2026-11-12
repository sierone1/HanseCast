"""Validate, test and package the exact Hanse Cast source snapshot (no installation)."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import struct
import subprocess
import sys
import zipfile
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "HanseCast"
TESTS = ["test_diagnostic_report.py", "test_profile_workflow.py", "test_review_lifecycle_contexts.py", "test_review_restricted_start.py", "test_review_profile_recovery.py", "test_review_profile_confirmations.py", "test_cast_comfort.py", "test_usability.py", "test_channel_data.py", "test_compatibility_boundaries.py", "test_ui_text_encoding.py", "test_render_cadence.py", "test_shared_cast_state.py", "test_units_in_development.py", "run.py", "test_gcd.py", "test_blizzard.py", "test_focus_replacement.py", "test_native_units.py", "test_settings.py", "test_menu.py",
         "test_effects.py", "test_cast_feedback.py", "test_texture_diagnostics.py",
         "test_texture_fallback.py", "test_render_resources.py", "test_effect_reentry.py",
         "test_controller_sequences.py", "test_controller_soak.py", "test_faction.py", "test_faction_materials.py",
         "test_spell_visuals.py", "test_class_effects.py", "test_material_selection.py", "test_static_transitions.py", "test_unit_bars.py", "test_profiles_comfort.py", "test_diagnostic_locale.py",
         "test_audit_menu.py", "test_audit_cast.py", "test_audit_comfort.py", "test_audit_units.py"]


TESTS.insert(0, "test_gcd_native.py")
TESTS.insert(0, "test_priest_v4.py")
TESTS.insert(0, "test_compact_integration.py")
TESTS.insert(0, "test_startup_fault_isolation.py")
TESTS.insert(0, "test_compact_menu_preview.py")
TESTS.insert(0, "test_compact_visuals.py")
TESTS.insert(0, "test_compact_controls.py")
TESTS.insert(0, "test_compact_highlight_native.py")
TESTS.insert(0, "test_review_compact_alpha6.py")
TESTS.insert(0, "test_menu_feedback_alpha7.py")
TESTS.insert(0, "test_compact_color_picker.py")
TESTS.insert(0, "test_compact_time.py")
TESTS.insert(0, "test_patch_70888.py")
TESTS.insert(0, "test_class_automation.py")


def snapshot():
    records = {}
    for path in sorted(SOURCE.rglob("*")):
        if path.is_symlink():
            raise RuntimeError(f"Symlink is not an addon asset: {path}")
        if not path.is_file():
            continue
        if path.suffix.lower() not in {".lua", ".toc", ".tga"}:
            raise RuntimeError(f"Unexpected shipped file: {path}")
        data = path.read_bytes()
        if path.suffix.lower() == ".tga":
            if len(data) < 18:
                raise RuntimeError(f"Short TGA header: {path}")
            id_len, cmap, image_type = data[:3]
            width, height, depth, descriptor = struct.unpack_from("<HHBB", data, 12)
            if (cmap != 0 or image_type != 2 or depth != 32 or descriptor & 15 != 8
                    or not width or not height or width & (width - 1) or height & (height - 1)
                    or len(data) < 18 + id_len + width * height * 4):
                raise RuntimeError(f"Invalid RGBA / power-of-two TGA: {path}")
        records[path.relative_to(SOURCE).as_posix()] = {
            "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "outputs")
    args = parser.parse_args()
    toc = (SOURCE / "HanseCast.toc").read_text(encoding="utf-8-sig")
    version = re.search(r"^## Version:\s*(\S+)\s*$", toc, re.M).group(1)
    core_version = re.search(r'HC.version\s*=\s*"([^"]+)"',
                             (SOURCE / "Core.lua").read_text(encoding="utf-8-sig")).group(1)
    if version != core_version or not re.fullmatch(r"[0-9A-Za-z.-]+", version):
        raise RuntimeError("TOC/Core version mismatch or invalid version")
    before = snapshot()
    documentation = {name: (ROOT / source).read_bytes() for name, source in {
        'README.txt': 'docs/public/README.txt', 'UPDATE.md': 'docs/public/RELEASE-1.0.8.md',
        'AUTO-SPELL-VISUALS.md': 'docs/public/AUTO-SPELL-VISUALS.md',
        'AUTO-SPELL-SOURCES.json': 'docs/public/AUTO-SPELL-SOURCES.json',
        'LICENSE.txt': 'LICENSE.txt', 'CREDITS.txt': 'docs/public/CREDITS.txt'}.items()}
    packaged = dict(before)
    packaged.update({name: {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
                     for name, data in documentation.items()})
    test_sources = {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in sorted((ROOT / "tests").iterdir())
                    if p.is_file() and p.suffix in {".lua", ".py"}}
    # The channel suite imports an offline validator and reads captured source
    # evidence outside tests/. Pin those inputs too, not just the test script.
    validation_paths = [ROOT / "tools/validate_channel_data.py", ROOT / "experiments/channel-data/catalog.json"]
    validation_paths += [ROOT / "tools/package_retail.py"] + sorted((ROOT / "retail").glob("*.lua"))
    validation_paths += [ROOT / "tools/build_priest_v4.py", ROOT / "tools/build_material_glow.py", ROOT / "tools/build_mage_fire.py", ROOT / "art/priest-v5/build.json"]
    validation_paths += [p for p in sorted((ROOT / "art/priest-v5/masters").iterdir()) if p.suffix in {".png", ".txt"}]
    validation_paths += [ROOT / "tools/build_compact_visuals.py", ROOT / "art/compact-v2/build.json"]
    validation_paths += [p for p in sorted((ROOT / "art/compact-v2/masters").iterdir()) if p.suffix in {".png", ".txt"}]
    validation_paths += [p for p in sorted((ROOT / "experiments/channel-data/sources-1.60.1.70862").iterdir()) if p.is_file()]
    validation_sources = {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in validation_paths}
    for line in toc.splitlines():
        line = line.strip()
        if line and not line.startswith("#") and line.replace("\\", "/") not in before:
            raise RuntimeError(f"TOC source missing: {line}")
    results = []
    for name in TESTS:
        print(f"Checking {name}", flush=True)
        result = subprocess.run([sys.executable, str(ROOT / "tests" / name)],
                                cwd=ROOT, capture_output=True, text=True, encoding="utf-8",
                                errors="replace")
        results.append({"test": name, "exitCode": result.returncode,
                        "stdout": result.stdout, "stderr": result.stderr})
        if result.returncode:
            print(result.stdout, result.stderr)
            raise RuntimeError(f"Test failed: {name}; package not created")
    if snapshot() != before:
        raise RuntimeError("Source changed during tests; rerun for a consistent package")
    for name, digest in test_sources.items():
        if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != digest:
            raise RuntimeError(f"Test source changed during validation: {name}")
    for name, digest in validation_sources.items():
        if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != digest:
            raise RuntimeError(f"Validation input changed during tests: {name}")
    args.output.mkdir(parents=True, exist_ok=True)
    archive = args.output / f"HanseCast-{version}.zip"
    temporary = archive.with_suffix(".zip.tmp")
    try:
        with zipfile.ZipFile(temporary, "w", compression=zipfile.ZIP_DEFLATED,
                             compresslevel=9) as output:
            for name, expected in packaged.items():
                data = documentation[name] if name in documentation else (SOURCE / name).read_bytes()
                if hashlib.sha256(data).hexdigest() != expected["sha256"]:
                    raise RuntimeError(f"Source changed while packaging: {name}")
                info = zipfile.ZipInfo(f"HanseCast/{name}", (2026, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o644 << 16
                output.writestr(info, data, compresslevel=9)
        with zipfile.ZipFile(temporary) as check:
            if len(check.namelist()) != len(packaged) or check.testzip() is not None:
                raise RuntimeError("ZIP member count / CRC check failed")
            for name, expected in packaged.items():
                data = check.read(f"HanseCast/{name}")
                if hashlib.sha256(data).hexdigest() != expected["sha256"]:
                    raise RuntimeError(f"Packaged bytes differ: {name}")
        if snapshot() != before:
            raise RuntimeError("Source changed before package verification completed")
        temporary.replace(archive)
    finally:
        temporary.unlink(missing_ok=True)
    manifest = {"version": version, "utc": datetime.now(timezone.utc).isoformat(),
                "scope": "Lua 5.1 mocked client and assets; no native WoW runtime proof",
                "installed": False, "archive": archive.name,
                "archiveSha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
                "fileCount": len(packaged), "files": packaged, "tests": results,
                "testSources": test_sources,
                "validationSources": validation_sources,
                "packagerSha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    manifest_path = archive.with_suffix(".manifest.json")
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
                             encoding="utf-8")
    print(f"Verified {len(before)} files and {len(results)} suites: {archive}")
    print(f"Evidence: {manifest_path}")


if __name__ == "__main__":
    main()
