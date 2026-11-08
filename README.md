# Hanse Cast

![Hanse Cast](docs/public/logo.png)

Animated player cast bars for **WoW Forever 1.60.1**. Current version: **1.0.5**.

**Target & focus: in development.** Disabled in both menu and runtime. Previous profile values are retained but cannot activate the feature. Blizzard target/focus bars remain available. Separate compact bars are planned, not included.

## Features

- Player casts and channels with spell name, progress and configurable time display.
- Separate global cooldown indicator.
- 145 visual variants, with filters and up to 20 favourites per profile.
- Named profiles with validated text import/export and scoped comfort presets.
- Reduced motion mode, cached display updates and full-rate cast progress.
- Optional cast-start delay estimate and a separate read-only spell queue setting indicator.
- Native-style settings in WoW Settings → AddOns, with hover help, positioning and horizontal alignment.
- Original-art menu preview reflecting font, time display and icon placement.
- German and English interface. No additional addon or runtime library required.

## Installation

Copy the `HanseCast` folder into your game's `Interface/AddOns` directory and fully
restart WoW. The resulting path must end in `Interface/AddOns/HanseCast/HanseCast.toc`.
When using GitHub's Download ZIP, extract it first and copy only the inner
`HanseCast` addon folder, not the complete repository folder.

Fully restart WoW after updating from 1.0.4 or earlier: this release adds a Lua module.
Keep your SavedVariables. Type `/hansecast` for settings, `/hansecast test` for preview,
`/hansecast diagnose` for compact diagnostics and `/hansecast status` for full diagnostics.
`/hansecast units` only reports the development status.

## Documentation

- [Release 1.0.5](docs/public/RELEASE-1.0.5.md)
- [English description](docs/public/DESCRIPTION-EN.md)
- [Deutsche Beschreibung](docs/public/DESCRIPTION-DE.md)
- [English menu guide](docs/public/MENU-EN.md)
- [Deutsche Menüanleitung](docs/public/MENU-DE.md)
- [Changelog](CHANGELOG.md)
- [Credits and resource notice](docs/public/CREDITS.txt)

## Compatibility and testing

This package targets WoW Forever 1.60.1 / interface 16001. Other editions are not
currently supported. The release is checked by 36 local simulated-client suites.
The alpha.3 candidate also passed 5,000 simulated controller cycles; the user
reported the bundled in-game checks successful on 8 November 2026. Stable 1.0.5
preserves that candidate's behaviour. This does not establish coverage of every
class, spell, display scale or addon combination, or a native FPS improvement.

Restricted or unavailable cast data can hide the affected custom bar. Player-bar
rendering requires readable timing. Target/focus are disabled; empower casts are
unsupported. Channel guide lines are manual divisions, not detected ticks. The
start delay is an estimate from safely matched local events, not exact server
latency. The queue indicator reads a client setting without changing it; missing
or inaccessible data is not replaced with guesses.

## License

Free personal use under [All Rights Reserved](LICENSE.txt). Public source visibility
does not grant an open-source license or unrestricted redistribution rights.
Custom artwork and the logo were prepared with AI assistance. Blizzard and other
third-party resources remain the property of their respective owners.

## Deutsch

Hanse Cast ist ein eigenständiges Zauberleisten-Addon für WoW Forever 1.60.1.
Den inneren Ordner `HanseCast` nach `Interface/AddOns` kopieren und WoW vollständig
neu starten. Mit `/hansecast` die Einstellungen öffnen. Aktuelle Version: **1.0.5**.
Favoriten, Filter, Komfort-Vorlagen, ruhiger Modus und optionale Zusatzanzeigen sind
in den oben verlinkten deutschen Anleitungen erklärt. SavedVariables nicht löschen.

Ziel & Fokus bleibt als **in Arbeit** im Menü und im Addon deaktiviert. Separate
kompakte Leisten sind geplant. Der Nutzer hat den gebündelten Spieltest des
funktionsgleichen alpha.3-Kandidaten als erfolgreich bestätigt; das ist keine
vollständige Prüfung aller Klassen oder Addonkombinationen.
