local _, HC = ...
-- Flat, typed profile data only. Never evaluates Lua or accepts arbitrary keys.
local specs={
 x={-10000,10000,0},y={-10000,10000,-180},width={180,600,300},height={24,60,32},scale={.6,2,1},
 opacity={.2,1,1},fontSize={10,20,12},
 theme={'modern','rune','minimal',default='modern'},family={'element','splinter','silk','pulse','mist',default='element'},
 element={default='frost'},identity={'neutral','class',default='class'},faction={'none','alliance','horde',default='none'},
 language={'auto','deDE','enUS',default='auto'},font={'default','modern',default='default'},
 timeFormat={'remaining','elapsed','both','hidden',default='remaining'},iconPosition={'hidden','left','right',default='hidden'},
 gcd={boolean=true,default=true},hideBlizzard={boolean=true,default=false},finishCue={boolean=true,default=true},
 autoSpellVisual={boolean=true,default=false},latency={boolean=true,default=false},channelTicks={boolean=true,default=false},
 channelTickCount={2,10,5},
}
for _,unit in ipairs({'target','focus'}) do
 local prefix='unitBars.'..unit..'.'
 local fields={enabled={boolean=true,default=false},showIcon={boolean=true,default=false},x={-10000,10000,0},
 y={-10000,10000,unit=='target' and -95 or -35},width={180,600,300},height={24,60,28},scale={.6,2,1},
 visibility={'always','combat',default='always'},family={'inherit','element','splinter','silk','pulse','mist',default='inherit'},
 element={default='inherit'}}
 for key,spec in pairs(fields) do specs[prefix..key]=spec end
end
HC.profileSpecs=specs
local function Default(s) if s.default~=nil then return s.default end;return s[3] end
local function Valid(key,value)
 local s=specs[key];if not s then return false end
 if s.boolean then return type(value)=='boolean' end
 if type(s[1])=='number' then return HC.ValidNumber(value,s[1],s[2]) and (key~='channelTickCount' or value%1==0) end
 if type(value)~='string' then return false end
 if key=='element' then return HC.elementKeys[value]==true end
 if key:match('%.element$') then return value=='inherit' or HC.elementKeys[value]==true end
 for _,v in ipairs(s) do if value==v then return true end end
 return false
end
local function Snapshot(source)
 local t={};for key,s in pairs(specs) do
  local value=source and source[key]
  local unit,field=key:match('^unitBars%.(%w+)%.(%w+)$')
  if unit and source and type(source.unitBars)=='table' and type(source.unitBars[unit])=='table' then value=source.unitBars[unit][field] end
  if Valid(key,value) then t[key]=value else t[key]=Default(s) end
 end
 return t
end
HC.ProfileSnapshot=Snapshot
local function Name(name)
 return type(name)=='string' and #name>0 and #name<=48 and not name:find('[%c|=\\]') and name:find('%S')~=nil
end
local function Allowed() return not (type(InCombatLockdown)=='function' and InCombatLockdown()) end
local function Refresh()
 if HC.frame and HC.ApplyLayout then HC.ApplyLayout() end
 if HC.UpdateBlizzard then HC.UpdateBlizzard() end
 if HC.RefreshUnitBars then HC.RefreshUnitBars() end
 if HC.Refresh then HC.Refresh() end
 if HC.RefreshGCD then HC.RefreshGCD() end
 if HC.UpdateOptions then HC.UpdateOptions() end
end
function HC.LoadExtendedSettings(db,saved)
 saved=type(saved)=='table' and saved or {}
 -- Core has already migrated legacy appearance fields. Only fill new keys here.
 for key,s in pairs(specs) do
  if not key:find('%.') and db[key]==nil then
   if Valid(key,saved[key]) then db[key]=saved[key] else db[key]=Default(s) end
  end
 end
 db.profiles={};local count=0
 if type(saved.profiles)=='table' then
  local names={};for name in pairs(saved.profiles) do if Name(name) then names[#names+1]=name end end;table.sort(names)
  for _,name in ipairs(names) do
   if count<12 and type(saved.profiles[name])=='table' then db.profiles[name]=Snapshot(saved.profiles[name]);count=count+1 end
  end
 end
 db.activeProfile=Name(saved.activeProfile) and db.profiles[saved.activeProfile] and saved.activeProfile or 'Default'
 if not db.profiles[db.activeProfile] then
  if count>=12 then local keys={};for k in pairs(db.profiles) do keys[#keys+1]=k end;table.sort(keys);db.profiles[keys[#keys]]=nil end
  db.profiles[db.activeProfile]=Snapshot(db)
 end
 -- Top-level settings remain authoritative during migration and normal reloads.
 db.profiles[db.activeProfile]=Snapshot(db)
 return db
end
function HC.SaveActiveProfile()
 if HC.db and HC.db.profiles then HC.db.profiles[HC.db.activeProfile]=Snapshot(HC.db) end
end
function HC.ProfileNames()
 local names={};for name in pairs(HC.db.profiles or {}) do names[#names+1]=name end;table.sort(names);return names
end
local function Apply(snapshot)
 for key,value in pairs(Snapshot(snapshot)) do
  local unit,field=key:match('^unitBars%.(%w+)%.(%w+)$')
  if unit then HC.db.unitBars=HC.db.unitBars or {};HC.db.unitBars[unit]=HC.db.unitBars[unit] or {};HC.db.unitBars[unit][field]=value
  else HC.db[key]=value end
 end
 HC.SaveActiveProfile();Refresh()
end
function HC.CreateProfile(name,copyCurrent)
 if not Allowed() then return false,'combat' end
 if not Name(name) or HC.db.profiles[name] or #HC.ProfileNames()>=12 then return false,'name' end
 HC.SaveActiveProfile();HC.db.profiles[name]=Snapshot(copyCurrent and HC.db or nil)
 HC.db.activeProfile=name;Apply(HC.db.profiles[name]);return true
end
function HC.SwitchProfile(name)
 if not Allowed() then return false,'combat' end
 if not HC.db.profiles[name] then return false,'name' end
 HC.SaveActiveProfile();HC.db.activeProfile=name;Apply(HC.db.profiles[name]);return true
end
function HC.DeleteProfile(name)
 if not Allowed() then return false,'combat' end
 if not HC.db.profiles[name] or #HC.ProfileNames()<=1 then return false,'last' end
 if HC.db.activeProfile==name then
  for _,other in ipairs(HC.ProfileNames()) do if other~=name then HC.SwitchProfile(other);break end end
 end
 HC.db.profiles[name]=nil;return true
end
function HC.ResetProfile()
 if not Allowed() then return false,'combat' end
 Apply(Snapshot(nil));return true
end
function HC.ExportProfile()
 local snapshot=Snapshot(HC.db);local keys={};for k in pairs(snapshot) do keys[#keys+1]=k end;table.sort(keys)
 local lines={'HANSECAST:1'};for _,k in ipairs(keys) do lines[#lines+1]=k..'='..tostring(snapshot[k]) end
 return table.concat(lines,'\n')
end
function HC.ParseProfile(text)
 if type(text)~='string' or #text>8192 or text:find('%z') then return nil,'size' end
 text=text:gsub('\r\n','\n')
 if text:sub(1,12)~='HANSECAST:1\n' then return nil,'version' end
 local result={};local count=0
 for line in (text:sub(13)..'\n'):gmatch('(.-)\n') do
  if line~='' then
   count=count+1;if count>64 then return nil,'size' end
   local key,value=line:match('^([A-Za-z][A-Za-z0-9_.]*)=(.*)$')
   local s=key and specs[key]
   if not s or result[key]~=nil then return nil,'key' end
   if s.boolean then
    if value=='true' then value=true elseif value=='false' then value=false else return nil,'type' end
   elseif type(s[1])=='number' then
    if not value:match('^%-?%d+%.?%d*$') and not value:match('^%-?%d+%.?%d*[eE][%+%-]?%d+$') then return nil,'number' end
    value=tonumber(value)
   end
   if not Valid(key,value) then return nil,'value' end
   result[key]=value
  end
 end
 if count==0 then return nil,'empty' end
 return Snapshot(result)
end
function HC.StageProfileImport(text)
 local snapshot,reason=HC.ParseProfile(text);HC.pendingProfileImport=snapshot
 return snapshot~=nil,reason
end
function HC.ApplyProfileImport()
 if not Allowed() then return false,'combat' end
 if not HC.pendingProfileImport then return false,'empty' end
 local snapshot=HC.pendingProfileImport;HC.pendingProfileImport=nil;Apply(snapshot);return true
end
