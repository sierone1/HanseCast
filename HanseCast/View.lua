local _, HC = ...
local L=function(text) return HC.L and HC.L(text) or text end
local texture="Interface\\Buttons\\WHITE8X8"
-- Native Blizzard texture paths; provenance and crop rationale in
-- docs/FACTION-EMBLEM-SOURCES.md. Selection is explicit, never inferred.
local factionTextures={alliance="Interface\\TargetingFrame\\UI-PVP-Alliance",
    horde="Interface\\TargetingFrame\\UI-PVP-Horde"}
local factionFailures={}
function HC.UpdateFactionIcon()
    local f,db=HC.frame,HC.db
    if not f or not f.icon or not db then return 0 end
    local path=factionTextures[db.faction]
    if not path then f.icon:Hide();f.factionReserve=0;HC.factionIconStatus="none";return 0 end
    local size=math.max(14,math.min(18,db.height*.65))
    local result=f.icon:SetTexture(path,"CLAMP","CLAMP","LINEAR")
    if result==false then factionFailures[path]=true elseif result==true then factionFailures[path]=nil end
    f.icon:SetSize(size,size);f.icon:ClearAllPoints()
    f.icon:SetPoint("RIGHT",f,"LEFT",-5,0)
    f.icon:SetTexCoord(0,.625,0,.625)
    f.icon:SetBlendMode("BLEND");f.icon:SetVertexColor(1,1,1,1);f.icon:SetAlpha(1)
    f.icon.hcFactionLoadFailed=factionFailures[path]==true
    HC.factionIconStatus=f.icon.hcFactionLoadFailed and "explicitfailed" or "selected"
    if f.icon.hcFactionLoadFailed then f.icon:Hide() else f.icon:Show() end
    f.factionReserve=size+5
    return f.factionReserve
end
local function Text(region,value)
    if region.hcText~=value then region:SetText(value);region.hcText=value end
end
local function LabelColor(region,r,g,b,a)
    if region.hcR~=r or region.hcG~=g or region.hcB~=b or region.hcA~=a then
        region:SetTextColor(r,g,b,a);region.hcR=r;region.hcG=g;region.hcB=b;region.hcA=a
    end
end
local function Alpha(frame,value)
    if frame.hcViewAlpha~=value or frame.hcViewOpacity~=(HC.db.opacity or 1) then frame.hcViewOpacity=HC.db.opacity or 1; frame:SetAlpha(value*(HC.db.opacity or 1));frame.hcViewAlpha=value end
end
local function TimeInset(frame,value)
    if frame.hcTimeInset~=value then
        frame.label:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",-value,4);frame.hcTimeInset=value
    end
end

function HC.CreateView()
    local f=CreateFrame("Frame","HanseCastPlayer",UIParent)
    HC.frame=f
    f:SetFrameStrata("MEDIUM");f:SetClampedToScreen(true);f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    -- Retained as an invisible numerical progress widget; no filled rectangle.
    f.bar=CreateFrame("StatusBar",nil,f);f.bar:Hide()
    f.caps={};f.marks={}
    f.icon=f:CreateTexture(nil,"ARTWORK");f.icon:Hide()
    if f.icon.SetSnapToPixelGrid then f.icon:SetSnapToPixelGrid(false) end
    if f.icon.SetTexelSnappingBias then f.icon:SetTexelSnappingBias(0) end
    HC.CreateEffects(f)
    if HC.CreateComfortView then HC.CreateComfortView(f) end
    f.resultOverlay=CreateFrame("Frame",nil,f)
    f.resultOverlay:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
    f.resultOverlay:SetFrameLevel(HC.effects.tipFrame:GetFrameLevel()+1)
    f.resultOverlay:Show()
    f.resultLight=f.resultOverlay:CreateTexture(nil,"OVERLAY")
    f.resultLight.hcLoadFailed=f.resultLight:SetTexture("Interface\\AddOns\\HanseCast\\Media\\Mote.tga","CLAMP","CLAMP","LINEAR")==false
    f.resultLight:SetBlendMode("ADD")
    if f.resultLight.SetSnapToPixelGrid then f.resultLight:SetSnapToPixelGrid(false) end
    if f.resultLight.SetTexelSnappingBias then f.resultLight:SetTexelSnappingBias(0) end
    f.resultLight:Hide()
    -- Text stays independent of the effect height and never covers the energy.
    f.label=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    f.label:SetPoint("BOTTOMLEFT",f,"TOPLEFT",0,4)
    f.label:SetPoint("BOTTOMRIGHT",f,"TOPRIGHT",-62,4)
    f.label:SetJustifyH("LEFT");f.label:SetWordWrap(false)
    f.label:SetShadowColor(0,0,0,1);f.label:SetShadowOffset(1,-1)
    f.time=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    f.time:SetPoint("BOTTOMRIGHT",f,"TOPRIGHT",0,4)
    f.time:SetShadowColor(0,0,0,1);f.time:SetShadowOffset(1,-1)
    f.hint=f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    f.hint:SetPoint("BOTTOM",f,"TOP",0,23)
    if HC.Localize then HC.Localize(f.hint,"HANSE CAST · Vorschau · Ziehen zum Verschieben") else f.hint:SetText("HANSE CAST · Vorschau · Ziehen zum Verschieben") end
    local g=CreateFrame("Frame","HanseCastGCD",UIParent)
    HC.gcdFrame=g;g:SetFrameStrata("MEDIUM")
    g.background=g:CreateTexture(nil,"BACKGROUND")
    g.background:SetPoint("TOPLEFT");g.background:SetPoint("BOTTOMRIGHT")
    g.background:SetColorTexture(0.24,0.28,0.34,0.55)
    g.bar=CreateFrame("StatusBar",nil,g)
    g.bar:SetPoint("TOPLEFT");g.bar:SetPoint("BOTTOMRIGHT")
    g.bar:SetStatusBarTexture(texture)
    g.label=g:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    g.label:SetPoint("TOPRIGHT",g,"BOTTOMRIGHT",0,-4);g.label:SetText("GCD");g:Hide()
    g.hint=g:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    g.hint:SetPoint("BOTTOM",g,"TOP",0,9)
    if HC.Localize then HC.Localize(g.hint,"Vorschau · Sofortzauber / Globaler Cooldown") else g.hint:SetText("Vorschau · Sofortzauber / Globaler Cooldown") end
    -- Tiny endpoint glint, never a rectangular frame around the energy form.
    local finish=CreateFrame("Frame","HanseCastFinishCue",UIParent)
    HC.finishFrame=finish;finish:SetFrameStrata("MEDIUM");finish:SetSize(10,10)
    finish.horizontal=finish:CreateTexture(nil,"OVERLAY")
    finish.horizontal:SetSize(12,8);finish.horizontal:SetPoint("CENTER")
    finish.horizontal.hcLoadFailed=finish.horizontal:SetTexture("Interface\\AddOns\\HanseCast\\Media\\Mote.tga","CLAMP","CLAMP","LINEAR")==false
    finish.horizontal:SetBlendMode("ADD")
    finish.vertical=finish:CreateTexture(nil,"OVERLAY")
    finish.vertical:SetSize(4,4);finish.vertical:SetPoint("CENTER")
    finish.vertical.hcLoadFailed=finish.vertical:SetTexture("Interface\\AddOns\\HanseCast\\Media\\Mote.tga","CLAMP","CLAMP","LINEAR")==false
    finish.vertical:SetBlendMode("ADD");finish:Hide()
    for _,light in ipairs({finish.horizontal,finish.vertical}) do
        if light.SetSnapToPixelGrid then light:SetSnapToPixelGrid(false) end
        if light.SetTexelSnappingBias then light:SetTexelSnappingBias(0) end
    end
    f:SetScript("OnDragStart",function(self)
        if HC.preview and not InCombatLockdown() then HC.dragging=true;self:StartMoving() end
    end)
    f:SetScript("OnDragStop",function(self)
        HC.dragging=false;self:StopMovingOrSizing()
        local x,y=self:GetCenter()
        local ratio=self:GetEffectiveScale()/UIParent:GetEffectiveScale()
        HC.db.x=x*ratio-UIParent:GetWidth()/2;HC.db.y=y*ratio-UIParent:GetHeight()/2
        HC.ApplyLayout()
    end)
    f:SetScript("OnMouseUp",function(_,button)
        if button=="RightButton" and HC.preview then HC.ToggleOptions() end
    end)
    f:Hide();HC.ApplyLayout()
end

function HC.ApplyLayout()
    local f,db=HC.frame,HC.db
    db.height=math.max(24,math.ceil(24/db.scale),db.height)
    f:SetSize(db.width,db.height);f:SetScale(db.scale);f:ClearAllPoints()
    f.resultOverlay:SetSize(db.width,db.height)
    local reserve=HC.UpdateFactionIcon()
    local spellReserve=(db.iconPosition=='left' or db.iconPosition=='right') and math.max(16,math.min(28,db.height))+6 or 0
    local rightReserve=db.iconPosition=='right' and spellReserve or 0
    if db.iconPosition=='left' then reserve=reserve+spellReserve end
    if f.SetClampRectInsets then f:SetClampRectInsets(-reserve,rightReserve,0,0) end
    local half=db.width*db.scale/2
    local xLimit=math.max(0,UIParent:GetWidth()/2-half-12-rightReserve*db.scale)
    local leftLimit=math.max(0,UIParent:GetWidth()/2-half-12-reserve*db.scale)
    local yLimit=math.max(0,UIParent:GetHeight()/2-db.height*db.scale/2-45)
    local x=math.max(-leftLimit,math.min(xLimit,db.x))
    local y=math.max(-yLimit,math.min(yLimit,db.y))
    f:SetPoint("CENTER",UIParent,"CENTER",x/db.scale,y/db.scale)
    HC.gcdFrame:SetScale(db.scale);HC.gcdFrame:SetSize(db.width,2);HC.gcdFrame:ClearAllPoints()
    HC.gcdFrame:SetPoint("TOPLEFT",f,"BOTTOMLEFT",0,-5)
    HC.finishFrame:SetScale(db.scale);HC.finishFrame:ClearAllPoints()
    HC.finishFrame:SetPoint("CENTER",f,"RIGHT",0,0)
    HC.LayoutEffects(db.width,db.height)
    if HC.ApplyComfortLayout then HC.ApplyComfortLayout() end
    if HC.RefreshLocale then HC.RefreshLocale() end
    HC.ApplyTheme();HC.effectsLastDraw=nil
    if HC.UpdateOptions then HC.UpdateOptions() end
end

function HC.Draw(cast,now)
    HC.UpdateSpellTheme(cast)
    local f=HC.frame
    Alpha(f,1)
    local value,duration,remaining=HC.Progress(cast,now)
    -- Select/retry the material before hiding an unavailable presentation.
    -- A failed resource must not cause a Show/Hide cycle on every game frame.
    HC.DrawEffects(duration>0 and value/duration or 0,now)
    local unavailable=HC.IsMaterialAvailable and not HC.IsMaterialAvailable() or false
    local previousUnavailable=HC.renderWasUnavailable
    HC.renderWasUnavailable=unavailable
    if previousUnavailable~=nil and previousUnavailable~=unavailable and HC.UpdateBlizzard then HC.UpdateBlizzard() end
    if unavailable then
        HC.HideEffects();f:Hide();HC.effectsLastDraw=nil;HC.visualCast=nil;return
    end
    if f.bar.hcDuration~=duration then f.bar:SetMinMaxValues(0,duration);f.bar.hcDuration=duration end
    f.bar:SetValue(value)
    Text(f.label,cast.name);LabelColor(f.label,1,1,1,1)
    if HC.FormatCastTime then
        local time,inset=HC.FormatCastTime(cast,now,remaining,duration);Text(f.time,time);TimeInset(f,inset)
    elseif cast.timingDelta and cast.timingUntil and now<cast.timingUntil then
        local color=cast.timingDelta>0 and "ffffbc70" or "ff8ce8ff"
        Text(f.time,string.format("%.1f s |c%s%+.1f|r",remaining,color,cast.timingDelta))
        TimeInset(f,112)
    else
        Text(f.time,string.format("%.1f s",remaining))
        TimeInset(f,62)
    end
    if HC.DrawComfort then HC.DrawComfort(cast,now,duration) end
    f.hint:SetShown(HC.preview==true);f:EnableMouse(HC.preview==true)
    f:Show()
    HC.effectsLastDraw=now;HC.visualCast=cast
end

function HC.DrawFailure(text)
    HC.HideEffects();if HC.HideComfortView then HC.HideComfortView() end;Text(HC.frame.label,L(text));LabelColor(HC.frame.label,1,0.4,0.3,1)
    TimeInset(HC.frame,0)
    Text(HC.frame.time,"");Alpha(HC.frame,1);HC.frame:Show();HC.effectsLastDraw=nil
end

local resultStyles={
    interrupted={text="Unterbrochen",color={1,.35,.25,1},duration=.42},
    failed={text="Fehlgeschlagen",color={1,.65,.28,1},duration=.38},
    cancelled={text="Abgebrochen",color={.70,.78,.86,1},duration=.24},
}
function HC.ClearCastResult()
    HC.resultUntil=nil;HC.resultStarted=nil;HC.resultKind=nil
    if HC.frame then Alpha(HC.frame,1);HC.frame.resultLight:Hide() end
end
function HC.ShowCastResult(kind,cast,now)
    HC.UpdateSpellTheme(cast)
    local style=resultStyles[kind] or resultStyles.failed
    HC.HideFinishCue()
    if HC.HideComfortView then HC.HideComfortView() end
    local stoppedAt=cast.stoppedAt or now
    local value,duration=HC.Progress(cast,stoppedAt)
    HC.DrawEffects(duration>0 and value/duration or 0,stoppedAt)
    if HC.IsMaterialAvailable and not HC.IsMaterialAvailable() then
        HC.ClearCastResult();HC.HideEffects();HC.frame:Hide();return
    end
    local progress=duration>0 and value/duration or 0
    local size=math.max(6,math.min(11,HC.db.height*.45))
    HC.frame.resultLight:SetSize(size,size)
    HC.frame.resultLight:SetPoint("BOTTOMLEFT",HC.frame.resultOverlay,"BOTTOMLEFT",HC.db.width*progress-size/2,(HC.db.height-size)/2)
    HC.frame.resultLight:SetVertexColor(unpack(style.color))
    HC.frame.resultLight:SetAlpha(kind=="cancelled" and .3 or .75)
    if not HC.frame.resultLight.hcLoadFailed then HC.frame.resultLight:Show() end
    Text(HC.frame.label,L(style.text));LabelColor(HC.frame.label,unpack(style.color))
    TimeInset(HC.frame,0)
    Text(HC.frame.time,"");HC.frame.hint:Hide();HC.frame:EnableMouse(false)
    Alpha(HC.frame,1);HC.frame:Show()
    HC.resultStarted=now;HC.resultUntil=now+style.duration;HC.resultKind=kind
    HC.effectsLastDraw=nil;HC.visualCast=nil
end
function HC.UpdateCastResult(now)
    if not HC.resultStarted or not HC.resultUntil then return end
    local age=(now-HC.resultStarted)/(HC.resultUntil-HC.resultStarted)
    -- A short readable hold, then fade the frozen material and text together.
    Alpha(HC.frame,math.max(0,1-math.max(0,age-.25)/.75))
end

function HC.DrawGCD(gcd,now)
    local g=HC.gcdFrame
    if not g then return end
    if not HC.db.gcd or not gcd or gcd.finish<=now or gcd.finish<=gcd.start then g:Hide();return end
    g.bar:SetMinMaxValues(0,gcd.finish-gcd.start);g.bar:SetValue(math.max(0,gcd.finish-now))
    g.label:SetShown(not HC.frame:IsShown())
    g:SetAlpha(HC.db.opacity or 1)
    g.hint:SetShown(HC.preview==true and not HC.frame:IsShown());g:Show()
end
function HC.HideFinishCue()
    if HC.finishFrame then HC.finishFrame:Hide();HC.finishFrame:SetScript("OnUpdate",nil) end
end
function HC.ShowFinishCue()
    if not HC.db.finishCue then return end
    if HC.IsMaterialAvailable and not HC.IsMaterialAvailable() then return end
    local f=HC.finishFrame;local theme=HC.GetTheme()
    if f.horizontal.hcLoadFailed or f.vertical.hcLoadFailed then return end
    f.horizontal:SetVertexColor(unpack(theme.cast))
    f.vertical:SetVertexColor(unpack(theme.bright or theme.cast))
    f.elapsed=0;f:SetAlpha(0.75*(HC.db.opacity or 1));f:Show()
    f:SetScript("OnUpdate",function(self,elapsed)
        self.elapsed=self.elapsed+elapsed
        if self.elapsed>=0.22 then HC.HideFinishCue()
        else self:SetAlpha(0.75*(1-self.elapsed/0.22)*(HC.db.opacity or 1)) end
    end)
end
