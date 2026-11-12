"""First-install specialization and per-cast material tests for both exact payloads."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT/'work/python-deps'),str(ROOT/'tools')]
from lupa.lua51 import LuaRuntime

def verify(retail_files=None):
    from package_retail import sources
    retail_files=retail_files or sources()
    forever={p.name:p.read_bytes() for p in (ROOT/'HanseCast').iterdir() if p.suffix in {'.lua','.toc'}}
    def load(files, init=''):
        lua=LuaRuntime(unpack_returned_tuples=True)
        lua.execute((ROOT/'tests/runtime.lua').read_text(encoding='utf-8'))
        lua.execute('print=function() end;'+init)
        if files is retail_files:
            lua.execute("WOW_PROJECT_MAINLINE=1;WOW_PROJECT_ID=1;function GetBuildInfo() return '12.1.5','mock','',120105 end")
        hc=lua.table();lua.globals().HC=hc
        for line in files['HanseCast.toc'].decode().splitlines():
            if line.strip() and not line.startswith('#'):
                lua.execute('return function(...)\n'+files[line.strip()].decode('utf-8-sig')+'\nend')('HanseCast',hc)
        lua.execute("Fire('ADDON_LOADED','HanseCast')")
        assert hc.ready
        return lua,hc

    tabs={
        'MAGE':['arcane','fire','frost'], 'PRIEST':['priest_discipline','priest_holy','priest_shadow'],
        'DRUID':['druid_balance','druid_feralguardian','druid_restoration'],
        'SHAMAN':['shaman_elemental','shaman_enhancement','shaman_restoration'],
        'PALADIN':['paladin_holy','paladin_protection','paladin_retribution'],
        'WARRIOR':['warrior_arms','warrior_fury','warrior_protection'],
        'HUNTER':['hunter_beast','hunter_marksman','hunter_survival'],
        'ROGUE':['rogue_assassination','rogue_combat','rogue_subtlety'],
        'WARLOCK':['warlock_affliction','warlock_demonology','warlock_destruction']}
    for cls,expected in tabs.items():
        for index,element in enumerate(expected,1):
            lua,hc=load(forever,f"function UnitClass() return 'Class','{cls}' end; function GetTalentTabInfo(i) return 'Tab',1,i=={index} and 31 or 5 end")
            assert hc.db.element==element,(cls,index,hc.db.element)
            assert hc.db.hideBlizzard and not hc.db.autoSpellVisual
            lua.execute("assert(HC.FirstRunSettings(HC.db)==HC.db);HC.db.element='fire';HC.db.hideBlizzard=false;HC.db.autoSpellVisual=true;local saved=HC.LoadSettings(HC.FirstRunSettings(HC.db));assert(saved.element=='fire' and not saved.hideBlizzard and saved.autoSpellVisual)")
    specs={
        'MAGE':[62,63,64], 'PRIEST':[256,257,258], 'DRUID':[102,103,105],
        'SHAMAN':[262,263,264], 'PALADIN':[65,66,70], 'WARRIOR':[71,72,73],
        'HUNTER':[253,254,255], 'ROGUE':[259,260,261], 'WARLOCK':[265,266,267],
        'DEATHKNIGHT':[250,251,252], 'MONK':[268,270,269], 'DEMONHUNTER':[577,581,1480], 'EVOKER':[1467,1468,1473]}
    expected=dict(tabs,DEATHKNIGHT=['deathknight_blood','deathknight_frost','deathknight_unholy'],
        MONK=['monk_brewmaster','monk_mistweaver','monk_windwalker'],
        DEMONHUNTER=['demonhunter_havoc','demonhunter_vengeance','demonhunter_devourer'],EVOKER=['evoker_red','evoker_green','evoker_bronze'])
    for cls,ids in specs.items():
        for index,spec in enumerate(ids):
            lua,hc=load(retail_files,f"function UnitClass() return 'Class','{cls}' end; C_SpecializationInfo={{GetSpecialization=function() return 1 end,GetSpecializationInfo=function() return {spec} end}}")
            assert hc.db.element==expected[cls][index],(cls,spec,hc.db.element)
            assert hc.db.hideBlizzard and not hc.db.autoSpellVisual
            # Every selected Retail alias resolves to shipped normal/small assets in all families.
            for family in ['element','splinter','silk','pulse','mist']:
                hc.db.family=family;hc.ApplyTheme()
                theme=hc.GetTheme();material=theme.materialElement or theme.element
                # Use renderer's real paths below, independent of folder assumptions.
                lua.execute("SetCast(100,10000,15000);HC.Refresh()")
                for region in [hc.effects.body,hc.effects.reveal]:
                    path=region.texture
                    assert path, 'Renderer did not select an asset'
                    key=path.replace('\\','/').split('Interface/AddOns/HanseCast/',1)[1]
                    assert key in retail_files,(cls,spec,family,key)
    # Legacy globals, modern Classic tuple, missing/secret/error API and guardian.
    lua,hc=load(retail_files,"function UnitClass() return 'Druid','DRUID' end;function GetSpecialization() return 3 end;function GetSpecializationInfo() return 104 end")
    assert hc.db.element=='druid_feralguardian'
    lua,hc=load(forever,"function UnitClass() return 'Priest','PRIEST' end;C_SpecializationInfo={GetSpecializationInfo=function(i) return i,'Tab','',1,'',1,i==3 and 31 or 0 end}")
    assert hc.db.element=='priest_shadow'
    for init in ["function GetTalentTabInfo() return 'Tab',1,SECRET end", "function GetTalentTabInfo() error('missing data') end"]:
        lua,hc=load(forever,init);assert hc.db.element=='frost'

    for files,cases in [(forever,[(8092,'priest_shadow'),(2061,'priest_holy'),(1316995,'priest_discipline'),
        (5176,'druid_balance'),(8936,'druid_restoration'),(403,'shaman_elemental'),(1064,'shaman_restoration'),
        (11605,'warrior_arms'),(1310200,'warrior_arms'),(1804,'rogue_subtlety')]),
        (retail_files,[(8092,'priest_shadow'),(2061,'priest_holy'),(47540,'priest_discipline'),(400169,'priest_shadow'),
        (34914,'priest_shadow'),(194509,'priest_discipline'),(194153,'druid_balance'),(8936,'druid_restoration'),
        (188196,'shaman_elemental'),(77472,'shaman_restoration'),(116,'frost'),(635,'paladin_holy'),
        (257044,'hunter_marksman'),(64382,'warrior_arms'),(315584,'rogue_assassination'),(116858,'warlock_destruction'),
        (206931,'deathknight_blood'),(115175,'monk_mistweaver'),(198013,'demonhunter_havoc'),(473728,'demonhunter_devourer'),
        (356995,'evoker_blue'),(361469,'evoker_red')])]:
        lua,hc=load(files)
        hc.db.element='priest_holy'
        for spell,element in cases:
            hc.db.autoSpellVisual=False
            lua.execute(f"SetCast({spell},10000,15000);cast[9]={spell};HC.Refresh()")
            assert hc.activeTheme.element=='priest_holy'
            hc.db.autoSpellVisual=True;hc.Refresh()
            assert hc.activeTheme.element==element,(spell,hc.activeTheme.element)
        lua.execute("cast=nil;channel={'Channel','Channel',1,10000,15000,false,false,15407,false,nil,901};HC.Refresh();assert(HC.activeTheme.element=='priest_shadow');channel=nil;HC.Refresh();assert(HC.activeTheme.element=='priest_holy');assert(HC.db.element=='priest_holy')")
        for spell,element in hc.spellVisualCatalog.items():
            assert hc.elements[element] is not None,(spell,element)
        lua.execute("assert(HC.ResolveSpellVisual({spellID=SECRET})=='priest_holy');assert(HC.ResolveSpellVisual({spellID=99999999})=='priest_holy');HC.preview=true;assert(HC.ResolveSpellVisual({spellID=8092})=='priest_holy')")
    lua,hc=load(retail_files)
    lua.execute("HC.db.autoSpellVisual=true;assert(select(2,HC.ResolveSpellVisual({spellID=1316995}))=='unknown')")
    print('PASS class automation: 27 Forever talent trees, 40 Retail specializations, all 13 Retail classes, real controller/theme transitions, shipped assets, saved-choice preservation and secret/unknown fallbacks')

if __name__=='__main__': verify()
