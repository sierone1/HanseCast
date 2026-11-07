local _, HC = ...
-- Explicit cast/channel spell IDs, including ranks. See SPELL-VISUAL-MODE.md
-- for pinned upstream data and boundaries. Never infer ranks via GetBaseSpell.
-- School-to-material choices are art direction, not a new gameplay classification.
local spells = {}
local function Add(element, ids)
    for _, id in ipairs(ids) do spells[id] = element end
end

-- Mage: Frostbolt / Blizzard; Fireball / Flamestrike / Pyroblast / Scorch;
-- Arcane Missiles / Arcane Blast / Forever Arcane Wrath / Evocation.
Add("frost", {116,205,837,7322,8406,8407,8408,10179,10180,10181,25304,
    10,6141,8427,10185,10186,10187})
Add("fire", {133,143,145,3140,8400,8401,8402,10148,10149,10150,10151,25306,
    2120,2121,8422,8423,10215,10216,11366,12505,12522,12523,12524,12525,12526,18809,
    2948,8444,8445,8446,10205,10206,10207})
Add("arcane", {5143,5144,5145,8416,8417,10211,10212,25345,30451,
    1326079,1326080,1326081,1326082,12051})

-- Priest: Smite / Holy Fire / direct heals / Resurrection.
Add("priest_holy", {585,591,598,984,1004,6060,10933,10934,
    14914,15262,15263,15264,15265,15266,15267,15261,
    2050,2052,2053,2054,2055,6063,6064,2060,10963,10964,10965,25314,
    2061,9472,9473,9474,10915,10916,10917,596,996,10960,10961,25316,
    2006,2010,10880,10881,20770})
-- Mind Blast / Mind Flay / Mind Control; Penance gets its own discipline art.
Add("priest_shadow", {8092,8102,8103,8104,8105,8106,10945,10946,10947,
    15407,17311,17312,17313,17314,18807,605,10911,10912})
Add("priest_discipline", {402174,1240720,1240721,1316995})

-- Warlock: Shadow Bolt / Drain Life / Drain Soul; fire casts; demon summons.
Add("warlock_affliction", {686,695,705,1088,1106,7641,11659,11660,11661,25307,
    689,699,709,7651,11699,11700,1120,8288,8289,11675})
Add("warlock_destruction", {348,707,1094,2941,11665,11667,11668,25309,
    412758,1293812,1293813,5740,6219,11677,11678,5676,17919,17920,17921,17922,17923,
    6353,17924})
Add("warlock_demonology", {691,688,712,697})

-- Druid: Wrath / Starfire / Hurricane; Healing Touch / Regrowth / Tranquility /
-- Rebirth. Feral art remains manually selectable; instant melee actions do not
-- invent a cast bar and therefore do not trigger an automatic cast material.
Add("druid_balance", {5176,5177,5178,5179,5180,6780,8905,9912,
    2912,8949,8950,8951,9875,9876,25298,16914,17401,17402})
Add("druid_restoration", {5185,5186,5187,5188,5189,6778,8903,9758,9888,9889,25297,
    8936,8938,8939,8940,8941,9750,9856,9857,9858,740,8918,9862,9863,
    20484,20739,20742,20747,20748})

-- Paladin: Holy Light / Flash of Light / Redemption (Classic rank IDs).
-- No instant seals, judgements or melee actions are used to synthesize casts.
Add("paladin_holy", {635,639,647,1026,1042,3472,10328,10329,25292,
    19750,19939,19940,19941,19942,19943,7328,10322,10324,20772,20773})

-- Shaman: parent Lightning Bolt / Chain Lightning / Forever Lava Burst casts.
-- Explicitly exclude overload child IDs: those are triggered damage events.
Add("shaman_elemental", {403,529,548,915,943,6041,10391,10392,15207,15208,
    421,930,2860,10605,408490,1238299,1238300,1326047})
-- Healing Wave / Lesser Healing Wave / Chain Heal / Ancestral Spirit.
Add("shaman_restoration", {331,332,547,913,939,959,8005,10395,10396,25357,
    8004,8008,8010,10466,10467,10468,1064,10622,10623,2008,20609,20610,20776,20777})

-- Hunter: Aimed Shot / Forever Sniper Shot / Volley channel parent IDs.
-- Not Auto Shot, instant shots, melee actions, or Volley's damage-tick IDs.
Add("hunter_marksman", {19434,20900,20901,20902,20903,20904,
    1310687,1310785,1310786,1510,14294,14295})
-- Warrior / Rogue remain manual. Their melee events never create a cast here.

function HC.ResolveSpellVisual(cast)
    local manual = HC.db.element
    -- Explicit faction artwork is a fixed visual choice, not a spell school.
    if manual=="faction_alliance" or manual=="faction_horde" then return manual,"faction" end
    if not HC.db.autoSpellVisual then return manual, "manual" end
    if HC.preview then return manual, "preview" end
    if not cast then return manual, "idle" end
    local id = cast.spellID
    if not HC.Accessible(id) then return manual, "restricted" end
    if not HC.ValidNumber(id, 1, 2147483647) or id % 1 ~= 0 then return manual, "unknown" end
    local element = spells[id]
    if not element then return manual, "unknown" end
    if not HC.elements or not HC.elements[element] then return manual, "unavailable" end
    return element, "spell"
end
