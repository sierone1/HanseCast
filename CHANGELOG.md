# Hanse Cast 1.0.5

- Gemeinsame Zauberzustände verhindern alte Rückmeldungen nach schnellen Zauberwechseln.
- Ruhiger Modus stoppt dekorative Bewegung und zusätzliche Lichtimpulse; Fortschritt bleibt flüssig.
- Weniger wiederholte Zeitformatierungen und Geometrieaufrufe; Dekoration getrennt getaktet.
- Optionale, sicher zugeordnete Zauberstart-Schätzung und getrennte Anzeige des gelesenen Warteschlangenfensters. Keine Änderung der Spiel-CVar.
- Browser für 145 Optiken, Filter und bis zu 20 Favoriten je Profil; validierter Import/Export.
- Komfort-Vorlagen, horizontale Ausrichtung und Vorschau mit eingestellter Schrift, Zeitformat und Symbolposition.
- Ziel/Fokus bleiben „in Arbeit“ und deaktiviert. Kanal-Hilfslinien bleiben manuell.
- Stable promotion of the tested alpha.3 behaviour: reduced motion, guarded comfort indicators, favourites/filters, scoped presets and improved preview.
- 36 automatisierte Testsuiten; alpha.3 zusätzlich mit 5.000 simulierten Abläufen geprüft. Nutzer bestätigt den gebündelten Spieltest mit „funktioniert alles“ am 08.11.2026. Keine vollständige Abdeckung aller Klassen, Zauber oder Addonkombinationen behauptet.

---

# Hanse Cast 1.0.4

- Ziel & Fokus: „in Arbeit“, Menü gesperrt, Laufzeit und Blizzard-Ersatz deaktiviert.
- Alte Profilwerte bleiben erhalten. Spieler/GCD unverändert verfügbar.
- Separate kompakte Ziel-/Fokusleisten geplant, noch nicht umgesetzt.
- Target/focus disabled in menu and runtime; prior profile values retained.
- `/reload` erforderlich. Auf GitHub und CurseForge veröffentlicht; vollständige native Prüfung offen.

---

# Hanse Cast 1.0.3

- Ziel und Fokus übernehmen die eingestellte Schriftart und Schriftgröße des aktiven Profils für Namen, Zeit und Unterbrechbarkeit. Die automatische Mindestgröße aus 1.0.2 entfällt. Unterschiedliche Leistenskalierungen bleiben erhalten.
- Gemeinsame Schriftanwendung mit der Spielerleiste; Menü erklärt den gemeinsamen Geltungsbereich.
- Target and focus now use the selected profile font and size for all cast labels. Removed the automatic physical minimum from 1.0.2. Individual bar scales remain intact.
- `/reload` genügt / is sufficient. Native Sichtprüfung der Korrektur offen. Kein Veröffentlichungsupload.

---

# Hanse Cast 1.0.2

## Deutsch

- Ziel/Fokus: native Dauerobjekt-Anzeige als Rückfall bei fehlenden lesbaren Zeitdaten. Schlichte farbige Timerleiste an gespeicherter Position; keine errechnete Restzeit aus geschützten Daten.
- Unabhängiger Blizzard-Zielersatz nur bei sichtbarer eigener Leiste, mit sicherem Rückfall. Namensplaketten/Leben/Mana bleiben erhalten.
- Menü zeigt nur die Ersatzoption der ausgewählten Einheit. Ziel-/Fokusschrift berücksichtigt kleine physische UI-Skalierung.
- Status nennt getrennte Einheitszustände, Abfrage-/Timergründe und Fehlerzähler. Begrenzte Wiederholungsabfragen erkennen verpasste Ziel-/Fokusstarts.
- Begleitaddon Duration Lab 0.1.1: eindeutige AN-/Ausschalten-Beschriftung.
- 28 lokale Testsuiten und separate Lab-Prüfung bestanden; installiert und per SHA-256 bestätigt.
- Vollständiger WoW-Neustart erforderlich (neues Lua-Modul). Einstellungen bleiben erhalten. Exporte mit hideBlizzardTarget benötigen mindestens 1.0.2. Native Spielprüfung offen; keine Veröffentlichung.

## English

- Added native duration fallback for target/focus with unreadable classic timing: plain tinted bar, saved placement, no guessed countdown.
- Added independent target cast-bar replacement, contextual options, readable unit text and per-unit diagnostic counters.
- Bounded recovery queries detect missed unit starts. Nameplates/health/power remain unaffected.
- Companion Duration Lab 0.1.1 clarifies ON and the disable command.
- Fully restart WoW for the new module. Existing settings remain intact; new profile exports require 1.0.2. Native validation pending; not published.

---

# Hanse Cast 1.0.1

## Deutsch

- Überlagerung der Hanse-Fokuscastbar durch die Blizzard-Castbar behoben: eigener Fokus-Ersatz mit sicherem Rückfall, standardmäßig eingeschaltet.
- Neue Option unter Ziel & Fokus → Fokus; Lebens-/Manabalken bleiben sichtbar.
- Diagnose ergänzt den Fokus-Ersatzstatus. Profile übernehmen die neue Option; bestehende Einstellungen bleiben erhalten.
- 27 lokale Testsuiten bestanden. Native Spielprüfung noch offen. Keine Veröffentlichung erfolgt.

Bestehende Profile und ältere Exporte können importiert werden. Neue Exporte enthalten `hideBlizzardFocus` und sind nicht für den Import in ältere Addon-Versionen vorgesehen.

## English

- Added independent focus cast-bar replacement to prevent overlap with the visible Hanse bar, with native fallback; enabled by default.
- Added a focus setting and diagnostic status. Health/power bars are unaffected.
- Existing profiles/imports migrate; exports containing the new field require 1.0.1 or newer.
- 27 local test suites passed. Native gameplay validation remains pending; not published.

---

# Hanse Cast 1.0.0

## English

Release for **WoW Forever 1.60.1 / Interface 16001**. Changes since the public 0.9.1 beta:

- Rebuilt settings inside WoW Settings → AddOns: four compact tabs, native-style controls, hover explanations, and expandable advanced settings.
- Added an independent animated menu sample using the original cast-bar artwork, plus a positioning toolbar that returns to settings.
- Added a quick profile selector and clearer profile import, export, copy, reset and delete workflows.
- Prevented unfinished numeric edits from being applied to a different unit or profile after switching context.
- Bound profile imports to the exact checked text and active profile; closing or switching settings windows invalidates stale input.
- Fixed movement cleanup when a real cast, channel or combat interrupts a draggable preview. Late drag events no longer save an unintended position.
- Made the optional class accent colour affect secondary light layers while preserving the original main artwork and neutral appearance.
- Added bounded recovery for temporarily unavailable spell icons on player, target and focus bars.
- Reduced redundant visibility updates for disabled optional player-bar elements.

**Updating:** keep your SavedVariables. Existing profiles, settings and HANSECAST:1 exports remain compatible. No additional addon is required; Hanse Cast Check is not included.

**Known limits:** accessible cast data is required; fully restricted duration objects and empower casts are unsupported. Channel guides are manual markers. The menu sample is a scaled artwork preview rather than an exact preview of every text/icon option. Local automated checks do not cover every native-client, spell or addon combination. Other WoW editions are not supported by this package.

## Deutsch

Release für **WoW Forever 1.60.1 / Interface 16001**. Änderungen seit der öffentlichen Beta 0.9.1:

- Einstellungen direkt unter WoW Optionen/Einstellungen → AddOns überarbeitet: vier kompakte Reiter, Bedienelemente im WoW-Stil, Erklärungen beim Darüberfahren und ausklappbare Zusatzoptionen.
- Unabhängige animierte Menüvorschau mit den Originalgrafiken sowie Positionierungsleiste mit Rückkehr zu den Einstellungen ergänzt.
- Schnelle Profilauswahl und verständlichere Abläufe für Import, Export, Kopieren, Zurücksetzen und Löschen ergänzt.
- Verhindert, dass noch nicht bestätigte Zahlen nach einem Wechsel bei der falschen Einheit oder im falschen Profil landen.
- Profilimporte an den exakt geprüften Text und das aktive Profil gebunden; veraltete Eingaben werden beim Schließen oder Fensterwechsel verworfen.
- Verschieben wird zuverlässig beendet, wenn ein echter Zauber, eine Kanalisierung oder Kampf die Vorschau unterbricht. Verspätete Zieh-Ereignisse speichern keine ungewollte Position mehr.
- Optionale Klassenakzente wirken nun auf Nebenlichter. Hauptgrafik und neutrale Darstellung bleiben erhalten.
- Zeitweise nicht verfügbare Zaubersymbole können sich bei Spieler-, Ziel- und Fokusleisten mit begrenzten Wiederholungen erholen.
- Überflüssige Sichtbarkeitsaufrufe für abgeschaltete Zusatzelemente der Spielerleiste reduziert.

**Update:** SavedVariables behalten. Bestehende Profile, Einstellungen und HANSECAST:1-Exporte bleiben kompatibel. Keine zusätzlichen Addons erforderlich; Hanse Cast Check ist nicht enthalten.

**Bekannte Grenzen:** Zugängliche Zauberdaten sind erforderlich; vollständig geschützte Dauerobjekte und Empower-Zauber werden nicht unterstützt. Kanal-Hilfslinien sind manuelle Markierungen. Die Menüvorschau zeigt die verkleinerte Grafik, nicht jede Text-/Symboloption exakt. Lokale automatische Tests decken nicht jede Kombination aus Spielclient, Zauber und weiteren Addons ab. Andere WoW-Ausgaben werden von diesem Paket nicht unterstützt.

---

# 0.10.1 — Compact native-style settings (beta)

- Four compact horizontal tabs: Player, Target & focus, Profiles and Help.
- Native red action buttons, gold labels, compact selection controls and hover explanations.
- Frequent player settings on one page; additional controls expand on demand.
- Independent animated menu preview uses the original artwork and shared renderer; no live-bar repositioning or synthetic gameplay events.
- Quick profile selector; existing profile data and import/export formats retained.
- Preview animation stops when hidden, on other tabs and in combat.

# 0.10.0 — Settings redesign (beta)

- Full settings canvas inside WoW Settings → AddOns, with seven pages and German/English explanations.
- Direct selection lists, checkboxes, sliders and validated numeric fields.
- Shared state across native settings and fallback window; existing profiles and HANSECAST:1 exports retained.
- Named confirmation dialogs and atomic import as a new profile.
- Player/target/focus positioning toolbar with explicit return and combat cleanup.
- Existing 0.9.1 SavedVariables remain compatible. Do not delete saved settings.

# Hanse Cast 0.9.1 · Beta

## English

Initial public beta package for WoW Forever 1.60.1.

- 145 selectable visual variants across nine class-inspired groups and Alliance/Horde styles.
- Ten faction-inspired variants added in 0.9.1.
- Player casts and channels, separate GCD display, and optional target/focus bars.
- Named profiles, text import/export, German/English controls and display options.
- Restricted-data checks and fallback behavior for unavailable information.
- Final Hanse Cast logo in the addon list, with installation, license and credit documents included.

Known limits: channel guide lines are manual; fully restricted duration objects are not displayed directly; empower casts are unsupported. Initial live-game performance comparisons and persistence of the tested settings after reload/restart have been checked. Broader functional coverage remains part of beta testing.

## Deutsch

Erstes öffentliches Betapaket für WoW Forever 1.60.1.

- Zehn Allianz- und Horde-Varianten ergänzen die Klassenoptiken; insgesamt 145 auswählbare Grafikvarianten.
- Spielerzauber und Kanalisierungen, separate GCD-Anzeige und optionale Ziel-/Fokusleisten.
- Benannte Profile mit Textimport/-export sowie deutsche und englische Bedienung.
- Zugriffsschutz und Rückfallverhalten bei nicht verfügbaren Informationen.
- Endgültiges Hanse-Cast-Logo in der Addonliste sowie Installations-, Lizenz- und Herkunftshinweise im Paket.

Bekannte Grenzen: manuelle Kanal-Hilfslinien, keine direkte Darstellung vollständig geschützter Dauerobjekte, keine Empower-Zauber. Erste Leistungsvergleiche und das Speichern der geprüften Einstellungen nach Reload/Neustart sind überprüft. Weitere Funktionsbereiche bleiben Teil der Betaprüfung.
