local _,HC=...
-- Shared live/menu material compositor. No unit queries, timers, progress reads,
-- SetValue calls or animation driver. The native StatusBar owns fill geometry.
local root='Interface\\AddOns\\HanseCast\\Media\\Compact\\'
local styles={classic={file='Classic'},silk={file='SilkCore'},split={file='Facets'}}
function HC.LayoutCompactTime(row,config,mode)
 if not row.timeLabel then
  row.timeLabel=row.overlay:CreateFontString(nil,'OVERLAY')
  row.timeLabel:SetWordWrap(false);row.timeLabel:SetJustifyH('RIGHT')
  row.timeLabel:SetTextColor(1,1,1,1);row.timeLabel:SetShadowColor(0,0,0,1);row.timeLabel:SetShadowOffset(1,-1)
 end
 local text=row.timeLabel;local width=config.font*4+8
 text:SetFont('Fonts\\FRIZQT__.TTF',config.font,'');text:SetSize(width,config.height)
 text:ClearAllPoints()
 if mode=='outside' then text:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMRIGHT',6,0)
 else text:SetPoint('BOTTOMRIGHT',row.frame,'BOTTOMRIGHT',-6,0) end
 row.label:SetWidth(math.max(1,config.width-12-((mode=='inside' and (config.header or 0)==0) and width+4 or 0)))
 text:SetShown(mode~='off')
 if mode=='off' then text:SetText('') end
end
local function Safe(v)
 if type(issecretvalue)=='function' then local ok,s=pcall(issecretvalue,v);if not ok or s~=false then return false end end
 if type(canaccessvalue)=='function' then local ok,a=pcall(canaccessvalue,v);if not ok or a~=true then return false end end
 return true
end
local function Smooth(texture)
 if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(false) end
 if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0) end
end
local function Load(texture,method,path)
 local cache=texture.hcCompactLoad
 if cache and cache.path==path and cache.ok then return true end
 local ok,result=pcall(texture[method],texture,path)
 if method=='SetStatusBarTexture' and type(texture.GetStatusBarTexture)=='function' then
  local read,region=pcall(texture.GetStatusBarTexture,texture)
  if read and region then Smooth(region) end
 else Smooth(texture) end
 local rejected=not ok or (Safe(result) and result==false)
 -- A nil retry does not erase a known failure on the same resource.
 local success=not rejected and not (cache and cache.path==path and cache.ok==false and not (Safe(result) and result==true))
 texture.hcCompactLoad={path=path,ok=success};return success
end
local function Instance(row)
 if row.compactVisuals then return row.compactVisuals end
 local v={edges={}}
 -- ARTWORK on the overlay remains below its OVERLAY FontString.
 for i=1,8 do v.edges[i]=row.overlay:CreateTexture(nil,'ARTWORK');Smooth(v.edges[i]) end
 v.separator=row.overlay:CreateTexture(nil,'ARTWORK')
 Smooth(v.separator)
 row.compactVisuals=v;return v
end
function HC.ApplyCompactVisuals(row,config)
 local style=styles[config.style] or styles.classic
 local w,h,header=config.width,config.height,config.header or 0
 local color=config.color;local v=Instance(row)
 local scale=type(row.frame.GetEffectiveScale)=='function' and row.frame:GetEffectiveScale() or 1
 local small=type(scale)=='number' and w*scale<=512 and h*scale<=64
 local path=root..style.file..(small and '-small' or '')..'.tga'
 local key=path..':'..w..':'..h..':'..header..':'..color[1]..':'..color[2]..':'..color[3]
 -- Menu paint runs at 30 Hz for known synthetic values. Geometry/materials
 -- need no writes at that rate when preferences and texture tier are unchanged.
 if v.key==key and v.available then
  local unchanged=true
  for _,name in ipairs({'native','bar','preview'}) do
   local bar=row[name]
   if bar and (bar:GetWidth()~=w-4 or bar:GetHeight()~=h-4) then unchanged=false end
  end
  if unchanged then row.visualAvailable=true;return true end
 end
 local available=Load(row.background,'SetTexture',root..'Recess.tga')
 row.background:SetVertexColor(1,1,1,1)
 row.background:ClearAllPoints();row.background:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',0,0);row.background:SetSize(w,h);row.background:Show()
 local bars={}
 for _,key in ipairs({'native','bar','preview'}) do if row[key] then bars[#bars+1]={key,row[key]} end end
 for _,entry in ipairs(bars) do
  local key,bar=entry[1],entry[2]
  if not Load(bar,'SetStatusBarTexture',path) then available=false end
  bar:ClearAllPoints();bar:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',2,2);bar:SetSize(w-4,h-4)
  bar:SetStatusBarColor(color[1],color[2],color[3],1)
  local highlightKey=key..'Highlight';local highlight=row[highlightKey]
  if not highlight then
   highlight=CreateFrame('StatusBar',nil,row.frame);highlight:Hide();row[highlightKey]=highlight
   if key~='native' then highlight:SetMinMaxValues(0,1) end
  end
  highlight:SetFrameLevel(bar:GetFrameLevel()+1)
  row.overlay:SetFrameLevel(math.max(row.overlay:GetFrameLevel(),highlight:GetFrameLevel()+1))
  highlight:ClearAllPoints();highlight:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',2,2);highlight:SetSize(w-4,h-4)
  if not Load(highlight,'SetStatusBarTexture',root..style.file..'-light'..(small and '-small' or '')..'.tga') then available=false end
  highlight:SetStatusBarColor(1,1,1,1)
  -- The owner submits the identical opaque duration directly to nativeHighlight
  -- and sets only known synthetic values on previewHighlight/barHighlight.
 end
 -- Plain opaque black frame, two UI units thick, inside the existing bounds.
 -- Shared by all three designs and by live bars and menu previews.
 local geometry={{0,0,w,1},{0,h-1,w,1},
  {0,1,1,h-2},{w-1,1,1,h-2},
  {1,1,w-2,1},{1,h-2,w-2,1},
  {1,2,1,h-4},{w-2,2,1,h-4}}
 for i,g in ipairs(geometry) do
  local t=v.edges[i];t:ClearAllPoints();t:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',g[1],g[2]);t:SetSize(g[3],g[4]);t:SetColorTexture(0,0,0,1);t:Show()
 end
 v.separator:ClearAllPoints();v.separator:SetPoint('BOTTOMLEFT',row.frame,'BOTTOMLEFT',0,h+2);v.separator:SetSize(w,1);v.separator:SetColorTexture(0,0,0,1);v.separator:SetShown(header>0)
 for _,old in ipairs(row.borders or row.edges or {}) do old:Hide() end
 row.visualAvailable=available;v.style=config.style;v.path=path;v.key=key;v.available=available
 return available
end
