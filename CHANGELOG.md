# Retail 1.0.8-retail-alpha.2 / Forever packaging audit

- Retail: compact target/focus bars now retain Blizzard for Empower, inaccessible Empower flags and failed channel metadata. Empower events trigger reconciliation; regression tests cover fallback and recovery.
- Both ZIPs include user documentation, license and credits with file hashes. Retail packaging uses a temporary archive and verifies every member before replacing the final ZIP.
- Forever runtime remains 1.0.8-alpha.1. Native acceptance is still pending for both variants. Full Retail guide: docs/public/RETAIL.md; Forever update: docs/public/RELEASE-1.0.8.md.

---

# Hanse Cast 1.0.8-alpha.1 / Retail 1.0.8-retail-alpha.1

- Erstinstallation: Optik nach aktiver Spezialisierung bzw. Forever-Talentpunkten; Blizzard-Spielerleiste ausblenden an; automatische Optik nach Zauber weiterhin optional und aus.
- Bestehende Einstellungen bleiben erhalten. Blizzard bleibt Rückfall bei nicht darstellbaren Zaubern.
- Forever: Krieger-Zerschmettern und Schurken-Werkzeugcasts ergänzt; vorhandene Priester-, Druiden-, Schamanen- und weitere Klassenwechsel geprüft.
- Retail: eigener Zauberkatalog für alle 13 Klassen, zusätzliche Klassenkategorien mit vorhandenen Material-Aliasen, einschließlich Verschlinger.
- First install now chooses specialization artwork, enables safe Blizzard player-bar replacement, and leaves per-spell switching off. Existing settings are preserved. Retail has a separate 13-class catalog; additional class labels reuse shipped art.
- Mocktests ersetzen keine Ingame-Abnahme. Details: docs/public/AUTO-SPELL-VISUALS.md.

---

# Hanse Cast 1.0.7

## Deutsch

- Behebt die Buildsperre der kompakten Ziel- und Fokusleisten nach dem WoW-Forever-Update auf 1.60.1 Build 70888.
- Build 70862 bleibt unterstützt. Andere Builds und Interface-Versionen werden weiterhin abgewiesen.
- Schutzprüfungen, Blizzard-Rückfallanzeige, Optiken und gespeicherte Einstellungen bleiben unverändert.

Für WoW Forever 1.60.1 / Interface 16001. Nach dem Update WoW neu starten. SavedVariables nicht löschen; das separate Compact Lab wird nicht benötigt.

Prüfstand: automatisierte Tests mit simulierten WoW-Schnittstellen. Die Buildsperre wurde mit der vorherigen Version im Spiel bestätigt; die korrigierten Ziel-/Fokusleisten sind auf Build 70888 noch nicht im Spiel abgenommen.

## English

- Fixes the build restriction disabling compact target and focus bars after the WoW Forever 1.60.1 build 70888 update.
- Build 70862 remains supported. Other builds and interface versions are still rejected.
- Secrecy checks, Blizzard fallback, artwork and saved settings are unchanged.

For WoW Forever 1.60.1 / Interface 16001. Restart WoW after updating. Do not delete SavedVariables; the separate Compact Lab is unnecessary.

Validation: automated tests using mocked WoW APIs. The previous version's build rejection was confirmed in game; the updated target/focus bars have not yet received in-game acceptance on build 70888.

---

# Hanse Cast 1.0.6

## Deutsch

- Kompakte Ziel- und Fokusleisten direkt im Hauptaddon: drei klassenunabhängige Designs mit schwarzem Rahmen, eigener Vorschau und getrennter Positionierung. Auch ausgewählte Begleiter werden in diesen beiden Slots unterstützt.
- Gemeinsame Hauptfarbe über den WoW-Farbwähler oder zehn benannte Farbfelder; Vorschau mit Bestätigung/Abbrechen. Farbcode nur optional.
- Restzeit wahlweise ausgeblendet, rechts in der Leiste oder rechts daneben. Fehlende zulässige Zeitdaten werden als Strich angezeigt, niemals geschätzt.
- Blizzard-Ziel-/Fokuszauberleisten getrennt ausblendbar, solange die eigene Anzeige verfügbar ist. Bei fehlenden Daten bleibt Blizzard als Rückfall verfügbar.
- Überarbeitete Heilig-/Disziplin-Grafiken, verständlichere Einstellungsrückmeldungen und dauerhaft erreichbare Positionierknöpfe.
- Verbesserte GCD-Anzeige, Diagnosebericht und Profilverwaltung sowie Korrekturen bei Zauberereignissen und Fehlerbehandlung.

Für WoW Forever 1.60.1 / Interface 16001; kompakte Einheitenanzeigen derzeit auf Build 70862 begrenzt. Keine Retail-/Empower-Unterstützung oder automatische Kanaltick-Erkennung. Ziel/Fokus-Einstellungen gelten gemeinsam über Spielerprofile hinweg. Nach dem Update WoW vollständig neu starten; Einstellungen bleiben erhalten. Ein separates Compact Lab wird nicht benötigt und sollte deaktiviert werden.

Der alpha.10-Stand wurde vom Nutzer allgemein bestätigt. 54 automatisierte Testsuiten prüfen simulierte Schnittstellen; keine vollständige Abdeckung jeder Klasse und Addonkombination. Der finale Paketnachweis wird separat mitgeliefert.

## English

- Integrated compact target and focus cast bars: three class-independent designs with black borders, previews and separate positioning. Selected pets work in these two unit slots.
- Shared main color using the native WoW color picker or ten named swatches; preview with confirm/cancel. Hex entry is optional.
- Optional remaining time inside right or outside right. Unavailable permitted time data shows a dash instead of an estimate.
- Separate options to hide Blizzard target/focus cast bars while Hanse can display the cast; native fallback remains available when data or artwork fails.
- Revised Holy/Discipline artwork, clearer setting feedback and persistent positioning buttons.
- Improved GCD display, diagnostic report and profile handling, with cast-event and error-handling corrections.

For WoW Forever 1.60.1 / Interface 16001; compact unit bars currently require build 70862. No Retail/empower support or automatic channel tick detection. Target/focus preferences are shared across player profiles. Fully restart WoW after updating; saved settings are preserved. The separate Compact Lab is unnecessary and should be disabled.

The user accepted the alpha.10 build overall. 54 automated suites cover simulated interfaces, not every class or addon combination. Final package evidence is supplied separately.

---

# Hanse Cast 1.0.6-alpha.10 – optionale Restzeit, unveröffentlicht

- Ziel/Fokus: Restzeit wahlweise aus, rechts in der Leiste oder rechts daneben. Gemeinsame gespeicherte Einstellung mit passender Menü-/Positioniervorschau.
- Innen reservierter Textbereich; außen zusätzliche Breite in der Menüvorschau. Gleiche Schriftgröße wie der Zaubername.
- Restdauer aus zugänglichem Dauerobjekt direkt nativ formatiert, alternativ ausschließlich frei lesbare Endzeitstempel. Bei fehlenden Daten **—** statt Schätzung; Diagnose nennt den Datenweg.
- [Prüfung und Spieltest](docs/TIME-ALPHA10.md). Keine Veröffentlichung.

---

# Hanse Cast 1.0.6-alpha.9 – schwarzer Kompaktrahmen, unveröffentlicht

- Alle drei Ziel-/Fokusdesigns erhalten einen schlichten, deckend schwarzen Rahmen statt des graublauen Metallrands. Zwei UI-Einheiten innerhalb der bisherigen Außenmaße; Füllfläche und Schriftposition bleiben erhalten.
- Menüvorschau und Liveanzeige verwenden denselben Rahmen. Die Trennlinie bei Design 4 ist ebenfalls schwarz.
- Farbauswahl von alpha.8 vom Nutzer im Spiel bestätigt. Priester und Spielerleiste unverändert.
- [Prüfung und kurzer Spieltest](docs/FRAME-ALPHA9.md). Keine Veröffentlichung.

---

# Hanse Cast 1.0.6-alpha.8 – visuelle Farbauswahl, unveröffentlicht

- „Farbe wählen …“ öffnet den WoW-Farbwähler mit der aktuellen gemeinsamen Ziel-/Fokusfarbe. Livevorschau, Bestätigung und Abbrechen sind getrennt; Vorschaufarben gelangen nicht durch andere Einstellungen in die gespeicherten Werte.
- Zehn anklickbare Farbfelder mit Namen im Tooltip und Auswahlrahmen. Konkrete Rückmeldung direkt unter den Reitern, beispielsweise „Hauptfarbe gespeichert: Türkis“. Farbcode bleibt nur als optionale präzise Eingabe.
- Menü-/Reiterwechsel und Kampfbeginn verwerfen die offene Farbauswahl. Ein bereits fremd belegter WoW-Farbwähler wird nicht übernommen. Moderne und ältere Schnittstelle werden nach Verfügbarkeit unterstützt.
- Priester Heilig und Disziplin bleiben wie vom Nutzer vorerst abgenommen. Keine neuen Grafiken.
- [Änderungen, Prüfnachweise und Spieltest](docs/COLOR-ALPHA8.md). Keine Veröffentlichung.

---

# Hanse Cast 1.0.6-alpha.7 – verständliche Einstellungen und zurückhaltendere Grafik, unveröffentlicht

- Feste Rückmeldung direkt unter den Reitern mit Einstellungsname und übernommenem Wert; konkrete Hinweise bei ungültigen Eingaben. Positionierung meldet gespeichert oder unverändert.
- Ziel-/Fokus-Positionierung und Vorschau-Neustart dauerhaft rechts neben der Menüvorschau statt versteckt im Scrollbereich.
- Weicher vorgefilterte kompakte Materialien, weniger harte Lichtadern, abgeschaltetes Pixelraster-Snapping und Schrift mit Schatten statt kräftiger Outline.
- Heilig-/Disziplin-Impuls gezielt schlanker und weniger deckend; andere Priesterkategorien bleiben erhalten.
- [Änderungen und kurzer Test](docs/QUALITY-ALPHA7.md). Keine Veröffentlichung; native Sichtprüfung offen.

---

# Hanse Cast 1.0.6-alpha.6 – Qualitätskorrektur für Priester und Einheiten, unveröffentlicht

- Ziel und Fokus erhalten getrennte Blizzard-Schalter und getrennt gespeicherte Positionen. Positionieren mit künstlicher Vorschau, Fertig/Speichern und Abbrechen; Kampf verwirft ungespeicherte Änderungen.
- Drei eigenständig ausgearbeitete kompakte Materialien mit feinem Rahmen und neutralen hellen Lichtadern. Menü und Liveanzeige verwenden dieselbe Komposition. Beide Füllebenen erhalten denselben nativen Timer direkt; Fehler stellen Blizzard wieder her.
- Zehn erneuerte Heilig-/Disziplin-Master und 40 exportierte Körper-/Glow-Dateien. Klarere Lichtschichten, passend normalisierte Körperhöhe, überarbeitete Nebelschleier und korrigierte Disziplin-Farbpalette.
- Bericht ergänzt gespeicherte Einheitenpositionen, Positioniermodus, Grafikstatus und beide Blizzard-Einstellungen. Aktuelle Status-/Übergabedokumente bereinigt; alte Zwischenstände archiviert.
- Zusätzliche Tests decken native-ähnliche Menü-/Toolbarcallbacks, Dragabbruch im Kampf, tatsächliche Texturablehnung, Blizzard-Fadebereinigung und Ablehnung der zweiten Timerübergabe ab. Unabhängiger Review ohne offene Blocker.
- Native visuelle Abnahme bleibt offen. [Gebündelter Spieltest](docs/TEST-ALPHA6.md), [aktueller Installationsstand](docs/RELEASE-STATUS.md). Keine Veröffentlichung.

---

# Hanse Cast 1.0.6-alpha.5 – Startfehler und Vorschau korrigiert, unveröffentlicht

- Schriftinitialisierung vor erstem Textzugriff der kompakten Leisten. Optionaler Kompaktstart kann Spielerereignisse, Slashbefehle und Diagnose nicht mehr abbrechen.
- Wiederholung vervollständigt einen teilweise aufgebauten Ziel-/Fokuspool. Verzögerter Start nach Kampfende aktualisiert die Diagnose.
- Eigene eingebettete Ziel-/Fokusvorschau in beiden Menühosts, ohne Umschalten echter Timer. Tabwechsel und Schließen räumen die Vorschau auf.
- Strengere Start-/Font-/Fehlerprüfungen und Tests für die tatsächliche Menü-Elternbeziehung ergänzen die bisher zu permissive Simulation.
- Native Bestätigung steht aus; keine Veröffentlichung.

---

# Hanse Cast 1.0.6-alpha.4 – Ziel/Fokus integriert, unveröffentlicht

- Kompakte Ziel-/Fokusleisten im Hauptaddon und direkt im normalen Menü verfügbar. Drei Designs, Hauptfarbe, Maße, Schrift und Vorschau; unabhängig von der Spielerleiste.
- Standardmäßig aktiviert, Aktivierung und Einstellungen bleiben nach Reload erhalten. Kein separates Testaddon oder manueller Live-Befehl mehr erforderlich.
- Alte große Ziel-/Fokusimplementierung bleibt gesperrt; Diagnose und Menü beziehen sich jetzt auf den neuen Kompaktpfad.
- Keine Veröffentlichung. Blizzard-Leisten bleiben zusätzlich sichtbar; numerische Restzeit, Icons und freie Positionierung noch offen.

---

# Hanse Cast 1.0.6-alpha.3 – Priester-Grafiken, unveröffentlicht

- Heilig und Disziplin erhalten jeweils fünf unabhängig gezeichnete Licht-/Schutzmaterialien nach freigegebenem Konzept. Zehn neue Master, 40 gezielt ersetzte Körper-/Glow-Dateien.
- Schatten, andere Klassen und Spieler-/GCD-Logik bleiben unverändert. Noch keine native Abnahme der neuen Grafiken und keine Installation dieser Version.
- Separat: Compact Lab 0.2.0 mit Klassik, Seidenkern und Geteilter Anzeige, frei wählbarer Hauptfarbe und denselben Designs für alle Klassen/Specs. Ausschließlich Ziel/Fokus einschließlich ausgewählter Begleiter; keine zusätzlichen Pet-/Ziel-des-Ziels-Leisten. Nicht im Hauptaddon enthalten.
- Keine Veröffentlichung; Ziel/Fokus im Hauptaddon bleiben in Arbeit.

---

# Hanse Cast 1.0.6-alpha.2 – GCD und Diagnose, unveröffentlicht

- Normale GCD-Abfrage und Dauerobjekt-Abfrage unabhängig ausgewertet; eingeschränkte normale Daten verhindern nicht mehr den zweiten Weg.
- Eigener nativer GCD-Timerbalken für eingeschränkte Zeitwerte, getrennt von lesbaren Daten/Vorschau. Keine geratene Dauer und kein zusätzlicher Lua-Pollingtreiber; im nativen Pfad kein bleibender Hintergrund oder GCD-Text.
- Getrennte Spieler-/GCD-Zähler, Datenwege je GCD-Prüfzauber, native Annahme/Ablehnung und Alter des zuletzt gelesenen Zustands im Bericht.
- 43 automatisierte Testsuiten bestanden. Sichtbarkeit, Ablauf und verschwundene Füllung im echten Kampf anschließend vom Nutzer bestätigt; native Übergabe allein ist keine Freigabe.
- Keine Veröffentlichung; Ziel/Fokus bleiben deaktiviert.

---

# Hanse Cast 1.0.6-alpha.1 – lokale Entwicklung, unveröffentlicht

- Neuer Zauberstart mit sicherer Kennung beendet den Feedbackbesitz des vorherigen Zaubers auch bei eingeschränkten oder zunächst fehlenden Zeitdaten. Verspätete Fehler-/Erfolgsmeldungen gehören nicht mehr zur neuen Rückfallanzeige.
- Profilimport zeigt vor Anwendung Werte, Standardergänzungen, Unterschiede und Darstellungsgröße. Verständliche Fehlermeldungen auf Deutsch/Englisch.
- Inhaltsgebundene, einmalige Bestätigungen verhindern Löschen oder Überschreiben nach zwischenzeitlichen Profiländerungen.
- Beschädigte aktive Profilkennung erhält bestehende benannte Profile, auch bei voller Liste. Profile lassen sich ohne zusätzlichen Platz umbenennen.
- Kopierbarer Diagnosebericht und freiwillige Aufzeichnung der letzten 80 Ereignisse, ohne Namen, Ereignisargumente oder persistente Speicherung.
- Ziel/Fokus bleiben deaktiviert; experimentelle kompakte Leisten und Kanaldaten werden getrennt entwickelt und nicht im Hauptaddon aktiviert.
- Gemeinsamer Paketlauf und native Prüfung werden getrennt dokumentiert. Keine neue Veröffentlichung auf GitHub oder CurseForge.

---

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
