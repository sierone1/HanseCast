# Hanse Cast 1.0.5 – Menüanleitung

Öffne **Escape → Optionen/Einstellungen → AddOns → Hanse Cast** oder `/hansecast`. Fehlt die benötigte Settings-Schnittstelle, öffnet sich ein eigenes Fenster mit denselben Bereichen. Oben steht das aktive Profil; normale Änderungen gelten sofort dafür. Im Kampf sind Änderungen gesperrt.

## Die vier Reiter

- **Spieler:** Optik-Browser, Filter, Favoriten, Kategorie und Themengruppe, Größe sowie die wichtigsten Anzeigeoptionen. **Weitere Einstellungen** öffnet Komfort-Vorlagen, Schrift, Zeitformat, Symbole, ruhigen Modus, Zusatzanzeigen und genaue Position.
- **Ziel & Fokus (in Arbeit):** ausgegraut und deaktiviert. Separate kompakte Leisten sind geplant.
- **Profile:** auswählen, aktivieren, erstellen, kopieren, exportieren, importieren, löschen oder zurücksetzen.
- **Hilfe:** Sprache, Kurzanleitung, Grenzen, Ereignis-Demo und Statusausgabe.

Fahre mit der Maus über eine Einstellung für eine Erklärung. Zahlenfelder: Enter übernimmt, Escape verwirft die laufende Eingabe. Größen sind UI-Einheiten, nicht zwingend physische Pixel.

## Optiken und Favoriten

Der gemeinsame Browser bietet alle **145 Kategorie-/Optik-Kombinationen**. Filter: alle Optiken, aktuelle Themengruppe oder nur Favoriten. Filtern verändert die aktive Auswahl nicht. Eine Auswahl außerhalb des Filters wird entsprechend bezeichnet; ohne Favoriten ist die Favoritenauswahl leer.

Mit **Als Favorit speichern** oder **Favorit entfernen** verwaltest du bis zu 20 Kombinationen je Profil. Favoriten werden beim Profilwechsel sowie Export/Import mitgeführt. Kategorie, Themengruppe und manuelle Optik bleiben auch einzeln auswählbar.

Die automatische Optik gilt nur für bekannte, zugängliche Zauber. Unbekannte Zauber und Vorschauen nutzen die manuelle Auswahl. Fraktionsoptiken bleiben fest und erhalten die gespeicherte Automatikpräferenz. Die Auswahl setzt zunächst das passende Wappen, das anschließend separat geändert werden kann. Akzentfarbe verändert Nebenakzente, nicht die Hauptfarbe.

## Komfort-Vorlagen und Zusatzanzeigen

Vorlagen werden erst nach Bestätigung angewendet und ändern nur die genannten Komfortwerte. Position, Größe, Skalierung, Optik, Favoriten und Blizzard-Ersatz bleiben erhalten:

- **Einfach:** Standardschrift 12, Restzeit, Symbol aus, ruhiger Modus aus, Abschlusslicht an; Zusatzhilfen aus.
- **Lesbar:** moderne Schrift 16, beide Zeiten, Symbol links, ruhiger Modus aus und Abschlusslicht an. Andere Hilfen bleiben wie eingestellt.
- **Ruhig:** ruhiger Modus an, Abschlusslicht aus, Restzeit, Symbol und Zusatzhilfen aus. Schrift bleibt wie eingestellt.

Der **ruhige Modus** stoppt dekorative Bewegung und zusätzliche Lichtimpulse. Der Zauberfortschritt läuft weiter; Abbruch-/Fehlertext bleibt lesbar.

**Latenzmarkierung:** gemeldete Weltlatenz als Orientierung über der Leiste. **Zauberstart-Verzögerung:** „Start ~… ms“ aus sicher passenden lokalen Sende-/Startereignissen; keine exakte Serverlatenz. **Zauberwarteschlange:** hellblaue Linie unter der Leiste entsprechend der gelesenen Client-Einstellung. Hanse verändert diese Einstellung nicht. Start-/Warteschlangenanzeigen sind standardmäßig aus; fehlende oder geschützte Werte werden nicht geraten. `/hansecast diagnose` zeigt den Status.

**Kanal-Hilfslinien** sind gleichmäßige manuelle Unterteilungen, keine erkannten Schadens- oder Heilticks. Automatische Tickmarkierungen sind nicht freigegeben.

## Vorschau und Positionierung

Die eingebettete Vorschau nutzt die Originalgrafiken und einen künstlichen Dreisekundenverlauf. Sie berücksichtigt Schriftart/-größe, Zeitformat, Symbolposition und ruhigen Modus, wird aber bei Bedarf passend verkleinert. Das Symbol ist ein Beispielsymbol. Sie simuliert keine echten Startmessungen oder Warteschlangendaten und verschiebt nicht die echte Spielerleiste. Animation stoppt bei verborgenem Menü, anderem Reiter oder Kampf.

**Positionieren** blendet das große Menü aus und zeigt eine verschiebbare Spielervorschau. Ziehe mit der linken Maustaste; **Fertig – zurück zu Einstellungen** sperrt die Position und öffnet das Menü wieder. Escape oder Kampfbeginn beendet die Vorschau. **Mittig ausrichten** setzt nur die horizontale Position auf die Bildschirmmitte. Höhe und Gestaltung bleiben erhalten. Ziel-/Fokusvorschauen sind deaktiviert.

## Profile

Bis zu zwölf accountweite Profile. Die Profilauswahl oben rechts wechselt direkt das aktive Profil. Im Reiter Profile wählt die Liste zunächst nur den Namen; **Aktivieren** wechselt. Ein neues Profil beginnt mit Standardwerten; eine Kopie übernimmt das aktive Profil. Export nutzt das aktive Profil.

Import: Text einfügen → Prüfen → als neues Profil importieren oder Ersetzen des aktiven Profils bestätigen. Prüfung allein ändert nichts. Textänderungen verwerfen das Prüfergebnis. Ungültige Namen, doppelte Namen oder volle Profilplätze erzeugen keine halbfertigen Profile. Löschen/Zurücksetzen nennt das betroffene Profil. **Spielerposition zurücksetzen** betrifft nur die Position.

Vorhandene Einstellungen und das Exportformat HANSECAST:1 bleiben unterstützt. SavedVariables nicht löschen. Nach dem Update von 1.0.4 oder älter WoW vollständig neu starten.

## Grenzen

Geschützte oder fehlende Zeitdaten können die Spieleranzeige verhindern. Keine Empower-Unterstützung oder automatische Tick-Erkennung. Der Browser hat Filter, aber keine Volltextsuche. Ziel/Fokus bleiben vollständig deaktiviert; `/hansecast units` meldet nur „in Arbeit“.
