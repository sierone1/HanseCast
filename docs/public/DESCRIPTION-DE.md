# Deutsch

**Deine Zauber, dein Stil.** Hanse Cast verbindet animierte Zauberleisten mit klasseninspirierten Grafiken für **WoW Forever 1.60.1**. Verfolge deine Zauber und Kanalisierungen, behalte die globale Abklingzeit im Blick und platziere die Anzeigen dort, wo du sie brauchst. Ziel und Fokus sind derzeit als „in Arbeit“ deaktiviert.

## Gestalte deine Leisten

Wähle aus **145 Grafikvarianten**: neun klasseninspirierte Gruppen mit jeweils drei Optiken sowie Allianz und Horde, jeweils in fünf Kategorien. Elementstrom, Splitter & Funken, Seidenfluss, Impuls und Nebellicht bieten unterschiedliche Darstellungen. Deine Auswahl ist unabhängig von der Klasse und Fraktion deines Charakters.

Die Grafik behält ihre Form und wird mit dem Zauberfortschritt freigelegt. Position, Größe, Deckkraft, Schrift, Symbolplatzierung und Zeitdarstellung lassen sich anpassen.

## Funktionen

- Spielerzauber und Kanalisierungen mit Namen, Fortschritt und wählbarer Zeitdarstellung.
- Separate GCD-Anzeige, auch bei unterstützten Sofortzaubern.
- Rückmeldungen zu Abbruch, Unterbrechung und Fehlschlag, soweit die nötigen Informationen verfügbar sind.
- Bis zu zwölf benannte Profile mit Kopierfunktion sowie validiertem Textimport und -export.
- Optionale automatische Optik für unterstützte Zauber; unbekannte Zauber behalten die manuelle Auswahl.
- Optik-Browser mit Filtern und bis zu 20 Favoriten pro Profil.
- Komfort-Vorlagen „Einfach“, „Lesbar“ und „Ruhig“, ohne Position oder Optik zu ersetzen.
- Ruhiger Modus ohne dekorative Bewegung und zusätzliche Lichtimpulse.
- Optionale Weltlatenzmarkierung, geschätzte Zauberstart-Verzögerung und getrenntes Warteschlangenfenster.
- Manuell einstellbare Kanal-Hilfslinien; keine automatische Tick-Erkennung.
- Deutsche und englische Bedienung. Keine zusätzlichen Addons oder Bibliotheken erforderlich.

## Erste Schritte

1. Hanse Cast installieren und WoW vollständig neu starten.
2. **Optionen/Einstellungen → AddOns → Hanse Cast** öffnen oder `/hansecast` eingeben.
3. Im Reiter **Spieler** die Optik und Größe wählen. **Weitere Einstellungen** öffnet Schrift, Symbole und Feineinstellungen. Erklärungen erscheinen beim Darüberfahren mit der Maus.
4. **Positionieren** wählen, die Leiste verschieben und mit **Fertig – zurück zu Einstellungen** sperren und zurückkehren.
5. Ziel & Fokus ist als „in Arbeit“ gesperrt. Für diese Einheiten bleiben die normalen Blizzard-Leisten verfügbar.

Das kompakte Menü hat vier Reiter: **Spieler**, **Ziel & Fokus**, **Profile** und **Hilfe**. Die animierte Menüvorschau verwendet die Originalgrafiken und dieselbe Zeichenfunktion wie die Castbar. Sie berücksichtigt die manuell gewählte Optik, Schrift, Zeitformat und Symbolposition und wird bei Bedarf verkleinert. Startmessung und Warteschlangenwerte werden nicht künstlich vorgetäuscht. Änderungen gelten sofort für das aktive Profil; im Kampf sind Änderungen gesperrt.

Nach dem Update von 1.0.4 oder älter WoW vollständig neu starten, da ein Lua-Modul hinzugekommen ist. SavedVariables bleiben erhalten.

Bei manueller Installation den Ordner `HanseCast` nach `Interface/AddOns` entpacken. Die Datei muss unter `Interface/AddOns/HanseCast/HanseCast.toc` liegen.

- `/hansecast` – Einstellungen öffnen.
- `/hansecast test` – Spielervorschau ein- oder ausschalten.
- `/hansecast units` – Status „in Arbeit“ anzeigen; keine Vorschau.
- `/hansecast diagnose` – kompakte Diagnose einschließlich optionaler Komfortanzeigen.
- `/hansecast status` – Version und Diagnoseinformationen anzeigen.

## Kompatibilität und Prüfstand

**Version 1.0.5 ist für WoW Forever 1.60.1, Interface 16001 vorgesehen.** Andere WoW-Ausgaben werden von diesem Paket derzeit nicht unterstützt.

36 lokale Testsuiten prüfen die Spielschnittstellen simuliert. Der alpha.3-Kandidat bestand zusätzlich 5.000 simulierte Abläufe; der Nutzer bestätigte den gebündelten Spieltest am 08.11.2026 mit „funktioniert alles“. Version 1.0.5 übernimmt dieses Verhalten unverändert. Dies ist keine vollständige Abdeckung jeder Klasse, jedes Zaubers, jeder Anzeigeskalierung oder Addonkombination und kein gemessener nativer FPS-Gewinn.

Die Spielerleiste benötigt zugängliche Zeitangaben. Ziel und Fokus sind vollständig deaktiviert; ihre bisherigen Einstellungen bleiben erhalten. Empower-Zauber werden nicht unterstützt. Kanal-Hilfslinien sind manuelle Markierungen. Die Latenzmarkierung ist eine Orientierung anhand gemeldeter Weltlatenz. Die separate Start-Schätzung beruht nur auf sicher zugeordneten lokalen Ereignissen, nicht auf exakter Serverlatenz. Das hellblaue Warteschlangenfenster zeigt eine gelesene Client-Einstellung unter der Leiste; Hanse verändert sie nicht. Bei fehlenden oder geschützten Daten bleiben die Zusatzanzeigen leer.

Das Ersetzen der normalen Spieler-Zauberleiste ist optional und zunächst ausgeschaltet. Blizzards Ziel- und Fokusframes bleiben erhalten. Bei mehreren aktiven Zauberleisten-Addons können sich Anzeigen überlagern. Dann eine der Anzeigen deaktivieren oder die Einstellungen anpassen.

## Einstellungen und Hilfe

Profile und Einstellungen werden accountweit gespeichert. Für ein Update müssen gespeicherte Einstellungen nicht gelöscht werden. Vor einem bewussten Zurücksetzen oder Entfernen die SavedVariables sichern.

Fehler bitte in den Projektkommentaren melden. Hilfreich sind Hanse-Cast-Version, WoW-Version, Schritte zum Nachstellen, weitere aktive Oberflächen-Addons und der vollständige Lua-Fehlertext, falls vorhanden. Bei Darstellungsproblemen ein Bild oder einen kurzen Clip beifügen. Private Chatnachrichten oder Kontoinformationen vor dem Teilen ausblenden.

## Urheber und Lizenz

Erstellt von **Hanse**. Eigene Grafiken und das Logo wurden mit KI-Unterstützung entwickelt und für dieses Projekt aufbereitet. Außerhalb von WoW zusammengesetzte Vorschauen werden als Software-Komposition und nicht als Spielaufnahme gekennzeichnet.

**Kostenlose persönliche Nutzung · All Rights Reserved.** Die enthaltene Lizenz regelt die erlaubte Nutzung. World of Warcraft, Blizzard-Marken und vom Client bereitgestellte Ressourcen gehören ihren jeweiligen Rechteinhabern. Hanse Cast ist ein unabhängiges Community-Addon.
