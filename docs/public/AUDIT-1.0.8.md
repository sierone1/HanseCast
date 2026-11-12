# Audit und Paketfreigabestand – 12.11.2026

Umfang: Hanse Cast Forever 1.0.8-alpha.1 und Retail 1.0.8-retail-alpha.2. Hanse Mark war nicht Gegenstand dieses Audits.

## Finalisierung nach Nutzerabnahme

Der Nutzer hat Forever Alpha.1 und anschließend die installierte Retail Alpha.2 im Spiel bestätigt. Retail-TOC Alpha.2 wurde separat gelesen. Final vorbereitet: Forever **1.0.8**, Retail **1.0.8-retail**. Gegenüber diesen bestätigten Vorstufen ändern sich nur Versions-/Statusmetadaten und Dokumentation; keine neue Laufzeitfunktion. Die folgenden Auditabschnitte beschreiben den vorherigen Vorabstand und dessen damalige offene Abnahme. Die allgemeine Bestätigung ist keine einzeln protokollierte Prüfung jeder Klasse, jedes Zaubers oder jedes Empower-Randfalls.

## Befunde und Korrekturen

| Bereich | Befund | Ergebnis |
|---|---|---|
| Retail Ziel/Fokus | Native Kanaltimer unterschieden Empower nicht ausdrücklich; Empower-Events fehlten im Kompaktpfad | Vor Übergabe werden lesbare Kanalmerkmale geprüft; Empower, Secret-Flag und API-Fehler behalten Blizzard. Start/Update/Stop lösen neue Prüfung aus. Regression einschließlich Wiederanlauf bestanden. |
| Forever-Paket | Anleitung/Lizenz/Credits waren nicht Bestandteil des ZIPs | Update-Anleitung, Klassenübersicht und Quellen, Lizenz/Credits enthalten und gehasht. |
| Retail-Paket | Direktes Schreiben des Ziel-ZIPs; Dokumente nicht im Datei-Manifest | Temporäres ZIP, vollständiger Inhalts-/CRC-Vergleich, atomare Ersetzung, Hashes aller Mitglieder. |
| Öffentliche Doku | Kurzbeschreibung und Menühinweise noch auf 1.0.7 | Aktueller Vorabstand und getrennte Retail-Anleitung ergänzt. |

## Tatsächlich ausgeführte Prüfungen

- Vollständiger Forever-Packager: 56 Testsuiten erfolgreich, 941 Addondateien plus sechs Dokumentations-/Lizenzdateien (947 ZIP-Mitglieder). Lua-5.1-Mocks, Grafikformatprüfung, TOC-Abgleich, Inhalts-/CRC-Prüfung und SHA-256-Manifest. Die 941 Addondateien wurden zusätzlich bytegleich mit der installierten Forever Alpha.1 verglichen.
- Retail-Packager: generiertes Addon aus TOC geladen; Client-/Projekt-Gates, isolierte Einstellungen, Spieler-Cast/Kanal, Secrets, Empower-Rückfall, native Ziel-/Fokustimer, API-Ausfall/Wiederanlauf, Profile/Vorschau und Kampfgrenzen erfolgreich geprüft.
- Klassenautomation: 27 Forever-Talentbäume, 40 Retail-Spezialisierungen, 13 Retail-Klassen, alle fünf Materialfamilien, echte Controller-/Themenwechsel im Mock, bestehende Einstellungen und unbekannte/geschützte IDs.
- Codeprüfung: Defaults, einmalige Erstwahl, optionale Zauberautomatik, getrennte Kataloge und Material-Aliase, kontrollierte Blizzard-Ausblendung und Wiederherstellung, Versions-/TOC-Konsistenz und Release-Dateien.

## Grenzen und offene Abnahme

Automatische Tests beweisen keine native Clientfunktion und keine vollständige Abdeckung aller existierenden Zauber-IDs. Retail-Zielinterface 120105 und benötigte APIs müssen im echten Client bestätigt werden. Spieler-Empower-Stufen sind nicht implementiert; Blizzard bleibt zuständig. Neue Retail-Kategorien verwenden vorhandene Materialien.

Steve prüft Forever separat im Spiel. Zum Zeitpunkt dieses Protokolls liegt noch kein abschließendes Ergebnis vor. Die bereits installierte Forever Alpha.1 besitzt denselben Spielcode wie das neue Paket; nur die Paketbeilagen ändern sich. Retail Alpha.2 enthält einen zusätzlichen Laufzeitfix und ist noch nicht installiert oder nativ abgenommen. Keine CurseForge-Veröffentlichung und keine stabile Releasefreigabe durch dieses Audit.

Prüfschritte und Update: [Forever](RELEASE-1.0.8.md), [Retail](RETAIL.md), [Klassen](AUTO-SPELL-VISUALS.md). Die jeweiligen Buildmanifeste enthalten die konkreten ZIP- und Dateihashes. Vollständige lokale Build-/Testabhängigkeiten werden nicht vollständig mit dem öffentlichen Repository ausgeliefert.
