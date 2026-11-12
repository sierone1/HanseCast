"""Build the isolated Retail alpha from shared sources. Never edits Forever files."""
from pathlib import Path
import hashlib
import json
import re
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
VERSION = '1.0.8-retail'

def replace_once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('Shared source changed; review Retail adapter: ' + old[:80])
    return text.replace(old, new, 1)

def sources():
    result = {}
    for path in sorted((ROOT / 'HanseCast').rglob('*')):
        if path.is_symlink():
            raise RuntimeError('Symlink in addon: ' + str(path))
        if path.is_file():
            if path.suffix.lower() not in {'.lua', '.toc', '.tga'}:
                raise RuntimeError('Unexpected addon file: ' + str(path))
            result[path.relative_to(ROOT / 'HanseCast').as_posix()] = path.read_bytes()
    for name, data in list(result.items()):
        if name.endswith(('.lua', '.toc')):
            result[name] = data.decode('utf-8-sig').replace('HanseCastDB', 'HanseCastRetailDB').encode('utf-8')
    def edit(name, old, new):
        result[name] = replace_once(result[name].decode('utf-8'), old, new).encode('utf-8')
    edit('HanseCast.toc', '## Interface: 16001', '## Interface: 120105')
    edit('HanseCast.toc', '## Title: Hanse Cast', '## Title: Hanse Cast Retail')
    base_version = re.search(r'^## Version: (\S+)', result['HanseCast.toc'].decode(), re.M).group(1)
    edit('HanseCast.toc', '## Version: ' + base_version, '## Version: ' + VERSION)
    edit('Core.lua', 'HC.version = "' + base_version + '"', 'HC.version = "' + VERSION + '"')
    # Load after Compatibility, before any consumer. SavedVariables remain isolated.
    edit('HanseCast.toc', 'Compatibility.lua', 'Compatibility.lua\nRetail.lua')
    result['Retail.lua'] = (ROOT / 'retail/Retail.lua').read_bytes()
    for source, adapter in [('SpellVisuals.lua', 'RetailSpellVisuals.lua'), ('Themes.lua', 'RetailThemes.lua')]:
        edit('HanseCast.toc', source, source + '\n' + adapter)
        result[adapter] = (ROOT / 'retail' / adapter).read_bytes()
    text = result['CompactUnits.lua'].decode('utf-8')
    start = text.index('local function Supported()')
    end = text.index('local function OutsideCombat()', start)
    text = text[:start] + 'local function Supported() return HC.RetailSupported() end\n' + text[end:]
    text = text.replace('nur Forever 1.60.1 Build 70862/70888', 'nur Retail 12.1.5 / Interface 120105')
    text = text.replace('only Forever 1.60.1 build 70862/70888', 'only Retail 12.1.5 / Interface 120105')
    # Do not import preferences from a separately installed Forever laboratory.
    text = text.replace('HanseCastCompactLabDB', 'HanseCastRetailCompactLabDB')
    text = replace_once(text, 'local function RefreshRow(row)', '''local function RefreshRow(row)
 if not HC.RetailCompactSupported(row.unit) then Clear(row,'unsupported');return end''')
    text = replace_once(text, 'local unitEvents={', '''local unitEvents={'UNIT_SPELLCAST_EMPOWER_START','UNIT_SPELLCAST_EMPOWER_UPDATE','UNIT_SPELLCAST_EMPOWER_STOP',''')
    result['CompactUnits.lua'] = text.encode('utf-8')
    edit('App.lua', 'local function Start()', '''local function Start()
    if not HC.RetailSupported() then
        HC.Print('Retail: requires WoW Retail 12.1.5 (120105).')
        return
    end''')
    edit('App.lua', 'local unitEvents = {', '''local unitEvents = {
    "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_UPDATE", "UNIT_SPELLCAST_EMPOWER_STOP",''')
    for line in result['HanseCast.toc'].decode().splitlines():
        if line.strip() and not line.startswith('#'):
            assert line.strip() in result, line
    return result

def main():
    before = sources()
    payload = dict(before)
    for name, source in {
        'RETAIL-README.txt': 'docs/public/RETAIL.md',
        'AUTO-SPELL-VISUALS.md': 'docs/public/AUTO-SPELL-VISUALS.md',
        'AUTO-SPELL-SOURCES.json': 'docs/public/AUTO-SPELL-SOURCES.json',
        'LICENSE.txt': 'LICENSE.txt', 'CREDITS.txt': 'docs/public/CREDITS.txt'}.items():
        payload[name] = (ROOT / source).read_bytes()
    sys.path.insert(0, str(ROOT / 'tests'))
    from test_retail import verify
    verify(before)
    from test_class_automation import verify as verify_classes
    verify_classes(before)
    if sources() != before:
        raise RuntimeError('Source changed during verification')
    output = ROOT / 'outputs/retail'
    output.mkdir(parents=True, exist_ok=True)
    target = output / ('HanseCast-' + VERSION + '.zip')
    temporary = target.with_suffix('.zip.tmp')
    try:
        with zipfile.ZipFile(temporary, 'w', zipfile.ZIP_DEFLATED) as archive:
            for name, data in payload.items():
                info = zipfile.ZipInfo('HanseCast/' + name, (2026, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o644 << 16
                archive.writestr(info, data)
        with zipfile.ZipFile(temporary) as archive:
            if len(archive.namelist()) != len(payload) or archive.testzip() is not None:
                raise RuntimeError('ZIP member count / CRC mismatch')
            for name, data in payload.items():
                if archive.read('HanseCast/' + name) != data:
                    raise RuntimeError('ZIP content mismatch: ' + name)
        if sources() != before:
            raise RuntimeError('Source changed during packaging')
        temporary.replace(target)
    finally:
        temporary.unlink(missing_ok=True)
    manifest = {'version': VERSION, 'interface': 120105, 'installed': False,
                'published': False, 'ingame_tested': False, 'tests': 'test_retail.py + test_class_automation.py: passed',
                'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
                'files': {k: hashlib.sha256(v).hexdigest() for k, v in payload.items()}}
    target.with_suffix('.manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    print(target)

if __name__ == '__main__':
    main()
