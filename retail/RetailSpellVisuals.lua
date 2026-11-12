local _, HC = ...
-- Separate Retail parent-cast catalog. Provenance/limits: docs/public/AUTO-SPELL-VISUALS.md.
-- No name matching, aura inspection, specialization guesses or inferred child IDs.
local spells = {}
local function Add(element, ids)
    for _, id in ipairs(ids) do
        assert(not spells[id], 'Duplicate Retail spell visual ID')
        spells[id] = element
    end
end
Add('frost', {116,10,199786})
Add('fire', {133,11366,2120,2948})
Add('arcane', {5143,30451,12051})
Add('priest_holy', {585,14914,2060,2061,596,2006,64843,64901,120517,289666,9484})
Add('priest_discipline', {47540,194509,421453,32375})
-- Dark Reprimand and Void Blast are deliberately Shadow, even on Discipline.
Add('priest_shadow', {8092,15407,605,34914,391403,263165,228260,205364,
    400169,450215,450405,450983,120644,375901,323673})
Add('druid_balance', {5176,190984,194153,197628,274281,274282,274283,202347})
Add('druid_restoration', {8936,740,20484,50769,48438})
Add('shaman_elemental', {403,421,188196,188443,51505,191634,305483,51514,6196,556})
Add('shaman_restoration', {8004,77472,1064,2008,73920,197995})
Add('paladin_holy', {635,19750,7328})
Add('hunter_marksman', {19434,56641,257044,203155,6197})
Add('warrior_arms', {64382})
Add('rogue_subtlety', {1804,1842})
Add('rogue_assassination', {3408,5761,8679,315584,381664,381637})
Add('warlock_affliction', {686,234153,198590,27243,316099,342938,48181,
    5782,30283,278350,386997,325640,264106,417537})
Add('warlock_demonology', {688,697,691,712,755,710,1098,105174,434635,264178,104316,265187})
Add('warlock_destruction', {348,6353,29722,116858,152108,196447})
Add('deathknight_blood', {206931})
Add('deathknight_unholy', {50977,111673,212552})
Add('monk_mistweaver', {115175,124682,116670,115294,115178,212051,198898})
Add('monk_windwalker', {117952,113656,101546})
Add('demonhunter_havoc', {198013,452497,258925,206966,370965,323639})
Add('demonhunter_vengeance', {212084,452486})
Add('demonhunter_devourer', {473662,1217610,473728,1221150})
Add('evoker_red', {361469})
Add('evoker_blue', {356995})
Add('evoker_green', {370960})
Add('evoker_bronze', {431443,373861,404977,408233,403631,442204})
Add('evoker_black', {395160,395152,378464})
-- Empower remains Blizzard-rendered; no fabricated stages or spell-school guesses.
-- Convoke is intentionally unclassified: one ID casts several schools/forms.
HC.spellVisualCatalog = spells
