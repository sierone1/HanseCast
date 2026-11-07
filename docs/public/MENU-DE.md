# Menüanleitung

Das Menü öffnest du außerhalb des Kampfes mit `/hansecast`. Die Zeile unter dem Titel zeigt die aktuell manuell gewählte Kategorie und Optik. Ein Punkt vor einer Schaltflächenbeschriftung markiert die Auswahl. Schaltflächen mit `>` wechseln bei jedem Klick zur nächsten Möglichkeit.

## Hauptmenü von oben nach unten

| Einstellung | Bedeutung |
| --- | --- |
| Elementstrom / Splitter & Funken / Seidenfluss / Impuls / Nebellicht | Wählt die grafische Kategorie der Leiste. Das verändert die Darstellung, nicht den Zauber oder seine Dauer. |
| Material: Magier > | Wechselt durch die Materialgruppen: die neun Klassen sowie Fraktionen. Die Auswahl ist unabhängig von der Klasse deines Charakters. |
| Frost / Feuer / Arkan | Wählt eine Optik innerhalb der Materialgruppe. Andere Gruppen zeigen andere Namen. Unter Fraktionen stehen Allianz und Horde zur Wahl. |
| Zauberoptik: Automatisch / Manuell | Automatisch verwendet bei bekannten, zugänglichen Zauber-IDs eine passende Optik. Manuell hält deine Auswahl fest. Unbekannte Zauber und Vorschauen verwenden die manuelle Auswahl. |
| Fest · Fraktionsoptik | Bei einer Fraktionsoptik bleibt die ausgewählte Darstellung während aller Zauber gleich. Die automatische Zauberoptik wird dafür nicht umgeschaltet; ihre gespeicherte Einstellung gilt wieder bei Klassenoptiken. |
| Akzente: Neutral / Klasse > | Neutral belässt die Akzentfarben. Klasse mischt die Farbe deiner Charakterklasse dezent in Nebenakzente. Die Hauptfarbe der gewählten Optik bleibt erhalten. |
| Ausführung: Neutral / Allianz / Horde > | Neutral blendet das kleine Fraktionswappen aus. Allianz oder Horde wählt ein natives Wappen links neben der Spielerleiste. Das ändert nicht die Fraktion deines Charakters. |
| Vorschau starten / Position verschieben | Zeigt eine künstliche Leiste. Ziehe sie mit gedrückter linker Maustaste an die gewünschte Position. |
| Vorschau beenden / Position sperren | Beendet die Vorschau und sperrt das Verschieben. Danach echte Zauber zum Prüfen verwenden. |
| Breite / Höhe | Ändert die Leistenabmessungen mit Minus und Plus. Die wirkliche Bildschirmgröße hängt auch von der WoW-Oberflächenskalierung ab. |
| Skalierung | Vergrößert oder verkleinert die gesamte Leiste. Die Größenbegrenzung kann sehr kleine Kombinationen aus Höhe und Skalierung anpassen. |
| Globaler Cooldown · schmale Linie | Schaltet die separate Anzeige der globalen Abklingzeit ein oder aus. Eine Fähigkeit ohne eigene Zauberzeit muss deshalb keine künstliche Castbar erhalten. |
| Abschlusslicht · kurzer Lichtimpuls | Schaltet den kurzen zusätzlichen Lichtimpuls zum Abschluss ein oder aus. |
| Blizzard-Castbar ersetzen | Ein erlaubt, die normale Spieler-Zauberleiste während eines aktiven Hanse-Zaubers auszublenden, wenn das sicher möglich ist. Bei fehlenden Daten oder Grafiken bleibt die Standardanzeige als Rückfall verfügbar. Das ersetzt keine Blizzard-Ziel-/Fokusframes. |
| Position zurücksetzen | Setzt nur die Position der Spielerleiste auf die Ausgangsposition zurück; es löscht keine Profile und setzt nicht die gesamte Gestaltung zurück. |
| Erweitert / Profile | Öffnet die drei Bereiche Komfort, Profile und Ziel / Fokus. |

Auf dem bereitgestellten Beispielbild sind Splitter & Funken, Magier und Frost ausgewählt. Die Zauberoptik steht auf Automatisch. GCD-Anzeige, Abschlusslicht und das Ersetzen der Blizzard-Spielerleiste sind eingeschaltet. Diese Aufnahme zeigt persönliche Einstellungen, nicht die Werkseinstellung.

## Erweitert: Komfort

- **Sprache:** automatisch anhand der Spielsprache, Deutsch oder Englisch.
- **Schrift / Schriftgröße:** Schriftbild und Größe der Beschriftungen.
- **Zeit:** Restzeit, verstrichene Zeit, beides oder keine Zeitanzeige.
- **Deckkraft:** Sichtbarkeit der Leiste anpassen.
- **Zaubersymbol:** ausblenden oder links/rechts anzeigen.
- **Latenzmarkierung:** optionale Orientierung anhand der lesbaren Weltlatenz. Sie misst weder deinen Tastendruck noch das exakte Zauberwarteschlangenfenster.
- **Kanal-Hilfslinien / Anzahl Abschnitte:** gleichmäßige, manuell eingestellte Unterteilung. Keine automatische Erkennung echter Schadens- oder Heilticks.

## Erweitert: Profile

Mit der oberen Schaltfläche ein Profil auswählen. Das Sternchen `*` markiert das aktive Profil. **Wechseln** aktiviert das ausgewählte Profil.

- **Neues Profil:** im Feld Profilname einen neuen Namen eingeben; erstellt ein Profil mit Standardwerten und aktiviert es.
- **Kopie erstellen:** erstellt unter dem eingegebenen Namen eine Kopie der aktuellen Einstellungen und aktiviert sie. Sinnvoll, um eine Gestaltung zu behalten und eine zweite auszuprobieren.
- **Löschen:** entfernt das ausgewählte Profil nach einem zweiten Bestätigungsklick. Das letzte verbleibende Profil kann nicht gelöscht werden.
- **Zurücksetzen:** setzt das ausgewählte Profil nach Bestätigung auf Standardwerte zurück. Das ist umfassender als Position zurücksetzen im Hauptmenü.
- **Exportieren:** schreibt die Einstellungen des aktiven Profils in das Textfeld. Den markierten Text zum Sichern oder Weitergeben kopieren.
- **Import prüfen:** eingefügten Profiltext prüfen. Dabei werden noch keine neuen Einstellungen übernommen.
- **Import anwenden:** übernimmt den zuvor geprüften Text in die aktuellen Einstellungen. Wenn du die bisherige Gestaltung behalten möchtest, vorher eine Profilkopie erstellen. Nach einer Änderung des Importtexts muss er erneut geprüft werden.

Es sind bis zu zwölf Profile möglich. Im geprüften Stand bleiben Profile, Position und Optik nach `/reload` und vollständigem Neustart erhalten.

## Erweitert: Ziel / Fokus

Zuerst **Ziel** oder **Fokus** auswählen. Die folgenden Einstellungen gelten nur für diese Auswahl:

- **Aktiv:** die jeweilige eigene Leiste ein- oder ausschalten.
- **Sichtbarkeit:** passende Zauber innerhalb und außerhalb des Kampfes anzeigen oder auf den Kampf beschränken. Immer bedeutet nicht, dass eine leere Leiste dauerhaft angezeigt wird.
- **Symbol:** Zaubersymbol ein- oder ausschalten.
- **Material / Zauberoptik:** Darstellung wählen. Übernehmen verwendet die entsprechende Auswahl der Spielerleiste.
- **Breite / Höhe / Skalierung:** Größe dieser Leiste unabhängig einstellen.
- **Position X / Y:** horizontale und vertikale Position anpassen.
- **Vorschau Ziel / Fokus:** künstliche Leisten zum Positionieren anzeigen. Die Vorschau ist kein Nachweis zugänglicher gegnerischer Zauberdaten.

## Ein einfacher Start

Für eine feste Optik zuerst Kategorie und Materialgruppe wählen, dann eine Optik auswählen und Zauberoptik auf Manuell stellen. Anschließend Vorschau einschalten, verschieben, Größe anpassen, Vorschau beenden und einen echten Zauber wirken. Weitere Optionen lassen sich später einzeln ergänzen.

`/hansecast demo` zeigt künstliche Beispiele zu Zeitänderungen und Abbrüchen. `/hansecast status` liefert Diagnoseinformationen. Die Demo ersetzt keinen Spieltest.
