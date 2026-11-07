local _,HC=...
local fonts={default='Fonts\\FRIZQT__.TTF',modern='Fonts\\ARIALN.TTF'}
function HC.CreateComfortView(f)
 f.spellIcon=f:CreateTexture(nil,'ARTWORK');f.spellIcon:Hide()
 f.latencyMark=f:CreateTexture(nil,'OVERLAY');f.latencyMark:SetColorTexture(1,.72,.3,.7);f.latencyMark:Hide()
 f.tickMarks={}
 for i=1,9 do local t=f:CreateTexture(nil,'OVERLAY');t:SetColorTexture(.85,.9,1,.5);t:Hide();f.tickMarks[i]=t end
end
function HC.HideComfortView()
 local f=HC.frame;if not f then return end
 if f.spellIcon then f.spellIcon:Hide();f.latencyMark:Hide();for _,t in ipairs(f.tickMarks) do t:Hide() end end
end
function HC.ApplyComfortLayout()
 local f,db=HC.frame,HC.db;if not f or not db then return end
 for _,label in ipairs({f.label,f.time}) do
  if label and label.SetFont then label:SetFont(fonts[db.font] or fonts.default,db.fontSize or 12,'') end
 end
 if f.spellIcon then
  local size=math.max(16,math.min(28,db.height));f.spellIcon:SetSize(size,size);f.spellIcon:ClearAllPoints()
  local right=db.iconPosition=='right'
  local reserve=not right and (f.factionReserve or 0) or 0
  f.spellIcon:SetPoint(right and 'LEFT' or 'RIGHT',f,right and 'RIGHT' or 'LEFT',right and 6 or -6-reserve,0)
  f.spellIcon:SetTexCoord(.08,.92,.08,.92)
 end
end
function HC.FormatCastTime(cast,now,remaining,duration)
 local mode=HC.db.timeFormat or 'remaining'
 if mode=='hidden' then return '',0 end
 local elapsed=math.max(0,math.min(duration,now-cast.start))
 if mode=='elapsed' then return string.format('%.1f s',elapsed),62 end
 if mode=='both' then return string.format('%.1f / %.1f s',elapsed,duration),96 end
 if cast.timingDelta and cast.timingUntil and now<cast.timingUntil then
  local color=cast.timingDelta>0 and 'ffffbc70' or 'ff8ce8ff'
  return string.format('%.1f s |c%s%+.1f|r',remaining,color,cast.timingDelta),112
 end
 return string.format('%.1f s',remaining),62
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
 f.spellIcon:Hide();f.latencyMark:Hide();for _,t in ipairs(f.tickMarks) do t:Hide() end
 if db.iconPosition and db.iconPosition~='hidden' and HC.Accessible(cast.icon)
  and (type(cast.icon)=='number' or type(cast.icon)=='string') then
  if f.spellIconValue~=cast.icon then
   f.spellIconValue=cast.icon;f.spellIconLoaded=f.spellIcon:SetTexture(cast.icon)~=false
  end
  if f.spellIconLoaded then f.spellIcon:Show() end
 end
 if db.latency and not cast.channel and duration>0 then
  local lag=Latency(now)
  if lag and lag>0 then
   local width=math.min(db.width*.25,db.width*lag/duration)
   f.latencyMark:SetSize(math.max(1,width),2);f.latencyMark:SetPoint('BOTTOMRIGHT',f,'TOPRIGHT',0,1);f.latencyMark:Show()
  end
 end
 -- Explicitly manual equal-segment guides. These are NOT observed damage/heal
 -- ticks and never infer a spell cadence or claim knowledge of secret data.
 if db.channelTicks and cast.channel and duration>0 then
  local count=math.floor(db.channelTickCount or 5)
  for i=1,math.min(9,count-1) do
   local t=f.tickMarks[i];t:SetSize(1,5);t:SetPoint('TOPLEFT',f,'TOPLEFT',db.width*i/count,-1);t:Show()
  end
 end
end
