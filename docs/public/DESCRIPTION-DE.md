# Deutsch

**Deine Zauber, dein Stil.** Hanse Cast verbindet animierte Zauberleisten mit klasseninspirierten Grafiken für **WoW Forever 1.60.1**. Verfolge deine Zauber und Kanalisierungen, behalte die globale Abklingzeit im Blick und platziere die Anzeigen dort, wo du sie brauchst. Optionale Ziel- und Fokusleisten ergänzen deine Oberfläche.

## Gestalte deine Leisten

Wähle aus **145 Grafikvarianten**: neun klasseninspirierte Gruppen mit jeweils drei Optiken sowie Allianz und Horde, jeweils in fünf Kategorien. Elementstrom, Splitter & Funken, Seidenfluss, Impuls und Nebellicht bieten unterschiedliche Darstellungen. Deine Auswahl ist unabhängig von der Klasse und Fraktion deines Charakters.

Die Grafik behält ihre Form und wird mit dem Zauberfortschritt freigelegt. Position, Größe, Deckkraft, Schrift, Symbolplatzierung und Zeitdarstellung lassen sich anpassen.

## Funktionen

- Spielerzauber und Kanalisierungen mit Namen, Fortschritt und wählbarer Zeitdarstellung.
- Separate GCD-Anzeige, auch bei unterstützten Sofortzaubern.
- Optionale Ziel- und Fokusleisten mit eigenen Positionen, Größen und Optiken.
- Rückmeldungen zu Abbruch, Unterbrechung und Fehlschlag, soweit die nötigen Informationen verfügbar sind.
- Bis zu zwölf benannte Profile mit Kopierfunktion sowie validiertem Textimport und -export.
- Optionale automatische Optik für unterstützte Zauber; unbekannte Zauber behalten die manuelle Auswahl.
- Optionale Latenzmarkierung und manuell einstellbare Kanal-Hilfslinien.
- Deutsche und englische Bedienung. Keine zusätzlichen Addons oder Bibliotheken erforderlich.

## Erste Schritte

1. Hanse Cast installieren und WoW vollständig neu starten.
2. Mit `/hansecast` die Einstellungen öffnen.
3. Vorschau einschalten, Leiste verschieben und Größe anpassen. Anschließend sperren und die Vorschau ausschalten.
4. Optik wählen. Ziel- und Fokusleisten bei Bedarf in den erweiterten Einstellungen aktivieren; beide sind zunächst ausgeschaltet.

Bei manueller Installation den Ordner `HanseCast` nach `Interface/AddOns` entpacken. Die Datei muss unter `Interface/AddOns/HanseCast/HanseCast.toc` liegen.

- `/hansecast` – Einstellungen öffnen.
- `/hansecast test` – Spielervorschau ein- oder ausschalten.
- `/hansecast units` – Ziel- und Fokusvorschau ein- oder ausschalten.
- `/hansecast status` – Version und Diagnoseinformationen anzeigen.

## Kompatibilität und Betastand

**Version 0.9.1 ist eine Beta für WoW Forever 1.60.1, Interface 16001.** Andere WoW-Ausgaben werden von diesem Paket derzeit nicht unterstützt.

Die Spielerleiste wurde im echten Spiel eingesetzt. Erste Leistungsvergleiche auf dem Test-PC des Autors und das Speichern der geprüften Einstellungen nach Reload und Neustart wurden überprüft. Weitere Klassen, Optiken sowie Ziel-/Fokusfunktionen sind Teil der Betaprüfung. Eine bestimmte Leistung auf jedem Rechner wird nicht zugesichert.

Hanse Cast verwendet zugängliche Zauberinformationen. Fehlen erforderliche Daten oder sind sie geschützt, wird die betroffene eigene Anzeige ausgeblendet. Vollständig geschützte Dauerobjekte werden nicht direkt dargestellt. Empower-Zauber werden nicht unterstützt. Kanal-Hilfslinien sind manuelle Markierungen und keine automatisch erkannten Schadens- oder Heilticks. Die Latenzmarkierung zeigt die gemeldete Netzwerklatenz und kein exaktes Eingabe- oder Zauberwarteschlangenfenster.

Das Ersetzen der normalen Spieler-Zauberleiste ist optional und zunächst ausgeschaltet. Blizzards Ziel- und Fokusframes bleiben erhalten. Bei mehreren aktiven Zauberleisten-Addons können sich Anzeigen überlagern. Dann eine der Anzeigen deaktivieren oder die Einstellungen anpassen.

## Einstellungen und Hilfe

Profile und Einstellungen werden accountweit gespeichert. Für ein Update müssen gespeicherte Einstellungen nicht gelöscht werden. Vor einem bewussten Zurücksetzen oder Entfernen die SavedVariables sichern.

Fehler bitte in den Projektkommentaren melden. Hilfreich sind Hanse-Cast-Version, WoW-Version, Schritte zum Nachstellen, weitere aktive Oberflächen-Addons und der vollständige Lua-Fehlertext, falls vorhanden. Bei Darstellungsproblemen ein Bild oder einen kurzen Clip beifügen. Private Chatnachrichten oder Kontoinformationen vor dem Teilen ausblenden.

## Urheber und Lizenz

Erstellt von **Hanse**. Eigene Grafiken und das Logo wurden mit KI-Unterstützung entwickelt und für dieses Projekt aufbereitet. Außerhalb von WoW zusammengesetzte Vorschauen werden als Software-Komposition und nicht als Spielaufnahme gekennzeichnet.

**Kostenlose persönliche Nutzung · All Rights Reserved.** Die enthaltene Lizenz regelt die erlaubte Nutzung. World of Warcraft, Blizzard-Marken und vom Client bereitgestellte Ressourcen gehören ihren jeweiligen Rechteinhabern. Hanse Cast ist ein unabhängiges Community-Addon.
