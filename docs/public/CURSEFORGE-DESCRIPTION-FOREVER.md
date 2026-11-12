# Hanse Cast - Forever

Animated player cast bars, a separate GCD indicator and compact target/focus bars.

For WoW Forever 1.60.1 / interface 16001. Compact target/focus bars support builds 70862 and 70888. This package is not for Retail.

## Player cast bar

Choose from five artwork families: Element Stream, Splinters & Sparks, Silk Flow, Pulse and Mistlight. Customize size, position, fonts, spell icons and time display. Class-inspired and Alliance/Horde artwork can be selected independently of your character's class.

On a fresh installation with no saved settings, Hanse Cast selects artwork for the current class and specialization. Forever can use the talent tree with the most invested points. If specialization data is unavailable, a class default is used. Settings are account-wide: this is a one-time initial selection, not automatic profile switching whenever you change characters or talents.

Optional **per-spell artwork** is off by default. Enable it to temporarily select artwork for recognized, readable cast/channel spell IDs, such as Shadow, Holy or Discipline priest spells. Unknown or restricted IDs keep your selected artwork. Instant abilities do not create artificial cast bars.

Safe Blizzard player-bar replacement is enabled for fresh settings. Blizzard is hidden only while Hanse Cast can provide the active display; unavailable data or artwork retain the default bar. Updates preserve your existing preferences.

Includes a separate GCD indicator, reduced motion, favorites and up to twelve named player profiles with copy, rename and text import/export. Channel guides are manual aids, not automatic tick detection.

## Target and focus

Three compact designs, a shared color picker, separate positions, adjustable dimensions and fonts, and optional remaining time inside or outside the right edge. A dash indicates unavailable time data. Blizzard target/focus replacement is configured separately. Compact settings are shared independently of player profiles.

No extra pet, target-of-target or nameplate bars. Selected pets can still be displayed as your target or focus.

## Compatibility limits

Player bars require readable timestamps. Restricted data and empowered casts retain Blizzard. Channel guides are manual aids, not automatic tick detection.

## Install and use

Install this project's file through CurseForge or extract its `HanseCast` folder into the correct client's `Interface/AddOns`. Fully restart WoW after updating. Keep saved settings; disable the obsolete standalone Hanse Cast Compact Lab if present. No additional addon or runtime library is required.

- `/hansecast`: settings, player appearance, profiles and help.
- `/hccompact`: target/focus settings.
- `/hansecast test`: toggle player preview.
- `/hansecast status`: version and status.
- `/hansecast report`: copyable diagnostics.

Configuration changes are blocked in combat. German and English UI are available. Retail and Forever store preferences separately. A player profile export is not a complete backup of compact settings.

## Support and credits

The author has confirmed general in-game testing of both variants. Automated tests cover mocked API contracts and assets; neither guarantees every spell, class or addon combination. Report the client build, addon version and reproduction steps without private account data.

Artwork was prepared using AI-assisted creation and local processing. Software-composed previews are illustrative and must not be confused with in-game screenshots; existing gallery images labelled Ingame are game captures. Blizzard icons, emblems and fonts are referenced from the client. Free to use; All Rights Reserved. Not affiliated with or endorsed by Blizzard.

Source: https://github.com/sierone1/HanseCast

Issues: https://github.com/sierone1/HanseCast/issues

---

# Deutsch

**Hanse Cast - Forever** bietet animierte Spieler-Zauberleisten, eine separate GCD und kompakte Ziel-/Fokusleisten für WoW Forever. Dieses Projekt enthält ausschließlich die Forever-Variante.

Ohne gespeicherte Einstellungen wird einmalig eine Klassen-/Spezialisierungsoptik gewählt. Die Einstellungen sind kontoweit und wechseln später nicht automatisch mit Charakter oder Skillung. Optionale Optik nach gewirktem Zauber ist anfangs aus; sichere Blizzard-Spielerleisten-Ausblendung bei frischen Einstellungen an. Vorhandene Einstellungen bleiben erhalten.

Fünf Grafikfamilien, Profile, Größen-/Positions-/Schrifteinstellungen und drei kompakte Ziel-/Fokusdesigns stehen bereit. Bei nicht darstellbaren Zaubern bleibt Blizzard verfügbar. Keine eigene Empower-Stufenanzeige und keine automatischen Kanalticks.

Nach dem Update WoW vollständig neu starten. `/hansecast` öffnet die Einstellungen, `/hccompact` Ziel/Fokus und `/hansecast bericht` die Diagnose. Allgemeiner Ingame-Test bestätigt; keine Zusage vollständiger Klassen-/Zauberabdeckung. KI-unterstützte Grafikerstellung und lokale Bearbeitung; kostenlose Nutzung, All Rights Reserved.
