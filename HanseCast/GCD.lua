local _, HC = ...

-- Dedicated GCD probes: modern client spell plus the Classic-content equivalent.
-- Forever combines modern APIs with Classic spell data; do not pick by TOC number.
HC.gcdSpellID = 61304
HC.gcdProbeIDs = {61304, 29515}
HC.gcdEvents = { "SPELL_UPDATE_COOLDOWN" }
HC.gcdProbeStatus = {}

local function ValidTime(value)
    return HC.Accessible(value) and HC.ValidNumber(value, 0, 1e15)
end

local function NativeTimes(spellID)
    if type(C_Spell.GetSpellCooldownDuration) ~= "function" then return nil, "missing" end
    local ok, object = pcall(C_Spell.GetSpellCooldownDuration, spellID)
    if not ok then return nil, "error" end
    if not HC.Accessible(object) then return nil, "restricted" end
    if object == nil then return nil, "missing" end
    -- Methods and returned times are guarded separately. Never inspect opaque values.
    local success, start, finish = pcall(function()
        return object:GetStartTime(), object:GetEndTime()
    end)
    if not success then return nil, "error" end
    if not HC.Accessible(start) or not HC.Accessible(finish) then return nil, "restricted" end
    if not ValidTime(start) or not ValidTime(finish) or finish <= start then return nil, "error" end
    return { start = start, finish = finish }, "active"
end

local function ReadProbe(spellID)
    local rawAPI = type(C_Spell.GetSpellCooldown) == "function"
    local ok, info = true, nil
    if rawAPI then ok, info = pcall(C_Spell.GetSpellCooldown, spellID) end
    if not ok then return nil, "error" end
    if not HC.Accessible(info) then return nil, "restricted" end
    -- A missing raw spell record must not prevent trying the native duration API.
    if info == nil then
        local native, reason = NativeTimes(spellID)
        if native and native.finish <= GetTime() then return nil, "idle" end
        return native, reason
    end
    if type(info) ~= "table" then return nil, "error" end
    if type(issecrettable) == "function" and issecrettable(info) then return nil, "restricted" end

    local readable, start, duration, rate, enabled, active = pcall(function()
        return info.startTime, info.duration, info.modRate, info.isEnabled, info.isActive
    end)
    if not readable then return nil, "restricted" end
    if not HC.Accessible(enabled) or not HC.Accessible(active) then return nil, "restricted" end
    if enabled == false or active == false then return nil, "idle" end

    -- Native RealTime getters account for modified cooldown speed without guessing
    -- a multiplication/division convention. Default modifier is RealTime in 70862.
    local native, nativeReason = NativeTimes(spellID)
    if native then
        if native.finish <= GetTime() then return nil, "idle" end
        return native, "active"
    end

    if not HC.Accessible(start) or not HC.Accessible(duration) or not HC.Accessible(rate) then
        return nil, "restricted"
    end
    if not ValidTime(start) or not HC.ValidNumber(duration, 0, 60) then return nil, "error" end
    if duration == 0 or start == 0 then return nil, "idle" end
    if rate == nil then rate = 1 end
    if not HC.ValidNumber(rate, 0.001, 1000) then return nil, "error" end
    if rate ~= 1 then
        return nil, nativeReason == "restricted" and "restricted" or "error"
    end
    local finish = start + duration
    if finish <= GetTime() then return nil, "idle" end
    return { start = start, finish = finish }, "active"
end

function HC.ReadGCD()
    HC.gcdSource=nil
    HC.gcdProbeStatus={}
    if type(C_Spell) ~= "table" or
        (type(C_Spell.GetSpellCooldown) ~= "function" and type(C_Spell.GetSpellCooldownDuration) ~= "function") then
        HC.gcdDetail="cooldown_api_missing"
        return nil,"missing"
    end
    local severity={missing=0,idle=1,error=2,restricted=3}
    local reason="missing"
    for _,id in ipairs(HC.gcdProbeIDs) do
        local result, probeReason=ReadProbe(id)
        HC.gcdProbeStatus[id]=probeReason
        if result then
            HC.gcdSource=id
            HC.gcdDetail="probe_"..id
            return result,"active"
        end
        if severity[probeReason]>severity[reason] then reason=probeReason end
    end
    HC.gcdDetail=reason=="missing" and "no_gcd_record" or reason
    return nil,reason
end

function HC.GetGCDDiagnostic()
    local function L(text) return HC.L and HC.L(text) or text end
    local spell=type(C_Spell)=="table"
    local raw=spell and type(C_Spell.GetSpellCooldown)=="function"
    local native=spell and type(C_Spell.GetSpellCooldownDuration)=="function"
    return "API "..L(raw and "ja" or "nein")..L(" / Dauer ")..L(native and "ja" or "nein")..
        " | 61304: "..(HC.gcdProbeStatus[61304] or L("nicht geprüft"))..
        " | 29515: "..(HC.gcdProbeStatus[29515] or L("nicht geprüft"))..
        " | "..(HC.gcdDetail or L("noch nicht geprüft"))
end
