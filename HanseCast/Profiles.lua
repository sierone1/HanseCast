local _, HC = ...
-- Flat, typed profile data only. Never evaluates Lua or accepts arbitrary keys.
local specs={
 x={-10000,10000,0},y={-10000,10000,-180},width={180,600,300},height={24,60,32},scale={.6,2,1},
 opacity={.2,1,1},fontSize={10,20,12},
 theme={'modern','rune','minimal',default='modern'},family={'element','splinter','silk','pulse','mist',default='element'},
 element={default='frost'},identity={'neutral','class',default='class'},faction={'none','alliance','horde',default='none'},
 language={'auto','deDE','enUS',default='auto'},font={'default','modern',default='default'},
 timeFormat={'remaining','elapsed','both','hidden',default='remaining'},iconPosition={'hidden','left','right',default='hidden'},
 gcd={boolean=true,default=true},hideBlizzard={boolean=true,default=false},hideBlizzardFocus={boolean=true,default=true},hideBlizzardTarget={boolean=true,default=true},finishCue={boolean=true,default=true},
 quietMode={boolean=true,default=false},castDelay={boolean=true,default=false},queueWindow={boolean=true,default=false},
 favorites={default='',favorites=true},
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
local familyKeys={element=true,splinter=true,silk=true,pulse=true,mist=true}
local function StyleKey(value)
 if type(value)~='string' then return nil end
 local family,element=value:match('^([a-z]+):([a-z_]+)$')
 if familyKeys[family] and HC.elementKeys[element] then return family,element end
end
local function Favorites(value)
 if type(value)~='string' or #value>1600 then return nil end
 local result,seen={},{}
 if value=='' then return result end
 for key in (value..','):gmatch('(.-),') do
  if not StyleKey(key) or seen[key] or #result>=20 then return nil end
  seen[key]=true;result[#result+1]=key
 end
 return result
end
local function Valid(key,value)
 local s=specs[key];if not s then return false end
 if s.favorites then return Favorites(value)~=nil end
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
local function WriteSnapshot(target,source)
 for key,value in pairs(Snapshot(source)) do
  local unit,field=key:match('^unitBars%.(%w+)%.(%w+)$')
  if unit then target.unitBars=target.unitBars or {};target.unitBars[unit]=target.unitBars[unit] or {};target.unitBars[unit][field]=value
  else target[key]=value end
 end
end
local function Serialize(source)
 local snapshot=Snapshot(source);local keys={};for k in pairs(snapshot) do keys[#keys+1]=k end;table.sort(keys)
 local lines={'HANSECAST:1'};for _,k in ipairs(keys) do lines[#lines+1]=k..'='..tostring(snapshot[k]) end
 return table.concat(lines,'\n')
end
local function Name(name)
 return type(name)=='string' and #name>0 and #name<=48 and not name:find('[%c|=\\]') and name:find('%S')~=nil
end
local function Allowed() return not (type(InCombatLockdown)=='function' and InCombatLockdown()) end
HC.ValidProfileValue=Valid
function HC.CheckNewProfileName(name)
 if not Name(name) then return false,'invalidName' end
 if HC.db.profiles[name] then return false,'duplicate' end
 if #HC.ProfileNames()>=12 then return false,'limit' end
 return true
end
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
 local validActive=Name(saved.activeProfile) and db.profiles[saved.activeProfile]
 db.activeProfile=validActive and saved.activeProfile or 'Default'
 if not validActive and (db.profiles.Default or count>=12) then
  -- A damaged active name must never overwrite an existing Default or evict
  -- a valid named profile to make room for orphaned top-level values.
  if not db.profiles[db.activeProfile] then
   local keys={};for key in pairs(db.profiles) do keys[#keys+1]=key end;table.sort(keys);db.activeProfile=keys[1]
  end
  WriteSnapshot(db,db.profiles[db.activeProfile])
 elseif not db.profiles[db.activeProfile] then db.profiles[db.activeProfile]=Snapshot(db) end
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
 if HC.ResetComfortTiming then HC.ResetComfortTiming() end
 -- Runtime-only revision invalidates unfinished edits even when a reset/import
 -- replaces the current profile without changing its name. Never persisted.
 HC.profileRevision=(HC.profileRevision or 0)+1
 WriteSnapshot(HC.db,snapshot)
 HC.SaveActiveProfile();Refresh()
end
function HC.CreateProfile(name,copyCurrent)
 if not Allowed() then return false,'combat' end
 local ok,reason=HC.CheckNewProfileName(name);if not ok then return false,reason end
 HC.SaveActiveProfile();HC.db.profiles[name]=Snapshot(copyCurrent and HC.db or nil)
 HC.db.activeProfile=name;Apply(HC.db.profiles[name]);return true
end
function HC.SwitchProfile(name)
 if not Allowed() then return false,'combat' end
 if not HC.db.profiles[name] then return false,'name' end
 HC.SaveActiveProfile();HC.db.activeProfile=name;Apply(HC.db.profiles[name]);return true
end
function HC.RenameProfile(name,newName)
 if not Allowed() then return false,'combat' end
 if not HC.db.profiles[name] then return false,'name' end
 if not Name(newName) then return false,'invalidName' end
 if name==newName then return true end
 if HC.db.profiles[newName] then return false,'duplicate' end
 -- Rename moves an existing entry, so the twelve-profile creation limit does
 -- not apply. Save live values before moving the active entry; never Apply a
 -- snapshot or refresh cast rendering merely because a name changed.
 HC.SaveActiveProfile()
 HC.db.profiles[newName]=HC.db.profiles[name];HC.db.profiles[name]=nil
 if HC.db.activeProfile==name then HC.db.activeProfile=newName end
 HC.profileRevision=(HC.profileRevision or 0)+1
 if HC.UpdateOptions then HC.UpdateOptions() end
 return true
end
function HC.DeleteProfile(name)
 if not Allowed() then return false,'combat' end
 if not HC.db.profiles[name] then return false,'name' end
 if #HC.ProfileNames()<=1 then return false,'last' end
 if HC.db.activeProfile==name then
  for _,other in ipairs(HC.ProfileNames()) do if other~=name then HC.SwitchProfile(other);break end end
 end
 HC.db.profiles[name]=nil;return true
end
function HC.ResetProfile()
 if not Allowed() then return false,'combat' end
 Apply(Snapshot(nil));return true
end
function HC.ExportProfile() return Serialize(HC.db) end
function HC.ProfileFingerprint(name)
 if not HC.db or not HC.db.profiles or not HC.db.profiles[name] then return nil end
 return Serialize(name==HC.db.activeProfile and HC.db or HC.db.profiles[name])
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
 local total=0;for _ in pairs(specs) do total=total+1 end
 return Snapshot(result),nil,{provided=count,defaults=total-count}
end
-- Read-only review of the exact parsed payload. No staging, profile writes or
-- code evaluation; missing legacy fields retain the established default policy.
function HC.InspectProfileImport(text)
 local snapshot,reason,details=HC.ParseProfile(text)
 if not snapshot then return nil,reason end
 local current=Snapshot(HC.db);local changed=0;local unitChanges=0
 for key,value in pairs(snapshot) do
  if value~=current[key] then
   changed=changed+1;if key:match('^unitBars%.') or key=='hideBlizzardTarget' or key=='hideBlizzardFocus' then unitChanges=unitChanges+1 end
  end
 end
 details.changed=changed;details.unitChanges=unitChanges
 details.width=snapshot.width;details.height=math.max(24,math.ceil(24/snapshot.scale),snapshot.height);details.fontSize=snapshot.fontSize
 details.heightAdjusted=details.height~=snapshot.height
 details.favorites=#(Favorites(snapshot.favorites) or {})
 return details
end
function HC.StageProfileImport(text)
 local snapshot,reason=HC.ParseProfile(text);HC.pendingProfileImport=snapshot
 return snapshot~=nil,reason
end
local function ImportSnapshot(text)
 -- UI callers pass their exact checked text. Legacy callers may still stage
 -- globally and apply with no argument; the two paths never share a payload.
 if text~=nil then return HC.ParseProfile(text) end
 if not HC.pendingProfileImport then return nil,'empty' end
 return Snapshot(HC.pendingProfileImport)
end
function HC.ApplyProfileImport(text)
 if not Allowed() then return false,'combat' end
 local snapshot,reason=ImportSnapshot(text);if not snapshot then return false,reason end
 HC.pendingProfileImport=nil;Apply(snapshot);return true
end
function HC.ImportAsNewProfile(name,text)
 if not Allowed() then return false,'combat' end
 local snapshot,reason=ImportSnapshot(text);if not snapshot then return false,reason end
 local ok,reason=HC.CheckNewProfileName(name);if not ok then return false,reason end
 HC.SaveActiveProfile()
 HC.db.profiles[name]=snapshot;HC.db.activeProfile=name
 HC.pendingProfileImport=nil;Apply(snapshot)
 return true
end

-- Bounded flat strings keep favourites compatible with the existing safe export.
function HC.FavoriteStyles() return Favorites(HC.db.favorites) or {} end
function HC.IsFavoriteStyle(key)
 for _,value in ipairs(HC.FavoriteStyles()) do if value==key then return true end end
 return false
end
function HC.ToggleFavoriteStyle(key)
 if not Allowed() then return false,'combat' end
 if not StyleKey(key) then return false,'value' end
 local items=HC.FavoriteStyles();local found=false
 for i=#items,1,-1 do if items[i]==key then table.remove(items,i);found=true end end
 if not found then
  if #items>=20 then return false,'favoriteLimit' end
  items[#items+1]=key
 end
 HC.db.favorites=table.concat(items,',');HC.SaveActiveProfile();Refresh();return true
end
function HC.ApplyAppearance(key)
 if not Allowed() then return false,'combat' end
 local family,element=StyleKey(key);if not family then return false,'value' end
 local snapshot=Snapshot(HC.db);snapshot.family=family;snapshot.element=element
 if HC.elements[element].faction then snapshot.faction=HC.elements[element].faction end
 Apply(snapshot);return true
end
local comfortPresets={
 quiet={quietMode=true,finishCue=false,timeFormat='remaining',iconPosition='hidden',latency=false,castDelay=false,queueWindow=false,channelTicks=false},
 readable={quietMode=false,finishCue=true,fontSize=16,font='modern',timeFormat='both',iconPosition='left'},
 simple={quietMode=false,finishCue=true,fontSize=12,font='default',timeFormat='remaining',iconPosition='hidden',latency=false,castDelay=false,queueWindow=false,channelTicks=false},
}
function HC.ApplyComfortPreset(key)
 if not Allowed() then return false,'combat' end
 local preset=comfortPresets[key];if not preset then return false,'value' end
 local snapshot=Snapshot(HC.db)
 for field,value in pairs(preset) do snapshot[field]=value end
 Apply(snapshot);return true
end
