local _, HC = ...

-- Dedicated GCD probes: modern client spell plus the Classic-content equivalent.
-- Forever combines modern APIs with Classic spell data; do not pick by TOC number.
HC.gcdSpellID = 61304
HC.gcdProbeIDs = {61304, 29515}
HC.gcdEvents = { "SPELL_UPDATE_COOLDOWN" }
HC.gcdProbeStatus = {}
HC.gcdProbePaths = {}
HC.gcdStats = {reads=0,restricted=0,apiErrors=0,nativeSubmissions=0,nativeDenied=0}

local function CanSubmit()
    local bar=HC.gcdFrame and HC.gcdFrame.nativeBar
    if not bar or type(bar.SetTimerDuration)~='function' or type(Enum)~='table'
        or type(Enum.StatusBarInterpolation)~='table' or type(Enum.StatusBarTimerDirection)~='table' then return false end
    local immediate,remaining=Enum.StatusBarInterpolation.Immediate,Enum.StatusBarTimerDirection.RemainingTime
    return HC.Accessible(immediate) and type(immediate)=='number'
        and HC.Accessible(remaining) and type(remaining)=='number'
end

local function ValidTime(value)
    return HC.Accessible(value) and HC.ValidNumber(value, 0, 1e15)
end

local function NativeTimes(spellID)
    if type(C_Spell.GetSpellCooldownDuration) ~= "function" then return nil, "missing" end
    local ok, object = pcall(C_Spell.GetSpellCooldownDuration, spellID)
    if not ok then return nil, "error" end
    if not HC.Accessible(object) then
        if CanSubmit() then return {native=true,object=object},'restricted' end
        return nil, "restricted"
    end
    if object == nil then return nil, "missing" end
    -- Methods and returned times are guarded separately. Never inspect opaque values.
    local success, start, finish = pcall(function()
        return object:GetStartTime(), object:GetEndTime()
    end)
    if not success then
        if CanSubmit() then return {native=true,object=object},'error' end
        return nil, "error"
    end
    if not HC.Accessible(start) or not HC.Accessible(finish) then
        if CanSubmit() then return {native=true,object=object},'restricted' end
        return nil, "restricted"
    end
    if not ValidTime(start) or not ValidTime(finish) or finish <= start then return nil, "error" end
    return { start = start, finish = finish }, "active"
end

local function RawTimes(spellID)
    local rawAPI = type(C_Spell.GetSpellCooldown) == "function"
    local ok, info = true, nil
    if rawAPI then ok, info = pcall(C_Spell.GetSpellCooldown, spellID) end
    if not ok then return nil, "error" end
    if not HC.Accessible(info) then return nil, "restricted" end
    if info == nil then return nil,'missing' end
    if type(info) ~= "table" then return nil, "error" end
    if type(issecrettable) == "function" and issecrettable(info) then return nil, "restricted" end

    local readable, start, duration, rate, enabled, active = pcall(function()
        return info.startTime, info.duration, info.modRate, info.isEnabled, info.isActive
    end)
    if not readable then return nil, "restricted" end
    if not HC.Accessible(enabled) or not HC.Accessible(active) then return nil, "restricted" end
    if enabled == false or active == false then return nil, "idle",true end

    if not HC.Accessible(start) or not HC.Accessible(duration) or not HC.Accessible(rate) then
        return nil, "restricted"
    end
    if not ValidTime(start) or not HC.ValidNumber(duration, 0, 60) then return nil, "error" end
    if duration == 0 or start == 0 then return nil, "idle" end
    if rate == nil then rate = 1 end
    if not HC.ValidNumber(rate, 0.001, 1000) then return nil, "error" end
    if rate ~= 1 then
        return nil, "error"
    end
    local finish = start + duration
    if finish <= GetTime() then return nil, "idle" end
    return { start = start, finish = finish }, "active"
end

local severity={missing=0,idle=1,error=2,restricted=3}
local function ReadProbe(id)
    local raw,rawReason,definiteIdle=RawTimes(id)
    local path={raw=rawReason,duration='not-queried',widget='not-used'}
    HC.gcdProbePaths[id]=path
    -- A readable disabled/inactive flag is authoritative. Otherwise the duration
    -- API is independent, even when raw records or flags are restricted.
    if definiteIdle then return nil,'idle',path end
    local duration,durationReason=NativeTimes(id)
    path.duration=durationReason
    if duration and not duration.native then
        if duration.finish<=GetTime() then return nil,'idle',path end
        return duration,'active',path
    end
    if raw then return raw,'active',path end
    if duration then return duration,'native',path end
    return nil,severity[rawReason]>severity[durationReason] and rawReason or durationReason,path
end

function HC.ReadGCD()
    HC.gcdSource=nil
    HC.gcdProbeStatus={}
    HC.gcdProbePaths={}
    HC.gcdStats.reads=HC.gcdStats.reads+1
    HC.gcdCheckedAt=GetTime()
    if type(C_Spell) ~= "table" or
        (type(C_Spell.GetSpellCooldown) ~= "function" and type(C_Spell.GetSpellCooldownDuration) ~= "function") then
        HC.gcdDetail="cooldown_api_missing"
        return nil,"missing"
    end
    local reason="missing"
    local pending
    local restricted,errors=false,false
    local function Finish(result,status)
        if restricted then HC.gcdStats.restricted=HC.gcdStats.restricted+1 end
        if errors then HC.gcdStats.apiErrors=HC.gcdStats.apiErrors+1 end
        return result,status
    end
    for _,id in ipairs(HC.gcdProbeIDs) do
        local result, probeReason,path=ReadProbe(id)
        restricted=restricted or path.raw=='restricted' or path.duration=='restricted'
        errors=errors or path.raw=='error' or path.duration=='error'
        HC.gcdProbeStatus[id]=probeReason=='native' and path.duration or probeReason
        if result and not result.native then
            HC.gcdSource=id
            HC.gcdDetail="probe_"..id
            return Finish(result,"active")
        elseif result and not pending then
            pending={id=id,object=result.object,path=path}
        end
        if severity[probeReason] and severity[probeReason]>severity[reason] then reason=probeReason end
    end
    if pending then
        -- The object lives only in this query; retained state contains no object,
        -- secret time, inferred expiry or identity derived from its contents.
        local ok,value=pcall(HC.gcdFrame.nativeBar.SetTimerDuration,HC.gcdFrame.nativeBar,pending.object,
            Enum.StatusBarInterpolation.Immediate,Enum.StatusBarTimerDirection.RemainingTime)
        if ok and not (HC.Accessible(value) and value==false) then
            pending.path.widget='accepted';HC.gcdSource=pending.id;HC.gcdDetail='native_timer'
            HC.gcdProbeStatus[pending.id]='native'
            HC.gcdStats.nativeSubmissions=HC.gcdStats.nativeSubmissions+1
            return Finish({native=true},'native')
        end
        pending.path.widget='denied';HC.gcdStats.nativeDenied=HC.gcdStats.nativeDenied+1
        HC.gcdProbeStatus[pending.id]='restricted'
        HC.gcdDetail='timer_denied'
        return Finish(nil,'restricted')
    end
    HC.gcdDetail=reason=="missing" and "no_gcd_record" or reason
    return Finish(nil,reason)
end

function HC.GetGCDDiagnostic()
    local function L(text) return HC.L and HC.L(text) or text end
    local spell=type(C_Spell)=="table"
    local raw=spell and type(C_Spell.GetSpellCooldown)=="function"
    local native=spell and type(C_Spell.GetSpellCooldownDuration)=="function"
    return "API "..L(raw and "ja" or "nein")..L(" / Dauer ")..L(native and "ja" or "nein")..
        " | 61304: "..(HC.gcdProbeStatus[61304] or L("nicht geprüft"))..
        " | 29515: "..(HC.gcdProbeStatus[29515] or L("nicht geprüft"))..
        " | "..(HC.gcdDetail or L("noch nicht geprüft"))..
        ' | GCD reads='..HC.gcdStats.reads..' restricted='..HC.gcdStats.restricted..
        ' errors='..HC.gcdStats.apiErrors..' native='..HC.gcdStats.nativeSubmissions..' denied='..HC.gcdStats.nativeDenied
end

function HC.GetGCDPathDiagnostic()
    local parts={}
    for _,id in ipairs(HC.gcdProbeIDs) do
        local p=HC.gcdProbePaths[id]
        parts[#parts+1]=id..': '..(p and ('raw='..p.raw..', duration='..p.duration..', widget='..p.widget) or 'not-queried')
    end
    return table.concat(parts,' | ')
end
