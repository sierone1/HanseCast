# Klassenoptik und optionale Zauberautomatik

Stand 12.11.2026: Forever **1.0.8-alpha.1**, Retail **1.0.8-retail-alpha.2**. Native Abnahme ausstehend.

## Erstinstallation

Ohne vorhandene SavedVariables wählt Hanse Cast die Optik passend zur aktiven Spezialisierung. In Forever wird ersatzweise der Talentbaum mit den meisten tatsächlich investierten Punkten verwendet. Bei Gleichstand gewinnt der erste dieser Bäume; ohne lesbare Talentdaten wird eine Klassen-Grundoptik gewählt (Magier: Frost). Eine fehlende API wird nicht als bestätigte Skillung ausgegeben.

„Blizzard-Spielerleiste ausblenden“ ist standardmäßig an. Sie wird nur unterdrückt, solange Hanse Cast den aktuellen Zauber tatsächlich darstellen kann. Geschützte Daten, fehlende Grafiken und Retail-Empower behalten die Blizzard-Rückfallanzeige. Ziel/Fokus haben weiterhin separate Einstellungen.

„Optik nach Zauber“ ist standardmäßig **aus**. Damit bleibt etwa beim Schattenpriester die Schattenoptik auch bei einem Heilzauber bestehen. Mit eingeschalteter Option wechselt das Material für bekannte, lesbare Cast-/Kanal-IDs; die gespeicherte Grundoptik bleibt erhalten. Nach dem Zauber kehrt die Grundoptik zurück. Vorschau und ausdrücklich gewählte Fraktionsmotive bleiben fest.

Bestehende Einstellungen und Profile werden nicht neu vorbelegt. Die Erstauswahl findet einmal pro neuer SavedVariables-Datei statt, nicht bei jedem Login, Charakterwechsel oder Umskillen. Die bisherigen Einstellungen sind kontoweit; eigene Charakteroptiken lassen sich über Profile speichern. Ein frischer Twink bekommt daher bei bereits vorhandenen Einstellungen keine ungefragte neue Auswahl.

## Klassenprüfung

| Klasse | Forever: hinterlegte Cast-/Kanalgruppen | Retail: zusätzliche bzw. getrennte Zuordnungen |
|---|---|---|
| Magier | Frost, Feuer, Arkan mit Ranglisten | Eigener Katalog, zusätzlich Gletscherstachel |
| Priester | Schatten: Gedankenschlag/-schinden/-kontrolle; Heilig: Heilungen, Heiliges Feuer, Göttliche Pein; Disziplin: Sühne | Sühne 47540 und Machtwort: Glanz → Disziplin; Dunkle Zurechtweisung/Leerenstoß → Schatten; Vampirberührung, Leerenstrom und weitere Schattenzauber ergänzt |
| Druide | Gleichgewichtsschaden / Naturheilung | Aktuelle Zorn-/Sternenfeuer-IDs, Mondphasen, Sterneneruption, Wildwuchs; Convoke bleibt wegen gemischter Magie unklassifiziert |
| Schamane | Elementarschaden / Heilung | Retail-Blitzschlag/Kettenblitz, Lavaeruption, Heilender Regen, Heilende Woge/Welle und weitere Casts |
| Paladin | Heiliges Licht, Lichtblitz, Erlösung | Eigenständige aktuelle Basiscatalog-Zuordnung |
| Hexenmeister | Gebrechen, Zerstörung, Dämonenbeschwörungen | Chaosblitz, Verbrennen, Dämonenblitz, Hand von Gul'dan, Tyrann, instabiles Gebrechen, Kanäle |
| Jäger | Gezielter Schuss, Forever-Sniper, Salve | Zuverlässiger Schuss, Schnellfeuer und Retail-Sniper |
| Krieger | Neu: Zerschmettern einschließlich Forever-Verbesserungs-Overrides → Waffenmotiv | Zerschmetternder Wurf → Waffenmotiv |
| Schurke | Neu: Schlossknacken/Falle entschärfen → Täuschungsmotiv | Zusätzlich Giftauftrag → Meuchelnmotiv |
| Todesritter | Im Forever-Katalog nicht vorgesehen | Bluttrinker → Blut; Schwarzes Tor, Untote kontrollieren, Geistwanderung → Unheilig |
| Mönch | Im Forever-Katalog nicht vorgesehen | Heilkanäle/-casts → Nebelwirker; Furorfäuste, Jadeknistern, Wirbelnder Kranichtritt → Windläufer |
| Dämonenjäger | Im Forever-Katalog nicht vorgesehen | Augenstrahl/Teufelsbeschuss → Verwüstung; Teufelsverwüstung → Rachsucht; Verschlinger-Casts → Verschlinger |
| Rufer | Im Forever-Katalog nicht vorgesehen | Lebende Flamme → Rot, Desintegration → Blau, Smaragdgrüne Zwiesprache → Grün, Zeitmagie → Bronze, Eruption/Ebenenmacht → Schwarz |

Die Motive sind gestalterische Zuordnungen, keine Behauptung über die aktuelle Charakterspezialisierung. Ein Disziplinpriester kann mit aktivierter Automatik eine Schattenleiste für Gedankenschlag und eine Heiligleiste für Blitzheilung sehen. Derselbe Zauber erhält nicht je nach Talentbaum eine andere behauptete Schule.

Für Todesritter, Mönch, Dämonenjäger und Rufer existieren nun eigene Retail-Menükategorien und Erstauswahlen. Sie verwenden ausdrücklich vorhandene passende Grafiken als Material-Aliase: etwa Blut → rotes Furormotiv, Nebelwirker → Wiederherstellungsmotiv, Verschlinger → Schattenmotiv, rote/blaue Drachenmagie → Feuer/Frost. Das sind keine neu illustrierten Klassenmotive. Alle fünf Materialfamilien und die vorhandenen Größen bleiben verfügbar.

## Grenzen

- Eine Zuordnung erzeugt niemals selbst eine Zauberleiste. Sofortzauber, Nahkampftreffer und passive Schadensereignisse werden nicht zu künstlichen Casts.
- Unbekannte IDs, neue ungeprüfte Ränge und geschützte IDs behalten die gewählte Grundoptik. Nicht jeder jemals existierende Zauber ist katalogisiert.
- Retail und Forever besitzen getrennte Kataloge. Forever-Overrides werden nicht pauschal in Retail verwendet.
- Retail-Empower wird weiterhin von Blizzard angezeigt. Eine Zuordnung ist kein Ersatz für die fehlende eigene Empower-Anzeige.
- Ziel-/Fokusleisten sind weiterhin kompakte, separat gestaltete Anzeigen; diese Option steuert die Spielerleiste.

## Nachweise und Entwicklung

`tests/test_class_automation.py` prüft 27 Forever-Talentbaumfälle und alle 40 Retail-Spezialisierungen einschließlich Wächter und Verschlinger, tatsächliche Controller-/Materialwechsel, alle fünf Grafikfamilien der Retail-Erstauswahl, vorhandene Assets, optionale Automatik, vorhandene Einstellungen sowie unbekannte/geschützte IDs. `tests/test_spell_visuals.py` bleibt die Rang-/API-Tupelregression des Forever-Katalogs. Beide Packager berücksichtigen die neue Klassenprüfung.

Maßgebliche Quellen: `HanseCast/FirstRun.lua`, `SpellVisuals.lua`, `Themes.lua`, `Effects.lua`, `App.lua`, `retail/RetailSpellVisuals.lua`, `RetailThemes.lua`. Das JSON `docs/public/AUTO-SPELL-SOURCES.json` hält die geprüften externen Dateien und Blob-Hashes fest.

Datengrundlage: bisherige festgehaltene Forever-Simulator-/SpellCalc-Daten plus erneut gelesene Krieger-/Schurkenquellen; Retail-IDs aus den Originalimplementierungen von Hekili (historischer TWW-Stand, belegt Identitäten, nicht aktuelle Verfügbarkeit) und für Verschlinger aus SimulationCrafts Midnight-Quellen. Aktuelle Spezialisierungs-API anhand des Blizzard-UI-Quellspiegels geprüft. Keine fremde Rotationslogik übernommen. Verfügbarkeit, Secret-Value-Verhalten und tatsächliche Events im installierten Client müssen im Spiel geprüft werden.

## Ingame-Abnahme

1. In einer gesicherten Testkonfiguration ohne SavedVariables mit Schattenpriester anmelden: Schatten gewählt, Zauberautomatik aus, Blizzard-Ausblendung an. Ein Heilzauber bleibt im Schattenmotiv.
2. Automatik aktivieren: Gedankenschlag/-schinden → Schatten, Blitzheilung → Heilig, Sühne → Disziplin. In Retail zusätzlich Dunkle Zurechtweisung → Schatten prüfen.
3. Beim Druiden Schaden ↔ Heilung und beim Schamanen Blitzschlag ↔ Kettenheilung testen, jeweils auch Kanalabbruch, schnelle Folge und Kampf.
4. Für jede Klasse die obigen vorhandenen Casts, niedrige/hohe Forever-Ränge sowie neue Retail-Overrides prüfen. Sofortfähigkeiten dürfen keine Castbar erzeugen.
5. Bei deaktivierter Automatik bleibt das vorausgewählte Motiv fest. Speichern, Reload, Profilwechsel und bestehende bewusst deaktivierte Blizzard-Ausblendung müssen erhalten bleiben.
6. Geschützte Daten/fehlende Darstellung und Evoker-Empower: Blizzard muss sichtbar bleiben. Erst nach diesen Tests eine Releasefreigabe erteilen.
