local _, HC = ...
local Localize=function(region,key) if HC.Localize then HC.Localize(region,key) else region:SetText(key) end end

-- Verified against Forever 1.60.1 (70862), Blizzard_Settings_Shared:
-- Blizzard_Settings.lua / Blizzard_ImplementationReadme.lua, revision
-- 9dc84f0d3bbae1768ac3405b3716000bd93eda06.
-- This is a launcher canvas, not a second set of options or a reparented UI.
local function Register()
    if not HC.settingsCanvas then
        local canvas=CreateFrame("Frame","HanseCastSettingsCanvas",UIParent)
        canvas:Hide()
        HC.settingsCanvas=canvas
        local title=canvas:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
        title:SetPoint("TOPLEFT",16,-16);title:SetText("Hanse Cast")
        local description=canvas:CreateFontString(nil,"OVERLAY","GameFontHighlight")
        description:SetPoint("TOPLEFT",16,-50);description:SetPoint("TOPRIGHT",-16,-50)
        description:SetJustifyH("LEFT");description:SetWordWrap(true)
        Localize(description,"Rahmenlose Zauberleisten, Materialien und Komfortoptionen. Alle Einstellungen öffnen sich in einem kompakten Fenster.")
        local open=CreateFrame("Button",nil,canvas,"UIPanelButtonTemplate")
        open:SetSize(220,30);open:SetPoint("TOPLEFT",16,-112)
        Localize(open,"Hanse Cast öffnen")
        open:SetScript("OnClick",function()
            if InCombatLockdown() then HC.OpenOptions();return end
            HC.OpenOptions()
            -- Let the compact window and live preview be visible rather than
            -- placing them behind the large native Settings panel.
            if HC.options and HC.options:IsShown() and SettingsPanel and type(HideUIPanel)=="function" then
                HideUIPanel(SettingsPanel)
            end
        end)
        canvas.openButton=open
        local hint=canvas:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT",16,-158);hint:SetPoint("TOPRIGHT",-16,-158)
        hint:SetJustifyH("LEFT");hint:SetWordWrap(true)
        Localize(hint,"Alternativ: /hansecast im Chat.\nDie Einstellungen sind außerhalb des Kampfes verfügbar.")
    end
    if not HC.settingsCategory then
        local category=Settings.RegisterCanvasLayoutCategory(HC.settingsCanvas,"Hanse Cast")
        if not category then return false end
        HC.settingsCategory=category
    end
    Settings.RegisterAddOnCategory(HC.settingsCategory)
    return true
end

function HC.RegisterSettings()
    if HC.settingsStatus=="registered" then return true end
    if type(Settings)~="table" or type(Settings.RegisterCanvasLayoutCategory)~="function"
        or type(Settings.RegisterAddOnCategory)~="function" then
        HC.settingsStatus="unavailable"
        return false
    end
    local ok,registered=pcall(Register)
    if ok and registered then HC.settingsStatus="registered";return true end
    HC.settingsStatus="error"
    return false
end
