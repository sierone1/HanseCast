local _, HC = ...
HC.version = "1.0.7"
-- Release gate, deliberately not a saved setting or profile option.
HC.unitBarsInDevelopment = true
HC.defaults = { schema = 3, x = 0, y = -180, width = 300, height = 32, scale = 1,
    theme = "modern", family = "element", element = "frost", identity = "class", faction = "none",
    gcd = true, hideBlizzard = false, hideBlizzardFocus = true, hideBlizzardTarget = true, finishCue = true, autoSpellVisual = false }

HC.elementKeys={frost=true,fire=true,arcane=true,faction_alliance=true,faction_horde=true,
    warlock_affliction=true,warlock_demonology=true,warlock_destruction=true,
    priest_holy=true,priest_discipline=true,priest_shadow=true,
    druid_balance=true,druid_restoration=true,druid_feralguardian=true,
    warrior_arms=true,warrior_fury=true,warrior_protection=true,
    paladin_holy=true,paladin_protection=true,paladin_retribution=true,
    hunter_beast=true,hunter_marksman=true,hunter_survival=true,
    rogue_assassination=true,rogue_combat=true,rogue_subtlety=true,
    shaman_elemental=true,shaman_enhancement=true,shaman_restoration=true}

function HC.ValidNumber(value, low, high)
    return type(value) == "number" and value == value and value >= low and value <= high
end

function HC.LoadSettings(saved)
    local db = {}
    for key, value in pairs(HC.defaults) do db[key] = value end
    if type(saved) ~= "table" then saved={} end
    local bounds = { x = {-10000,10000}, y = {-10000,10000}, width = {180,600},
        height = {10,60}, scale = {0.6,2} }
    for key, range in pairs(bounds) do
        if HC.ValidNumber(saved[key], range[1], range[2]) then db[key] = saved[key] end
    end
    db.height = math.max(24,db.height)
    for _, key in ipairs({"gcd", "hideBlizzard", "hideBlizzardFocus", "hideBlizzardTarget", "finishCue", "autoSpellVisual"}) do
        if type(saved[key]) == "boolean" then db[key] = saved[key] end
    end
    if saved.theme == "modern" or saved.theme == "rune" or saved.theme == "minimal" then db.theme = saved.theme end
    if saved.identity == "neutral" or saved.identity == "race" then db.identity = "neutral"
    elseif saved.identity == "class" or saved.identity == "combined" then db.identity = "class" end
    if saved.faction == "none" or saved.faction == "alliance" or saved.faction == "horde" then db.faction = saved.faction end
    local families = {element=true,splinter=true,silk=true,pulse=true,mist=true}
    if type(saved.family)=="string" and families[saved.family] then db.family=saved.family end
    if type(saved.element)=="string" and HC.elementKeys[saved.element] then db.element=saved.element end
    db.launches = HC.ValidNumber(saved.launches, 0, 1000000) and saved.launches or 0
    if HC.LoadUnitBarSettings then db.unitBars=HC.LoadUnitBarSettings(saved.unitBars) end
    if HC.LoadExtendedSettings then HC.LoadExtendedSettings(db,saved) end
    if HC.LoadCompactSettings then HC.LoadCompactSettings(db,saved) end
    return db
end

function HC.Progress(cast, now)
    local duration = cast.finish - cast.start
    local remaining = math.max(0, cast.finish - now)
    local value = cast.channel and remaining or math.max(0, now - cast.start)
    return math.min(duration, value), duration, remaining
end

function HC.Matches(cast, id)
    return cast and id ~= nil and cast.id ~= nil and cast.id == id
end

-- All cast labels use the active profile; parent bar scale remains independent.
function HC.ApplyCastFont(label)
    local db=HC.db or {}
    local font=db.font=='modern' and 'Fonts\\ARIALN.TTF' or 'Fonts\\FRIZQT__.TTF'
    label:SetFont(font,db.fontSize or 12,'')
end
