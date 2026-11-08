# Hanse Cast 1.0.0 – Menüanleitung

Öffne **Escape → Optionen/Einstellungen → AddOns → Hanse Cast** oder gib `/hansecast` ein. Die Einstellungen lassen sich direkt im WoW-Fenster bearbeiten. Wenn die benötigte Settings-Schnittstelle fehlt, öffnet sich ein eigenes Fenster mit denselben Bereichen.

Oben steht immer das aktive Profil. Normale Änderungen gelten sofort für dieses Profil. Öffnen und Schließen des Menüs setzt keine Einstellungen zurück. Im Kampf sind Änderungen gesperrt.

## Die vier Reiter

- **Spieler:** Kategorie, Themengruppe, manuelle Optik, Zauberautomatik, Breite, Höhe, Skalierung, GCD, Abschlusslicht und Blizzard-Ersatz. **Weitere Einstellungen** öffnet Akzente, Wappen, genaue Position, Schrift, Zeitanzeige, Deckkraft, Symbol, Latenz und Kanal-Hilfslinien.
- **Ziel & Fokus:** zuerst die betroffene Leiste auswählen. Aktivierung, Sichtbarkeit, Symbol, Optik, Größe und Position gelten nur für diese Leiste.
- **Profile:** auswählen, aktivieren, erstellen, kopieren, exportieren, importieren, löschen oder zurücksetzen.
- **Hilfe:** Sprache, Kurzanleitung, Grenzen, Ereignis-Demo und Statusausgabe.

Fahre für Erklärungen mit der Maus über eine Einstellung oder ihr Bedienelement. Änderungen gelten sofort. Zahlenfelder: Enter übernimmt, Escape verwirft die laufende Eingabe. Die Werte sind UI-Einheiten, nicht zwingend physische Pixel.

## Vorschau und Positionierung

Die eingebettete Original-Vorschau verwendet dieselben Originaltexturen und dieselbe Effekt-Zeichenfunktion wie die Castbar. Sie zeigt die manuell gewählte Optik mit einem künstlichen Dreisekundenverlauf, bei Bedarf passend verkleinert. Sie ist eine Gestaltungsvorschau, keine maßstabsgetreue Vorschau aller Text-, Symbol- und Zusatzanzeigen. Sie verändert weder die Spielerposition noch das aktive Zauberereignis und stoppt bei verborgenem Menü, anderem Reiter oder Kampf.

„Positionieren“ blendet das große Menü aus und zeigt eine künstliche Vorschau mit einer kleinen Werkzeugleiste. Ziehe die Leiste mit der linken Maustaste. „Fertig – zurück zu Einstellungen“ beendet die Vorschau, sperrt die Position und öffnet die Einstellungen wieder. Escape beendet die Vorschau ebenfalls. Bei Kampfbeginn werden Vorschauen und Verschieben beendet.

Ziel/Fokus-Vorschauen zeigen nur die ausgewählte Leiste. Eine Vorschau aktiviert eine abgeschaltete Leiste nicht dauerhaft. Prüfe die Darstellung anschließend mit echten Zaubern.

## Gestaltung verstehen

**Kategorie** bestimmt den grafischen Aufbau. **Themengruppe** wählt eine Klassen- oder Fraktionsgestaltung unabhängig von deiner eigenen Klasse. **Manuelle Optik** wird auch für unbekannte Zauber und Vorschauen genutzt. Die Automatik wählt nur bei bekannten, zugänglichen Zaubern eine passende Optik. Fraktionsoptiken bleiben fest und bewahren die gespeicherte Automatikpräferenz; ihre Auswahl setzt zunächst das passende Wappen, das anschließend separat geändert werden kann.

**Akzentfarbe** verändert Nebenakzente, nicht die Hauptfarbe. **Fraktionswappen** ist ein kleines Symbol und ändert nicht die Charakterfraktion. Die **Latenzmarkierung** ist nur eine Orientierung anhand gemeldeter Weltlatenz. **Kanal-Hilfslinien** sind gleichmäßige manuelle Abschnitte, keine erkannten Schadens- oder Heilticks.

## Profile sicher verwenden

Profile sind accountweit gespeichert; bis zu zwölf sind möglich. Die Profilauswahl oben rechts wechselt direkt das aktive Profil. Im Reiter Profile aktiviert die Auswahl allein noch nichts. „Aktivieren“ wechselt bewusst. „Neues Profil“ erstellt Standardwerte unter dem eingegebenen Namen. „Kopie erstellen“ kopiert das aktive Profil und aktiviert die Kopie. Export verwendet immer das aktive Profil; Kopieren des Texts mit Strg+C.

Import: Text mit Strg+V einfügen → Prüfen → entweder unter dem eingegebenen Namen neu importieren oder das aktive Profil nach Bestätigung überschreiben. Prüfung allein ändert nichts. Jede Textänderung verwirft das Prüfergebnis. Bei ungültigem Namen, bereits vergebenem Namen oder vollen Profilplätzen wird kein halbfertiges Profil angelegt.

Löschen und Zurücksetzen nennen das ausgewählte Profil in einem Bestätigungsdialog. Zurücksetzen setzt dieses Profil auf Standardwerte und aktiviert es. „Spielerposition zurücksetzen“ betrifft dagegen ausschließlich die Spielerposition. Vorhandene 0.9.1-Profile und das Exportformat HANSECAST:1 bleiben erhalten; SavedVariables nicht löschen.

## Grenzen

Geschützte oder fehlende Zauberdaten können die eigene Anzeige verhindern. Keine Empower-Unterstützung. Die eingebetteten Seiten bieten derzeit keine eigene Volltextsuche. Menü und Kernfunktionen werden automatisiert mit simulierten Spiel-APIs geprüft; echte Clientdarstellung und Spielverhalten benötigen zusätzlich die Ingame-Prüfung.
