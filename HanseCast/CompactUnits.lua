local _,HC=...
local Lab={};HC.compact=Lab
HanseCastCompactOwner=Lab
-- Main-addon compact unit engine. Only target/focus, never the player bar.
-- Opaque duration objects pass directly to native widgets; no payload/ID inspection.
Lab.version='0.2.0';Lab.mode='off';Lab.rows={}
Lab.layout={width=240,height=20,font=12}
-- Exactly three unit-bar designs. Neither class nor specialization selects art.
Lab.timePlacement='off'
Lab.style='classic';Lab.color={.24,.67,.9}
Lab.positions={};Lab.hideBlizzard={target=false,focus=false}
local styles={classic=true,silk=true,split=true}
local styleNames={classic='1 · Klassik',silk='3 · Seidenkern',split='4 · Geteilte Anzeige'}
local textures={classic='Interface\\TargetingFrame\\UI-StatusBar',
 silk='Interface\\AddOns\\HanseCast\\Media\\Compact\\Silk.tga',
 split='Interface\\AddOns\\HanseCast\\Media\\Compact\\Silk.tga'}
Lab.stats={queries=0,submissions=0,errors=0,denied=0,polls=0,events=0,missingEvents=0}
local german=type(GetLocale)=='function' and GetLocale()=='deDE'
local function T(de,en) return german and de or en end
local labels={target=T('Ziel','Target'),focus=T('Fokus','Focus')}
local reasons={off=T('aus','off'),preview=T('synthetische Vorschau','synthetic preview'),
 active=T('Dauerobjekt übergeben','duration submitted'),idle=T('kein Dauerobjekt','no duration'),
 absent=T('keine Einheit','no unit'),changed=T('Einheit gewechselt','unit changed'),
 missing=T('Schnittstelle fehlt','API missing'),guard=T('Schutzprüfung fehlt/fehlerhaft','secrecy guard unavailable/failed'),
 denied=T('native Übergabe abgelehnt','native submission rejected'),error=T('Abfrage fehlgeschlagen','query failed'),
 unsupported=T('nur Forever 1.60.1 Build 70862/70888','only Forever 1.60.1 build 70862/70888'),
 combat=T('Aktivierung/Anpassung nur außerhalb des Kampfes','enable/change outside combat only'),
 events=T('Ereignisregistrierung fehlgeschlagen','event registration failed'),
 ['font-fit']=T('Schrift passt nicht: Höhe muss mindestens Schriftgröße + 4 sein.','Font does not fit: height must be at least font size + 4.')}
local function Accessible(value)
 if type(issecretvalue)~='function' then return false end
 local ok,secret=pcall(issecretvalue,value);if not ok or secret~=false then return false end
 if type(canaccessvalue)=='function' then
  local checked,allowed=pcall(canaccessvalue,value);if not checked or allowed~=true then return false end
 end
 return true
end
local function Supported()
 if type(GetBuildInfo)~='function' or type(issecretvalue)~='function' then return false end
 local ok,version,build,_,interface=pcall(GetBuildInfo)
 return ok and Accessible(version) and Accessible(build) and Accessible(interface)
  and version=='1.60.1' and (build=='70862' or build==70862 or build=='70888' or build==70888) and interface==16001
end
local function OutsideCombat()
 if type(InCombatLockdown)~='function' then return false end
 local ok,value=pcall(InCombatLockdown);return ok and Accessible(value) and (value==false or value==nil)
end
local function SetText(row,text)
 if row.text~=text then row.text=text;row.label:SetText(text) end
end
local function Clear(row,reason)
 row.timeReason='idle';if row.timeLabel then row.timeLabel:SetText('');row.timeLabel:Hide() end
 row.kind=nil;row.reason=reason;row.frame:Hide();row.native:Hide();row.preview:Hide()
 if row.nativeHighlight then row.nativeHighlight:Hide() end
 if row.previewHighlight then row.previewHighlight:Hide() end
 SetText(row,'')
 if HC.UpdateCompactBlizzard then HC.UpdateCompactBlizzard(row.unit) end
end
local function ClearAll(reason) for _,row in ipairs(Lab.rows) do Clear(row,reason) end end
local dirty={target=false,focus=false}
local elapsedTotal,previewTime=0,0
local control=CreateFrame('Frame');Lab.driver=control
local function Layout()
 for i,row in ipairs(Lab.rows) do
  local config=Lab.layout
  local header=Lab.style=='split' and config.font+6 or 0
  local totalHeight=config.height+header
  row.frame:SetSize(config.width,totalHeight);row.frame:ClearAllPoints()
  local position=(Lab.positionDraft and Lab.positionDraft[row.unit]) or Lab.positions[row.unit]
  row.frame:SetPoint('CENTER',UIParent,'CENTER',position and position.x or 0,position and position.y or -70-(i-1)*(totalHeight+12))
  row.background:ClearAllPoints();row.background:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',0,0)
  row.background:SetSize(config.width,config.height)
  for _,bar in ipairs({row.native,row.preview}) do
   bar:ClearAllPoints();bar:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',1,1)
   bar:SetSize(config.width-2,config.height-2)
   if not HC.ApplyCompactVisuals then bar:SetStatusBarTexture(textures[Lab.style]) end
   bar:SetStatusBarColor(Lab.color[1],Lab.color[2],Lab.color[3],1)
  end
  row.label:ClearAllPoints()
  if header>0 then
   row.label:SetPoint('TOPLEFT',row.frame,'TOPLEFT',4,0);row.label:SetHeight(config.font+2)
  else
   row.label:SetPoint('LEFT',row.frame,'LEFT',6,0);row.label:SetHeight(config.height)
  end
  row.label:SetWidth(math.max(1,config.width-12))
  row.label:SetFont('Fonts\\FRIZQT__.TTF',config.font,'')
  row.label:SetTextColor(1,1,1,1);row.label:SetShadowColor(0,0,0,1);row.label:SetShadowOffset(1,-1)
  -- Borders describe the track, not its progress; they never read native values.
  for j,edge in ipairs(row.borders) do
   edge:ClearAllPoints();edge:SetColorTexture(.32,.36,.40,1)
   if j<=2 then
    edge:SetSize(config.width,1)
    edge:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',0,j==1 and 0 or config.height-1)
   else
    edge:SetSize(1,config.height)
    edge:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',j==3 and 0 or config.width-1,0)
   end
  end
  if HC.LayoutCompactTime then HC.LayoutCompactTime(row,{width=config.width,height=config.height,font=config.font,header=header},Lab.timePlacement) end
  if HC.ApplyCompactVisuals then HC.ApplyCompactVisuals(row,{style=Lab.style,color=Lab.color,width=config.width,height=config.height,header=header}) end
 end
 if HC.UpdateCompactBlizzard then HC.UpdateCompactBlizzard('target');HC.UpdateCompactBlizzard('focus') end
end
local function MakePool()
 if #Lab.rows==2 then Layout();return end
 for _,unit in ipairs({'target','focus'}) do
  if not Lab[unit] then
  local row={unit=unit,reason='off'}
  row.frame=CreateFrame('Frame',nil,UIParent);row.frame:Hide();row.frame:SetFrameStrata('MEDIUM');row.frame:SetClampedToScreen(true)
  row.frame:SetMovable(true);row.frame:RegisterForDrag('LeftButton');row.frame:EnableMouse(false)
  row.frame:SetScript('OnDragStart',function(self)
   if Lab.mode=='preview' and Lab.positioning==unit and OutsideCombat() then row.dragging=true;self:StartMoving() end
  end)
  row.frame:SetScript('OnDragStop',function(self)
   local wanted=row.dragging and Lab.mode=='preview' and Lab.positioning==unit and OutsideCombat()
   row.dragging=false;self:StopMovingOrSizing()
   if not wanted then return end
   local ok,x,y=pcall(self.GetCenter,self)
   local fs,scale=pcall(self.GetEffectiveScale,self);local ps,parentScale=pcall(UIParent.GetEffectiveScale,UIParent)
   local ws,width=pcall(UIParent.GetWidth,UIParent);local hs,height=pcall(UIParent.GetHeight,UIParent)
   local function Numeric(v) return Accessible(v) and type(v)=='number' and v==v and v>-100000 and v<100000 end
   if not ok or not fs or not ps or not ws or not hs or not Numeric(x) or not Numeric(y) or not Numeric(scale) or not Numeric(parentScale) or not Numeric(width) or not Numeric(height) or scale<=0 or parentScale<=0 then Layout();return end
   HC.SetCompactPositionDraft(unit,x*scale/parentScale-width/2,y*scale/parentScale-height/2)
  end)
  row.background=row.frame:CreateTexture(nil,'BACKGROUND');row.background:SetAllPoints(row.frame)
  row.background:SetColorTexture(.03,.05,.07,.82)
  -- Independent synthetic widget: preview never reads or reuses a native timer.
  row.native=CreateFrame('StatusBar',nil,row.frame);row.native:SetPoint('TOPLEFT',row.frame,'TOPLEFT',0,0)
  row.preview=CreateFrame('StatusBar',nil,row.frame);row.preview:SetPoint('TOPLEFT',row.frame,'TOPLEFT',0,0)
  row.preview:SetMinMaxValues(0,1)
  local level=row.frame:GetFrameLevel()
  row.native:SetFrameLevel(level+1);row.preview:SetFrameLevel(level+1)
  row.overlay=CreateFrame('Frame',nil,row.frame);row.overlay:SetAllPoints(row.frame);row.overlay:SetFrameLevel(level+3);row.overlay:EnableMouse(false)
  -- A native FontString must have a font before Clear() first calls SetText.
  row.label=row.overlay:CreateFontString(nil,'OVERLAY','GameFontHighlight');row.label:SetFont('Fonts\\FRIZQT__.TTF',Lab.layout.font,'');row.label:SetPoint('CENTER',row.frame,'CENTER',0,0)
  row.label:SetJustifyH('LEFT');row.label:SetWordWrap(false)
  row.borders={}
  for i=1,4 do row.borders[i]=row.overlay:CreateTexture(nil,'ARTWORK') end
  row.driver=CreateFrame('Frame')
  -- Unit registration determines ownership; never inspect the event payload.
  row.driver:SetScript('OnEvent',function() if Lab.mode=='on' then dirty[unit]=true;Lab.stats.events=Lab.stats.events+1 end end)
  Clear(row,'off');Lab.rows[#Lab.rows+1]=row;Lab[unit]=row
  end
 end
 Layout()
end
local function Capability(row)
 if row.nativeHighlight and type(row.nativeHighlight.SetTimerDuration)~='function' then return 'missing' end
 if type(issecretvalue)~='function' then return 'guard' end
 if type(UnitExists)~='function' or type(UnitCastingDuration)~='function' or type(UnitChannelDuration)~='function'
  or type(row.native.SetTimerDuration)~='function' or type(Enum)~='table'
  or type(Enum.StatusBarInterpolation)~='table' or type(Enum.StatusBarTimerDirection)~='table' then return 'missing' end
 for _,value in ipairs({Enum.StatusBarInterpolation.Immediate,Enum.StatusBarTimerDirection.ElapsedTime,Enum.StatusBarTimerDirection.RemainingTime}) do
  if not Accessible(value) or type(value)~='number' then return 'missing' end
 end
 if Enum.StatusBarInterpolation.Immediate==nil or Enum.StatusBarTimerDirection.ElapsedTime==nil or Enum.StatusBarTimerDirection.RemainingTime==nil then return 'missing' end
end
local function PaintTime(row,object,channel)
 if Lab.timePlacement=='off' or not row.timeLabel then row.timeReason='off';return end
 -- Only call methods on an accessible duration object. A returned secret number
 -- is handed directly to the native formatter, never compared or calculated.
 local ok,value=false,nil
 if Accessible(object) and object~=nil then
  ok,value=pcall(function() return object:GetRemainingDuration() end)
 end
 if ok and (not Accessible(value) or (type(value)=='number' and value==value and value>=0 and value<math.huge)) then
  local written=pcall(row.timeLabel.SetFormattedText,row.timeLabel,'%.1f',value)
  if written then row.timeLabel:Show();row.timeReason='duration';return end
 end
 -- Older clients may expose ordinary end timestamps even without this method.
 local info=channel and UnitChannelInfo or UnitCastingInfo
 if type(info)=='function' then
  local read,_,_,_,_,ends=pcall(info,row.unit)
  if read and Accessible(ends) and type(ends)=='number' and ends==ends and ends>0 and ends<math.huge then
   row.timeLabel:SetFormattedText('%.1f',math.max(0,ends/1000-GetTime()))
   row.timeLabel:Show();row.timeReason='timestamp';return
  end
 end
 row.timeLabel:SetText('—');row.timeLabel:Show();row.timeReason='unavailable'
end
local function RefreshRow(row)
 local unavailable=Capability(row);if unavailable then Clear(row,unavailable);return end
 local existsOK,exists=pcall(UnitExists,row.unit)
 if not existsOK then Lab.stats.errors=Lab.stats.errors+1;Clear(row,'error');return end
 if Accessible(exists) and exists==false then Clear(row,'absent');return end
 -- An inaccessible existence flag is not proof that the unit is absent.
 for _,channel in ipairs({false,true}) do
  local api=channel and UnitChannelDuration or UnitCastingDuration
  Lab.stats.queries=Lab.stats.queries+1
  local ok,object=pcall(api,row.unit)
  if not ok then Lab.stats.errors=Lab.stats.errors+1;Clear(row,'error');return end
  -- No comparison, methods, arithmetic, retention or string conversion on an
  -- inaccessible/opaque duration. Only accessible nil proves this API idle.
  if not Accessible(object) or object~=nil then
   local direction=channel and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime
   local accepted,result=pcall(row.native.SetTimerDuration,row.native,object,Enum.StatusBarInterpolation.Immediate,direction)
   if not accepted or (Accessible(result) and result==false) then
    Lab.stats.denied=Lab.stats.denied+1;Clear(row,'denied');return
   end
   -- The neutral light layer receives the same opaque object directly. Never
   -- retain it or derive progress in Lua; either native handoff failing hides both.
   if row.nativeHighlight then
    local lightOK,lightResult=pcall(row.nativeHighlight.SetTimerDuration,row.nativeHighlight,object,Enum.StatusBarInterpolation.Immediate,direction)
    if not lightOK or (Accessible(lightResult) and lightResult==false) then
     Lab.stats.denied=Lab.stats.denied+1;Clear(row,'denied');return
    end
   end
   local name=T(channel and 'Kanalzauber' or 'Zauber',channel and 'Channel' or 'Cast')
   local info=channel and UnitChannelInfo or UnitCastingInfo
   if type(info)=='function' then
    local read,value=pcall(info,row.unit)
    if read and Accessible(value) and type(value)=='string' and value~='' then name=value end
   end
   PaintTime(row,object,channel)
   Lab.stats.submissions=Lab.stats.submissions+1;row.kind=channel and 'channel' or 'cast';row.reason='active'
   SetText(row,labels[row.unit]..' · '..name)
   row.preview:Hide();if row.previewHighlight then row.previewHighlight:Hide() end
   row.native:Show();if row.nativeHighlight then row.nativeHighlight:Show() end;row.frame:Show()
   if HC.UpdateCompactBlizzard then HC.UpdateCompactBlizzard(row.unit) end
   return
  end
 end
 Clear(row,'idle')
end
local function PaintPreview()
 for i,row in ipairs(Lab.rows) do
  row.reason='preview';row.kind=nil;row.native:Hide();if row.nativeHighlight then row.nativeHighlight:Hide() end
  local progress=i==1 and previewTime/3 or 1-previewTime/3
  row.preview:SetValue(progress)
  if row.previewHighlight then row.previewHighlight:SetValue(progress);row.previewHighlight:Show() end
  if row.timeLabel and Lab.timePlacement~='off' then row.timeLabel:SetFormattedText('%.1f',3-previewTime);row.timeLabel:Show() end
  SetText(row,labels[row.unit]..T(' · Vorschau',' · Preview'))
  row.preview:Show();row.frame:Show()
  row.frame:EnableMouse(Lab.positioning==row.unit)
  if HC.UpdateCompactBlizzard then HC.UpdateCompactBlizzard(row.unit) end
 end
end
local function Update(_,elapsed)
 if Lab.mode=='preview' then previewTime=(previewTime+elapsed)%3;PaintPreview();return end
 if Lab.mode~='on' then return end
 elapsedTotal=elapsedTotal+elapsed
 local poll=elapsedTotal>=.2
 if poll then elapsedTotal=0;Lab.stats.polls=Lab.stats.polls+1 end
 for _,row in ipairs(Lab.rows) do
  if dirty[row.unit] or poll then dirty[row.unit]=false;RefreshRow(row) end
 end
end
local function Disable()
 Lab.mode='off';elapsedTotal=0;previewTime=0;dirty.target=false;dirty.focus=false
 control:SetScript('OnUpdate',nil);control:UnregisterAllEvents()
 for _,row in ipairs(Lab.rows) do row.driver:UnregisterAllEvents();row.dragging=false;row.frame:StopMovingOrSizing();row.frame:EnableMouse(false) end
 ClearAll('off')
end
local unitEvents={'UNIT_SPELLCAST_START','UNIT_SPELLCAST_STOP','UNIT_SPELLCAST_DELAYED','UNIT_SPELLCAST_CHANNEL_START',
 'UNIT_SPELLCAST_CHANNEL_UPDATE','UNIT_SPELLCAST_CHANNEL_STOP','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_FAILED_QUIET',
 'UNIT_SPELLCAST_INTERRUPTED','UNIT_SPELLCAST_SUCCEEDED'}
local function Register(frame,event,unit)
 local api=unit and frame.RegisterUnitEvent or frame.RegisterEvent
 local ok=false
 if type(api)=='function' then
  if unit then ok=pcall(api,frame,event,unit) else ok=pcall(api,frame,event) end
 end
 if not ok then Lab.stats.missingEvents=Lab.stats.missingEvents+1 end
 return ok
end
control:SetScript('OnEvent',function(_,event)
 if Lab.mode=='preview' then if event=='PLAYER_REGEN_DISABLED' then
  if Lab.positioning and HC.EndCompactPositioning then HC.EndCompactPositioning(false,'combat')
  else Disable();if Lab.ResumeAfterPreview then Lab.ResumeAfterPreview() end end
 end;return end
 if Lab.mode~='on' then return end
 if event=='PLAYER_TARGET_CHANGED' or event=='PLAYER_FOCUS_CHANGED' then
  local unit=event=='PLAYER_TARGET_CHANGED' and 'target' or 'focus'
  Clear(Lab[unit],'changed');dirty[unit]=true
 elseif event=='PLAYER_ENTERING_WORLD' then
  ClearAll('changed');dirty.target=true;dirty.focus=true
 end
end)
function Lab.SetMode(mode)
 if mode=='off' then Disable();return true end
 if mode~='on' and mode~='preview' then return false,'command' end
 if not Supported() then return false,'unsupported' end
 if mode=='preview' and not OutsideCombat() then return false,'combat' end
 Disable();MakePool();Lab.mode=mode;Lab.stats.missingEvents=0
 local registered=true
 if mode=='on' then
  for _,row in ipairs(Lab.rows) do
   for _,event in ipairs(unitEvents) do if not Register(row.driver,event,row.unit) then registered=false end end
  end
  for _,event in ipairs({'PLAYER_TARGET_CHANGED','PLAYER_FOCUS_CHANGED','PLAYER_ENTERING_WORLD'}) do
   if not Register(control,event) then registered=false end
  end
 else registered=Register(control,'PLAYER_REGEN_DISABLED') end
 if not registered then Disable();return false,'events' end
 control:SetScript('OnUpdate',Update)
 if mode=='on' then for _,row in ipairs(Lab.rows) do RefreshRow(row) end else PaintPreview() end
 return true
end
function Lab.SetLayout(width,height,font)
 if not OutsideCombat() then return false,'combat' end
 if not Accessible(width) or not Accessible(height) or not Accessible(font) then return false,'layout' end
 if type(width)~='number' or width~=width or width<120 or width>420 or width%1~=0
  or type(height)~='number' or height~=height or height<16 or height>36 or height%1~=0
  or type(font)~='number' or font~=font or font<10 or font>20 or font%1~=0 then return false,'layout' end
 if font>height-4 then return false,'font-fit' end
 Lab.layout.width=width;Lab.layout.height=height;Lab.layout.font=font;Layout();if Lab.OnSettingsChanged then Lab.OnSettingsChanged() end;return true
end
function Lab.SetStyle(style)
 if not OutsideCombat() then return false,'combat' end
 if not Accessible(style) or type(style)~='string' or not styles[style] then return false,'style' end
 Lab.style=style;Layout();if Lab.OnSettingsChanged then Lab.OnSettingsChanged() end;return true
end
function Lab.SetColor(r,g,b)
 if not OutsideCombat() then return false,'combat' end
 for _,value in ipairs({r,g,b}) do
  if not Accessible(value) or type(value)~='number' or value~=value or value<0 or value>1 then return false,'color' end
 end
 -- Explicit nil checks: ipairs stops at holes.
 if r==nil or g==nil or b==nil then return false,'color' end
 Lab.color={r,g,b};Layout();if Lab.OnSettingsChanged then Lab.OnSettingsChanged() end;return true
end

-- Preferences are owned by HanseCastDB. The old unit-bar settings remain inert.
local initialized,restoring=false,false
local lifecycle=CreateFrame('Frame');Lab.lifecycle=lifecycle
local function Number(value,low,high,integer)
 return Accessible(value) and type(value)=='number' and value==value and value>=low and value<=high and (not integer or value%1==0)
end
local function Table(value) return Accessible(value) and type(value)=='table' end
local function Normalize(source)
 local result={enabled=true,timePlacement='off',style='classic',color={.24,.67,.9},layout={width=240,height=20,font=12},positions={},hideBlizzard={target=false,focus=false}}
 if not Table(source) then return result end
 if Accessible(source.timePlacement) and (source.timePlacement=='off' or source.timePlacement=='inside' or source.timePlacement=='outside') then result.timePlacement=source.timePlacement end
 if Accessible(source.enabled) and type(source.enabled)=='boolean' then result.enabled=source.enabled end
 if Accessible(source.style) and type(source.style)=='string' and styles[source.style] then result.style=source.style end
 local color=source.color
 if Table(color) and Number(color[1],0,1) and Number(color[2],0,1) and Number(color[3],0,1) then result.color={color[1],color[2],color[3]} end
 local layout=source.layout
 if Table(layout) and Number(layout.width,120,420,true) and Number(layout.height,16,36,true) and Number(layout.font,10,20,true) and layout.font<=layout.height-4 then
  result.layout={width=layout.width,height=layout.height,font=layout.font}
 end
 for _,unit in ipairs({'target','focus'}) do
  local positions=source.positions
  local position=Table(positions) and positions[unit] or nil
  if Table(position) and Number(position.x,-10000,10000) and Number(position.y,-10000,10000) then result.positions[unit]={x=position.x,y=position.y} end
  if Table(source.hideBlizzard) and Accessible(source.hideBlizzard[unit]) and type(source.hideBlizzard[unit])=='boolean' then result.hideBlizzard[unit]=source.hideBlizzard[unit] end
 end
 return result
end
function HC.LoadCompactSettings(db,saved)
 if type(db)~='table' then return end
 local source
 if Table(saved) then source=saved.compactUnits end
 -- One-time preference migration only; the separate lab's live mode is ignored.
 if not Table(source) and Table(HanseCastCompactLabDB) and Accessible(HanseCastCompactLabDB.schema) and HanseCastCompactLabDB.schema==1 then source=HanseCastCompactLabDB end
 db.compactUnits=Normalize(source)
 return db.compactUnits
end
local function Save()
 if restoring or not initialized or type(HC.db)~='table' then return end
 local color=Lab.colorPreviewOriginal or Lab.color
 HC.db.compactUnits={enabled=Lab.enabled==true,timePlacement=Lab.timePlacement,style=Lab.style,color={color[1],color[2],color[3]},
  layout={width=Lab.layout.width,height=Lab.layout.height,font=Lab.layout.font},positions={},hideBlizzard={target=Lab.hideBlizzard.target,focus=Lab.hideBlizzard.focus}}
 for _,unit in ipairs({'target','focus'}) do local position=Lab.positions[unit];if position then HC.db.compactUnits.positions[unit]={x=position.x,y=position.y} end end
end
Lab.OnSettingsChanged=Save
function HC.BeginCompactColorPreview()
 if not initialized or not OutsideCombat() or Lab.colorPreviewOriginal then return false end
 Lab.colorPreviewOriginal={Lab.color[1],Lab.color[2],Lab.color[3]};return true
end
function HC.UpdateCompactColorPreview(r,g,b)
 if not Lab.colorPreviewOriginal or not OutsideCombat() then return false end
 if not Number(r,0,1) or not Number(g,0,1) or not Number(b,0,1) then return false end
 Lab.color={r,g,b};Layout();return true
end
function HC.EndCompactColorPreview(commit)
 if not Lab.colorPreviewOriginal then return end
 local original=Lab.colorPreviewOriginal;Lab.colorPreviewOriginal=nil
 if commit and OutsideCombat() then Save() else Lab.color=original;Layout() end
end
local function RegisterLifecycle()
 lifecycle:UnregisterAllEvents()
 if not initialized or Lab.enabled then
  lifecycle:RegisterEvent('PLAYER_REGEN_ENABLED');lifecycle:RegisterEvent('PLAYER_ENTERING_WORLD')
 end
end
local function Activate()
 if not initialized then return false,'initializing' end
 if Lab.enabled then return Lab.SetMode('on') end
 return Lab.SetMode('off')
end
function HC.InitializeCompactUnits()
 if type(HC.db)~='table' then return false,'settings' end
 -- Saved geometry is restored only outside combat; live resume itself is safe.
 if not OutsideCombat() then initialized=false;RegisterLifecycle();return false,'combat' end
 local config=Normalize(HC.db.compactUnits)
 restoring=true;Lab.timePlacement=config.timePlacement;Lab.enabled=config.enabled;Lab.positions=config.positions;Lab.hideBlizzard=config.hideBlizzard
 Lab.SetStyle(config.style);Lab.SetColor(config.color[1],config.color[2],config.color[3])
 Lab.SetLayout(config.layout.width,config.layout.height,config.layout.font)
 restoring=false;initialized=true;Save();RegisterLifecycle();return Activate()
end
function HC.SetCompactEnabled(enabled)
 if not Accessible(enabled) or type(enabled)~='boolean' then return false,'enabled' end
 if enabled and not OutsideCombat() then return false,'combat' end
 if not initialized then
  if type(HC.db)~='table' then return false,'settings' end
  if not enabled then
   HC.db.compactUnits=Normalize(HC.db.compactUnits);HC.db.compactUnits.enabled=false
   Lab.enabled=false;Lab.SetMode('off');return true
  end
  HC.InitializeCompactUnits()
 end
 if Lab.positioning then HC.EndCompactPositioning(false,'disabled') end
 Lab.enabled=enabled;Save();RegisterLifecycle();return Activate()
end
function HC.SetCompactStyle(style)
 if not initialized then return false,'initializing' end
 return Lab.SetStyle(style)
end
function HC.SetCompactColor(hex)
 if not initialized then return false,'initializing' end
 if not Accessible(hex) or type(hex)~='string' or not hex:match('^%x%x%x%x%x%x$') then return false,'color' end
 if not OutsideCombat() then return false,'combat' end
 if HC.CancelCompactColorPicker then HC.CancelCompactColorPicker() end
 return Lab.SetColor(tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255)
end
function HC.SetCompactTimePlacement(mode)
 if not initialized then return false,'initializing' end
 if not OutsideCombat() then return false,'combat' end
 if not Accessible(mode) or (mode~='off' and mode~='inside' and mode~='outside') then return false,'value' end
 Lab.timePlacement=mode;Layout();Save();dirty.target=true;dirty.focus=true;return true
end
function HC.SetCompactLayout(width,height,font)
 if not initialized then return false,'initializing' end
 return Lab.SetLayout(width,height,font)
end
function HC.PreviewCompactUnits(show)
 if not initialized then return false,'initializing' end
 if not Accessible(show) or type(show)~='boolean' then return false,'preview' end
 if Lab.positioning then HC.EndCompactPositioning(false,'preview') end
 if show then return Lab.SetMode('preview') end
 return Activate()
end
function HC.SetCompactHideBlizzard(unit,enabled)
 if not initialized then return false,'initializing' end
 if not OutsideCombat() then return false,'combat' end
 if not Accessible(unit) or (unit~='target' and unit~='focus') or not Accessible(enabled) or type(enabled)~='boolean' then return false,'value' end
 Lab.hideBlizzard[unit]=enabled;Save()
 if HC.UpdateCompactBlizzard then HC.UpdateCompactBlizzard(unit) end
 return true
end
function HC.StartCompactPositioning(unit)
 if not initialized then return false,'initializing' end
 if not OutsideCombat() then return false,'combat' end
 if not Accessible(unit) or (unit~='target' and unit~='focus') then return false,'unit' end
 if Lab.positioning then HC.EndCompactPositioning(false,'restart') end
 local ok,reason=Lab.SetMode('preview');if not ok then return false,reason end
 Lab.positioning=unit;Lab.positionDraft={}
 local total=Lab.layout.height+(Lab.style=='split' and Lab.layout.font+6 or 0)
 for i,row in ipairs(Lab.rows) do
  local position=Lab.positions[row.unit]
  Lab.positionDraft[row.unit]={x=position and position.x or 0,y=position and position.y or -70-(i-1)*(total+12)}
 end
 Layout();PaintPreview();return true
end
function HC.SetCompactPositionDraft(unit,x,y)
 if not OutsideCombat() then return false,'combat' end
 if not Accessible(unit) or unit~=Lab.positioning or not Lab.positionDraft then return false,'positioning' end
 if not Number(x,-10000,10000) or not Number(y,-10000,10000) then Layout();return false,'position' end
 Lab.positionDraft[unit]={x=x,y=y};Layout();return true
end
function HC.EndCompactPositioning(commit,reason)
 if not Accessible(commit) or type(commit)~='boolean' then return false,'value' end
 if not Lab.positioning then return true end
 local unit=Lab.positioning
 local accepted=commit==true and OutsideCombat()
 if accepted then local position=Lab.positionDraft[unit];Lab.positions[unit]={x=position.x,y=position.y} end
 Lab.positioning=nil;Lab.positionDraft=nil
 for _,row in ipairs(Lab.rows) do row.dragging=false;row.frame:StopMovingOrSizing();row.frame:EnableMouse(false) end
 Layout();if accepted then Save() end
 local ok,why=Activate()
 if HC.OnCompactPositionEnded then HC.OnCompactPositionEnded(accepted,reason) end
 return ok,why
end
function HC.CompactMode() return Lab.mode end
Lab.ResumeAfterPreview=Activate
lifecycle:SetScript('OnEvent',function(_,event)
 if not initialized then if OutsideCombat() then
  if HC.StartCompactSafely then HC.StartCompactSafely() else HC.InitializeCompactUnits() end
 end
 elseif Lab.enabled and Lab.mode=='off' and (event=='PLAYER_REGEN_ENABLED' or event=='PLAYER_ENTERING_WORLD') then Activate() end
end)
