# Hanse Cast 1.0.4

## English

Target and focus are now marked **in development** and disabled in both the menu and addon runtime. Old profiles cannot activate them. Their saved values are retained for future development. Blizzard target/focus cast bars remain available without suppression by Hanse Cast. Separate compact unit bars are planned, not included.

Player casts, channels, artwork, GCD and profiles remain available. The `/hansecast units` command reports the development status instead of starting previews. Menu help and diagnostics explain the disabled feature.

For an existing installation, type `/reload` after replacing the addon folder. Do not delete SavedVariables. First installations require a game restart. No additional addons are needed; experimental measurement helpers are not included.

Validation: 29 local suites passed, including the release gate with previously enabled unit profiles and unchanged native bars. Native validation of 1.0.4 remains pending. Historical unit-engine regression tests explicitly enable the dormant engine only inside the test environment.

Check in game: disabled Target & focus tab; normal player casts/channels and GCD; Blizzard target/focus casts during combat and unit changes; `/hansecast units` produces no preview; profile switching and reload retain player settings and keep target/focus disabled.

## Deutsch

Ziel und Fokus sind jetzt **in Arbeit** und sowohl im Menü als auch im Addon deaktiviert. Alte Profile können die Funktion nicht aktivieren. Ihre Werte bleiben für eine spätere Entwicklung erhalten. Hanse Cast blendet die Blizzard-Ziel-/Fokusleisten nicht mehr aus. Separate kompakte Leisten sind geplant, aber noch nicht enthalten.

Spielerzauber, Kanäle, Gestaltung, GCD und Profile bleiben verfügbar. `/hansecast units` zeigt den Entwicklungsstatus statt einer Vorschau. Menü-Hilfe und Diagnose erklären den Zustand.

Bei vorhandener Installation nach dem Ersetzen des Addonordners `/reload` eingeben. SavedVariables nicht löschen. Bei Erstinstallation das Spiel neu starten. Keine zusätzlichen Addons erforderlich; experimentelle Messhilfen sind nicht enthalten.

29 lokale Testsuiten bestanden. Die Prüfung von 1.0.4 im echten Spiel steht noch aus. Prüfen: gesperrter Ziel-/Fokusreiter, eigene Zauber/Kanäle und GCD, normale Blizzard-Ziel-/Fokusleisten im Kampf und bei Einheitswechseln, keine Vorschau durch `/hansecast units`, erhaltene Spielerwerte nach Profilwechsel und Reload.
