local _,HC=...
-- One settings model, shared by the native canvas and standalone fallback.
-- No schema migration and no writes merely from opening a page.
local function S(de,en) return {de,en} end
local function T(v)
 if type(v)=='function' then return v() end
 if type(v)=='table' then return v[HC.GetLanguage and HC.GetLanguage()=='enUS' and 2 or 1] end
 return HC.L and HC.L(v) or v
end
local pageNames={
 {'player',S('Spieler','Player')},
 {'units',S('Ziel & Fokus','Target & focus')},{'profiles',S('Profile','Profiles')},
 {'help',S('Hilfe','Help')},
}
local function Page(key)
 if key=='overview' or key=='appearance' or key=='layout' or key=='comfort' then return 'player' end
 return key
end
local families={{'element','Elementstrom'},{'splinter','Splitter & Funken'},{'silk','Seidenfluss'},{'pulse','Impuls'},{'mist','Nebellicht'}}
local hosts={};HC.menuHosts=hosts
local updating=false
local function Allowed() return not InCombatLockdown() end
local function ClosePopup(h) if h.popup then h.popup:Hide() end end
local messages={
 combat=S('Im Kampf sind Änderungen gesperrt.','Changes are locked during combat.'),
 invalidName=S('Name: 1–48 Bytes, nicht leer; keine Steuerzeichen oder | = \\.','Name: 1–48 bytes, not blank; no control characters or | = \\.'),
 duplicate=S('Dieser Profilname ist bereits vergeben.','This profile name is already in use.'),
 limit=S('Alle zwölf Profilplätze sind belegt.','All twelve profile slots are occupied.'),
 last=S('Das letzte Profil kann nicht gelöscht werden.','The last profile cannot be deleted.'),
 empty=S('Bitte zuerst den Importtext prüfen.','Check the import text first.'),
 name=S('Das ausgewählte Profil existiert nicht mehr.','The selected profile no longer exists.'),
}
local function Status(h,message) h.message=message;HC.UpdateOptions() end
local function Result(h,ok,reason)
 Status(h,ok and S('Erledigt.','Done.') or messages[reason] or S('Ungültige Daten. Keine Änderung.','Invalid data. Nothing changed.'))
end
function HC.SetMenuValue(key,value,unit)
 if HC.unitBarsInDevelopment and (unit or key=='hideBlizzardTarget' or key=='hideBlizzardFocus') then return false,'in-development' end
 if not Allowed() then return false,'combat' end
 local specKey=unit and ('unitBars.'..unit..'.'..key) or key
 if not HC.ValidProfileValue or not HC.ValidProfileValue(specKey,value) then return false,'value' end
 if unit then
  if unit~='target' and unit~='focus' then return false,'value' end
  local ok,why=HC.ConfigureUnitBar(unit,{[key]=value});if not ok then return false,why end
 else
  if key=='autoSpellVisual' and HC.elements[HC.db.element].faction then return false,'value' end
  if key=='castDelay' and HC.db[key]~=value and HC.ResetComfortTiming then HC.ResetComfortTiming() end
  HC.db[key]=value
  if key=='element' and HC.elements[value].faction then HC.db.faction=HC.elements[value].faction end
 end
 if HC.ApplyLayout then HC.ApplyLayout() end
 if HC.UpdateSpellTheme then HC.UpdateSpellTheme(HC.preview and nil or HC.cast) end
 if HC.ApplyTheme then HC.ApplyTheme() end
 if HC.RefreshUnitBars then HC.RefreshUnitBars() end
 if HC.UpdateBlizzard then HC.UpdateBlizzard() end
 if HC.Refresh then HC.Refresh() end
 if HC.RefreshGCD then HC.RefreshGCD() end
 if HC.SaveActiveProfile then HC.SaveActiveProfile() end
 if key=='language' and HC.RefreshLocale then HC.RefreshLocale() end
 HC.UpdateOptions();return true
end
local function Label(parent,value,font)
 local f=parent:CreateFontString(nil,'OVERLAY',font or 'GameFontHighlight')
 f:SetJustifyH('LEFT');f:SetWordWrap(true);f:SetText(T(value));return f
end
local function Button(parent,value,action,selector)
 local b=CreateFrame('Button',nil,parent,selector and 'BackdropTemplate' or 'UIPanelButtonTemplate');b:SetSize(240,26)
 b:SetNormalFontObject('GameFontNormal');b:SetHighlightFontObject('GameFontHighlight');b:SetDisabledFontObject('GameFontDisable')
 if selector then
  b:SetBackdrop({bgFile='Interface\\ChatFrame\\ChatFrameBackground',edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
  b:SetBackdropColor(.055,.05,.04,.95);b:SetBackdropBorderColor(.6,.48,.28,1)
 end
 b:SetText(T(value))
 b:SetScript('OnClick',function() if Allowed() then action() end end);return b
end
local function Tooltip(widget,title,help)
 widget:SetScript('OnEnter',function(self)
  if not GameTooltip or T(help)=='' then return end
  GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(T(title),1,.82,0)
  GameTooltip:AddLine(T(help),1,1,1,true);GameTooltip:Show()
 end)
 widget:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
end
local function Edit(parent,multi)
 local e=CreateFrame('EditBox',nil,parent,'InputBoxTemplate');e:SetSize(240,28)
 e:SetAutoFocus(false);e:SetMultiLine(multi==true);e:SetMaxLetters(multi and 8192 or 48);e:SetFontObject('GameFontHighlight')
 return e
end
local function ClearFocus(e) e:ClearFocus() end
local function Enable(control,on)
 if control.SetEnabled then control:SetEnabled(on) elseif on then control:Enable() else control:Disable() end
 control:SetAlpha(on and 1 or .5)
end
local function DiscardEdits(h,unitsOnly)
 for _,r in ipairs(h.rows) do if r.discard and (not unitsOnly or r.unitEdit) then r.discard() end end
end
local function ClearImport(h)
 h.checkedText=nil;h.checkedProfile=nil;h.checkedRevision=nil;h.checkedDB=nil
end
local function SelectPage(h,key)
 if HC.unitBarsInDevelopment and Page(key)=='units' then return end
 DiscardEdits(h)
 ClosePopup(h);h.confirm:Hide();h.page=Page(key);HC.menuPage=h.page;h.message=nil
 h.scroll:SetVerticalScroll(0);HC.UpdateOptions()
end
local function Confirm(h,text,action)
 -- Drop pending text before disabling controls can trigger native focus loss.
 DiscardEdits(h)
 ClosePopup(h);h.confirm.active=HC.db.activeProfile;h.confirm.caption=text;h.confirm.action=action
 h.confirm:Show();HC.UpdateOptions()
end
local function Dropdown(h,anchor,items,chosen,action)
 if not Allowed() then return end
 local p=h.popup
 if not p then
  p=CreateFrame('Frame',nil,UIParent,'BackdropTemplate');h.popup=p;p:SetFrameStrata('TOOLTIP');p:SetClampedToScreen(true);p:EnableMouse(true)
  p:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
  p:SetBackdropColor(.06,.07,.09,1);p:SetBackdropBorderColor(.6,.5,.3,1)
  p.scroll=CreateFrame('ScrollFrame',nil,p,'UIPanelScrollFrameTemplate');p.scroll:SetPoint('TOPLEFT',8,-8);p.scroll:SetPoint('BOTTOMRIGHT',-28,8)
  p.child=CreateFrame('Frame',nil,p.scroll);p.child:SetSize(300,30);p.scroll:SetScrollChild(p.child);p.buttons={}
 end
 p:ClearAllPoints();p:SetPoint('TOPLEFT',anchor,'BOTTOMLEFT',0,-2);p:SetSize(items.wide and 460 or 336,math.min(250,#items*30+16));p.child:SetWidth(items.wide and 424 or 300);p.child:SetHeight(#items*30);p.scroll:SetVerticalScroll(0)
 for i,item in ipairs(items) do
  local b=p.buttons[i]
  if not b then b=Button(p.child,'',function() end,true);b:SetSize(296,28);b:SetPoint('TOPLEFT',0,-(i-1)*30);p.buttons[i]=b end
  b:SetWidth(items.wide and 420 or 296)
  b:SetNormalFontObject(items.wide and 'GameFontHighlightSmall' or 'GameFontNormal')
  b:SetHighlightFontObject(items.wide and 'GameFontHighlightSmall' or 'GameFontHighlight')
  Tooltip(b,item[2],item[2])
  b:SetText((item[1]==chosen and '|cffffd080> |r' or '')..T(item[2]))
  local value=item[1];b:SetScript('OnClick',function() p:Hide();if Allowed() then action(value) end end);b:Show()
 end
 for i=#items+1,#p.buttons do p.buttons[i]:Hide() end;p:Show()
end
local function Row(h,page,id,title,help,height)
 page=Page(page)
 local p=h.pages[page];local r=CreateFrame('Frame',nil,p)
 r:SetPoint('TOPLEFT',0,-p.used);r:SetPoint('TOPRIGHT',0,-p.used);r:SetHeight(height or 34)
 p.used=p.used+(height or 34);p:SetHeight(p.used)
 r.title=Label(r,title,'GameFontNormal');r.title:SetPoint('TOPLEFT',0,-6);r.title:SetPoint('TOPRIGHT',-258,-6)
 r.help=Label(r,help,'GameFontHighlightSmall');r.help:SetPoint('TOPLEFT',0,-40);r.help:SetPoint('TOPRIGHT',-8,-40)
 r.help:Hide();r:EnableMouse(true);Tooltip(r,title,help)
 r.titleText=title;r.helpText=help;r.widgets={};r.id=id;r.page=page;r.baseHeight=height or 34;h.rows[#h.rows+1]=r;h.controls[id]=r
 return r
end
local function Get(h,key,unit) if unit then return HC.db.unitBars[h.unit][key] else return HC.db[key] end end
local function Field(h,page,id,title,help,choices,key,unit)
 local r=Row(h,page,id,title,help)
 r.items=function() return type(choices)=='function' and choices() or choices end
 r.get=function() return Get(h,key,unit) end
 r.select=function(value) Result(h,HC.SetMenuValue(key,value,unit and h.unit)) end
 r.button=Button(r,'',function() Dropdown(h,r.button,r.items(),r.get(),r.select) end,true);r.button:SetPoint('TOPRIGHT',-4,0);r.widgets={r.button}
 r.refresh=function()
  local caption='';for _,v in ipairs(r.items()) do if v[1]==r.get() then caption=T(v[2]);break end end;r.button:SetText(caption..'  >')
 end
 return r
end
local function Toggle(h,page,id,title,help,key,unit,enabled)
 local r=Row(h,page,id,title,help);local b=CreateFrame('CheckButton',nil,r,'UICheckButtonTemplate')
 b:SetSize(30,30);b:SetPoint('TOPRIGHT',-8,2);r.button=b;r.widgets={b};r.enabled=enabled;r.checkbox=true
 r.title:SetPoint('TOPRIGHT',-48,-2)
 b:SetScript('OnClick',function()
  if Allowed() and (not enabled or enabled()) then Result(h,HC.SetMenuValue(key,not Get(h,key,unit),unit and h.unit)) else HC.UpdateOptions() end
 end)
 r.refresh=function() b:SetChecked(Get(h,key,unit)==true) end;return r
end
local function Number(h,page,id,title,help,key,lo,hi,step,factor,unit,enabled)
 factor=factor or 1;local r=Row(h,page,id,title,help)
 r.unitEdit=unit==true
 local e=Edit(r);e:SetSize(78,26);e:SetPoint('TOPRIGHT',-12,0);r.edit=e
 local function current() return Get(h,key,unit)*factor end
 local function editContext()
  return {db=HC.db,profile=HC.db.activeProfile,revision=HC.profileRevision or 0,unit=unit and h.unit}
 end
 local function sameContext(context)
  return context and context.db==HC.db and context.profile==HC.db.activeProfile
   and context.revision==(HC.profileRevision or 0) and context.unit==(unit and h.unit)
 end
 r.discard=function()
  r.dirty=false;r.editContext=nil;e:ClearFocus()
 end
 r.commit=function(value,context)
  if not Allowed() or h.confirm:IsShown() or (enabled and not enabled())
   or (context and not sameContext(context)) then return false end
  local n=tonumber(value)
  if not n or n~=n or n<lo or n>hi then
   e:SetText(string.format('%g',current()));Status(h,T(S('Zulässiger Bereich: ','Allowed range: '))..lo..'–'..hi);return false
  end
  n=math.max(lo,math.min(hi,math.floor((n-lo)/step+.5)*step+lo))
  local ok,why=HC.SetMenuValue(key,n/factor,unit and h.unit);Result(h,ok,why);return ok
 end
 local function commit()
  if r.dirty then
   local context=r.editContext;r.dirty=false;r.editContext=nil
   if sameContext(context) then r.commit(e:GetText(),context) end
  end
  HC.UpdateOptions()
 end
 e:SetScript('OnTextChanged',function(_,user)
  if user and Allowed() and not h.confirm:IsShown() then
   if not r.dirty then r.editContext=editContext() end;r.dirty=true
  end
 end)
 e:SetScript('OnEnterPressed',function() commit();e:ClearFocus() end);e:SetScript('OnEditFocusLost',commit)
 e:SetScript('OnEscapePressed',function() r.discard();e:SetText(string.format('%g',current())) end)
 local slider=CreateFrame('Slider',nil,r,'OptionsSliderTemplate');r.slider=slider
 slider:SetSize(134,18);slider:SetPoint('TOPRIGHT',-104,-4);slider:SetMinMaxValues(lo,hi);slider:SetValueStep(step);slider:SetObeyStepOnDrag(true)
 if slider.Low then slider.Low:SetText('') end;if slider.High then slider.High:SetText('') end
 slider:SetScript('OnValueChanged',function(_,value)
  if not updating then r.discard();r.commit(value) end
 end)
 r.widgets={e,slider};r.enabled=enabled
 r.refresh=function()
  if r.dirty and not sameContext(r.editContext) then r.discard() end
  if not r.dirty then e:SetText(string.format('%g',current())) end;slider:SetValue(current())
 end
 return r
end
local function Action(h,page,id,title,help,caption,action)
 local r=Row(h,page,id,title,help);r.button=Button(r,caption,action);r.button:SetPoint('TOPRIGHT',-4,0);r.widgets={r.button}
 r.refresh=function() r.button:SetText(T(caption)) end;return r
end
local function Note(h,page,id,title,text)
 local r=Row(h,page,id,title,text,94);r.note=true;r.help:Show();r.title:SetPoint('TOPRIGHT',-4,-2);return r
end
local function Groups() local r={};for _,g in ipairs(HC.visualGroups) do r[#r+1]={g.key,g.title} end;return r end
local function Elements(group)
 local r={};for _,g in ipairs(HC.visualGroups) do if g.key==group then for _,k in ipairs(g.elements) do r[#r+1]={k,HC.elements[k].title} end end end;return r
end
function HC.AppearanceChoices(filter)
 local list={wide=true}
 local group=HC.GetVisualGroup(HC.db.element).key
 for _,family in ipairs(families) do
  for _,g in ipairs(HC.visualGroups) do
   for _,element in ipairs(g.elements) do
    local key=family[1]..':'..element
    if filter~='favorites' or HC.IsFavoriteStyle(key) then
     if filter~='group' or g.key==group then
      list[#list+1]={key,T(family[2])..' / '..T(g.title)..': '..T(HC.elements[element].title)}
     end
    end
   end
  end
 end
 return list
end
local function Build(h)
 local active=function() return T(S('Aktives Profil: ','Active profile: '))..HC.db.activeProfile end
 Toggle(h,'overview','hideBlizzard',S('Blizzard-Spielerleiste ersetzen','Replace Blizzard player bar'),S('Bei passenden Hanse-Cast-Zaubern ausblenden. Bei fehlenden Daten/Grafiken bleibt die Standardanzeige verfügbar. Ziel-/Fokusframes bleiben erhalten.','Hide during valid Hanse Cast spells. Missing data/artwork keeps the default display available. Target/focus frames remain.'),'hideBlizzard')

 local filter=Field(h,'appearance','appearanceFilter',S('Optiken filtern','Filter appearances'),S('Alle Varianten, aktuelle Themengruppe oder deine Favoriten. Der Filter ändert keine Optik.','All variants, current theme group or your favourites. Filtering does not change the appearance.'),{{'all',S('Alle Optiken','All appearances')},{'group',S('Aktuelle Themengruppe','Current theme group')},{'favorites',S('Nur Favoriten','Favourites only')}},'element')
 filter.get=function() return h.appearanceFilter or 'all' end
 filter.select=function(value)
  if value~='all' and value~='group' and value~='favorites' then return end
  h.appearanceFilter=value;ClosePopup(h);HC.UpdateOptions()
 end
 local browser=Field(h,'appearance','appearanceBrowse',S('Optik auswählen','Choose appearance'),S('Kategorie und Optik gemeinsam auswählen. Favoriten werden pro Profil gespeichert.','Select category and appearance together. Favourites are saved per profile.'),function() return HC.AppearanceChoices(h.appearanceFilter) end,'element')
 browser.get=function() return HC.db.family..':'..HC.db.element end
 browser.select=function(value) Result(h,HC.ApplyAppearance(value)) end
 local refreshBrowser=browser.refresh
 browser.refresh=function()
  refreshBrowser()
  local items=browser.items();local found=false
  for _,item in ipairs(items) do if item[1]==browser.get() then found=true end end
  if found then
   browser.button:SetText(T(HC.GetVisualGroup(HC.db.element).title)..': '..T(HC.elements[HC.db.element].title)..'  >')
  end
  browser.button:SetNormalFontObject('GameFontHighlightSmall');browser.button:SetHighlightFontObject('GameFontHighlightSmall')
  if #items==0 then browser.button:SetText(T(S('Noch keine Favoriten','No favourites yet')))
  elseif not found then browser.button:SetText(T(S('Auswahl außerhalb des Filters','Selection outside filter'))..'  >') end
 end
 browser.enabled=function() return #browser.items()>0 end
 Action(h,'appearance','favorite',S('Aktuelle Optik merken','Remember current appearance'),S('Bis zu 20 Kombinationen aus Kategorie und Optik pro Profil.','Up to 20 category/appearance combinations per profile.'),function()
  return T(HC.IsFavoriteStyle(HC.db.family..':'..HC.db.element) and S('Favorit entfernen','Remove favourite') or S('Als Favorit speichern','Save favourite'))
 end,function() Result(h,HC.ToggleFavoriteStyle(HC.db.family..':'..HC.db.element)) end)
 Field(h,'appearance','family',S('Kategorie','Category'),S('Grafischer Aufbau und Effekte. Zauberzeit und Spielmechanik bleiben gleich.','Visual structure and effects. Spell duration and mechanics remain unchanged.'),families,'family')
 local g=Field(h,'appearance','group',S('Themengruppe','Theme group'),S('Alle Klassenoptiken sind frei wählbar. Fraktionsoptiken wählen auch das passende Wappen.','All class styles are available. Faction styles also select the matching emblem.'),Groups,'element')
 g.get=function() return HC.GetVisualGroup(HC.db.element).key end
 g.select=function(v) local list=Elements(v);if list[1] then Result(h,HC.SetMenuValue('element',list[1][1])) end end
 Field(h,'appearance','element',S('Manuelle Optik','Manual appearance'),S('Gilt auch für unbekannte Zauber und Vorschauen.','Also used for unknown spells and previews.'),function() return Elements(HC.GetVisualGroup(HC.db.element).key) end,'element')
 Toggle(h,'appearance','autoSpellVisual',S('Automatische Zauberoptik','Automatic spell appearance'),function()
  return T(HC.elements[HC.db.element].faction and S('Fraktionsoptik bleibt fest. Die Automatikpräferenz bleibt gespeichert.','Faction appearance stays fixed. Your automatic preference is preserved.') or S('Bekannte, zugängliche Zauber erhalten eine passende Optik. Sonst gilt die manuelle Auswahl.','Known accessible spells use a matching appearance. Otherwise the manual choice is used.'))
 end,'autoSpellVisual',nil,function() return not HC.elements[HC.db.element].faction end)
 Field(h,'appearance','identity',S('Akzentfarbe','Accent colour'),S('Klassenfarbe beeinflusst Nebenakzente, nicht die Hauptfarbe.','Class colour affects secondary accents, not the main colour.'),{{'neutral',S('Neutral','Neutral')},{'class',S('Eigene Klassenfarbe','Your class colour')}},'identity')
 Field(h,'appearance','faction',S('Fraktionswappen','Faction emblem'),S('Wappen neben der Spielerleiste. Ändert nicht deine Charakterfraktion.','Emblem beside the player bar. Does not change your character faction.'),{{'none','Aus'},{'alliance','Allianz'},{'horde','Horde'}},'faction')
 Action(h,'appearance','preview',S('Auswahl ausprobieren','Try this appearance'),S('Künstliche Vorschau im Spiel; keine echte Zaubermessung.','Artificial preview in game; not a real spell measurement.'),S('Vorschau starten','Start preview'),function() HC.StartMenuPreview(h,'player') end)

 local sizeHelp=S('UI-Einheiten; die Bildschirmgröße hängt auch von der WoW-Skalierung ab.','UI units; screen size also depends on WoW UI scale.')
 Number(h,'layout','width','Breite',sizeHelp,'width',180,600,20)
 Number(h,'layout','height','Höhe',S('Mindestens 24 skalierte UI-Einheiten. Kleine Skalierung kann die Grundhöhe automatisch erhöhen.','At least 24 scaled UI units. A small scale may automatically increase the base height.'),'height',24,60,2)
 Number(h,'layout','scale','Skalierung',S('Gesamtgröße in Prozent.','Overall size in percent.'),'scale',60,200,10,100)
 Number(h,'layout','x','Position X',S('Vom Bildschirmzentrum: negativ links, positiv rechts. Auf den sichtbaren Bereich begrenzt.','From screen centre: negative left, positive right. Limited to the visible area.'),'x',-10000,10000,1)
 Number(h,'layout','y','Position Y',S('Vom Bildschirmzentrum: negativ unten, positiv oben.','From screen centre: negative down, positive up.'),'y',-10000,10000,1)
 Action(h,'layout','move',S('Verschieben','Move'),S('Linke Maustaste zum Ziehen. Fertig sperrt die Leiste wieder.','Drag with the left mouse button. Done locks the bar again.'),S('Im Spiel positionieren','Position in game'),function() HC.StartMenuPreview(h,'player') end)
 Action(h,'layout','centerHorizontal',S('Horizontal ausrichten','Horizontal alignment'),S('Setzt nur die horizontale Position auf die Bildschirmmitte; Höhe und Gestaltung bleiben erhalten.','Sets only the horizontal position to screen centre; vertical position and appearance are preserved.'),S('Mittig ausrichten','Centre horizontally'),function() Result(h,HC.SetMenuValue('x',0)) end)
 Action(h,'layout','resetPosition',S('Nur Position zurücksetzen','Reset position only'),S('Gestaltung und andere Profile bleiben erhalten.','Appearance and other profiles are preserved.'),S('Spielerposition zurücksetzen','Reset player position'),function() HC.SetMenuValue('x',0);HC.SetMenuValue('y',-180) end)

 local preset=Field(h,'comfort','comfortPreset',S('Komfort-Vorlage','Comfort preset'),S('Ändert die genannten Komfortwerte im aktiven Profil. Position, Größe, Optik und Favoriten bleiben erhalten.','Changes the listed comfort settings in the active profile. Position, size, appearance and favourites are preserved.'),{{'simple',S('Einfach: Standardtext, Restzeit, ohne Extras','Simple: standard text, remaining time, no extras')},{'readable',S('Lesbar: Schrift 16, beide Zeiten, Symbol links','Readable: font 16, both times, icon left')},{'quiet',S('Ruhig: ohne Bewegung, Licht und Extras','Quiet: no motion, light or extras')}},'element')
 preset.get=function() return '' end
 preset.refresh=function() preset.button:SetText(T(S('Vorlage auswählen …','Choose preset …'))) end
 preset.select=function(value)
  if value~='simple' and value~='readable' and value~='quiet' then return end
  Confirm(h,S('Komfortwerte im aktiven Profil durch diese Vorlage ersetzen? Position, Größe und Optik bleiben erhalten.','Replace comfort settings in the active profile with this preset? Position, size and appearance are preserved.'),function() Result(h,HC.ApplyComfortPreset(value)) end)
 end
 Field(h,'comfort','font','Schrift',S('Schrift für die Spielerleiste.','Font for the player bar.'),{{'default','Standard'},{'modern','Modern'}},'font')
 Number(h,'comfort','fontSize','Schriftgröße',S('Schriftgröße für die Spielerleiste. Die Leistenskalierung wirkt zusätzlich.','Font size for the player bar. Bar scale also applies.'),'fontSize',10,20,1)
 Field(h,'comfort','timeFormat',S('Zeitanzeige','Time display'),'',{{'remaining','Restzeit'},{'elapsed','Verstrichen'},{'both','Beides'},{'hidden','Aus'}},'timeFormat')
 Number(h,'comfort','opacity','Deckkraft',S('Sichtbarkeit der Spielerleiste in Prozent.','Player bar visibility in percent.'),'opacity',20,100,10,100)
 Field(h,'comfort','iconPosition','Zaubersymbol','',{{'hidden','Aus'},{'left','Links'},{'right','Rechts'}},'iconPosition')
 Toggle(h,'comfort','gcd',S('Globale Abklingzeit (GCD)','Global cooldown (GCD)'),S('Die kurze gemeinsame Abklingzeit vieler Fähigkeiten als schmale Linie.','The brief shared cooldown of many abilities as a thin line.'),'gcd')
 Toggle(h,'comfort','quietMode',S('Ruhiger Modus','Reduced motion'),S('Stoppt dekorative Bewegung und zusätzliche Lichtimpulse. Der Zauberfortschritt bleibt flüssig.','Stops decorative motion and extra light pulses. Cast progress stays smooth.'),'quietMode')
 Toggle(h,'comfort','finishCue',S('Lichtimpuls beim Abschluss','Completion light pulse'),S('Kurzer zusätzlicher Lichtimpuls nach erfolgreichem Abschluss.','Brief extra light pulse after successful completion.'),'finishCue')
 Toggle(h,'comfort','castDelay',S('Zauberstart-Verzögerung','Cast start delay estimate'),S('Start ~N ms nur bei sicher zugeordnetem Sende- und Startereignis. Schätzwert, keine Serverlatenz.','Start ~N ms only for safely matched sent/start events. An estimate, not server latency.'),'castDelay')
 Toggle(h,'comfort','queueWindow',S('Zauberwarteschlange','Spell queue window'),S('Separater cyanfarbener Hinweis unter der Leiste anhand der zugänglichen Client-Einstellung. Die Weltlatenz bleibt getrennt darüber.','Separate cyan guide below the bar from the accessible client setting. World latency remains separate above it.'),'queueWindow')
 Toggle(h,'comfort','latency','Latenzmarkierung',S('Orientierung anhand der Weltlatenz; kein exaktes Eingabe- oder Zauberwarteschlangenfenster.','Guidance based on world latency; not an exact input or spell queue window.'),'latency')
 Toggle(h,'comfort','channelTicks',S('Manuelle Kanal-Hilfslinien','Manual channel guides'),S('Gleichmäßige Unterteilung, keine erkannten Schadens- oder Heilticks.','Equal segments, not detected damage or healing ticks.'),'channelTicks')
 Number(h,'comfort','channelTickCount','Anzahl Abschnitte',S('Nur bei eingeschalteten Kanal-Hilfslinien verfügbar.','Available when channel guides are enabled.'),'channelTickCount',2,10,1,1,nil,function() return HC.db.channelTicks end)

 local u=Field(h,'units','unit',S('Bearbeitete Leiste','Editing bar'),S('Ziel und Fokus haben eigene Einstellungen.','Target and focus have independent settings.'),{{'target','Ziel'},{'focus','Fokus'}},'element')
 u.get=function() return h.unit end;u.select=function(v)
  if v~='target' and v~='focus' then return end
  DiscardEdits(h,true);h.unit=v;HC.UpdateOptions()
 end
 Toggle(h,'units','unitEnabled',S('Eigene Leiste aktivieren','Enable custom bar'),S('Aktiviert die eigene Zauberleiste. Lebens- und Manabalken bleiben erhalten.','Enables the custom cast bar. Health and power bars remain unchanged.'),'enabled',true)
 Toggle(h,'units','hideBlizzardFocus',S('Blizzard-Fokusleiste ersetzen','Replace Blizzard focus cast bar'),S('Nur bei ausgewähltem Fokus einstellbar. Verbirgt die Standard-Zauberleiste, solange Hanse den echten Fokuszauber darstellt. Bei fehlenden Daten oder Grafiken bleibt Blizzard verfügbar.','Configurable when Focus is selected. Hides the default cast bar while Hanse displays the actual focus cast. Missing data or artwork keeps Blizzard available.'),'hideBlizzardFocus',false,function() return h.unit=='focus' end)
 h.controls.hideBlizzardFocus.visible=function() return h.unit=='focus' end
 Toggle(h,'units','hideBlizzardTarget',S('Blizzard-Zielleiste ersetzen','Replace Blizzard target cast bar'),S('Nur bei ausgewähltem Ziel einstellbar. Verbirgt die Standard-Zauberleiste, solange Hanse den echten Zielzauber darstellt. Bei fehlenden Daten oder Grafiken bleibt Blizzard verfügbar.','Configurable when Target is selected. Hides the default cast bar while Hanse displays the actual target cast. Missing data or artwork keeps Blizzard available.'),'hideBlizzardTarget',false,function() return h.unit=='target' end)
 h.controls.hideBlizzardTarget.visible=function() return h.unit=='target' end
 Field(h,'units','visibility',S('Anzeigen bei','Show during'),S('Nur zugängliche Zauber; keine dauerhaft leere Leiste.','Only accessible spells; not a permanently empty bar.'),{{'always',S('Innerhalb & außerhalb des Kampfes','In and out of combat')},{'combat','Im Kampf'}},'visibility',true)
 Toggle(h,'units','showIcon','Zaubersymbol','','showIcon',true)
 Field(h,'units','unitFamily',S('Kategorie','Category'),function() return T(S('Spieler-Auswahl: ','Player selection: '))..T((function() for _,v in ipairs(families) do if v[1]==HC.db.family then return v[2] end end end)()) end,function()
  local r={{'inherit',S('Von Spielerleiste übernehmen','Inherit player bar')}};for _,v in ipairs(families) do r[#r+1]=v end;return r
 end,'family',true)
 Field(h,'units','unitElement',S('Optik','Appearance'),function() return T(S('Spieler-Auswahl: ','Player selection: '))..T(HC.elements[HC.db.element].title) end,function()
  local r={{'inherit',S('Von Spielerleiste übernehmen','Inherit player bar')}}
  for _,g in ipairs(HC.visualGroups) do for _,key in ipairs(g.elements) do r[#r+1]={key,T(g.title)..' · '..T(HC.elements[key].title)} end end;return r
 end,'element',true)
 for _,v in ipairs({{'width','Breite',180,600,20,1},{'height','Höhe',24,60,2,1},{'scale','Skalierung',60,200,10,100},{'x','Position X',-10000,10000,1,1},{'y','Position Y',-10000,10000,1,1}}) do
  Number(h,'units','unit'..v[1],v[2],sizeHelp,v[1],v[3],v[4],v[5],v[6],true)
 end
 Action(h,'units','unitPreview',S('Vorschau & Position','Preview & position'),S('Nur die ausgewählte Leiste; keine dauerhafte Aktivierung abgeschalteter Leisten.','Only the selected bar; does not permanently enable a disabled bar.'),S('Diese Leiste positionieren','Position this bar'),function() HC.StartMenuPreview(h,h.unit) end)

 local p=Field(h,'profiles','profileSelect',S('Profil auswählen','Select profile'),S('Auswahl allein aktiviert nichts. Maximal zwölf Profile.','Selecting does not activate a profile. Up to twelve profiles.'),function()
  local r={};for _,n in ipairs(HC.ProfileNames()) do r[#r+1]={n,n..(n==HC.db.activeProfile and T(S(' · Aktiv',' · Active')) or '')} end;return r
 end,'element')
 p.get=function() return h.selectedProfile end;p.select=function(v) h.selectedProfile=v;HC.UpdateOptions() end
 Action(h,'profiles','activate',S('Ausgewähltes Profil','Selected profile'),function() return h.selectedProfile end,S('Aktivieren','Activate'),function() Result(h,HC.SwitchProfile(h.selectedProfile)) end)
 local name=Row(h,'profiles','name',S('Name für neues Profil','Name for new profile'),S('Für Erstellen, Kopieren oder Import als neues Profil.','For creating, copying or importing as a new profile.'))
 h.profileName=Edit(name);h.profileName:SetPoint('TOPRIGHT',-4,0);name.widgets={h.profileName};h.profileName:SetScript('OnEscapePressed',ClearFocus)
 Action(h,'profiles','new',S('Mit Standardwerten starten','Start with defaults'),S('Erstellt und aktiviert ein neues Profil. Bestehende Profile bleiben erhalten.','Creates and activates a new profile. Existing profiles are preserved.'),S('Neues Profil','New profile'),function() Result(h,HC.CreateProfile(h.profileName:GetText(),false));h.selectedProfile=HC.db.activeProfile;HC.UpdateOptions() end)
 Action(h,'profiles','copy',S('Aktives Profil kopieren','Copy active profile'),active,S('Kopie erstellen','Create copy'),function() Result(h,HC.CreateProfile(h.profileName:GetText(),true));h.selectedProfile=HC.db.activeProfile;HC.UpdateOptions() end)
 Action(h,'profiles','delete',S('Ausgewähltes Profil löschen','Delete selected profile'),function() return h.selectedProfile end,S('Löschen …','Delete …'),function()
  local name=h.selectedProfile;Confirm(h,function() return T(S('Profil endgültig löschen: ','Permanently delete profile: '))..name end,function() Result(h,HC.DeleteProfile(name));h.selectedProfile=HC.db.activeProfile end)
 end)
 Action(h,'profiles','reset',S('Zurücksetzen & aktivieren','Reset & activate'),function() return h.selectedProfile end,S('Zurücksetzen …','Reset …'),function()
  local name=h.selectedProfile;Confirm(h,function() return T(S('Auf Standardwerte zurücksetzen und aktivieren: ','Reset to defaults and activate: '))..name end,function()
   local ok,why=HC.SwitchProfile(name);if ok then ok,why=HC.ResetProfile() end;Result(h,ok,why)
  end)
 end)
 Action(h,'profiles','export',S('Aktives Profil exportieren','Export active profile'),active,S('Exportieren','Export'),function()
  h.importText:SetText(HC.ExportProfile());HC.pendingProfileImport=nil;ClearImport(h);h.importText:HighlightText()
  Status(h,S('Profiltext unten markieren und mit Strg+C kopieren.','Select the profile text below and copy with Ctrl+C.'))
 end)
 local input=Row(h,'profiles','importText',S('Profiltext','Profile text'),S('Strg+V zum Einfügen. Import wird geprüft; es wird kein Code ausgeführt.','Ctrl+V to paste. Import is validated; no code is executed.'),245);input.title:SetPoint('TOPRIGHT',-4,-2)
 local sc=CreateFrame('ScrollFrame',nil,input,'UIPanelScrollFrameTemplate');sc:SetPoint('TOPLEFT',8,-80);sc:SetPoint('BOTTOMRIGHT',-28,12)
 h.importText=Edit(sc,true);h.importText:SetSize(440,150);sc:SetScrollChild(h.importText)
 h.importText:SetScript('OnTextChanged',function() HC.pendingProfileImport=nil;ClearImport(h);if not updating then HC.UpdateOptions() end end)
 h.importText:SetScript('OnEscapePressed',ClearFocus);input.widgets={h.importText}
 Action(h,'profiles','checkImport',S('1. Import prüfen','1. Check import'),S('Prüft nur. Deine Einstellungen bleiben unverändert.','Checks only. Your settings stay unchanged.'),S('Prüfen','Check'),function()
  local text=h.importText:GetText();local ok,why=HC.StageProfileImport(text);ClearImport(h)
  if ok then
   h.checkedText=text;h.checkedProfile=HC.db.activeProfile;h.checkedRevision=HC.profileRevision or 0;h.checkedDB=HC.db
  end
  if ok then Status(h,S('Import gültig. Ziel wählen und bewusst anwenden.','Import valid. Choose a destination and apply explicitly.')) else Result(h,false,why) end
 end)
 local function validImport()
  return h.checkedText~=nil and h.checkedText==h.importText:GetText() and h.checkedDB==HC.db
   and h.checkedProfile==HC.db.activeProfile and h.checkedRevision==(HC.profileRevision or 0)
 end
 local nr=Action(h,'profiles','importNew',S('2. Als neues Profil importieren','2. Import as a new profile'),S('Verwendet den oben eingegebenen Namen. Bestehende Profile bleiben erhalten.','Uses the name above. Existing profiles are preserved.'),S('Neu importieren','Import as new'),function()
  if validImport() then Result(h,HC.ImportAsNewProfile(h.profileName:GetText(),h.checkedText));h.selectedProfile=HC.db.activeProfile;HC.UpdateOptions() end
 end);nr.enabled=validImport
 local ow=Action(h,'profiles','overwrite',S('Alternativ: aktives Profil ersetzen','Alternatively: replace active profile'),active,S('Überschreiben …','Overwrite …'),function()
  if not validImport() then return end
  local name=HC.db.activeProfile;local text=h.checkedText
  Confirm(h,function() return T(S('Aktives Profil mit Import ersetzen: ','Replace active profile with import: '))..name end,function()
   if HC.db.activeProfile==name and h.checkedText==text and validImport() then Result(h,HC.ApplyProfileImport(text)) end
  end)
 end);ow.enabled=validImport

 Field(h,'help','language','Sprache',S('Im Profil gespeichert. Automatisch folgt der Spielsprache.','Saved in the profile. Automatic follows the game language.'),{{'auto','Automatisch'},{'deDE','Deutsch'},{'enUS','English'}},'language')
 Note(h,'help','guide',S('In vier Schritten starten','Get started in four steps'),S('1. Gestaltung wählen. 2. Größe und Position anpassen. 3. Vorschau beenden. 4. Echten Zauber wirken und Darstellung prüfen.','1. Choose an appearance. 2. Adjust size and position. 3. End preview. 4. Cast a real spell to check the result.'))
 Note(h,'help','unitDevelopment',S('Ziel & Fokus – in Arbeit','Target & focus – in development'),S('Derzeit deaktiviert. Separate kompakte Leisten sind geplant. Blizzard zeigt Ziel und Fokus weiterhin an.','Currently disabled. Separate compact bars are planned. Blizzard continues to display target and focus.'))
 Note(h,'help','limits',S('Grenzen der Anzeige','Display limitations'),S('Geschützte oder fehlende Daten können die eigene Leiste ausblenden. Keine Empower-Zauber. Kanal-Hilfslinien sind manuell.','Restricted or missing data can hide the custom bar. No empower spells. Channel guides are manual.'))
 Action(h,'help','demo',S('Ereignis-Demo','Event demo'),S('Künstliche Beispiele für Zeitänderung, Abbruch und Unterbrechung.','Artificial examples of timing changes, cancellation and interruption.'),S('Demo starten','Start demo'),function() HC.StartMenuPreview(h,'player','feedback') end)
 Action(h,'help','diagnose',S('Diagnoseinformationen','Diagnostic information'),S('Version und Status im Chat; es werden keine privaten Chatnachrichten gesammelt.','Version and status in chat; does not collect private messages.'),S('Status im Chat anzeigen','Show status in chat'),function() if SlashCmdList.HANSECAST then SlashCmdList.HANSECAST('status') end end)
 Note(h,'help','support',S('Fehler melden','Report an issue'),function() return 'Hanse Cast '..HC.version..'\n'..T(S('Nenne WoW-Version und Schritte zum Nachstellen. /hansecast öffnet dieses Menü.','Include the WoW version and reproduction steps. /hansecast opens this menu.')) end)
end

-- Independent effect instance: no reparenting of live bars, no synthetic cast
-- events, no database writes and no changes to the player's selected theme.
local function MenuPreview(h)
 local p=CreateFrame('Frame',nil,h);h.previewPanel=p
 p:SetPoint('BOTTOMLEFT',16,42);p:SetPoint('BOTTOMRIGHT',-32,42);p:SetHeight(88)
 p.caption=Label(p,S('Vorschau · Originalgrafik · Beispielzauber','Preview · original artwork · sample cast'),'GameFontHighlightSmall')
 p.caption:SetPoint('TOPLEFT',0,0)
 p.bar=CreateFrame('Frame',nil,p);p.bar:SetPoint('BOTTOMLEFT',8,14)
 p.effects=HC.CreateEffects(p.bar,true)
 p.name=Label(p.bar,'','GameFontHighlightSmall');p.name:SetPoint('BOTTOMLEFT',p.bar,'TOPLEFT',0,4)
 p.time=Label(p.bar,'','GameFontHighlightSmall');p.time:SetPoint('BOTTOMRIGHT',p.bar,'TOPRIGHT',0,4);p.time:SetJustifyH('RIGHT')
 p.timeCache={}
 p.icon=p.bar:CreateTexture(nil,'ARTWORK');p.iconLoaded=p.icon:SetTexture('Interface\\Icons\\INV_Misc_QuestionMark')~=false;p.icon:SetTexCoord(.08,.92,.08,.92);p.icon:Hide()
 p.gcd=p.bar:CreateTexture(nil,'BACKGROUND');p.gcd:SetPoint('TOPLEFT',p.bar,'BOTTOMLEFT',0,-5);p.gcd:SetColorTexture(.5,.5,.5,.6)
 p.place=Button(p,S('Positionieren','Position'),function() HC.StartMenuPreview(h,'player') end)
 p.place:SetSize(138,24);p.place:SetPoint('BOTTOMRIGHT',0,4)
 p.paint=function()
  local db=HC.db;local palette=HC.elements[db.element]
  local key=db.family..':'..db.element..':'..db.identity
  if p.key~=key then
   p.key=key;p.theme={family=db.family,element=db.element,cast=palette.color,bright=palette.bright,
    secondary=palette.secondary,secondaryBright=palette.secondaryBright,ghost=palette.ghost,classMaterial=palette.classMaterial,
    accentTint=HC.GetIdentityTint(db.identity)}
  end
  local width=math.max(180,math.min(db.width,600));local height=db.height
  local scale=math.min(db.scale,math.max(.3,(h.content:GetWidth()-170)/width),36/height)
  local layout=width..':'..height..':'..scale..':'..(db.iconPosition or 'hidden')
  if p.layout~=layout then
   p.layout=layout;p.bar:SetSize(width,height);p.bar:SetScale(scale);HC.LayoutEffects(width,height,p.effects)
   p.name:SetWordWrap(false);p.time:SetWordWrap(false)
   local iconSize=math.max(16,math.min(28,height));p.icon:SetSize(iconSize,iconSize);p.icon:ClearAllPoints()
   local right=db.iconPosition=='right';p.icon:SetPoint(right and 'LEFT' or 'RIGHT',p.bar,right and 'RIGHT' or 'LEFT',right and 6 or -6,0)
  end
  local fontKey=(db.font or 'default')..':'..(db.fontSize or 12)
  if p.fontKey~=fontKey then p.fontKey=fontKey;HC.ApplyCastFont(p.name);HC.ApplyCastFont(p.time) end
  local now=GetTime();local progress=(now%3)/3
  HC.DrawEffects(progress,now,p.effects,p.theme)
  local available=HC.IsMaterialAvailable(p.effects)
  p.name:SetText(available and T(HC.elements[db.element].title) or T(S('Grafik nicht verfügbar','Artwork unavailable')))
  local sample={start=now-now%3,finish=now-now%3+3}
  local text,inset=HC.FormatCastTime(sample,now,3*(1-progress),3,p.timeCache)
  if p.timeText~=text or p.timeAvailable~=available then p.timeText=text;p.timeAvailable=available;p.time:SetText(available and text or '') end
  inset=inset*(db.fontSize or 12)/12
  if p.textInset~=inset or p.textWidth~=width then p.textInset=inset;p.textWidth=width;p.name:SetWidth(math.max(30,width-inset)) end
  p.icon:SetShown(available and p.iconLoaded and db.iconPosition~='hidden')
  p.bar:SetAlpha(db.opacity or 1);p.gcd:SetSize(width*(1-progress),2);p.gcd:SetShown(db.gcd and available)
 end
 p.tick=function(_,elapsed)
  p.elapsed=(p.elapsed or 0)+elapsed
  if p.elapsed<1/30 then return end;p.elapsed=0;p.paint()
 end
 p:SetScript('OnHide',function() p:SetScript('OnUpdate',nil);HC.HideEffects(p.effects) end)
 p:Hide()
end

function HC.CreateMenuCanvas(parent,native)
 local h=CreateFrame('Frame',native and 'HanseCastSettingsCanvas' or 'HanseCastOptions',parent,native and nil or 'BackdropTemplate')
 h.native=native;h.page=Page(HC.menuPage or 'player');h.unit='target';h.rows={};h.controls={};h.pages={};h.nav={}
 h.selectedProfile=HC.db.activeProfile;hosts[#hosts+1]=h
 h.title=Label(h,'Hanse Cast','GameFontNormalLarge');h.title:SetPoint('TOPLEFT',16,-14)
 h.active=Label(h,'','GameFontHighlightSmall');h.active:SetPoint('TOPLEFT',16,-42);h.active:SetPoint('TOPRIGHT',-30,-42)
 h.profileButton=Button(h,'',function()
  local items={};for _,name in ipairs(HC.ProfileNames()) do items[#items+1]={name,name} end
  Dropdown(h,h.profileButton,items,HC.db.activeProfile,function(name) Result(h,HC.SwitchProfile(name)) end)
 end,true);h.profileButton:SetSize(210,26);h.profileButton:SetPoint('TOPRIGHT',-32,-12)
 h.status=Label(h,'','GameFontHighlightSmall');h.status:SetPoint('BOTTOMLEFT',16,12);h.status:SetPoint('BOTTOMRIGHT',-16,12);h.status:SetHeight(32)
 h.scroll=CreateFrame('ScrollFrame',nil,h,'UIPanelScrollFrameTemplate');h.scroll:SetPoint('TOPLEFT',16,-98);h.scroll:SetPoint('BOTTOMRIGHT',-32,140)
 h.content=CreateFrame('Frame',nil,h.scroll);h.content:SetSize(500,600);h.scroll:SetScrollChild(h.content)
 for i,p in ipairs(pageNames) do
  local key=p[1];local b=Button(h,p[2],function() SelectPage(h,key) end,true);b:SetSize(140,28);b:SetPoint('TOPLEFT',16+(i-1)*146,-62);h.nav[key]={button=b,text=p[2]}
  local page=CreateFrame('Frame',nil,h.content);page:SetPoint('TOPLEFT');page:SetPoint('TOPRIGHT');page:SetHeight(10);page.used=0;h.pages[key]=page
 end
 local d=CreateFrame('Frame',nil,h,'BackdropTemplate');h.confirm=d;d:Hide();d:SetFrameStrata('DIALOG');d:SetFrameLevel(h:GetFrameLevel()+30);d:SetSize(460,190);d:SetPoint('CENTER');d:EnableMouse(true)
 d:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});d:SetBackdropColor(.06,.07,.09,1);d:SetBackdropBorderColor(.8,.6,.3,1)
 d.text=Label(d,'');d.text:SetPoint('TOPLEFT',20,-20);d.text:SetPoint('TOPRIGHT',-20,-20)
 d.accept=Button(d,'',function() local action=d.action;local active=d.active;d:Hide();if action and active==HC.db.activeProfile then action() end;HC.UpdateOptions() end)
 d.accept:SetSize(190,30);d.accept:SetPoint('BOTTOMRIGHT',-20,18)
 d.cancel=Button(d,'',function() d:Hide();HC.UpdateOptions() end);d.cancel:SetSize(190,30);d.cancel:SetPoint('BOTTOMLEFT',20,18)
 Build(h)
 local more=Action(h,'player','more',S('Weitere Einstellungen','More settings'),S('Schrift, Symbole, Akzente und genaue Position.','Font, icons, accents and exact position.'),function() return T(h.expanded and S('Weniger anzeigen','Show less') or S('Weitere Einstellungen …','More settings …')) end,function() h.expanded=not h.expanded;ClosePopup(h);HC.UpdateOptions() end)
 local order={'appearanceFilter','appearanceBrowse','favorite','family','group','element','autoSpellVisual','width','height','scale','gcd','finishCue','hideBlizzard','more'}
 local basic={};local ordered={}
 for _,id in ipairs(order) do basic[id]=true;ordered[#ordered+1]=h.controls[id] end
 for _,r in ipairs(h.rows) do if not basic[r.id] then r.advanced=r.page=='player';ordered[#ordered+1]=r end end
 h.rows=ordered
 for _,r in ipairs(h.rows) do
  for _,widget in ipairs(r.widgets) do Tooltip(widget,r.titleText,r.helpText) end
 end
 MenuPreview(h)
 h.resize=function(w)
  local width=math.max(300,w-64);h.content:SetWidth(width);h.importText:SetWidth(math.max(240,width-44))
  local tabWidth=math.min(140,(width-18)/4)
  for i,p in ipairs(pageNames) do local b=h.nav[p[1]].button;b:SetWidth(tabWidth);b:ClearAllPoints();b:SetPoint('TOPLEFT',16+(i-1)*(tabWidth+6),-62) end
  local stack=width<440
  for _,p in pairs(h.pages) do p.used=0 end
  for _,r in ipairs(h.rows) do
   local p=h.pages[r.page];local extra=stack and #r.widgets>0 and r.id~='importText' and 28 or 0
   local visible=(not r.advanced or h.expanded) and (not r.visible or r.visible());r:SetShown(visible)
   r:ClearAllPoints();r:SetPoint('TOPLEFT',0,-p.used);r:SetPoint('TOPRIGHT',0,-p.used);r:SetHeight(r.baseHeight+extra)
   if visible then p.used=p.used+r.baseHeight+extra end;p:SetHeight(p.used)
   r.title:ClearAllPoints();r.title:SetPoint('TOPLEFT',0,-2)
   r.title:SetPoint('TOPRIGHT',(stack or #r.widgets==0 or r.id=='importText') and -4 or -258,-2)
   r.help:ClearAllPoints();r.help:SetPoint('TOPLEFT',0,-40-extra);r.help:SetPoint('TOPRIGHT',-8,-40-extra)
   if r.button then r.button:ClearAllPoints();r.button:SetPoint('TOPRIGHT',r.checkbox and -214 or -4,-extra) end
   if r.edit then r.edit:ClearAllPoints();r.edit:SetPoint('TOPRIGHT',-12,-extra);r.slider:ClearAllPoints();r.slider:SetPoint('TOPRIGHT',-104,-4-extra) end
   if r.id=='name' then h.profileName:ClearAllPoints();h.profileName:SetPoint('TOPRIGHT',-4,-extra) end
  end
  h.content:SetHeight(h.pages[h.page].used)
  local preview=h.page=='player'
  h.scroll:ClearAllPoints();h.scroll:SetPoint('TOPLEFT',16,-98);h.scroll:SetPoint('BOTTOMRIGHT',-32,preview and 140 or 52)
 end
 h:SetScript('OnSizeChanged',function(_,w) h.resize(w) end)
 h:SetScript('OnShow',function()
  for _,other in ipairs(hosts) do
   if other~=h and other:IsShown() then
    if other.native and SettingsPanel and type(HideUIPanel)=='function' then HideUIPanel(SettingsPanel) else other:Hide() end
   end
  end
  HC.UpdateOptions()
 end)
 h:SetScript('OnHide',function()
  h.previewPanel:SetScript('OnUpdate',nil);HC.HideEffects(h.previewPanel.effects)
  if GameTooltip then GameTooltip:Hide() end
  ClosePopup(h);d:Hide();HC.pendingProfileImport=nil;ClearImport(h)
  DiscardEdits(h)
  if not HC.menuPreviewTransition then HC.EndMenuPreview(false) end
 end)
 h.OnDefault=function() Status(h,S('Zum Zurücksetzen die benannte Aktion im Bereich Profile verwenden.','Use the named reset action on the Profiles page.')) end
 h.OnRefresh=function() HC.UpdateOptions() end
 h:Hide();return h
end
function HC.UpdateOptions()
 if updating or not HC.db then return end;updating=true
 for _,h in ipairs(hosts) do
  if HC.unitBarsInDevelopment and h.page=='units' then h.page='player' end
  if not HC.db.profiles[h.selectedProfile] then h.selectedProfile=HC.db.activeProfile end
  if h.previousActive and (h.previousActive~=HC.db.activeProfile or h.previousRevision~=(HC.profileRevision or 0) or h.previousDB~=HC.db) then
   h.confirm:Hide();ClearImport(h);HC.pendingProfileImport=nil;DiscardEdits(h)
  end
  h.previousActive=HC.db.activeProfile;h.previousRevision=HC.profileRevision or 0;h.previousDB=HC.db;h.title:SetText('Hanse Cast  '..HC.version)
  h.profileButton:SetText(HC.db.activeProfile..'  >');Enable(h.profileButton,Allowed() and not h.confirm:IsShown())
  h.active:SetText(T(S('Aktives Profil: ','Active profile: '))..HC.db.activeProfile..' · '..#HC.ProfileNames()..'/12')
  h.status:SetText(not Allowed() and T(messages.combat) or T(h.message or S('Änderungen gelten sofort für das aktive Profil.','Changes apply immediately to the active profile.')))
  for key,nav in pairs(h.nav) do
   nav.button:SetText((h.page==key and '|cffffd080> |r' or '')..T(nav.text))
   if h.page==key then nav.button:SetBackdropColor(.25,.21,.13,1) else nav.button:SetBackdropColor(.055,.05,.04,.95) end
   if key=='units' and HC.unitBarsInDevelopment then nav.button:SetText(T(S('Ziel & Fokus\n(in Arbeit)','Target & focus\n(in development)'))) end
   Enable(nav.button,Allowed() and not h.confirm:IsShown() and not (key=='units' and HC.unitBarsInDevelopment))
  end
  for key,page in pairs(h.pages) do page:SetShown(h.page==key) end;h.content:SetHeight(h.pages[h.page].used)
  for _,r in ipairs(h.rows) do
   r.title:SetText(T(r.titleText));r.help:SetText(T(r.helpText));if r.refresh then r.refresh() end
   local on=Allowed() and not (r.page=='units' and HC.unitBarsInDevelopment) and not h.confirm:IsShown() and (not r.enabled or r.enabled());for _,w in ipairs(r.widgets) do Enable(w,on) end
  end
  h.resize(h:GetWidth())
  local p=h.previewPanel
  local preview=h:IsShown() and (not h.IsVisible or h:IsVisible()) and h.page=='player' and Allowed() and not h.confirm:IsShown()
  p:SetShown(preview);p:SetScript('OnUpdate',preview and p.tick or nil)
  if preview then p.paint() else HC.HideEffects(p.effects) end
  p.caption:SetText(T(S('Original-Vorschau · bei Bedarf verkleinert','Original preview · scaled to fit')))
  p.place:SetText(T(S('Positionieren','Position')));Enable(p.place,Allowed() and not h.confirm:IsShown())
  h.confirm.accept:SetText(T(S('Bestätigen','Confirm')));h.confirm.cancel:SetText(T(S('Abbrechen','Cancel')))
  if h.confirm:IsShown() then h.confirm.text:SetText(T(h.confirm.caption)) end
 end
 updating=false
end
HC.UpdateAdvancedOptions=HC.UpdateOptions
local function Fallback()
 if HC.settingsCanvas then
  if HC.settingsCanvas:IsShown() and SettingsPanel and type(HideUIPanel)=='function' then HideUIPanel(SettingsPanel)
  else HC.settingsCanvas:Hide() end
 end
 if not HC.options then
  local h=HC.CreateMenuCanvas(UIParent,false);HC.options=h
  h:SetSize(820,620);h:SetPoint('CENTER');h:SetClampedToScreen(true);h:SetFrameStrata('DIALOG');h:EnableMouse(true)
  h:SetScale(math.min(1,(UIParent:GetHeight()-40)/620,(UIParent:GetWidth()-40)/820))
  h:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});h:SetBackdropColor(.045,.055,.07,1);h:SetBackdropBorderColor(.62,.47,.27,1)
  local close=CreateFrame('Button',nil,h,'UIPanelCloseButton');close:SetPoint('TOPRIGHT');close:SetScript('OnClick',function() h:Hide() end)
  if type(UISpecialFrames)=='table' then UISpecialFrames[#UISpecialFrames+1]='HanseCastOptions' end
 end
 HC.options:Show();HC.UpdateOptions()
end
function HC.OpenOptions()
 if not Allowed() then if HC.Print then HC.Print(T(messages.combat)) end;return end
 if HC.RegisterSettings then HC.RegisterSettings() end
 if HC.settingsCategory and Settings and type(Settings.OpenToCategory)=='function' then
  local c=HC.settingsCategory;local id=c.GetID and c:GetID() or c.ID or c.id
  if id then
   local ok=pcall(Settings.OpenToCategory,id)
   if ok then if HC.options then HC.options:Hide() end;HC.UpdateOptions();return end
  end
 end
 Fallback()
end
function HC.ToggleOptions() HC.OpenOptions() end
function HC.OpenAdvancedOptions()
 HC.menuPage='player';HC.OpenOptions()
 for _,h in ipairs(hosts) do h.page='player';h.expanded=true end;HC.UpdateOptions()
end
function HC.StartMenuPreview(h,unit,mode)
 if HC.unitBarsInDevelopment and unit~='player' then return false end
 if not Allowed() then return end;HC.EndMenuPreview(false)
 HC.menuPreviewHost=h;HC.menuPreviewTransition=true
 if h.native and SettingsPanel and type(HideUIPanel)=='function' then HideUIPanel(SettingsPanel) else h:Hide() end
 HC.menuPreviewTransition=false
 if unit=='player' then if HC.TogglePreview then HC.TogglePreview(mode) end elseif HC.PreviewUnitBars then HC.PreviewUnitBars(true,unit) end
 if not HC.positionToolbar then
  local f=CreateFrame('Frame','HanseCastPositionToolbar',UIParent,'BackdropTemplate');HC.positionToolbar=f
  f:SetSize(500,100);f:SetPoint('TOP',0,-80);f:SetFrameStrata('DIALOG');f:SetClampedToScreen(true);f:EnableMouse(true)
  f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});f:SetBackdropColor(.04,.06,.08,1)
  f.text=Label(f,'');f.text:SetPoint('TOPLEFT',16,-12);f.text:SetPoint('TOPRIGHT',-16,-12)
  f.done=Button(f,'',function() HC.EndMenuPreview(true) end);f.done:SetPoint('BOTTOM',0,12)
  f:SetScript('OnHide',function() if not HC.endingMenuPreview then HC.EndMenuPreview(false) end end)
  if type(UISpecialFrames)=='table' then UISpecialFrames[#UISpecialFrames+1]='HanseCastPositionToolbar' end
 end
 local f=HC.positionToolbar
 f.text:SetText(T(S('Künstliche Vorschau · Ziehen mit linker Maustaste · ','Artificial preview · Drag with left mouse button · '))..T(unit=='player' and S('Spieler','Player') or unit=='target' and 'Ziel' or 'Fokus'))
 f.done:SetText(T(S('Fertig – zurück zu Einstellungen','Done – return to settings')));f:Show()
end
function HC.EndMenuPreview(reopen)
 if HC.endingMenuPreview then return end;HC.endingMenuPreview=true
 -- Restore the saved anchor before any exit path clears the drag state,
 -- including combat, where TogglePreview is intentionally unavailable.
 if HC.CancelPreviewDrag then HC.CancelPreviewDrag() end
 local host=HC.menuPreviewHost;HC.menuPreviewHost=nil
 if HC.preview then
  if Allowed() and HC.TogglePreview then HC.TogglePreview()
  else
   if HC.ClearCastResult then HC.ClearCastResult() end
   HC.preview=false;HC.previewMode=nil
   if HC.frame then HC.frame:StopMovingOrSizing();HC.frame:EnableMouse(false);HC.frame.hint:Hide() end
  end
 end
 if HC.unitBarsPreview and HC.PreviewUnitBars and Allowed() then HC.PreviewUnitBars(false) end
 if HC.positionToolbar then HC.positionToolbar:Hide() end
 if HC.frame then HC.frame:StopMovingOrSizing();HC.frame:EnableMouse(false) end
 if host and HC.SaveActiveProfile then HC.SaveActiveProfile() end
 HC.endingMenuPreview=false;if reopen and host and Allowed() then HC.OpenOptions() end
end
local events=CreateFrame('Frame');events:RegisterEvent('PLAYER_REGEN_DISABLED');events:RegisterEvent('PLAYER_REGEN_ENABLED')
events:SetScript('OnEvent',function(_,event)
 if event=='PLAYER_REGEN_DISABLED' then
   for _,h in ipairs(hosts) do ClosePopup(h);h.confirm:Hide();ClearImport(h);DiscardEdits(h) end
  HC.pendingProfileImport=nil;HC.EndMenuPreview(false)
 end
 HC.UpdateOptions()
end)
