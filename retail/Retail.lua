local _, HC = ...
-- Retail is a separate build, never a relaxation of the Forever allowlist.
HC.retail = true
function HC.RetailSupported()
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE or WOW_PROJECT_MAINLINE == nil then return false end
    if type(GetBuildInfo) ~= 'function' or type(issecretvalue) ~= 'function' then return false end
    local ok, _, _, _, interface = pcall(GetBuildInfo)
    return ok and HC.Accessible(interface) and interface == 120105
end

-- Compact timers cannot represent Empower stages. Keep Blizzard visible when
-- the channel kind cannot be established safely, including inaccessible flags.
function HC.RetailCompactSupported(unit)
    if type(UnitChannelInfo) ~= 'function' then return false end
    local ok, _, _, _, _, _, _, _, _, empowered = pcall(UnitChannelInfo, unit)
    return ok and HC.Accessible(empowered) and (empowered == nil or empowered == false)
end
