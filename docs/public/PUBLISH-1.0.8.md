# Veröffentlichung 1.0.8 – GitHub und CurseForge

Vorbereitet am 12.11.2026. Bestehendes CurseForge-Projekt **Hanse Cast** weiterverwenden: https://www.curseforge.com/wow/addons/hanse-cast . Kein zweites Projekt nur für den Retail-Spielzweig anlegen. Hanse Mark ist von diesem Release nicht betroffen.

## Upload-Felder

| Feld | Forever | Retail |
|---|---|---|
| Datei | `HanseCast-1.0.8.zip` | `HanseCast-1.0.8-retail.zip` |
| Anzeigename | Hanse Cast 1.0.8 - Forever | Hanse Cast 1.0.8 - Retail |
| Release Type | Release | Release |
| Spielzweig | Forever | Retail |
| Spielversion | 1.60.1 | 12.1.5 |
| TOC Interface | 16001 | 120105 |
| Changelog (Markdown) | `CURSEFORGE-CHANGELOG-FOREVER.md` | `CURSEFORGE-CHANGELOG-RETAIL.md` |
| Erforderliche Abhängigkeiten | Keine | Keine |

Nur die jeweils passende Spielversion markieren. Nicht beide Zweige auf dasselbe ZIP setzen. Falls die passende Version im Formular fehlt, keine unpassende als Ersatz wählen; Versionszuordnung beim Portal klären. Die aktuelle Dropdownliste konnte wegen verweigertem Opera-Zugriff nicht eingesehen werden.

Projektname **Hanse Cast** beibehalten (ohne Versionsnummer oder Spielzweig). Summary: **Animated cast bars with class-inspired artwork, profiles and compact target/focus bars for Forever and Retail.** Beschreibung im Markdown-Editor aus `CURSEFORGE-DESCRIPTION.md` übernehmen. Englisch steht vor Deutsch. Bestehende passende Kategorien beibehalten; vorgeschlagen Unit Frames und Combat. Lizenz: All Rights Reserved. Quellcode und Issue-Tracker in die vorgesehenen Projektfelder eintragen. Keine Downloadlinks zu externen ZIPs in die Beschreibung aufnehmen.

## Ablauf in CurseForge

1. Bestehendes Hanse-Cast-Projekt im Autorenbereich öffnen; Summary/Beschreibung aktualisieren, Galerie und ausgewähltes Logo beibehalten.
2. Unter Files → Upload die Forever-ZIP wählen, Forever/1.60.1 und Release setzen, zugehöriges Changelog einfügen und absenden.
3. Vorgang für die Retail-ZIP mit Retail/12.1.5 wiederholen. Jeder Upload ist eine eigene Hauptdatei für seinen Zweig, kein Zusatzarchiv zum anderen ZIP.
4. Nach Upload Dateinamen, Spielzweig, Version und Status kontrollieren. „Under Review“ ist noch keine Freigabe. Nach Moderation beide zweigspezifischen Downloads prüfen.
5. Bei Ablehnung den angegebenen Grund im bestehenden Eintrag bearbeiten; nicht durch Löschen und erneutes Hochladen umgehen.

Die beiden Addon-ZIPs enthalten ausschließlich `HanseCast/` mit Lua/TOC/TGA und Dokumentations-/Lizenzbeilagen. Keine Installationsskripte, privaten Einstellungen, Sicherungen oder Testhelfer. Manifestdateien und dieses Veröffentlichungsset sind Prüfunterlagen, keine Addondateien für CurseForge.

## GitHub

Repository: https://github.com/sierone1/HanseCast . Code und öffentliche Dokumentation werden auf `main` aktualisiert. Release-Titel: **Hanse Cast 1.0.8 – Forever and Retail**; vorgesehener Tag **v1.0.8**. Beide ZIPs plus SHA-256-Datei als Release-Assets verwenden. Ein GitHub-Quellcode-ZIP ist kein installierbares Addonpaket. Der GitHub-Connector kann Commits/Branches schreiben, aber in dieser Sitzung keine Release-Assets hochladen. Ohne Browserfreigabe bleiben Tag/Release-Assets als Veröffentlichungsschritt offen.

## Berücksichtigte CurseForge-Regeln

Stand der Prüfung: 12.11.2026. Englisch vor weiteren Sprachen; aussagekräftige Beschreibung/Summary; Projektname ohne technische Versionsangaben; passender Spielzweig je Datei; echtes ZIP unter 2 GB; Changelog für jedes Update; keine externen Datei-Downloadlinks; konsistente Lizenz/Credits. Bestehendes 400×400-PNG-Logo weiterverwenden. Keine neue Galeriebehauptung: KI-veränderte Vorschauen, die vom tatsächlichen Spielinhalt abweichen könnten, deutlich kennzeichnen. Vorhandene echte Spielbilder nicht als Retail-Aufnahmen umbenennen, wenn sie aus Forever stammen.

Release-Kennzeichnung beruht auf den bestandenen automatisierten Prüfungen und den bestätigten allgemeinen Ingame-Tests. Das ist keine Zusage vollständiger Klassen-/Zauberabdeckung. Die endgültige Annahme entscheidet CurseForge nach Moderation.

Offizielle Quellen:

- https://support.curseforge.com/support/solutions/articles/9000197279-moderation-policies
- https://support.curseforge.com/support/solutions/articles/9000197241-creating-and-submitting-a-project
- https://support.curseforge.com/support/solutions/articles/9000199552-project-submission-guide-and-tips
- https://support.curseforge.com/support/solutions/articles/9000209856-multi-toc-for-world-of-warcraft-addons
