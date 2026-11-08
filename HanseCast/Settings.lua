local _,HC=...
-- Full native settings canvas with shared values; no launcher-only page.
function HC.RegisterSettings()
 if HC.settingsStatus=='registered' then return true end
 if not HC.db or not HC.CreateMenuCanvas or type(Settings)~='table'
  or type(Settings.RegisterCanvasLayoutCategory)~='function'
  or type(Settings.RegisterAddOnCategory)~='function' then HC.settingsStatus='unavailable';return false end
 local ok,result=pcall(function()
  if not HC.settingsCanvas then HC.settingsCanvas=HC.CreateMenuCanvas(UIParent,true) end
  if not HC.settingsCategory then HC.settingsCategory=Settings.RegisterCanvasLayoutCategory(HC.settingsCanvas,'Hanse Cast') end
  if not HC.settingsCategory then return false end
  Settings.RegisterAddOnCategory(HC.settingsCategory);return true
 end)
 HC.settingsStatus=ok and result and 'registered' or 'error';return HC.settingsStatus=='registered'
end
