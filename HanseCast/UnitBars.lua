local _, HC = ...
local function L(text) return HC.L and HC.L(text) or text end
-- Addon-owned target/focus frames only. Blizzard's frames are never modified.
local units={"target","focus"}
local labels={target="Ziel",focus="Fokus"}
local defaults={enabled=false,x=0,y=-95,width=300,height=28,scale=1,
    visibility="always",family="inherit",element="inherit",showIcon=false}
local bounds={x={-10000,10000},y={-10000,10000},width={180,600},height={24,60},scale={.6,2}}
local terminal={UNIT_SPELLCAST_STOP=true,UNIT_SPELLCAST_CHANNEL_STOP=true,
    UNIT_SPELLCAST_FAILED=true,UNIT_SPELLCAST_FAILED_QUIET=true,UNIT_SPELLCAST_INTERRUPTED=true}
local eventNames={"UNIT_SPELLCAST_START","UNIT_SPELLCAST_DELAYED","UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_UPDATE","UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_FAILED_QUIET","UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_SUCCEEDED","UNIT_SPELLCAST_INTERRUPTIBLE","UNIT_SPELLCAST_NOT_INTERRUPTIBLE","UNIT_AURA"}
local driver, events
local pending={}
local function sanitize(unit,saved)
    local out={}
    for k,v in pairs(defaults) do out[k]=v end
    if unit=="focus" then out.y=-35 end
    if type(saved)~="table" then return out end
    for k,range in pairs(bounds) do if HC.ValidNumber(saved[k],range[1],range[2]) then out[k]=saved[k] end end
    for _,k in ipairs({"enabled","showIcon"}) do if type(saved[k])=="boolean" then out[k]=saved[k] end end
    if saved.visibility=="combat" then out.visibility="combat" end
    if saved.family=="inherit" or (type(saved.family)=="string" and HC.families[saved.family]) then out.family=saved.family end
    if saved.element=="inherit" or (type(saved.element)=="string" and HC.elementKeys[saved.element]) then out.element=saved.element end
    return out
end
function HC.LoadUnitBarSettings(saved)
    saved=type(saved)=="table" and saved or {}
    return {target=sanitize("target",saved.target),focus=sanitize("focus",saved.focus)}
end
local function hide(s,reason)
    s.cast=nil;s.reason=reason or s.reason
    HC.HideEffects(s.effects);s.frame:Hide()
end
local function theme(s)
    local cfg=s.config
    local family=cfg.family=="inherit" and HC.db.family or cfg.family
    local element=cfg.element=="inherit" and HC.db.element or cfg.element
    family=HC.families[family] and family or "element"
    local palette=HC.elements[element] or HC.elements.frost
    if not HC.elements[element] then element="frost" end
    local key=family..":"..element
    if s.themeKey~=key then
        s.themeKey=key
        s.theme={family=family,element=element,cast=palette.color,bright=palette.bright,
            secondaryBright=palette.secondaryBright,classMaterial=palette.classMaterial}
    end
    return s.theme
end
local function paint(s,now)
    local c=s.cast;if not c then return end
    local value,duration,remaining=HC.Progress(c,now)
    HC.DrawEffects(value/duration,now,s.effects,theme(s))
    if not HC.IsMaterialAvailable(s.effects) then hide(s,"material-unavailable");return end
    s.name:SetText(L(labels[s.unit]).." · "..c.name)
    s.time:SetText(string.format("%.1f s",remaining))
    if c.interruptible==true then
        s.interrupt:SetText(L("Unterbrechbar"));s.interrupt:SetTextColor(.65,.95,.75,1)
    elseif c.interruptible==false then
        s.interrupt:SetText(L("Nicht unterbrechbar"));s.interrupt:SetTextColor(1,.75,.40,1)
    else
        s.interrupt:SetText(L("Unterbrechbarkeit unbekannt"));s.interrupt:SetTextColor(.75,.75,.80,1)
    end
    if s.config.showIcon then
        if s.iconValue~=c.icon then s.icon:SetTexture(c.icon);s.iconValue=c.icon end
        s.icon:Show()
    else s.icon:Hide() end
    s.frame:Show()
end
local function unitAvailable(unit)
    if type(UnitExists)~="function" then return false,"unsupported" end
    local ok,exists=pcall(UnitExists,unit)
    if not ok then return false,"unsupported" end
    if not HC.Accessible(exists) then return false,"restricted" end
    if exists~=true then return false,"absent" end
    return true
end
local function identity(unit)
    if type(UnitGUID)~="function" then return nil end
    local ok,guid=pcall(UnitGUID,unit)
    if ok and HC.Accessible(guid) and type(guid)=="string" then return guid end
end
local function reset(s)
    s.generation=s.generation+1;s.ended=nil;s.guid=nil
    hide(s,"changed")
end
local function refresh(s)
    if HC.unitBarsPreview then return end
    if not s.config.enabled then hide(s,"disabled");return end
    if s.config.visibility=="combat" and not InCombatLockdown() then hide(s,"visibility");return end
    local available,reason=unitAvailable(s.unit)
    if not available then reset(s);s.reason=reason;return end
    local guid=identity(s.unit)
    if guid and s.guid and guid~=s.guid then reset(s) end
    s.guid=guid
    local cast,why=HC.ReadCurrent(s.unit)
    local now=GetTime()
    if s.ended then
        for i=#s.ended,1,-1 do
            local ended=s.ended[i]
            if now>ended.untilTime then table.remove(s.ended,i)
            elseif cast and cast.id~=nil and cast.id==ended.id then cast=nil;why="ended" end
        end
        if #s.ended==0 then s.ended=nil end
    end
    s.cast=cast;s.reason=why;s.lastRead=now
    if cast then paint(s,now) else hide(s,why) end
end
local function tick()
    local now=GetTime();local active=false
    for _,unit in ipairs(units) do
        local s=HC.unitBars[unit]
        if HC.unitBarsPreview then
            local elapsed=(now-HC.unitBarsPreviewStart)%6
            local channel=elapsed>=3
            local start=now-elapsed%3
            s.cast={name=channel and L("Vorschau · Kanalzauber") or L("Vorschau · Zauber"),start=start,finish=start+3,
                channel=channel,icon=135846,interruptible=unit=="target"}
            paint(s,now);active=true
        elseif s.cast then
            -- Re-query live data for duration changes and restrictions. No idle polling.
            if now-(s.lastRead or 0)>=.10 or now>=s.cast.finish then refresh(s) end
            if s.cast then paint(s,now);active=true end
        end
    end
    if not active then driver:SetScript("OnUpdate",nil);driver:Hide() end
end
local function wake()
    local active=HC.unitBarsPreview
    for _,unit in ipairs(units) do if HC.unitBars[unit].cast then active=true end end
    if active then driver:SetScript("OnUpdate",tick);driver:Show()
    else driver:SetScript("OnUpdate",nil);driver:Hide() end
end
local function layout(s)
    local cfg=s.config
    s.frame:ClearAllPoints();s.frame:SetPoint("CENTER",UIParent,"CENTER",cfg.x/cfg.scale,cfg.y/cfg.scale)
    s.frame:SetScale(cfg.scale);s.frame:SetSize(cfg.width,cfg.height)
    s.name:SetWidth(math.max(80,cfg.width-65));s.icon:SetSize(cfg.height,cfg.height)
    HC.LayoutEffects(cfg.width,cfg.height,s.effects)
end
local function create(unit)
    local frame=CreateFrame("Frame",nil,UIParent)
    frame:SetFrameStrata("MEDIUM");frame:SetClampedToScreen(true);frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton");frame:EnableMouse(false)
    local s={unit=unit,frame=frame,generation=0,reason="disabled"}
    s.effects=HC.CreateEffects(frame,true)
    s.name=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    s.name:SetPoint("BOTTOMLEFT",frame,"TOPLEFT",0,2);s.name:SetJustifyH("LEFT");s.name:SetWordWrap(false)
    s.time=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    s.time:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",0,2)
    s.interrupt=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    s.interrupt:SetPoint("TOPLEFT",frame,"BOTTOMLEFT",0,-2)
    s.icon=frame:CreateTexture(nil,"ARTWORK");s.icon:SetPoint("RIGHT",frame,"LEFT",-6,0)
    s.icon:SetTexCoord(.08,.92,.08,.92)
    frame:SetScript("OnDragStart",function()
        if HC.unitBarsPreview and not InCombatLockdown() then s.dragging=true;frame:StartMoving() end
    end)
    frame:SetScript("OnDragStop",function()
        if not s.dragging then return end
        s.dragging=false;frame:StopMovingOrSizing()
        local x,y=frame:GetCenter();local px,py=UIParent:GetCenter()
        local scale=frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
        HC.ConfigureUnitBar(unit,{x=x*scale-px,y=y*scale-py})
    end)
    return s
end
function HC.ConfigureUnitBar(unit,patch)
    if unit~="target" and unit~="focus" then return false,"unsupported" end
    if type(patch)~="table" or not HC.db then return false,"invalid" end
    local base=pending[unit] or HC.db.unitBars[unit];local merged={}
    for k,v in pairs(base) do merged[k]=v end
    for k,v in pairs(patch) do if defaults[k]~=nil then merged[k]=v end end
    local cfg=sanitize(unit,merged)
    if InCombatLockdown() then pending[unit]=cfg;return true,"deferred" end
    HC.db.unitBars[unit]=cfg
    if HC.unitBars then
        local s=HC.unitBars[unit];s.config=cfg;layout(s);refresh(s);wake()
    end
    return true,"applied"
end
function HC.RefreshUnitBars()
    if not HC.unitBars then return end
    for _,unit in ipairs(units) do
        local s=HC.unitBars[unit]
        if not InCombatLockdown() then s.config=sanitize(unit,HC.db.unitBars[unit]);HC.db.unitBars[unit]=s.config;layout(s) end
        refresh(s)
    end
    wake()
end
function HC.PreviewUnitBars(enabled)
    if not HC.unitBars or InCombatLockdown() then return false end
    HC.unitBarsPreview=enabled==true;HC.unitBarsPreviewStart=GetTime()
    for _,unit in ipairs(units) do
        local s=HC.unitBars[unit];s.frame:EnableMouse(HC.unitBarsPreview)
        reset(s)
        if not HC.unitBarsPreview then refresh(s) end
    end
    if HC.unitBarsPreview then tick() end
    wake();return true
end
local function reconcile(s)
    if s.queued then return end
    s.queued=true;local generation=s.generation
    C_Timer.After(0,function()
        s.queued=false
        if generation==s.generation and not HC.unitBarsPreview then refresh(s);wake() end
    end)
end
function HC.InitializeUnitBars()
    if HC.unitBars or not HC.db then return end
    HC.db.unitBars=HC.LoadUnitBarSettings(HC.db.unitBars)
    HC.unitBars={};driver=CreateFrame("Frame");driver:Hide();HC.unitBarsDriver=driver
    for _,unit in ipairs(units) do
        local s=create(unit);HC.unitBars[unit]=s;s.config=HC.db.unitBars[unit];layout(s);hide(s)
    end
    events=CreateFrame("Frame");HC.unitBarsEvents=events
    for _,event in ipairs(eventNames) do HC.Register(events,event) end
    for _,event in ipairs({"PLAYER_TARGET_CHANGED","PLAYER_FOCUS_CHANGED","PLAYER_ENTERING_WORLD",
        "PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED","UI_SCALE_CHANGED","DISPLAY_SIZE_CHANGED"}) do HC.Register(events,event) end
    events:SetScript("OnEvent",function(_,event,unit,...)
        if event=="PLAYER_REGEN_ENABLED" then
            for key,cfg in pairs(pending) do HC.db.unitBars[key]=cfg end
            pending={};HC.RefreshUnitBars();return
        elseif event=="PLAYER_REGEN_DISABLED" then
            if HC.unitBarsPreview then
                HC.unitBarsPreview=false
                for _,u in ipairs(units) do local s=HC.unitBars[u];s.dragging=false;s.frame:StopMovingOrSizing();s.frame:EnableMouse(false);reset(s) end
            end
            HC.RefreshUnitBars();return
        elseif event=="PLAYER_TARGET_CHANGED" or event=="PLAYER_FOCUS_CHANGED" then
            local s=HC.unitBars[event=="PLAYER_TARGET_CHANGED" and "target" or "focus"]
            reset(s);refresh(s);wake();return
        elseif event=="PLAYER_ENTERING_WORLD" or event=="UI_SCALE_CHANGED" or event=="DISPLAY_SIZE_CHANGED" then
            HC.RefreshUnitBars();return
        end
        if HC.unitBarsPreview or not HC.Accessible(unit) then return end
        if unit~="target" and unit~="focus" then return end
        local s=HC.unitBars[unit]
        if terminal[event] then
            local id
            if event=="UNIT_SPELLCAST_INTERRUPTED" or event=="UNIT_SPELLCAST_CHANNEL_STOP" then id=select(4,...)
            else id=select(3,...) end
            if HC.Accessible(id) and id~=nil and s.cast and s.cast.id~=nil and id==s.cast.id then
                s.ended=s.ended or {}
                s.ended[#s.ended+1]={id=id,untilTime=math.max(GetTime()+2,s.cast.finish+1)}
                if #s.ended>16 then table.remove(s.ended,1) end
                hide(s,"ended")
            end
            reconcile(s)
        else refresh(s) end
        wake()
    end)
    HC.RefreshUnitBars()
end
