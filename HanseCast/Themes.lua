local _, HC = ...
HC.families={
    element={title="Elementstrom",short="Elementstrom",description="Facettiertes Eis, Flammenfäden oder drei arkane Wellen."},
    splinter={title="Splitter & Funken",short="Splitter & Funken",description="Kristallsplitter, Glutpartikel und arkane Lichtsplitter."},
    silk={title="Seidenfluss",short="Seidenfluss",description="Drei weich verflochtene Lichtbänder ohne Rahmen."},
    pulse={title="Impuls",short="Impuls",description="Eine ruhige Energielinie mit einzelnen Lichtimpulsen."},
    mist={title="Nebellicht",short="Nebellicht",description="Sanfte, durchscheinende Energieschleier."},
}
HC.familyOrder={"element","splinter","silk","pulse","mist"}
HC.elements={
    frost={title="Frost",short="Frost",color={0.16,0.73,1,1},bright={0.67,0.95,1,1},
        secondary={0.30,0.65,1,1},secondaryBright={0.55,0.82,1,1},ghost={0.27,0.52,0.66,1}},
    fire={title="Feuer",short="Feuer",color={1,0.25,0.035,1},bright={1,0.73,0.12,1},
        secondary={1,0.10,0.015,1},secondaryBright={1,0.46,0.04,1},ghost={0.65,0.23,0.12,1}},
    arcane={title="Arkan",short="Arkan",color={0.80,0.18,1,1},bright={0.96,0.60,1,1},
        secondary={0.33,0.34,1,1},secondaryBright={0.61,0.65,1,1},ghost={0.43,0.26,0.66,1}},
}
HC.elementOrder={"frost","fire","arcane"}

-- Material groups describe artwork, never the character's eligibility.
HC.visualGroups={
    {key="mage",title="Magier",elements={"frost","fire","arcane"}},
    {key="warlock",title="Hexenmeister",elements={"warlock_affliction","warlock_demonology","warlock_destruction"}},
    {key="priest",title="Priester",elements={"priest_holy","priest_discipline","priest_shadow"}},
    {key="druid",title="Druide",elements={"druid_balance","druid_restoration","druid_feralguardian"}},
    {key="warrior",title="Krieger",elements={"warrior_arms","warrior_fury","warrior_protection"}},
    {key="paladin",title="Paladin",elements={"paladin_holy","paladin_protection","paladin_retribution"}},
    {key="hunter",title="Jäger",elements={"hunter_beast","hunter_marksman","hunter_survival"}},
    {key="rogue",title="Schurke",elements={"rogue_assassination","rogue_combat","rogue_subtlety"}},
    {key="shaman",title="Schamane",elements={"shaman_elemental","shaman_enhancement","shaman_restoration"}},
    {key="factions",title="Fraktionen",elements={"faction_alliance","faction_horde"}},
}
local classPalettes={
    {"faction_alliance","Allianz",{.14,.32,.88,1},{1,.85,.48,1}},
    {"faction_horde","Horde",{.70,.08,.13,1},{1,.48,.21,1}},
    {"warlock_affliction","Gebrechen",{.62,.22,.82,1},{.75,.84,.40,1}},
    {"warlock_demonology","Dämonologie",{.30,.83,.24,1},{.78,1,.46,1}},
    {"warlock_destruction","Zerstörung",{.95,.23,.08,1},{1,.65,.25,1}},
    {"priest_holy","Heilig",{1,.76,.29,1},{1,.96,.76,1}},
    {"priest_discipline","Disziplin",{.65,.81,.98,1},{.97,.96,.85,1}},
    {"priest_shadow","Schatten",{.56,.23,.83,1},{.84,.59,1,1}},
    {"druid_balance","Gleichgewicht",{.91,.67,.33,1},{.87,.83,1,1}},
    {"druid_restoration","Wiederherstellung",{.32,.77,.38,1},{.80,.98,.61,1}},
    {"druid_feralguardian","Wilde Kraft",{.91,.49,.20,1},{1,.85,.52,1}},
    {"warrior_arms","Waffen",{.42,.56,.68,1},{.94,.81,.66,1}},
    {"warrior_fury","Furor",{.72,.10,.12,1},{1,.52,.28,1}},
    {"warrior_protection","Schutz",{.42,.45,.48,1},{.92,.76,.44,1}},
    {"paladin_holy","Heilig",{.92,.71,.34,1},{1,.96,.79,1}},
    {"paladin_protection","Schutz",{.72,.61,.39,1},{1,.91,.65,1}},
    {"paladin_retribution","Vergeltung",{.85,.40,.12,1},{1,.78,.40,1}},
    {"hunter_beast","Tierherrschaft",{.65,.36,.12,1},{1,.76,.36,1}},
    {"hunter_marksman","Treffsicherheit",{.18,.53,.56,1},{.76,.96,.98,1}},
    {"hunter_survival","Überleben",{.42,.48,.19,1},{.89,.74,.35,1}},
    {"rogue_assassination","Meucheln",{.12,.61,.35,1},{.69,.96,.48,1}},
    {"rogue_combat","Kampf",{.40,.52,.60,1},{.91,.94,.97,1}},
    {"rogue_subtlety","Täuschung",{.30,.25,.56,1},{.73,.66,.94,1}},
    {"shaman_elemental","Elementar",{.19,.45,.85,1},{.90,.72,.47,1}},
    {"shaman_enhancement","Verstärkung",{.65,.41,.18,1},{.98,.84,.53,1}},
    {"shaman_restoration","Wiederherstellung",{.07,.47,.52,1},{.51,.94,.86,1}},
}
for _,entry in ipairs(classPalettes) do
    local key,title,color,bright=unpack(entry)
    HC.elements[key]={title=title,short=title,color=color,bright=bright,secondary=color,
        secondaryBright=bright,ghost=color,classMaterial=true}
    HC.elementOrder[#HC.elementOrder+1]=key
end
HC.elements.druid_restoration.short="Naturheilung"
HC.elements.faction_alliance.faction="alliance"
HC.elements.faction_horde.faction="horde"
function HC.GetVisualGroup(element)
    for _,group in ipairs(HC.visualGroups) do
        for _,key in ipairs(group.elements) do if key==element then return group end end
    end
    return HC.visualGroups[1]
end

local classAccents={MAGE={0.35,0.78,0.95},WARRIOR={0.78,0.61,0.43},PALADIN={0.96,0.55,0.73},
    HUNTER={0.67,0.83,0.45},ROGUE={1,0.92,0.38},PRIEST={0.94,0.94,0.90},SHAMAN={0.19,0.48,0.95},
    WARLOCK={0.62,0.47,0.91},DRUID={1,0.49,0.15},DEATHKNIGHT={0.86,0.18,0.28},MONK={0.15,0.90,0.58},
    DEMONHUNTER={0.64,0.24,0.86},EVOKER={0.29,0.70,0.58}}
local function Identity(api,accents)
    if type(api)~="function" then return nil end
    local ok,label,token=pcall(api,"player")
    if ok and HC.Accessible(label) and HC.Accessible(token) and type(label)=="string"
        and type(token)=="string" and accents[token] then return label,accents[token] end
end
local function Accent(base,color,weight)
    if not color then return base end
    return {base[1]*(1-weight)+color[1]*weight,base[2]*(1-weight)+color[2]*weight,
        base[3]*(1-weight)+color[3]*weight,base[4] or 1}
end

function HC.ResolveTheme()
    local family=HC.families[HC.db.family] and HC.db.family or "element"
    local selected=HC.ResolveSpellVisual and HC.ResolveSpellVisual(HC.themeCast) or HC.db.element
    local element=HC.elements[selected] and selected or "frost"
    local palette=HC.elements[element]
    local identity="Neutral"
    local ghost,secondaryBright=palette.ghost,palette.secondaryBright
    local weight=0.08
    -- Identity affects only faint accents. Main element colors remain immutable.
    if HC.db.identity=="class" then
        local label,color=Identity(UnitClass,classAccents)
        if label then identity=label;ghost=Accent(ghost,color,weight);secondaryBright=Accent(secondaryBright,color,weight) end
    end
    return {family=family,element=element,title=HC.families[family].title.." / "..palette.title,
        identityLabel=identity,cast=palette.color,channel=palette.color,gcd=palette.color,
        bright=palette.bright,secondary=palette.secondary,secondaryBright=secondaryBright,
        ghost=ghost,classMaterial=palette.classMaterial,rail=2,texture="Interface\\Buttons\\WHITE8X8"}
end

function HC.UpdateSpellTheme(cast)
    HC.themeCast=cast
    local selected=HC.ResolveSpellVisual and HC.ResolveSpellVisual(cast) or HC.db.element
    if not HC.activeTheme or HC.activeTheme.element~=selected then HC.ApplyTheme() end
end

function HC.GetTheme() return HC.activeTheme or HC.ResolveTheme() end

function HC.ApplyTheme()
    HC.activeTheme=HC.ResolveTheme()
    HC.effectsLastDraw=nil
    if HC.gcdFrame and HC.gcdFrame.bar then
        HC.gcdFrame.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        HC.gcdFrame.bar:SetStatusBarColor(unpack(HC.activeTheme.gcd))
        HC.gcdFrame.bar:SetAlpha(0.6)
    end
    -- No fill rectangles, background panels or enclosing frame are created here.
end
