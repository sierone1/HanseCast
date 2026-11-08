local _,HC=...
-- These regions are owned exclusively by this module. Parent-frame hiding does
-- not change a child's own shown flag, so retain the cache across frame hides.
local function Visible(region,shown)
 shown=shown==true
 if region.hcComfortShown==shown then return end
 region.hcComfortShown=shown
 if shown then region:Show() else region:Hide() end
end
-- Optional observations, never a replacement for authoritative cast timing.
-- Keep one pending send and one accepted sample; no history or polling driver.
local pendingSend,delaySample
local function Context() return {db=HC.db,profile=HC.db.activeProfile,revision=HC.profileRevision or 0} end
local function SameContext(context)
 return context and context.db==HC.db and context.profile==HC.db.activeProfile and context.revision==(HC.profileRevision or 0)
end
local function SafeID(value)
 if not HC.Accessible(value) then return nil end
 if type(value)=='string' and value~='' then return value end
 if HC.ValidNumber(value,0,1e15) then return value end
end
local function SafeSpell(value)
 if HC.Accessible(value) and HC.ValidNumber(value,1,2147483647) and value%1==0 then return value end
end
function HC.ResetComfortTiming()
 pendingSend=nil;delaySample=nil;HC.queueChecked=nil;HC.queueSeconds=nil;HC.delayObserved=false
end
function HC.ObserveComfortEvent(event,unit,...)
 if not HC.db.castDelay or HC.preview then pendingSend=nil;delaySample=nil;return end
 local now=GetTime()
 if event=='UNIT_SPELLCAST_SENT' then
  -- target is deliberately ignored; GUID/spell are checked before inspection.
  local guid,spell=SafeID(select(2,...)),SafeSpell(select(3,...))
  if not guid or not spell then pendingSend=nil;return end
  if pendingSend and now>=pendingSend.at and now-pendingSend.at<=2 then
   -- Multiple sends before START are ambiguous, even with equal spell IDs.
   pendingSend={blocked=true,at=now};return
  end
  pendingSend={guid=guid,spell=spell,at=now,context=Context()};return
 end
 if event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' then
  HC.delayObserved=false
  local send=pendingSend;pendingSend=nil;delaySample=nil
  local guid,spell,id=SafeID(select(1,...)),SafeSpell(select(2,...)),SafeID(select(3,...))
  if not send or send.blocked or not SameContext(send.context) or not guid or not spell or not id then return end
  local elapsed=now-send.at
  if guid~=send.guid or spell~=send.spell or elapsed<0 or elapsed>2 then return end
  delaySample={id=id,spell=spell,seconds=elapsed,at=now,context=send.context};HC.delayObserved=true;return
 end
 if HC.CastState and HC.CastState.terminalEvents[event] or event=='UNIT_SPELLCAST_SUCCEEDED' then
  local guid=SafeID(select(1,...))
  if pendingSend and guid and pendingSend.guid==guid then pendingSend=nil end
 end
end
function HC.GetCastStartDelay(cast)
 if not HC.db.castDelay or HC.preview then pendingSend=nil;delaySample=nil;return nil end
 if not delaySample or not cast then return nil end
 if not SameContext(delaySample.context) then delaySample=nil;HC.delayObserved=false;return nil end
 local id,spell=SafeID(cast.id),SafeSpell(cast.spellID)
 if not id or not spell or id~=delaySample.id or spell~=delaySample.spell then return nil end
 -- Refreshed API records may change duration; identity, not table identity, owns it.
 if cast.finish<=delaySample.at or cast.start>delaySample.at+.5 or cast.start<delaySample.at-2 then return nil end
 -- START is observed before the authoritative cast read. Bind the first read
 -- to its safe start; later legitimate timing changes are handled by the
 -- lifecycle without granting an unrelated reused identifier a sample.
 if delaySample.castStart and cast.start~=delaySample.castStart then
  delaySample=nil;HC.delayObserved=false;return nil
 end
 delaySample.castStart=cast.start
 return delaySample.seconds
end
function HC.ReadQueueWindow(now)
 if HC.queueChecked and now>=HC.queueChecked and now-HC.queueChecked<1 then return HC.queueSeconds end
 HC.queueChecked=now;HC.queueSeconds=nil
 local api=C_CVar and C_CVar.GetCVar or GetCVar
 if type(api)~='function' then return nil end
 local ok,value=pcall(api,'SpellQueueWindow')
 if not ok or not HC.Accessible(value) then return nil end
 if type(value)~='number' and type(value)~='string' then return nil end
 value=tonumber(value)
 if not HC.ValidNumber(value,0,2000) then return nil end
 HC.queueSeconds=value/1000;return HC.queueSeconds
end
function HC.GetComfortDiagnostic()
 local de=not HC.GetLanguage or HC.GetLanguage()=='deDE'
 local delay=not HC.db.castDelay and (de and 'aus' or 'off')
  or HC.delayObserved and (de and 'zuletzt sicher zugeordnet' or 'last sample safely matched')
  or (de and 'keine sichere Zuordnung; ggf. geschuetzte/fehlende Ereignisdaten' or 'no safe match; event data may be restricted/missing')
 local queue=de and 'aus' or 'off'
 if HC.db.queueWindow then
  local value=HC.ReadQueueWindow(GetTime())
  queue=value and string.format('%d ms',math.floor(value*1000+.5))
   or (de and 'nicht lesbar/verfuegbar' or 'unreadable/unavailable')
 end
 return (de and 'Start-Schaetzung: ' or 'Start estimate: ')..delay..(de and ' | Warteschlange: ' or ' | Queue window: ')..queue
end
function HC.CreateComfortView(f)
 f.spellIcon=f:CreateTexture(nil,'ARTWORK');Visible(f.spellIcon,false)
 f.latencyMark=f:CreateTexture(nil,'OVERLAY');f.latencyMark:SetColorTexture(1,.72,.3,.7);Visible(f.latencyMark,false)
 f.queueMark=f:CreateTexture(nil,'OVERLAY');f.queueMark:SetColorTexture(.3,.8,1,.75);Visible(f.queueMark,false)
 f.delayText=f:CreateFontString(nil,'OVERLAY');Visible(f.delayText,false)
 f.tickMarks={}
 for i=1,9 do local t=f:CreateTexture(nil,'OVERLAY');t:SetColorTexture(.85,.9,1,.5);Visible(t,false);f.tickMarks[i]=t end
end
function HC.HideComfortView()
 local f=HC.frame;if not f then return end
 if f.spellIcon then Visible(f.spellIcon,false);Visible(f.latencyMark,false);Visible(f.queueMark,false);Visible(f.delayText,false);for _,t in ipairs(f.tickMarks) do Visible(t,false) end end
end
function HC.ApplyComfortLayout()
 local f,db=HC.frame,HC.db;if not f or not db then return end
 for _,label in ipairs({f.label,f.time,f.delayText}) do
  if label and label.SetFont then HC.ApplyCastFont(label) end
 end
 if f.delayText then f.delayText:ClearAllPoints();f.delayText:SetPoint('TOPLEFT',f,'BOTTOMLEFT',0,-10) end
 if f.spellIcon then
  local size=math.max(16,math.min(28,db.height));f.spellIcon:SetSize(size,size);f.spellIcon:ClearAllPoints()
  local right=db.iconPosition=='right'
  local reserve=not right and (f.factionReserve or 0) or 0
  f.spellIcon:SetPoint(right and 'LEFT' or 'RIGHT',f,right and 'RIGHT' or 'LEFT',right and 6 or -6-reserve,0)
  f.spellIcon:SetTexCoord(.08,.92,.08,.92)
 end
end
-- Cache one visible time value, never a growing per-cast history. Quantize
-- display values only; progress and cast deadlines retain their full precision.
local timeCache={}
local function Tenth(value) return math.floor(value*10+.5) end
function HC.FormatCastTime(cast,now,remaining,duration,cache)
 local timeCache=cache or timeCache
 local mode=HC.db.timeFormat or 'remaining'
 if mode=='hidden' then return '',0 end
 local elapsed=math.max(0,math.min(duration,now-cast.start))
 local delta=mode=='remaining' and cast.timingDelta and cast.timingUntil and now<cast.timingUntil and cast.timingDelta or nil
 local value=Tenth((mode=='elapsed' or mode=='both') and elapsed or remaining)
 local total=mode=='both' and Tenth(duration) or nil
 if timeCache.mode==mode and timeCache.value==value and timeCache.total==total and timeCache.delta==delta then
  return timeCache.text,timeCache.inset
 end
 local text,inset
 if mode=='both' then text,inset=string.format('%.1f / %.1f s',value/10,total/10),96
 elseif delta then
  local color=delta>0 and 'ffffbc70' or 'ff8ce8ff'
  text,inset=string.format('%.1f s |c%s%+.1f|r',value/10,color,delta),112
 else text,inset=string.format('%.1f s',value/10),62 end
 timeCache.mode,timeCache.value,timeCache.total,timeCache.delta=mode,value,total,delta
 timeCache.text,timeCache.inset=text,inset
 return text,inset
end

local function Latency(now)
 if HC.latencyChecked and now>=HC.latencyChecked and now-HC.latencyChecked<1 then return HC.latencySeconds end
 HC.latencyChecked=now;HC.latencySeconds=nil
 if type(GetNetStats)~='function' then return nil end
 local ok,_,_,_,world=pcall(GetNetStats)
 if not ok or not HC.Accessible or not HC.Accessible(world) or not HC.ValidNumber(world,0,5000) then return nil end
 HC.latencySeconds=world/1000;return HC.latencySeconds
end
function HC.DrawComfort(cast,now,duration)
 local f,db=HC.frame,HC.db;if not f.spellIcon then return end
 local showIcon=false
 if db.iconPosition and db.iconPosition~='hidden' and HC.Accessible(cast.icon)
  and (type(cast.icon)=='number' or type(cast.icon)=='string') then
  local id=HC.Accessible(cast.id) and cast.id or nil
  if type(id)~='number' and type(id)~='string' then id=nil end
  local newCast
  if id~=nil then newCast=id~=f.spellIconCastID
  else newCast=cast.start~=f.spellIconCastStart or cast.channel~=f.spellIconCastChannel end
  -- Successful loads stay cached. A failed optional icon can recover on the
  -- next cast, or once per second while the same cast is still being drawn.
  -- No timers and no per-frame retry loop for a missing resource.
  if f.spellIconValue~=cast.icon or (not f.spellIconLoaded and
   (newCast or not f.spellIconRetryAt or now>=f.spellIconRetryAt or now<(f.spellIconAttemptAt or now))) then
   f.spellIconValue=cast.icon;f.spellIconLoaded=f.spellIcon:SetTexture(cast.icon)~=false
   f.spellIconCastID=id;f.spellIconCastStart=cast.start;f.spellIconCastChannel=cast.channel
   f.spellIconAttemptAt=now;f.spellIconRetryAt=f.spellIconLoaded and nil or now+1
  end
  showIcon=f.spellIconLoaded==true
 end
 Visible(f.spellIcon,showIcon)
 local showLatency=false
 if db.latency and not cast.channel and duration>0 then
  local lag=Latency(now)
  if lag and lag>0 then
   local width=math.min(db.width*.25,db.width*lag/duration)
   width=math.max(1,width)
   if f.latencyMark.hcWidth~=width then
    f.latencyMark:SetSize(width,2);f.latencyMark:SetPoint('BOTTOMRIGHT',f,'TOPRIGHT',0,1);f.latencyMark.hcWidth=width
   end
   showLatency=true
  end
 end
 Visible(f.latencyMark,showLatency)
 local showQueue=false
 if db.queueWindow and not cast.channel and duration>0 then
  local seconds=HC.ReadQueueWindow(now)
  if seconds and seconds>0 then
   local width=math.max(1,db.width*math.min(1,seconds/duration))
   if f.queueMark.hcWidth~=width then
    f.queueMark:SetSize(width,2);f.queueMark:SetPoint('TOPRIGHT',f,'BOTTOMRIGHT',0,-1);f.queueMark.hcWidth=width
   end
   showQueue=true
  end
 end
 Visible(f.queueMark,showQueue)
 local delay=HC.GetCastStartDelay(cast)
 if delay then
  local ms=math.floor(delay*1000+.5)
  if f.delayText.hcMilliseconds~=ms then
   f.delayText:SetText(string.format('Start ~%d ms',ms));f.delayText.hcMilliseconds=ms
  end
 end
 Visible(f.delayText,delay~=nil)
 -- Explicitly manual equal-segment guides. These are NOT observed damage/heal
 -- ticks and never infer a spell cadence or claim knowledge of secret data.
 local count=db.channelTicks and cast.channel and duration>0 and math.floor(db.channelTickCount or 5) or 0
 for i,t in ipairs(f.tickMarks) do
  local shown=i<count
  local x=shown and db.width*i/count or nil
  if shown and t.hcGuideX~=x then
   t:SetSize(1,5);t:SetPoint('TOPLEFT',f,'TOPLEFT',x,-1);t.hcGuideX=x
  end
  Visible(t,shown)
 end
end
