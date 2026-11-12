# Hanse Cast Retail - 1.0.8-retail

Stand: 12.11.2026. Eigenständiges Release-Paket für Retail 12.1.5, Interface 120105. Allgemeine Ingame-Prüfung der zugrunde liegenden Alpha.2 vom Nutzer bestätigt. Gemeinsame Grundlage ist Forever 1.0.8.

## Umfang und Grenzen

Vorhandene Spielerdesigns, Profile, Konfiguration, GCD und kompakte Ziel-/Fokusleisten werden aus dem gemeinsamen Quellstand gebaut. Retail besitzt eine eigene Clientprüfung und SavedVariable `HanseCastRetailDB`. Unbekannte Interfaces und Classic/Forever werden abgelehnt. Addonordner und Befehle bleiben `HanseCast`, `/hansecast`, `/hccompact`.

Die animierte Spielerleiste setzt lesbare Cast-/Kanalzeiten voraus. Bei Secret Values, API-Fehlern oder Empower-Casts fällt sie auf Blizzard zurück. Empower-Ereignisse lösen die erneute Zustandsprüfung aus; eine eigene Empower-Stufenanzeige ist nicht implementiert. Ziel/Fokus reichen Dauerobjekte direkt an native StatusBars weiter. Der Retail-Build verspricht keine vollständige Retail-Funktionsgleichheit. Retail besitzt einen getrennten Zauberkatalog für alle 13 Klassen. Zusätzliche Klassenkategorien verwenden vorhandene Grafiken als Material-Aliase. Erstauswahl nach Spezialisierung, sichere Blizzard-Ausblendung standardmäßig an, optionale Zauberautomatik standardmäßig aus. Bestehende Einstellungen bleiben erhalten. Klassenabdeckung und Grenzen: [Klassenoptik](AUTO-SPELL-VISUALS.md).

## Installation und Test

1. WoW schließen. Vorhandenen Retail-Addonordner und Einstellungen sichern.
2. ZIP in `<WoW>/_retail_/Interface/AddOns/` entpacken. Ergebnis: `HanseCast/HanseCast.toc`. Nicht zusätzlich zur Forever-Version im selben Client installieren.
3. WoW starten, Hanse Cast Retail aktivieren. `/hansecast status` prüfen.
4. `/hansecast test`: Designs, Größe, Position und Profile prüfen; Vorschau danach beenden.
5. Spieler: Cast, Kanal, Abbruch, Unterbrechung, Sofortzauber/GCD, schnelle Folge und Kampf testen. Die standardmäßig aktive Blizzard-Ausblendung und ihre Rückfallanzeige gezielt prüfen.
6. Ziel/Fokus: Wechsel während Cast/Kanal, leeres Ziel, Kampf, Unterbrechung und API-Ausfall prüfen. Blizzard-Ausblendung erst nach Sichtprüfung aktivieren.
7. Evoker: Empower starten, Stufen halten, früh loslassen und abbrechen. Blizzard muss als Rückfall lesbar bleiben.
8. Speichern, `/reload`, Profilwechsel und erneutes Einloggen prüfen. Erst anschließend Freigabe bewerten.

Eigene Einstellungen liegen in `<WoW>/_retail_/WTF/Account/<ACCOUNT>/SavedVariables/HanseCast.lua` unter `HanseCastRetailDB`. Dateiname folgt dem Addonordner, nicht dem Variablennamen. Kein automatischer Import aus Forever.

## Entwicklung

Die Alpha.2 behebt zusätzlich die Empower-Behandlung in kompakten Ziel-/Fokusleisten: Empower-Ereignisse lösen eine Aktualisierung aus; Empower, nicht lesbare Empower-Merkmale und API-Fehler unterdrücken die eigene Kompaktanzeige, damit Blizzard verfügbar bleibt. Der Nutzer hat anschließend Alpha.2 installiert und allgemein im Spiel bestätigt. Der finale Build ändert nur Versions-/Statusmetadaten und Dokumentation; der Empower-Fix bleibt unverändert.

## Bedienung und Einstellungen

`/hansecast` öffnet das Menü. Im Reiter **Spieler** wählst du Grafikfamilie und Optik sowie Größe, Position, Schrift, Symbol und Zeitdarstellung. Fünf Familien stehen zur Verfügung: Elementstrom, Splitter & Funken, Seidenfluss, Impuls und Nebellicht. Allianz-/Hordemotive sind bewusst feste Optiken. Zusätzliche Retail-Klassen verwenden vorhandene Materialien; es handelt sich nicht um neu gezeichnete Klassengrafiken.

Die Grundeinstellung wird nur einmal ohne vorhandene `HanseCastRetailDB` anhand der aktiven Spezialisierung gewählt. Alle 13 Klassen und 40 hinterlegten Spezialisierungen sind in den Mocktests erfasst. Ohne lesbare Spezialisierung dient eine Klassenoptik als Ersatz. Die Auswahl gilt kontoweit und folgt späteren Talent- oder Charakterwechseln nicht automatisch.

**Optik nach Zauber** ist optional und anfangs aus. Eingeschaltet wechseln bekannte, lesbare Cast-/Kanal-IDs die Darstellung vorübergehend. Unbekannte oder geschützte IDs behalten die Grundoptik. Sofortzauber erzeugen keine künstliche Castbar. Beim Priester können beispielsweise Schatten, Heilig und Disziplin unterschieden werden; die Zuordnung erfolgt nach dem gewirkten Zauber, nicht allein nach der Skillung. Die vollständige Klassenübersicht steht in [AUTO-SPELL-VISUALS.md](AUTO-SPELL-VISUALS.md).

**Ziel & Fokus** bzw. `/hccompact` bietet Aktivierung, Klassik/Seidenkern/Geteilte Anzeige, gemeinsame Farbe, Maße, Schrift und getrennte Positionierung. Restzeit kann aus, innen rechts oder außen rechts angezeigt werden. Ein Strich bedeutet fehlende Zeitdaten. Blizzard-Ziel- und Fokusleisten haben getrennte Ausblendoptionen. Diese Einstellungen gehören nicht zu den Spielerprofilen. Keine zusätzlichen Pet-, Ziel-des-Ziels- oder Namensplakettenleisten.

**Profile** speichert bis zu zwölf Spielerprofile. Kopieren, Umbenennen und Textimport/-export sind vorhanden. Ein Profilexport ist kein vollständiges Backup der Kompakteinstellungen. Retail übernimmt Forever-Einstellungen nicht automatisch; für eine vollständige Sicherung die oben genannte SavedVariables-Datei bei geschlossenem Spiel kopieren.

`/hansecast test` schaltet die Vorschau um, `/hansecast demo` zeigt die Rückmeldungsvorschau, `/hansecast units` die Einheitenvorschau. Vorschauen nach dem Einrichten beenden. Konfigurations- und Positionieränderungen im Kampf werden gesperrt. Speichern/Abbrechen beim Positionieren und Okay/Abbrechen beim Farbwähler beachten.

## Fehlerbehebung und Entfernung

- **Addon fehlt:** Ordnerstruktur und Retail-ZIP prüfen, Client vollständig neu starten. Die Forever-Version darf nicht in denselben Clientordner kopiert werden.
- **Nicht unterstützt:** `/hansecast status` und die Clientversion prüfen. Dieser Build erlaubt ausschließlich Mainline mit Interface 120105 und benötigter Secret-Value-Prüfung. „Veraltete Addons laden“ umgeht diese interne Prüfung nicht.
- **Blizzard erscheint weiterhin:** Bei Empower, geschützten Zeiten, API-Fehlern oder fehlendem Material ist das der vorgesehene Rückfall. Vorhandene Einstellungen können die Ausblendoption deaktiviert haben. Bei Ziel/Fokus zusätzlich deren eigene Optionen prüfen.
- **Falsche Klassenoptik:** Vorhandene kontoweite Einstellungen bleiben erhalten. Gewünschte Optik/Profil im Spielermenü auswählen; die Erstwahl läuft nicht bei jedem Login erneut.
- **Fehler melden:** `/hansecast report` bzw. `/hansecast bericht` öffnet die Diagnose. Version, Clientbuild, betroffene Einheit, Zauber und genaue Schritte angeben. Keine vollständigen privaten SavedVariables oder Accountdaten veröffentlichen. Fehlerberichte: https://github.com/sierone1/HanseCast/issues
- **Zurücksetzen/entfernen:** Erst WoW beenden und privat sichern. Addonordner entfernen oder eine gesicherte passende Retail-Version wiederherstellen. SavedVariables nur entfernen, wenn Einstellungen tatsächlich gelöscht werden sollen. Für ein vollständiges Zurücksetzen auch die Backup-Datei `.lua.bak` berücksichtigen.

## Technische Architektur und Prüfumfang

TOC und Core tragen die Retail-Version. `Retail.lua` prüft den Client, `RetailSpellVisuals.lua` ersetzt den Forever-Zauberkatalog und `RetailThemes.lua` ergänzt Klassenkategorien mit Material-Aliasen. Spielerleisten verwenden ausschließlich zugängliche Zeitwerte. Native Ziel-/Fokustimer erhalten Dauerobjekte direkt; deren Fortschritt wird nicht aus geschützten Werten berechnet. Blizzard-Skripte und Ereignisregistrierungen bleiben erhalten; die Ausblendung erfolgt kontrolliert über Alpha mit Wiederherstellung.

Mocktests prüfen das tatsächlich generierte TOC-Payload, Clientablehnung, getrennte SavedVariables, Erstwahl, Materialdateien aller Familien, Cast-/Kanalwechsel, Secrets, Empower, API-Ausfälle, Wiederanlauf, Profile, Vorschau und Kampfgrenzen. Paketprüfung kontrolliert sämtliche Dateien einschließlich Dokumentation/Lizenz per Bytevergleich und ZIP-CRC; das Manifest enthält SHA-256 für jede Datei. Veröffentlichung des ZIPs erfolgt erst nach abgeschlossener Prüfung aus einer temporären Datei. Das ist keine Bestätigung der nativen Retail-Funktion.

Das öffentliche Repository enthält die Laufzeitquellen und Retail-Transformationen. Die vollständige lokale Testumgebung einschließlich gemeinsamer Mockhelfer und Grafikprüfquellen wird nicht vollständig veröffentlicht. Ein frischer GitHub-Checkout allein genügt daher nicht für den vollständigen Release-Build. Lokaler Aufruf und Abhängigkeit:

```text
python tools/package_retail.py
lupa 2.8 mit Lua-5.1-Runtime
```

## English overview

Retail 1.0.8 targets Mainline interface 120105 and stores settings in `HanseCastRetailDB`. Install the `HanseCast` folder into `_retail_/Interface/AddOns`, restart WoW and open `/hansecast`. Fresh settings choose specialization artwork, enable safe Blizzard player-bar replacement and leave optional per-spell switching off. Existing preferences are preserved. Thirteen classes use a separate Retail spell catalog; additional classes reuse existing artwork. Empower and inaccessible player timings retain Blizzard's bar. Alpha.2 also prevents compact target/focus bars from replacing Empower or unreadable channel kinds. Profiles cover player preferences, not all compact settings. The user confirmed general in-game testing of alpha.2; the final release changes only version/status metadata and documentation. Individual spell/class coverage is not exhaustive.

## Build und Quellen

Maßgeblich: `HanseCast/` plus die Adapter unter `retail/` und die geprüften Transformationen in `tools/package_retail.py`. Keine manuell gepflegte zweite Kopie aller Grafiken. `python tools/package_retail.py` prüft den generierten Lua-Stand, führt Retail-Mocktests aus und erzeugt ZIP und SHA-256-Manifest unter `outputs/retail/`. Abhängigkeit wie im Hauptprojekt: lupa 2.8 (Lua 5.1). Geänderte Transformationsanker brechen den Build ab. Vorhandene uncommittete gemeinsame Änderungen gehören zum gehashten Buildstand.

Automatische Prüfungen sind Mocktests, kein Nachweis des nativen Retail-Clients. Aktueller Zielpatch anhand der Blizzard-Updateseite recherchiert; genaue Client-Buildnummer und tatsächliches Interface im Spiel noch abzugleichen. Keine Installation oder Veröffentlichung durch den Packager.

Quellen (12.11.2026):
- https://worldofwarcraft.blizzard.com/en-us/content-update-notes
- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua
- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_EncounterTimeline/EncounterTimelineTimerEvent.lua
