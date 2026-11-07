local _, HC = ...
HC.stats = { restricted = 0, apiErrors = 0, unknownEvents = 0 }

-- Never inspect, stringify or compare a value before the secrecy check.
function HC.Accessible(value)
    if type(issecretvalue) ~= "function" then return false end
    if issecretvalue(value) then return false end
    if type(canaccessvalue) == "function" and not canaccessvalue(value) then return false end
    return true
end

local function Read(channel, unit)
    local api = channel and UnitChannelInfo or UnitCastingInfo
    if type(api) ~= "function" then return nil, "missing" end
    local ok, name, _, icon, startMs, endMs, _, a7, a8, a9, a10, a11 = pcall(api, unit)
    if not ok then return nil, "error" end
    if not HC.Accessible(name) then return nil, "restricted" end
    if name == nil then return nil, "idle" end
    if type(name) ~= "string" then return nil, "invalid" end
    if not HC.Accessible(startMs) or not HC.Accessible(endMs) then return nil, "restricted" end
    if not HC.ValidNumber(startMs, 0, 1e15) or not HC.ValidNumber(endMs, 0, 1e15)
        or endMs <= startMs then return nil, "invalid" end
    -- Some interaction casts briefly retain their finished API record after STOP.
    -- Never resurrect that old bar during the next-frame reconciliation.
    if endMs / 1000 <= GetTime() then return nil, "idle" end
    if not HC.Accessible(icon) then icon = 134400 end
    if type(icon) ~= "number" and type(icon) ~= "string" then icon = 134400 end
    local id
    if channel then id = a11 else id = a10 end
    if not HC.Accessible(id) then id = nil end
    if id ~= nil and type(id) ~= "number" and type(id) ~= "string" then id = nil end
    local blocked
    -- Read the slot explicitly: never branch on the unguarded flag.
    if channel then blocked = a7 else blocked = a8 end
    local interruptible
    if HC.Accessible(blocked) and type(blocked) == "boolean" then interruptible = not blocked end
    -- Visual classification is optional: a secret spell ID must not hide an
    -- otherwise readable cast. Do not compare or index it before this guard.
    local spellID
    if channel then spellID = a8 else spellID = a9 end
    if not HC.Accessible(spellID) then spellID = nil
    elseif not HC.ValidNumber(spellID, 1, 2147483647) or spellID % 1 ~= 0 then spellID = nil end
    -- Empower casts are outside this mage prototype's scope.
    if channel then
        if not HC.Accessible(a9) then return nil, "restricted" end
        if a9 then return nil, "unsupported" end
    end
    return { name = name, icon = icon or 134400, start = startMs / 1000,
        finish = endMs / 1000, channel = channel, id = id, spellID = spellID,
        interruptible = interruptible, unit = unit }, "active"
end

function HC.ReadCurrent(unit)
    if not HC.Accessible(unit) then return nil, "restricted" end
    unit = unit or "player"
    if unit ~= "player" and unit ~= "target" and unit ~= "focus" then return nil, "unsupported" end
    local cast, reason = Read(false, unit)
    if cast or reason ~= "idle" then return cast, reason end
    return Read(true, unit)
end

function HC.Register(frame, event, unit)
    local ok
    if unit then ok = pcall(frame.RegisterUnitEvent, frame, event, unit)
    else ok = pcall(frame.RegisterEvent, frame, event) end
    if not ok then HC.stats.unknownEvents = HC.stats.unknownEvents + 1 end
end
