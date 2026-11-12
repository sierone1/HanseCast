# Hanse Cast – Deutsch

Aktueller Release: Forever 1.0.8. Erstwahl nach Spezialisierung, sichere Blizzard-Spielerleisten-Ausblendung an, optionale Zauberautomatik aus; vorhandene Einstellungen bleiben erhalten. [Update](RELEASE-1.0.8.md). Retail ist eine [separate Variante](RETAIL.md). Allgemeine Ingame-Prüfung durch den Nutzer bestätigt.

Animierte Spieler-Zauberleisten und kompakte Ziel-/Fokusleisten für **WoW Forever 1.60.1**.

## Spielerleiste

145 Grafikvarianten in fünf Kategorien: Elementstrom, Splitter & Funken, Seidenfluss, Impuls und Nebellicht. Klasseninspirierte Optiken sowie Allianz/Horde sind unabhängig von der eigenen Klasse wählbar. Heilig und Disziplin wurden für 1.0.7 überarbeitet.

Position, Größe, Schrift, Zeitdarstellung und Symbolplatzierung lassen sich anpassen. Dazu kommen eine separate GCD-Anzeige, Favoriten, bis zu zwölf benannte Profile mit Kopieren/Umbenennen und validiertem Textimport/-export, Komfort-Vorlagen und ein ruhiger Modus. Optionale Latenz-, Startschätzungs- und Warteschlangenanzeigen bleiben getrennt; das Warteschlangenfenster verändert keine Clienteinstellung.

## Ziel und Fokus

Drei kompakte Designs: **Klassik**, **Seidenkern**, **Geteilte Anzeige**. Schwarzer Rahmen, eigene Menüvorschau und getrennte Positionierung für Ziel/Fokus. Die Hauptfarbe lässt sich mit dem WoW-Farbwähler oder zehn benannten Farbfeldern auswählen. Restzeit optional rechts innen oder rechts daneben. Blizzard-Zauberleisten für Ziel/Fokus können getrennt ausgeblendet werden, solange Hanse die eigene Anzeige zuverlässig bereitstellt.

Nur Ziel und Fokus, auch wenn ein Begleiter ausgewählt ist. Keine zusätzlichen Pet- oder Ziel-des-Ziels-Leisten. Designs und gemeinsame Farbe sind für alle Klassen identisch; diese Einstellungen sind unabhängig von den Spielerprofilen.

## Installation und Bedienung

Den Ordner `HanseCast` nach `Interface/AddOns` entpacken. `HanseCast.toc` muss direkt darin liegen. Nach einem Update WoW vollständig neu starten. Gespeicherte Einstellungen bleiben erhalten. Ein separates Hanse Cast Compact Lab ist nicht nötig; gegebenenfalls deaktivieren.

`/hansecast` öffnet die Reiter Spieler, Ziel & Fokus, Profile und Hilfe. Vorschau und Positionieren sind direkt im Menü erreichbar. Änderungen werden unmittelbar übernommen; der Farbwähler bietet Bestätigen/Abbrechen. Im Kampf sind Einstellungsänderungen gesperrt.

- `/hansecast test`: Spielervorschau.
- `/hccompact`: Ziel-/Fokus-Einstellungen.
- `/hansecast diagnose`: Kurzdiagnose.
- `/hansecast bericht`: kopierbarer Diagnosebericht.

## Kompatibilität und Grenzen

Version **1.0.8**, Forever **1.60.1**, Interface **16001**. Kompakte Einheitenanzeigen derzeit nur für Build **70862/70888**. Andere WoW-Ausgaben und Empower werden nicht unterstützt. Keine zusätzliche Bibliothek erforderlich. Deutsche und englische Oberfläche.

Bei fehlenden zulässigen Zeitdaten zeigt die optionale Restzeit einen Strich. Die Spielerleiste benötigt zugängliche Zeitangaben; native Einheiten-/GCD-Timer verwenden unterstützte Dauerobjekte. Automatische Kanalticks sind nicht aktiviert; Hilfslinien sind manuelle Orientierung. Weitere Castbar-Addons können überlappende Anzeigen verursachen.

56 automatisierte Testsuiten prüfen simulierte Schnittstellen. Der Nutzer hat den aktuellen Forever-Stand allgemein im Spiel bestätigt. Keine pauschale Freigabe jeder Klasse, jedes Zaubers oder jeder Addonkombination.

[Quellcode und Fehlerberichte](https://github.com/sierone1/HanseCast) · Lizenz: All Rights Reserved. Keine Verbindung zu oder Empfehlung durch Blizzard.
