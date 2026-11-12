local _, HC = ...
-- Only used when no SavedVariables exist. Never rewrites an existing profile,
-- follows a respec automatically, or enables per-spell visual switching.
local classes = {
    MAGE={'arcane','fire','frost'}, PRIEST={'priest_discipline','priest_holy','priest_shadow'},
    DRUID={'druid_balance','druid_feralguardian','druid_restoration'},
    SHAMAN={'shaman_elemental','shaman_enhancement','shaman_restoration'},
    PALADIN={'paladin_holy','paladin_protection','paladin_retribution'},
    WARRIOR={'warrior_arms','warrior_fury','warrior_protection'},
    HUNTER={'hunter_beast','hunter_marksman','hunter_survival'},
    ROGUE={'rogue_assassination','rogue_combat','rogue_subtlety'},
    WARLOCK={'warlock_affliction','warlock_demonology','warlock_destruction'},
    DEATHKNIGHT={'deathknight_blood','deathknight_frost','deathknight_unholy'},
    MONK={'monk_brewmaster','monk_mistweaver','monk_windwalker'},
    DEMONHUNTER={'demonhunter_havoc','demonhunter_vengeance','demonhunter_devourer'},
    EVOKER={'evoker_red','evoker_green','evoker_bronze'},
}
local specIDs = {
    MAGE={[62]='arcane',[63]='fire',[64]='frost'},
    PRIEST={[256]='priest_discipline',[257]='priest_holy',[258]='priest_shadow'},
    DRUID={[102]='druid_balance',[103]='druid_feralguardian',[104]='druid_feralguardian',[105]='druid_restoration'},
    SHAMAN={[262]='shaman_elemental',[263]='shaman_enhancement',[264]='shaman_restoration'},
    PALADIN={[65]='paladin_holy',[66]='paladin_protection',[70]='paladin_retribution'},
    WARRIOR={[71]='warrior_arms',[72]='warrior_fury',[73]='warrior_protection'},
    HUNTER={[253]='hunter_beast',[254]='hunter_marksman',[255]='hunter_survival'},
    ROGUE={[259]='rogue_assassination',[260]='rogue_combat',[261]='rogue_subtlety'},
    WARLOCK={[265]='warlock_affliction',[266]='warlock_demonology',[267]='warlock_destruction'},
    DEATHKNIGHT={[250]='deathknight_blood',[251]='deathknight_frost',[252]='deathknight_unholy'},
    MONK={[268]='monk_brewmaster',[270]='monk_mistweaver',[269]='monk_windwalker'},
    DEMONHUNTER={[577]='demonhunter_havoc',[581]='demonhunter_vengeance',[1480]='demonhunter_devourer'},
    EVOKER={[1467]='evoker_red',[1468]='evoker_green',[1473]='evoker_bronze'},
}
local function Number(value)
    return HC.Accessible(value) and HC.ValidNumber(value,0,10000)
end
function HC.InitialVisual()
    if type(UnitClass)~='function' then return 'frost','unavailable' end
    local ok,_,class=pcall(UnitClass,'player')
    if not ok or not HC.Accessible(class) or type(class)~='string' or not classes[class] then
        return 'frost','unavailable'
    end
    local api=C_SpecializationInfo
    local getSpec=api and api.GetSpecialization or GetSpecialization
    local getInfo=api and api.GetSpecializationInfo or GetSpecializationInfo
    if type(getSpec)=='function' and type(getInfo)=='function' then
        local read,index=pcall(getSpec)
        if read and Number(index) and index>=1 then
            local found,id=pcall(getInfo,index)
            if found and Number(id) then
                local element=specIDs[class][id]
                if element and HC.elementKeys[element] then return element,'specialization' end
            end
        end
    end
    -- Forever/Classic: actual spent points, never preview/unsaved talent points.
    if not HC.retail then
        local best,maximum= nil,0
        for index=1,3 do
            local points
            if type(GetTalentTabInfo)=='function' then
                local read,a,_,c,_,e=pcall(GetTalentTabInfo,index,false,false)
                if read and HC.Accessible(a) then
                    if type(a)=='string' then points=c -- Classic: name, icon, points
                    elseif type(a)=='number' then points=e end -- older id-based tuple
                end
            elseif type(getInfo)=='function' then
                local read,_,_,_,_,_,_,spent=pcall(getInfo,index)
                if read then points=spent end
            end
            if Number(points) and points>maximum then best=index;maximum=points end
        end
        local element=best and classes[class][best]
        if element and HC.elementKeys[element] then return element,'talents' end
    end
    local fallback=class=='MAGE' and 'frost' or classes[class][1]
    if not HC.elementKeys[fallback] then return 'frost','unavailable' end
    return fallback,'class'
end
function HC.FirstRunSettings(saved)
    if saved~=nil then return saved end
    local element,reason=HC.InitialVisual()
    HC.initialVisualReason=reason
    return {element=element,hideBlizzard=true,autoSpellVisual=false}
end
