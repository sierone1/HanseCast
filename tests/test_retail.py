"""Exercise the generated Retail payload, not the Forever source files."""
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / 'work/python-deps'), str(ROOT / 'tools')]
from lupa.lua51 import LuaRuntime

def load(files, interface=120105, project=1):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute((ROOT / 'tests/runtime.lua').read_text(encoding='utf-8'))
    lua.execute(f"WOW_PROJECT_MAINLINE=1;WOW_PROJECT_ID={project};function GetBuildInfo() return '12.1.5','mock','', {interface} end")
    lua.execute('''
      print=function() end
      PlayerCastingBarFrame=CreateFrame('Frame');PlayerCastingBarFrame:SetAlpha(.8);PlayerCastingBarFrame:Show()
      function hooksecurefunc(object,key,after)
        local prior=object[key];object[key]=function(...) prior(...);after(...) end
      end
      HanseCastDB={sentinel='forever'}
    ''')
    hc = lua.table(); lua.globals().HC = hc
    for line in files['HanseCast.toc'].decode().splitlines():
        if line.strip() and not line.startswith('#'):
            lua.execute('return function(...)\n' + files[line.strip()].decode('utf-8-sig') + '\nend')('HanseCast', hc)
    lua.execute("Fire('ADDON_LOADED','HanseCast')")
    return lua, hc

def verify(files):
    lua, hc = load(files)
    lua.execute('''
      assert(HC.ready and HC.retail and HanseCastRetailDB==HC.db)
      assert(HanseCastDB.sentinel=='forever' and HanseCastDB.launches==nil)
      assert(HC.CompactMode()=='on')
      assert(not HC.compact.target.frame:IsShown()) -- APIs missing in this mock
      HC.db.hideBlizzard=true
      SetCast(101,10000,14000);Fire('UNIT_SPELLCAST_START','player','guid',116,101);Flush()
      assert(HC.cast and HC.frame:IsShown())
      assert(PlayerCastingBarFrame:GetAlpha()==0)
      cast[4]=SECRET;HC.Refresh()
      assert(not HC.cast and not HC.frame:IsShown())
      assert(PlayerCastingBarFrame:GetAlpha()==.8)
      cast=nil;channel={'Empower','Empower',134400,10000,15000,false,false,123,true,3,202}
      Fire('UNIT_SPELLCAST_EMPOWER_START','player','guid',123,202);Flush()
      assert(not HC.cast and HC.lastReason=='unsupported')
      assert(PlayerCastingBarFrame:GetAlpha()==.8)
      channel=nil;Fire('UNIT_SPELLCAST_EMPOWER_STOP','player','guid',123,202);Flush()
      assert(HC.lastReason=='idle')
      local profile=HC.ExportProfile();assert(type(profile)=='string')
      HC.TogglePreview();assert(HC.preview);HC.TogglePreview();assert(not HC.preview)
    ''')
    for interface, project in [(16001,1),(120105,2),(120107,1),(120000,1)]:
        lua, hc = load(files, interface, project)
        lua.execute('assert(not HC.ready and not HanseCastRetailDB and HanseCastDB.sentinel=="forever")')
    # Native opaque objects, secrets, failure recovery and unit transitions.
    from test_compact_lab import setup
    lua, _ = setup()
    hc = lua.table(); lua.globals().HC = hc
    lua.execute("WOW_PROJECT_MAINLINE=1;WOW_PROJECT_ID=1;function GetBuildInfo() return '12.1.5','mock','',120105 end")
    for name in ['Compatibility.lua','Retail.lua','CompactUnits.lua']:
        lua.execute('return function(...)\n'+files[name].decode('utf-8-sig')+'\nend')('HanseCast',hc)
    lua.execute('''
      Lab=HC.compact;HC.db={};HC.LoadCompactSettings(HC.db,nil)
      units.target.cast=opaqueA;units.focus.channel=inaccessible
      assert(HC.InitializeCompactUnits() and Lab.mode=='on')
      assert(Lab.target.native:IsShown() and Lab.focus.native:IsShown())
      local channelInfo=UnitChannelInfo
      for _,flag in ipairs({true,SECRET}) do
        UnitChannelInfo=function() return 'Empower',nil,nil,nil,nil,nil,nil,nil,flag end
        UnitEvent('focus','UNIT_SPELLCAST_EMPOWER_START');TickLab(.001)
        assert(not Lab.focus.native:IsShown() and Lab.focus.reason=='unsupported')
      end
      UnitChannelInfo=function() error('unavailable channel metadata') end
      UnitEvent('focus','UNIT_SPELLCAST_EMPOWER_UPDATE');TickLab(.001)
      assert(not Lab.focus.native:IsShown())
      UnitChannelInfo=channelInfo
      UnitEvent('focus','UNIT_SPELLCAST_EMPOWER_STOP');TickLab(.001)
      assert(Lab.focus.native:IsShown())
      denyTimer=true;UnitEvent('target','UNIT_SPELLCAST_START');TickLab(.001)
      assert(not Lab.target.native:IsShown())
      denyTimer=false;UnitEvent('target','UNIT_SPELLCAST_START');TickLab(.001)
      assert(Lab.target.native:IsShown())
      units.target.cast=nil;UnitEvent('target','UNIT_SPELLCAST_STOP');TickLab(.001)
      assert(not Lab.target.native:IsShown())
      combat=true;assert(not HC.SetCompactStyle('split'));combat=false
      assert(HC.SetCompactStyle('split') and HC.db.compactUnits.style=='split')
    ''')
    print('PASS Retail: generated TOC load, client gates, isolated settings, player cast, secret/Empower fallback, profiles/preview, opaque target/focus timers, rejection/recovery, combat guard')

if __name__ == '__main__':
    from package_retail import sources
    verify(sources())
