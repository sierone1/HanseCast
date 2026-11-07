local _, HC = ...
local L=function(text) return HC.L and HC.L(text) or text end
local texture="Interface\\Buttons\\WHITE8X8"
local families={
    {"element","Elementstrom"},{"splinter","Splitter & Funken"},{"silk","Seidenfluss"},
    {"pulse","Impuls"},{"mist","Nebellicht"},
}

local identities={{"neutral","Neutral"},{"class","Klasse"}}
local factions={{"none","Neutral"},{"alliance","Allianz"},{"horde","Horde"}}
local function Caption(list,key)
    for _,item in ipairs(list) do if item[1]==key then return L(item[2]) end end
    return L(list[1][2])
end

-- Advanced controls live on separate pages so the everyday appearance panel
-- remains small. Text imports are staged and applied by a separate action.
function HC.OpenAdvancedOptions()
 if InCombatLockdown() then return end
 if HC.advanced then HC.advanced:Show();HC.UpdateAdvancedOptions();return end
 local p=CreateFrame('Frame','HanseCastAdvanced',UIParent,'BackdropTemplate');HC.advanced=p
 p:SetSize(480,590);p:SetPoint('CENTER');p:SetClampedToScreen(true);p:SetFrameStrata('DIALOG');p:EnableMouse(true)
 p:SetBackdrop({bgFile=texture,edgeFile=texture,edgeSize=1});p:SetBackdropColor(.045,.055,.07,1);p:SetBackdropBorderColor(.62,.47,.27,1)
 local close=CreateFrame('Button',nil,p,'UIPanelCloseButton');close:SetPoint('TOPRIGHT')
 p.pages={};p.dynamic={};p.tab='comfort';p.unit='target'
 local function Label(parent,key,x,y)
  local t=parent:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');t:SetPoint('TOPLEFT',x,y);HC.Localize(t,key);return t
 end
 local function Button(parent,key,x,y,width,action)
  local b=CreateFrame('Button',nil,parent,'UIPanelButtonTemplate');b:SetSize(width,26);b:SetPoint('TOPLEFT',x,y);HC.Localize(b,key)
  b:SetScript('OnClick',function() if InCombatLockdown() then return end;action();HC.UpdateAdvancedOptions() end);return b
 end
 Label(p,'Erweitert / Profile',22,-20)
 for i,entry in ipairs({{'comfort','Komfort'},{'profiles','Profile'},{'units','Ziel / Fokus'}}) do
  local key=entry[1];local page=CreateFrame('Frame',nil,p);page:SetAllPoints();page:Hide();p.pages[key]=page
  Button(p,entry[2],22+(i-1)*146,-48,140,function() p.tab=key end)
 end
 local function Dynamic(button,fn) p.dynamic[#p.dynamic+1]={button,fn} end
 local function RefreshPlayer() HC.ApplyLayout();if HC.Refresh then HC.Refresh() end end
 local function Cycle(page,label,key,choices,y)
  Label(page,label,22,y-6)
  local b=Button(page,'',222,y,234,function()
   local index=1;for i,c in ipairs(choices) do if c[1]==HC.db[key] then index=i end end
   HC.db[key]=choices[index%#choices+1][1];RefreshPlayer()
   if key=='language' then HC.RefreshLocale() end
  end)
  Dynamic(b,function() for _,c in ipairs(choices) do if c[1]==HC.db[key] then return L(c[2]) end end;return '' end)
 end
 local function Number(page,label,key,low,high,step,y)
  Label(page,label,22,y-5);local value=Label(page,'',250,y-5)
  Dynamic(value,function() return string.format('%.2g',HC.db[key]) end)
  Button(page,'−',364,y,42,function() HC.db[key]=math.max(low,HC.db[key]-step);RefreshPlayer() end)
  Button(page,'+',414,y,42,function() HC.db[key]=math.min(high,HC.db[key]+step);RefreshPlayer() end)
 end
 local c=p.pages.comfort
 Cycle(c,'Sprache','language',{{'auto','Automatisch'},{'deDE','Deutsch'},{'enUS','English'}},-92)
 Cycle(c,'Schrift','font',{{'default','Standard'},{'modern','Modern'}},-128)
 Number(c,'Schriftgröße','fontSize',10,20,1,-164)
 Cycle(c,'Zeit','timeFormat',{{'remaining','Restzeit'},{'elapsed','Verstrichen'},{'both','Beides'},{'hidden','Versteckt'}},-200)
 Number(c,'Deckkraft','opacity',.2,1,.1,-236)
 Cycle(c,'Zaubersymbol','iconPosition',{{'hidden','Versteckt'},{'left','Links'},{'right','Rechts'}},-272)
 Cycle(c,'Latenzmarkierung','latency',{{false,'Aus'},{true,'Ein'}},-308)
 Cycle(c,'Kanal-Hilfslinien (manuell)','channelTicks',{{false,'Aus'},{true,'Ein'}},-344)
 Number(c,'Anzahl Abschnitte','channelTickCount',2,10,1,-380)
 local note=Label(c,'Gleichmäßige Hilfslinien, keine gemessenen Zauberticks. Latenz nutzt nur lesbare Weltlatenz.',22,-432)
 note:SetWidth(430);note:SetWordWrap(true)
 local profiles=p.pages.profiles
 local function Edit(parent,x,y,w,h,multi)
  local e=CreateFrame('EditBox',nil,parent,'InputBoxTemplate');e:SetSize(w,h);e:SetPoint('TOPLEFT',x,y)
  if e.SetAutoFocus then e:SetAutoFocus(false) end
  if e.SetMultiLine then e:SetMultiLine(multi==true) end
  if e.SetMaxLetters then e:SetMaxLetters(multi and 8192 or 48) end
  if e.SetFontObject then e:SetFontObject('GameFontHighlightSmall') end
  e:SetScript('OnEscapePressed',function(self) if self.ClearFocus then self:ClearFocus() end end)
  return e
 end
 p.selectedProfile=HC.db.activeProfile
 p.profileSelect=Button(profiles,'',22,-92,434,function()
  local names=HC.ProfileNames();local index=1;for i,n in ipairs(names) do if n==p.selectedProfile then index=i end end
  p.selectedProfile=names[index%#names+1];p.confirm=nil
 end)
 Dynamic(p.profileSelect,function() return (p.selectedProfile or HC.db.activeProfile)..(p.selectedProfile==HC.db.activeProfile and ' *' or '') end)
 local function Status(ok) p.status:SetText(L(ok and 'Erledigt.' or 'Nicht möglich: Name, Profilgrenze oder Kampf prüfen.')) end
 Button(profiles,'Wechseln',22,-126,140,function() Status(HC.SwitchProfile(p.selectedProfile)) end)
 p.deleteButton=Button(profiles,'Löschen',168,-126,140,function()
  if p.confirm=='delete' then Status(HC.DeleteProfile(p.selectedProfile));p.selectedProfile=HC.db.activeProfile;p.confirm=nil else p.confirm='delete' end
 end)
 Dynamic(p.deleteButton,function() return L(p.confirm=='delete' and 'Löschen bestätigen' or 'Löschen') end)
 p.resetButton=Button(profiles,'Zurücksetzen',314,-126,142,function()
  if p.confirm=='reset' then
   if HC.SwitchProfile(p.selectedProfile) then Status(HC.ResetProfile()) else Status(false) end
   p.confirm=nil
  else p.confirm='reset' end
 end)
 Dynamic(p.resetButton,function() return L(p.confirm=='reset' and 'Reset bestätigen' or 'Zurücksetzen') end)
 Label(profiles,'Profilname',22,-171);p.profileName=Edit(profiles,145,-164,310,26,false)
 Button(profiles,'Neues Profil',22,-202,212,function() Status(HC.CreateProfile(p.profileName:GetText(),false));p.selectedProfile=HC.db.activeProfile end)
 Button(profiles,'Kopie erstellen',244,-202,212,function() Status(HC.CreateProfile(p.profileName:GetText(),true));p.selectedProfile=HC.db.activeProfile end)
 Label(profiles,'Import / Export (Text)',22,-243)
 local scroll=CreateFrame('ScrollFrame',nil,profiles,'UIPanelScrollFrameTemplate');scroll:SetSize(408,166);scroll:SetPoint('TOPLEFT',22,-266)
 p.importText=Edit(scroll,0,0,400,166,true);if scroll.SetScrollChild then scroll:SetScrollChild(p.importText) end
 p.importText:SetScript('OnTextChanged',function() HC.pendingProfileImport=nil end)
 Button(profiles,'Exportieren',22,-450,140,function() p.importText:SetText(HC.ExportProfile());if p.importText.HighlightText then p.importText:HighlightText() end end)
 Button(profiles,'Import prüfen',168,-450,140,function()
  local ok=HC.StageProfileImport(p.importText:GetText());p.status:SetText(L(ok and 'Import geprüft. Mit Anwenden bestätigen.' or 'Ungültiges Profil. Keine Änderung.'))
 end)
 Button(profiles,'Import anwenden',314,-450,142,function() Status(HC.ApplyProfileImport()) end)
 p.status=Label(profiles,'',22,-493);p.status:SetWidth(430);p.status:SetWordWrap(true)
 local units=p.pages.units
 Button(units,'Ziel',22,-92,212,function() p.unit='target' end);Button(units,'Fokus',244,-92,212,function() p.unit='focus' end)
 local function UnitCycle(label,key,choices,y)
  Label(units,label,22,y-6)
  local b=Button(units,'',222,y,234,function()
   local current=HC.db.unitBars[p.unit][key];local index=1;for i,v in ipairs(choices) do if v[1]==current then index=i end end
   HC.ConfigureUnitBar(p.unit,{[key]=choices[index%#choices+1][1]})
  end)
  Dynamic(b,function() local current=HC.db.unitBars and HC.db.unitBars[p.unit][key];for _,v in ipairs(choices) do if v[1]==current then return (v[3] and L(v[3])..' · ' or '')..L(v[2]) end end;return '' end)
 end
 UnitCycle('Aktiv','enabled',{{false,'Aus'},{true,'Ein'}},-128)
 UnitCycle('Sichtbarkeit','visibility',{{'always','Immer'},{'combat','Im Kampf'}},-162)
 UnitCycle('Symbol','showIcon',{{false,'Aus'},{true,'Ein'}},-196)
 local fs={{'inherit','Übernehmen'}};for _,v in ipairs(families) do fs[#fs+1]=v end
 UnitCycle('Material: ','family',fs,-230)
 local es={{'inherit','Übernehmen'}};for _,group in ipairs(HC.visualGroups) do for _,key in ipairs(group.elements) do es[#es+1]={key,HC.elements[key].title,group.title} end end
 UnitCycle('Zauberoptik: ','element',es,-264)
 for i,row in ipairs({{'Breite','width',180,600,20},{'Höhe','height',24,60,2},{'Skalierung','scale',.6,2,.1},{'Position X','x',-10000,10000,10},{'Position Y','y',-10000,10000,10}}) do
  local y=-298-(i-1)*34;local key=row[2];Label(units,row[1],22,y-5);local val=Label(units,'',250,y-5)
  Dynamic(val,function() return tostring(HC.db.unitBars and HC.db.unitBars[p.unit][key] or '') end)
  for j,sign in ipairs({-1,1}) do Button(units,sign<0 and '−' or '+',364+(j-1)*50,y,42,function()
   HC.ConfigureUnitBar(p.unit,{[key]=math.max(row[3],math.min(row[4],HC.db.unitBars[p.unit][key]+sign*row[5]))})
  end) end
 end
 Button(units,'Vorschau Ziel / Fokus',22,-484,434,function() HC.PreviewUnitBars(not HC.unitBarsPreview) end)
 p:SetScript('OnHide',function() HC.pendingProfileImport=nil;p.unitPreview=false;if HC.PreviewUnitBars then HC.PreviewUnitBars(false) end end)
 if HC.options then HC.options:Hide() end
 HC.UpdateAdvancedOptions();p:Show()
end
function HC.UpdateAdvancedOptions()
 local p=HC.advanced;if not p then return end
 for key,page in pairs(p.pages) do page:SetShown(p.tab==key) end
 for _,item in ipairs(p.dynamic) do item[1]:SetText(item[2]()) end
end

-- Native Settings entry opens the same panel; repeated clicks never toggle it off.
function HC.OpenOptions()
    if InCombatLockdown() then HC.Print(L("Einstellungen bitte außerhalb des Kampfes öffnen."));return end
    if HC.options and HC.options:IsShown() then HC.UpdateOptions();return end
    HC.ToggleOptions()
end

function HC.UpdateOptions()
    local p=HC.options
    if not p or not p.controls then return end
    local group=HC.GetVisualGroup(HC.db.element)
    if p.elementButtons then
        p.controls.element={}
        for index,button in ipairs(p.elementButtons) do
            local key=group.elements[index]
            button.elementKey=key;button:SetShown(key~=nil)
            if key then
                button.caption=HC.elements[key].short
                button:SetWidth(#group.elements==2 and 212 or 140)
                button:ClearAllPoints();button:SetPoint("TOPLEFT",24+(index-1)*(#group.elements==2 and 222 or 146),-180)
                p.controls.element[key]=button
            end
        end
    end
    for key,control in pairs(p.controls) do
        if key=="family" or key=="element" then
            for value,button in pairs(control) do button:SetText((HC.db[key]==value and "• " or "")..L(button.caption)) end
        elseif key=="visualGroup" then
            control:SetText(L("Material: ")..L(group.title).."  >")
        elseif key=="autoSpellVisual" then
            control:SetText(group.key=="factions" and L("Fest · Fraktionsoptik") or L("Zauberoptik: ")..L(HC.db.autoSpellVisual and "Automatisch" or "Manuell"))
        elseif key=="identity" then
            control:SetText(L("Akzente: ")..Caption(identities,HC.db.identity).."  >")
        elseif key=="faction" then
            control:SetText(L("Ausführung: ")..Caption(factions,HC.db.faction).."  >")
        elseif key=="preview" then control:SetText(L(HC.preview and "Vorschau beenden / Position sperren" or "Vorschau starten / Position verschieben"))
        elseif key=="width" then control:SetText(HC.db.width.." px")
        elseif key=="height" then control:SetText(HC.db.height.." px")
        elseif key=="scale" then control:SetText(math.floor(HC.db.scale*100+0.5).." %")
        else control:SetText(L(HC.db[key] and "Ein" or "Aus")) end
    end
    p.subtitle:SetText(Caption(families,HC.db.family).." · "..L(HC.elements[HC.db.element].title).." · "..L("ohne Rahmen"))
    if p.previewNote then
        p.previewNote:SetText(L(HC.preview and HC.previewMode=="feedback"
            and "Demo: Zeitänderung / Abbruch / Unterbrechung"
            or "Zauber / Kanal / GCD · Ereignis-Demo: /hansecast demo"))
    end
end

function HC.ToggleOptions()
    if InCombatLockdown() then HC.Print(L("Einstellungen bitte außerhalb des Kampfes öffnen."));return end
    if HC.options then HC.UpdateOptions();HC.options:SetShown(not HC.options:IsShown());return end
    local p=CreateFrame("Frame","HanseCastOptions",UIParent,"BackdropTemplate")
    HC.options=p;p.controls={}
    p:SetSize(480,616);p:SetPoint("LEFT",UIParent,"LEFT",28,0)
    p:SetClampedToScreen(true);p:SetFrameStrata("DIALOG");p:EnableMouse(true)
    p:SetBackdrop({bgFile=texture,edgeFile=texture,edgeSize=1})
    p:SetBackdropColor(0.045,0.055,0.070,1);p:SetBackdropBorderColor(0.62,0.47,0.27,1)
    local function Text(text,x,y,font)
        local label=p:CreateFontString(nil,"OVERLAY",font or "GameFontHighlight")
        label:SetPoint("TOPLEFT",x,y);if HC.Localize then HC.Localize(label,text) else label:SetText(text) end;return label
    end
    Text("Hanse Cast",24,-20,"GameFontNormalLarge")
    p.subtitle=Text("",24,-45,"GameFontHighlightSmall")
    local close=CreateFrame("Button",nil,p,"UIPanelCloseButton");close:SetPoint("TOPRIGHT")
    local function Button(text,x,y,w,action)
        local b=CreateFrame("Button",nil,p,"UIPanelButtonTemplate")
        b:SetSize(w,26);b:SetPoint("TOPLEFT",x,y);if HC.Localize then HC.Localize(b,text) else b:SetText(text) end
        b:SetScript("OnClick",function() if InCombatLockdown() then return end;action();HC.UpdateOptions() end)
        return b
    end
    p.controls.family={}
    for index,item in ipairs(families) do
        local key,caption=item[1],item[2]
        local x=index<=3 and 24+(index-1)*146 or 97+(index-4)*146
        local y=index<=3 and -76 or -106
        local b=Button(caption,x,y,140,function() HC.db.family=key;HC.ApplyTheme() end)
        b.caption=caption;p.controls.family[key]=b
    end
    p.controls.visualGroup=Button("",24,-146,210,function()
        local current=HC.GetVisualGroup(HC.db.element)
        for index,group in ipairs(HC.visualGroups) do
            if group==current then
                HC.db.element=HC.visualGroups[index % #HC.visualGroups+1].elements[1];break
            end
        end
        local faction=HC.elements[HC.db.element].faction
        if faction then HC.db.faction=faction;HC.ApplyLayout() else HC.ApplyTheme() end
    end)
    p.controls.autoSpellVisual=Button("",246,-146,210,function()
        if HC.elements[HC.db.element].faction then return end
        HC.db.autoSpellVisual=not HC.db.autoSpellVisual
        HC.UpdateSpellTheme(HC.preview and nil or HC.cast);HC.ApplyTheme()
    end)
    p.elementButtons={};p.controls.element={}
    for index=1,3 do
        local b
        b=Button("",24+(index-1)*146,-180,140,function()
            if not b.elementKey then return end
            HC.db.element=b.elementKey
            local faction=HC.elements[b.elementKey].faction
            if faction then HC.db.faction=faction;HC.ApplyLayout() else HC.ApplyTheme() end
        end)
        p.elementButtons[index]=b
    end
    p.controls.identity=Button("",24,-214,210,function()
        local selected=1
        for index,item in ipairs(identities) do if item[1]==HC.db.identity then selected=index end end
        HC.db.identity=identities[selected % #identities+1][1]
        HC.ApplyTheme()
    end)
    p.controls.faction=Button("",246,-214,210,function()
        local selected=1
        for index,item in ipairs(factions) do if item[1]==HC.db.faction then selected=index end end
        HC.db.faction=factions[selected % #factions+1][1]
        HC.ApplyLayout()
    end)
    p.controls.preview=Button("Vorschau",24,-250,432,function() HC.TogglePreview() end)
    p.previewNote=Text("",24,-281,"GameFontHighlightSmall")
    local function Dimension(label,key,step,low,high,y)
        Text(label,24,y-5);p.controls[key]=Text("",265,y-5)
        Button("−",364,y,42,function() HC.db[key]=math.max(low,HC.db[key]-step);HC.ApplyLayout() end)
        Button("+",414,y,42,function() HC.db[key]=math.min(high,HC.db[key]+step);HC.ApplyLayout() end)
    end
    Dimension("Breite","width",20,180,600,-306)
    Dimension("Höhe","height",2,24,60,-336)
    Dimension("Skalierung","scale",0.1,0.6,2,-366)
    local function Toggle(label,key,y,changed)
        Text(label,24,y-5)
        p.controls[key]=Button("",384,y,72,function() HC.db[key]=not HC.db[key];if changed then changed() end end)
    end
    Toggle("Globaler Cooldown · schmale Linie","gcd",-406,function()
        if not HC.db.gcd then HC.DrawGCD(nil,GetTime()) end
        if HC.RefreshGCD then HC.RefreshGCD() end
    end)
    Toggle("Abschlusslicht · kurzer Lichtimpuls","finishCue",-436,function() if not HC.db.finishCue then HC.HideFinishCue() end end)
    Toggle("Blizzard-Castbar ersetzen","hideBlizzard",-466,function() if HC.UpdateBlizzard then HC.UpdateBlizzard() end end)
    Button("Position zurücksetzen",24,-506,432,function() HC.db.x=0;HC.db.y=-180;HC.ApplyLayout() end)
    Button("Erweitert / Profile",24,-538,432,function() HC.OpenAdvancedOptions() end)
    local note=Text("Bei nicht verfügbaren Daten oder Grafiken bleibt die Standardanzeige erhalten.",24,-580,"GameFontHighlightSmall")
    note:SetWidth(432);note:SetWordWrap(true)
    HC.UpdateOptions();p:Show()
end
