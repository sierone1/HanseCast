# Hanse Cast Forever – Update 1.0.8

Stand: 12.11.2026. Release-Paket vorbereitet; allgemeine Ingame-Abnahme des zugrunde liegenden Alpha.1-Spielcodes durch den Nutzer bestätigt. Für WoW Forever 1.60.1, Interface 16001. Kompakte Ziel-/Fokusleisten erlauben Builds 70862 und 70888.

## Änderungen gegenüber 1.0.7

- Bei einer echten Erstinstallation wird die Grundoptik anhand der aktiven Spezialisierung bzw. des Talentbaums mit den meisten investierten Punkten gewählt. Alle neun Forever-Klassen sind hinterlegt.
- Blizzard-Spielerleiste ausblenden ist bei neuen Einstellungen aktiv. Unterdrückt wird sie nur während eines sicher dargestellten Hanse-Zaubers; bei fehlenden Daten oder Grafiken bleibt Blizzard verfügbar.
- „Optik nach Zauber“ bleibt optional und standardmäßig aus. Eingeschaltet wählt sie für bekannte, lesbare Zauber-IDs die passende Optik, etwa Schatten beim Priester. Krieger-Zerschmettern und Schurken-Werkzeugcasts wurden ergänzt.
- Bestehende Einstellungen und Profile werden beibehalten. Es gibt keinen automatischen Profilwechsel bei jedem Charakterlogin oder Umskillen.

## Update und Sicherung

1. WoW vollständig schließen. Bestehenden Ordner `Interface/AddOns/HanseCast` sowie `WTF/Account/<ACCOUNT>/SavedVariables/HanseCast.lua` und gegebenenfalls `.lua.bak` privat sichern.
2. Den Ordner `HanseCast` aus dem Forever-ZIP nach `_forever_/Interface/AddOns/` kopieren. Die TOC muss direkt unter `AddOns/HanseCast/HanseCast.toc` liegen. Alte Addonkopien außerhalb von AddOns aufbewahren.
3. WoW neu starten; `/hansecast status` zeigt `1.0.8`. Das frühere separate Compact Lab deaktivieren.
4. Vorhandene Nutzer aktivieren die gewünschte Blizzard-Ausblendung bei Bedarf im Spielermenü. Das Update überschreibt eine bisher deaktivierte Option nicht.

Keine SavedVariables löschen, um neue Defaults zu erzwingen. Für eine isolierte Erstinstallationsprüfung die Einstellungen bei geschlossenem Spiel sichern und vorübergehend aus dem SavedVariables-Ordner nehmen; danach wiederherstellen. Dabei ebenfalls die `.bak` berücksichtigen. Die Einstellungen gelten kontoweit.

## Abnahme

Spieler-Cast und Kanal starten, abbrechen, unterbrechen und schnell nacheinander ausführen; Blizzard-Rückfall, Kampf, Ziel-/Fokuswechsel, Vorschau, Profile und `/reload` prüfen. Priester: mit aktivierter Zauberautomatik Heil-/Schattenzauber vergleichen, danach mit deaktivierter Automatik die feste Grundoptik prüfen. Erstinstallation getrennt vom Update testen. Weitere Klassenfälle stehen in `AUTO-SPELL-VISUALS.md` im Paket.

Das Paket enthält gegenüber der im Spiel bestätigten Forever Alpha.1 ausschließlich aktualisierte Versionsmetadaten und Dokumentation. Update-Anleitung, Klassenübersicht, Quellenverzeichnis, Lizenz und Credits sind enthalten. Das neue ZIP besitzt deshalb einen neuen Hash. Automatisierte Prüfungen ersetzen keine native Abnahme; Retail ist ein separates Paket.

## English update notes

Fresh settings select class/spec artwork and enable safe Blizzard player-bar replacement; optional per-spell artwork remains off. Existing account-wide preferences survive the update. Warrior and Rogue cast mappings were added. All nine Forever class defaults are covered by mocked tests. Close WoW, back up the addon and SavedVariables, replace the addon folder, then fully restart. The user confirmed general in-game testing of alpha.1. This final release changes version metadata and documentation; runtime behavior is unchanged.
