# Hanse Cast

![Hanse Cast](docs/public/logo.png)

Animated player cast bars for **WoW Forever 1.60.1**. Current version: **1.0.4**.

**Target & focus: in development.** Disabled in both menu and runtime. Previous profile values are retained but cannot activate the feature. Blizzard target/focus bars remain available. Separate compact bars are planned, not included.

## Features

- Player casts and channels with spell name, progress and configurable time display.
- Separate global cooldown indicator.
- 145 visual variants, selectable independently of character class or faction.
- Named profiles with validated text import/export.
- Compact native-style settings in WoW Settings → AddOns, with four tabs and hover help.
- Original-art animated menu preview and an explicit positioning mode.
- German and English interface. No additional addon or runtime library required.

## Installation

Copy the `HanseCast` folder into your game's `Interface/AddOns` directory and fully
restart WoW. The resulting path must end in `Interface/AddOns/HanseCast/HanseCast.toc`.
When using GitHub's Download ZIP, extract it first and copy only the inner
`HanseCast` addon folder, not the complete repository folder.

Type `/hansecast` for settings, `/hansecast test` for preview, and
`/hansecast status` for diagnostics. `/hansecast units` only reports the development status. For an existing 1.0.x installation, `/reload` is sufficient after updating; keep SavedVariables.

## Documentation

- [Release 1.0.4 and game checks](docs/public/RELEASE-1.0.4.md)
- [English description](docs/public/DESCRIPTION-EN.md)
- [Deutsche Beschreibung](docs/public/DESCRIPTION-DE.md)
- [English menu guide](docs/public/MENU-EN.md)
- [Deutsche Menüanleitung](docs/public/MENU-DE.md)
- [Changelog](CHANGELOG.md)
- [Credits and resource notice](docs/public/CREDITS.txt)

## Compatibility and testing

This package targets WoW Forever 1.60.1 / interface 16001. Other editions are not
currently supported. Local simulated-client tests cover cast events, profiles,
settings, rendering and resource recovery. Earlier versions were exercised in live
gameplay and reload/restart persistence checks. These are not a comprehensive native
test of every class, spell, display scale or addon combination in version 1.0.4. All 29 local suites passed; native acceptance of 1.0.4 remains pending.

Restricted or unavailable cast data can hide the affected custom bar. Player-bar rendering still requires readable timing. Target/focus functionality is disabled. Empower casts are not supported. Channel guide
lines are manual markers rather than detected ticks. Performance on every system
is not guaranteed.

## License

Free personal use under [All Rights Reserved](LICENSE.txt). Public source visibility
does not grant an open-source license or unrestricted redistribution rights.
Custom artwork and the logo were prepared with AI assistance. Blizzard and other
third-party resources remain the property of their respective owners.

## Deutsch

Hanse Cast ist ein eigenständiges Zauberleisten-Addon für WoW Forever 1.60.1.
Den inneren Ordner `HanseCast` nach `Interface/AddOns` kopieren und WoW vollständig
neu starten. Mit `/hansecast` die Einstellungen öffnen. Die deutsche Anleitung
und Menüerklärung sind oben verlinkt. Aktuelle Version: 1.0.4; die Lizenz bleibt
All Rights Reserved bei kostenloser persönlicher Nutzung.

Ziel & Fokus ist als **in Arbeit** im Menü und im Addon deaktiviert. Alte Profilwerte bleiben erhalten; separate kompakte Leisten sind geplant. Spielerleiste und GCD bleiben verfügbar. Nach einem Update `/reload` eingeben. Native Spielprüfung dieser Version offen.
