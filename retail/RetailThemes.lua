local _, HC = ...
-- Retail-only labels reuse shipped artwork. These are explicit material aliases,
-- not new painted assets; every family and size uses the existing source texture.
local groups = {
    {key='deathknight', title='Todesritter', entries={
        {'deathknight_blood','Blut','warrior_fury'},
        {'deathknight_frost','Frost','frost'},
        {'deathknight_unholy','Unheilig','warlock_affliction'}}},
    {key='monk', title='Mönch', entries={
        {'monk_brewmaster','Braumeister','warrior_arms'},
        {'monk_mistweaver','Nebelwirker','shaman_restoration'},
        {'monk_windwalker','Windläufer','shaman_enhancement'}}},
    {key='demonhunter', title='Dämonenjäger', entries={
        {'demonhunter_havoc','Verwüstung','warlock_demonology'},
        {'demonhunter_vengeance','Rachsucht','warlock_destruction'},
        {'demonhunter_devourer','Verschlinger','priest_shadow'}}},
    {key='evoker', title='Rufer', entries={
        {'evoker_red','Rote Drachenmagie','fire'},
        {'evoker_blue','Blaue Drachenmagie','frost'},
        {'evoker_green','Grüne Drachenmagie','druid_restoration'},
        {'evoker_bronze','Bronzene Drachenmagie','priest_holy'},
        {'evoker_black','Schwarze Drachenmagie','druid_balance'}}},
}
for _, group in ipairs(groups) do
    local visual = {key=group.key, title=group.title, elements={}}
    for _, entry in ipairs(group.entries) do
        local key, title, source = unpack(entry)
        local palette = {}
        for k, v in pairs(HC.elements[source]) do palette[k] = v end
        palette.title=title;palette.short=title;palette.materialElement=source
        HC.elements[key]=palette;HC.elementKeys[key]=true
        HC.elementOrder[#HC.elementOrder+1]=key
        visual.elements[#visual.elements+1]=key
    end
    table.insert(HC.visualGroups, #HC.visualGroups, visual)
end
