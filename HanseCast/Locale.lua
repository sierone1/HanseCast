local _,HC=...
local en={
 ['Fraktionen']='Factions',['Fest · Fraktionsoptik']='Fixed · Faction style',
 ['Vorschau · ']='Preview · ',['Zauber: ']='Cast: ',['unbekannt']='unknown',
 [' | geschützt: ']=' | restricted: ',[' | API-Fehler: ']=' | API errors: ',[' | fehlende Events: ']=' | missing events: ',
 ['Optik: ']='Appearance: ',[' | Wappenstatus: ']=' | emblem status: ',[' | Auswahl: ']=' | selection: ',
 ['automatisch']='automatic',['manuell']='manual',
 ['Starr / kompakt']='Static / compact',['Starr / hoch']='Static / high resolution',
 ['Arkan kompakt']='Arcane compact',['Arkan normal']='Arcane normal',['weich / niedrig']='soft / low',
 ['weich']='soft',['normal']='normal',
 ['Darstellung: %d x %d UI | %.1f x %.1f Pixel | Faktor %.3f | %s']='Rendering: %d x %d UI | %.1f x %.1f pixels | scale %.3f | %s',
 ['Texturen: ']='Textures: ',[' gemeldete Ladefehler']=' reported load errors',
 [' | WoW vollständig neu starten.']=' | Restart WoW completely.',
 ['GCD-Prüfung: ']='GCD check: ',['Addon-Einstellungsmenü: ']='Addon settings menu: ',
 [' | gespeicherte Starts: ']=' | saved starts: ',[' (inkl. /reload)']=' (including /reload)',
 ['Quartz ist aktiv. Für den Einzeltest bitte vorübergehend deaktivieren.']='Quartz is active. Temporarily disable it for an isolated test.',
 ['ja']='yes',['nein']='no',[' / Dauer ']=' / duration ',['nicht geprüft']='not checked',['noch nicht geprüft']='not checked yet',
 ['unverändert']='unchanged',['Wiederherstellung ausstehend']='restoration pending',
 ['Zauberende wird abgeglichen']='reconciling cast end',
 ['Grafikfehler: Standard nicht ausgeblendet']='artwork failure: default bar remains visible',
 ['Standard als Rückfall verfügbar']='default bar available as fallback',
 ['Standard bleibt: Frame nicht sicher veränderbar']='default bar remains: frame cannot be safely modified',
 ['Standard bei aktivem Hanse-Zauber ausgeblendet']='default bar hidden during an active Hanse cast',
 ['Standard bleibt: Änderung nicht möglich']='default bar remains: change unavailable',
 ['Vorschau nur außerhalb des Kampfes.']='Preview is available outside combat only.',
 [' geladen. /hansecast öffnet die Einstellungen.']=' loaded. /hansecast opens settings.',
 ['Unterbrechbar']='Interruptible',['Nicht unterbrechbar']='Not interruptible',['Unterbrechbarkeit unbekannt']='Interruptibility unknown',
 ['Vorschau · Kanalzauber']='Preview · Channel',['Vorschau · Zauber']='Preview · Cast',
 ['Vorschau · Verlängert']='Preview · Delayed',['Vorschau · Verkürzt']='Preview · Shortened',
 ['Vorschau · Abbruch']='Preview · Cancelled',['Vorschau · Unterbrechung']='Preview · Interrupted',
 ['Vorschau · Fehlgeschlagen']='Preview · Failed',['Vorschau · Kanal angepasst']='Preview · Channel adjusted',
 ['Vorschau · Ziehen']='Preview · Drag',

 ['Elementstrom']='Element stream',['Splitter & Funken']='Shards & sparks',['Seidenfluss']='Silk flow',['Impuls']='Pulse',['Nebellicht']='Mist light',
 ['Klasse']='Class',['Allianz']='Alliance',['Feuer']='Fire',['Arkan']='Arcane',['Magier']='Mage',['Hexenmeister']='Warlock',['Priester']='Priest',['Druide']='Druid',
 ['Gebrechen']='Affliction',['Dämonologie']='Demonology',['Zerstörung']='Destruction',['Heilig']='Holy',['Disziplin']='Discipline',['Schatten']='Shadow',
 ['Gleichgewicht']='Balance',['Wiederherstellung']='Restoration',['Naturheilung']='Nature healing',['Wildheit / Wächter']='Feral / Guardian',
 ['Wilde Kraft']='Wild power',['Krieger']='Warrior',['Jäger']='Hunter',['Schurke']='Rogue',['Schamane']='Shaman',
 ['Waffen']='Arms',['Furor']='Fury',['Schutz']='Protection',['Vergeltung']='Retribution',['Tierherrschaft']='Beast mastery',
 ['Treffsicherheit']='Marksmanship',['Überleben']='Survival',['Meucheln']='Assassination',['Kampf']='Combat',['Täuschung']='Subtlety',
 ['Elementar']='Elemental',['Verstärkung']='Enhancement',
 ['Material: ']='Material: ',['Zauberoptik: ']='Spell visuals: ',['Automatisch']='Automatic',['Manuell']='Manual',['Akzente: ']='Accents: ',['Ausführung: ']='Style: ',
 ['Vorschau beenden / Position sperren']='Stop preview / lock position',['Vorschau starten / Position verschieben']='Start preview / move position',
 ['Ein']='On',['Aus']='Off',['ohne Rahmen']='frameless',['Demo: Zeitänderung / Abbruch / Unterbrechung']='Demo: timing / cancellation / interruption',
 ['Zauber / Kanal / GCD · Ereignis-Demo: /hansecast demo']='Cast / channel / GCD · event demo: /hansecast demo',
 ['Einstellungen bitte außerhalb des Kampfes öffnen.']='Please open settings outside combat.',
 ['Breite']='Width',['Höhe']='Height',['Skalierung']='Scale',['Vorschau']='Preview',
 ['Globaler Cooldown · schmale Linie']='Global cooldown · thin line',['Abschlusslicht · kurzer Lichtimpuls']='Completion · brief light pulse',
 ['Blizzard-Castbar ersetzen']='Replace Blizzard castbar',['Position zurücksetzen']='Reset position',
 ['Bei nicht verfügbaren Daten oder Grafiken bleibt die Standardanzeige erhalten.']='The default display remains when data or artwork is unavailable.',
 ['HANSE CAST · Vorschau · Ziehen zum Verschieben']='HANSE CAST · Preview · Drag to move',
 ['Vorschau · Sofortzauber / Globaler Cooldown']='Preview · Instant spell / global cooldown',
 ['Unterbrochen']='Interrupted',['Fehlgeschlagen']='Failed',['Abgebrochen']='Cancelled',
 ['Hanse Cast öffnen']='Open Hanse Cast',
 ['Rahmenlose Zauberleisten, Materialien und Komfortoptionen. Alle Einstellungen öffnen sich in einem kompakten Fenster.']='Frameless castbars, materials and comfort options. All settings open in one compact window.',
 ['Alternativ: /hansecast im Chat.\nDie Einstellungen sind außerhalb des Kampfes verfügbar.']='Alternatively: /hansecast in chat.\nSettings are available outside combat.',
 ['Erweitert / Profile']='Advanced / profiles',['Komfort']='Comfort',['Profile']='Profiles',['Ziel / Fokus']='Target / focus',
 ['Sprache']='Language',['Schrift']='Font',['Schriftgröße']='Font size',['Zeit']='Time',['Deckkraft']='Opacity',['Zaubersymbol']='Spell icon',
 ['Standard']='Default',['Modern']='Modern',['Restzeit']='Remaining',['Verstrichen']='Elapsed',['Beides']='Both',['Versteckt']='Hidden',['Links']='Left',['Rechts']='Right',
 ['Latenzmarkierung']='Latency marker',['Kanal-Hilfslinien (manuell)']='Channel guides (manual)',
 ['Anzahl Abschnitte']='Number of segments',
 ['Gleichmäßige Hilfslinien, keine gemessenen Zauberticks. Latenz nutzt nur lesbare Weltlatenz.']='Equal guides, not measured spell ticks. Latency uses accessible world latency only.',
 ['Neues Profil']='New profile',['Kopie erstellen']='Create copy',['Wechseln']='Switch',['Löschen']='Delete',['Zurücksetzen']='Reset',
 ['Exportieren']='Export',['Import prüfen']='Check import',['Import anwenden']='Apply import',
 ['Profilname']='Profile name',['Profil auswählen']='Select profile',['Import geprüft. Mit Anwenden bestätigen.']='Import checked. Confirm with Apply.',
 ['Ungültiges Profil. Keine Änderung.']='Invalid profile. Nothing changed.',['Erledigt.']='Done.',
 ['Nicht möglich: Name, Profilgrenze oder Kampf prüfen.']='Unavailable: check name, profile limit or combat.',
 ['Import / Export (Text)']='Import / export (text)',
 ['Löschen bestätigen']='Confirm delete',['Reset bestätigen']='Confirm reset',
 ['Ziel']='Target',['Fokus']='Focus',['Aktiv']='Enabled',['Sichtbarkeit']='Visibility',['Immer']='Always',['Im Kampf']='In combat',
 ['Übernehmen']='Inherit',['Symbol']='Icon',['Vorschau Ziel / Fokus']='Preview target / focus',
 ['Position X']='Position X',['Position Y']='Position Y',
}
HC.localeEnglish=en
function HC.GetLanguage()
 local choice=HC.db and HC.db.language or 'auto'
 if choice=='auto' then
  local ok,value=false,nil;if type(GetLocale)=='function' then ok,value=pcall(GetLocale) end
  return ok and value=='deDE' and 'deDE' or 'enUS'
 end
 return choice=='deDE' and 'deDE' or 'enUS'
end
function HC.L(key) return HC.GetLanguage()=='deDE' and key or en[key] or key end
HC.localizedRegions={}
function HC.Localize(region,key)
 HC.localizedRegions[region]=key;region:SetText(HC.L(key));return region
end
function HC.RefreshLocale()
 for region,key in pairs(HC.localizedRegions) do region:SetText(HC.L(key)) end
 if HC.UpdateOptions then HC.UpdateOptions() end
 if HC.UpdateAdvancedOptions then HC.UpdateAdvancedOptions() end
end
