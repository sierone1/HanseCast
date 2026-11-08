local addonName, HC = ...
local function L(text) return HC.L and HC.L(text) or text end
local events = CreateFrame("Frame")
-- Independent driver: instant-cast GCD must keep updating with the cast frame hidden.
local driver = CreateFrame("Frame")
local terminal = {
    UNIT_SPELLCAST_STOP=true, UNIT_SPELLCAST_CHANNEL_STOP=true,
    UNIT_SPELLCAST_FAILED=true, UNIT_SPELLCAST_FAILED_QUIET=true,
    UNIT_SPELLCAST_INTERRUPTED=true,
}
local unitEvents = {
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_SUCCEEDED",
}
function HC.Print(message) print("|cffc7a66aHanse Cast:|r " .. message) end
local function Wake()
    driver:SetScript("OnUpdate", HC.Tick)
    driver:Show()
end
-- Display changes can alter physical pixels without changing saved bar size.
-- Coalesce the pair of display events and select the matching texture tier.
local displayRefreshQueued=false
local displayRefreshPending=false
local timingRefreshQueued=false
local gcdRefreshQueued=false
local function QueueGCDRefresh(immediate)
    if gcdRefreshQueued then return end
    gcdRefreshQueued=true
    if immediate then HC.RefreshGCD() end
    C_Timer.After(0,function()
        gcdRefreshQueued=false
        HC.RefreshGCD()
    end)
end
local function QueueTimingRefresh()
    if not HC.cast or HC.preview or timingRefreshQueued then return end
    timingRefreshQueued=true
    C_Timer.After(0,function()
        timingRefreshQueued=false
        if HC.ready and HC.cast and not HC.preview then HC.Refresh("UNIT_AURA") end
    end)
end
local function QueueDisplayRefresh()
    displayRefreshPending=true
    if displayRefreshQueued or InCombatLockdown() then return end
    displayRefreshQueued=true
    C_Timer.After(0,function()
        displayRefreshQueued=false
        if not HC.ready or InCombatLockdown() then return end
        displayRefreshPending=false
        HC.LayoutEffects(HC.db.width,HC.db.height)
        HC.effectsLastDraw=nil
        if HC.preview or HC.cast then Wake() end
    end)
end
function HC.Tick()
    local now = GetTime()
    if HC.preview then
        if HC.previewMode=="feedback" then HC.DrawFeedbackPreview(now);return end
        local cycle = (now - (HC.previewStart or now)) % (HC.db.gcd and 9 or 6)
        if HC.dragging then cycle=1 end
        local phase = math.floor(cycle / 3)
        local start = now - cycle % 3
        if phase < 2 then
            local previewName=L(HC.elements[HC.db.element].title)
            HC.previewCast=HC.previewCast or {}
            local sample=HC.previewCast
            sample.name=phase == 0 and (L("Vorschau · ")..previewName) or L("Vorschau · Kanalzauber")
            sample.start=start;sample.finish=start+3;sample.channel=phase==1
            HC.Draw(sample, now)
        else HC.frame:Hide() end
        local gcdStart = phase == 2 and (now - cycle % 1.5) or start
        HC.previewGCD=HC.previewGCD or {}
        HC.previewGCD.start=gcdStart;HC.previewGCD.finish=gcdStart+1.5
        HC.DrawGCD(HC.previewGCD,now)
        return
    end
    if HC.cast and now >= HC.cast.finish then
        local expired=HC.cast
        -- A delay event may be a frame late. Read the current client finish
        -- before treating the cached duration as an ended cast.
        HC.Refresh()
        if not HC.cast then HC.RememberTerminal(expired,now,false) end
    end
    if HC.cast then HC.Draw(HC.cast, now)
    elseif HC.resultUntil and now<HC.resultUntil then
        HC.UpdateCastResult(now)
    else
        HC.ClearCastResult()
        HC.UpdateSpellTheme(nil)
        HC.HideEffects();HC.frame:Hide()
    end
    if HC.gcd and now >= HC.gcd.finish then HC.gcd=nil; HC.gcdReason="idle" end
    HC.DrawGCD(HC.gcd,now)
    if not HC.cast and not HC.gcd and not HC.resultUntil then driver:SetScript("OnUpdate",nil) end
end
function HC.RefreshGCD()
    if not HC.ready or HC.preview then return end
    if HC.db.gcd then HC.gcd,HC.gcdReason=HC.ReadGCD()
    else HC.gcd=nil; HC.gcdReason="disabled" end
    HC.DrawGCD(HC.gcd,GetTime())
    if HC.gcd then Wake() end
end
function HC.Refresh(event)
    if not HC.ready or HC.preview then return end
    local cast, reason=HC.ReadCurrent()
    if HC.IsTerminated(cast,GetTime()) then cast=nil;reason="ended" end
    HC.lastReason=reason
    if reason == "restricted" then HC.stats.restricted=HC.stats.restricted+1 end
    if reason == "error" then HC.stats.apiErrors=HC.stats.apiErrors+1 end
    local previous=HC.cast
    HC.TrackCastTiming(previous,cast,event,GetTime())
    -- The unit query may turn idle before its terminal event is dispatched
    -- (for example an interrupt aura update). Retain identity briefly, without
    -- treating missing/restricted/error data as proof that the cast ended.
    if previous and not cast and reason=="idle" then
        HC.RememberTerminal(previous,GetTime(),false)
    end
    HC.cast=cast
    if cast then
        -- A newer accepted cast owns subsequent presentation, even if its
        -- data later becomes unavailable. Retire older delayed feedback only;
        -- terminal identities remain available to reject stale API records.
        if HC.lastEnded and not HC.Matches(cast,HC.lastEnded.id) then HC.lastEnded=nil end
        HC.ClearCastResult()
        if not previous or not HC.Matches(previous,cast.id) then HC.HideFinishCue() end
        HC.Draw(cast,GetTime())
    elseif not HC.resultUntil then HC.UpdateSpellTheme(nil);HC.HideEffects();HC.frame:Hide() end
    HC.UpdateBlizzard()
    HC.RefreshGCD()
    if cast or HC.gcd or HC.resultUntil then Wake() else driver:SetScript("OnUpdate",nil) end
end
function HC.TogglePreview(mode)
    if InCombatLockdown() then HC.Print(HC.L("Vorschau nur außerhalb des Kampfes.")); return end
    if HC.preview and mode~=nil and HC.previewMode~=mode then HC.preview=false end
    HC.preview=not HC.preview
    HC.previewMode=HC.preview and mode or nil
    HC.feedbackPreviewKey=nil
    HC.cast=nil; HC.gcd=nil; HC.ClearCastResult(); HC.lastEnded=nil; HC.CancelPreviewDrag()
    HC.UpdateSpellTheme(nil)
    HC.HideFinishCue()
    HC.UpdateBlizzard()
    if HC.preview then HC.previewStart=GetTime(); Wake(); HC.Tick()
    else HC.frame:EnableMouse(false); HC.frame.hint:Hide(); HC.Refresh() end
    if HC.UpdateOptions then HC.UpdateOptions() end
end
local function Status()
    local version, build, _, interface=GetBuildInfo()
    HC.Print("Version "..HC.version.." | Client "..version.." / "..build.." / "..interface)
    HC.Print(L("Spieler").." | "..L("Zauber: ")..(HC.lastReason or L("unbekannt")).." | GCD: "..(HC.gcdReason or L("unbekannt"))..
        L(" | geschützt: ")..HC.stats.restricted..L(" | API-Fehler: ")..HC.stats.apiErrors..
        L(" | fehlende Events: ")..HC.stats.unknownEvents)
    HC.Print(L("Optik: ")..HC.db.family.." / "..HC.db.element.." / "..HC.db.identity.." | Blizzard: "..L(HC.blizzardStatus or "unverändert"))
    HC.Print(L("Ausführung: ")..HC.db.faction..L(" | Wappenstatus: ")..(HC.factionIconStatus or "none"))
    local visual,visualReason=HC.ResolveSpellVisual(HC.themeCast)
    HC.Print(L("Zauberoptik: ")..L(HC.db.autoSpellVisual and "automatisch" or "manuell").." | Material: "..visual..L(" | Auswahl: ")..visualReason)
    local scale=HC.frame:GetEffectiveScale()
    local e=HC.effects
    local detail=e.staticMaterial and (e.mageFireCompact and "Starr / kompakt" or "Starr / hoch")
        or HC.db.element=="arcane" and (e.arcaneCompact and "Arkan kompakt" or "Arkan normal")
        or (e.softLow and "weich / niedrig" or (e.softLOD and "weich" or "normal"))
    HC.Print(string.format(L("Darstellung: %d x %d UI | %.1f x %.1f Pixel | Faktor %.3f | %s"),
        HC.db.width,HC.db.height,HC.db.width*scale,HC.db.height*scale,scale,L(detail)))
    if HC.GetTextureFailureCount then
        local failures=HC.GetTextureFailureCount()
        HC.Print(L("Texturen: ")..failures..L(" gemeldete Ladefehler")..(failures>0 and L(" | WoW vollständig neu starten.") or ""))
    end
    HC.Print(L("GCD-Prüfung: ")..HC.GetGCDDiagnostic())
    HC.Print(L("Addon-Einstellungsmenü: ")..(HC.settingsStatus or L("unbekannt")))
    if HC.PrintUnitStatus then HC.PrintUnitStatus() end
    HC.Print(L("Blizzard-Ziel: ")..L(HC.blizzardTargetStatus or "unverändert"))
    HC.Print(L("Blizzard-Fokus: ")..L(HC.blizzardFocusStatus or "unverändert"))
    HC.Print("Position "..math.floor(HC.db.x)..", "..math.floor(HC.db.y)..
        L(" | gespeicherte Starts: ")..(HC.db.launches or 1)..L(" (inkl. /reload)"))
    local quartz=C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Quartz")
    if quartz then HC.Print(L("Quartz ist aktiv. Für den Einzeltest bitte vorübergehend deaktivieren.")) end
end
local function Start()
    if HC.ready then return end
    HC.db=HC.LoadSettings(HanseCastDB)
    HC.db.launches=(HC.db.launches or 0)+1
    HanseCastDB=HC.db
    HC.CreateView(); HC.ready=true
    if HC.InitializeUnitBars then HC.InitializeUnitBars() end
    HC.RegisterSettings()
    for _,event in ipairs(unitEvents) do HC.Register(events,event,"player") end
    for _,event in ipairs(HC.gcdEvents or {"SPELL_UPDATE_COOLDOWN"}) do HC.Register(events,event) end
    HC.Register(events,"PLAYER_ENTERING_WORLD")
    HC.Register(events,"PLAYER_LOGOUT")
    HC.Register(events,"PLAYER_REGEN_DISABLED")
    HC.Register(events,"PLAYER_REGEN_ENABLED")
    HC.Register(events,"UI_SCALE_CHANGED")
    HC.Register(events,"DISPLAY_SIZE_CHANGED")
    HC.Register(events,"UNIT_AURA","player")
    SLASH_HANSECAST1="/hansecast"
    SlashCmdList.HANSECAST=function(input)
        local command=input:lower():match("^%s*(%S*)")
        if command=="status" then Status()
        elseif command=="diagnose" then
            HC.Print("Version "..HC.version)
            HC.PrintUnitStatus()
            HC.Print(L("Blizzard-Ziel: ")..L(HC.blizzardTargetStatus or "unverändert"))
            HC.Print(L("Blizzard-Fokus: ")..L(HC.blizzardFocusStatus or "unverändert"))
        elseif command=="test" then HC.TogglePreview()
        elseif command=="demo" then HC.TogglePreview("feedback")
        elseif command=="units" and HC.PreviewUnitBars then
            if HC.unitBarsInDevelopment then HC.Print(L("Ziel & Fokus: in Arbeit – deaktiviert"))
            else HC.PreviewUnitBars(not HC.unitBarsPreview) end
        else HC.ToggleOptions() end
    end
    HC.Print(HC.version..HC.L(" geladen. /hansecast öffnet die Einstellungen."))
    HC.Refresh()
end
events:SetScript("OnEvent",function(_, event, ...)
    if event=="ADDON_LOADED" then
        local name=...
        if name==addonName then
            HC.Register(events,"PLAYER_LOGIN")
            if IsLoggedIn() then Start() end
        elseif HC.ready then HC.UpdateBlizzard(); if HC.UpdateBlizzardFocus then HC.UpdateBlizzardFocus() end
        if HC.UpdateBlizzardTarget then HC.UpdateBlizzardTarget() end; HC.RegisterSettings() end
        return
    end
    if event=="PLAYER_LOGIN" then Start(); return end
    if not HC.ready then return end
    if event=="PLAYER_LOGOUT" then
        if HC.SaveActiveProfile then HC.SaveActiveProfile() end
        return
    end
    if event=="UI_SCALE_CHANGED" or event=="DISPLAY_SIZE_CHANGED" then
        QueueDisplayRefresh(); return
    end
    if event=="UNIT_AURA" then
        -- No aura payloads, IDs or multipliers are read. Reconcile only the
        -- already active cast's authoritative time after aura updates settle.
        QueueTimingRefresh(); return
    end
    for _,gcdEvent in ipairs(HC.gcdEvents or {"SPELL_UPDATE_COOLDOWN"}) do
        if event==gcdEvent then
            QueueGCDRefresh(true)
            return
        end
    end
    if event=="PLAYER_REGEN_DISABLED" then
        if HC.preview then HC.ClearCastResult() end
        HC.preview=false; HC.previewMode=nil; HC.CancelPreviewDrag(); HC.frame:EnableMouse(false)
        HC.frame.hint:Hide(); HC.HideFinishCue()
        if HC.options then HC.options:Hide() end
        if HC.advanced then HC.advanced:Hide() end
        HC.Refresh(); return
    end
    if event=="PLAYER_REGEN_ENABLED" then
        if displayRefreshPending then QueueDisplayRefresh() end
        HC.Refresh(); return
    end
    if event=="PLAYER_ENTERING_WORLD" then
        HC.ClearCastResult(); HC.lastEnded=nil; HC.terminalCast=nil; HC.terminalCasts=nil; HC.Refresh(); return
    end
    -- Registered for player only. Never inspect unit/castGUID/spellID payloads.
    if HC.preview then
        HC.preview=false; HC.previewMode=nil; HC.CancelPreviewDrag(); HC.frame:EnableMouse(false); HC.frame.hint:Hide()
        HC.ClearCastResult();HC.HideEffects();HC.frame:Hide()
        if HC.UpdateOptions then HC.UpdateOptions() end
    end
    local id
    if event=="UNIT_SPELLCAST_CHANNEL_STOP" or event=="UNIT_SPELLCAST_INTERRUPTED" then
        id=select(5,...)
    else id=select(4,...) end
    if not HC.Accessible(id) then id=nil end
    if event=="UNIT_SPELLCAST_SUCCEEDED" then
        local completed=HC.cast
        if not HC.Matches(completed,id) then
            completed=not HC.cast and HC.lastEnded or nil
            if completed and GetTime()>completed.untilTime then completed=nil end
        end
        if HC.Matches(completed,id) and not completed.channel and not completed.succeeded then
            completed.succeeded=true
            HC.RememberTerminal(completed,GetTime())
            HC.cast=nil
            HC.ClearCastResult()
            HC.HideEffects();HC.frame:Hide();HC.UpdateBlizzard()
            HC.UpdateSpellTheme(completed)
            HC.ShowFinishCue()
            HC.lastEnded=nil
        end
        HC.RefreshGCD(); C_Timer.After(0,HC.Refresh)
    elseif terminal[event] then
        local ended=HC.Matches(HC.cast,id) and HC.cast
            or (not HC.cast and HC.Matches(HC.lastEnded,id) and GetTime()<=HC.lastEnded.untilTime and HC.lastEnded)
        if ended then
            local record=HC.RememberTerminal(ended,GetTime())
            HC.cast=nil
            if event=="UNIT_SPELLCAST_INTERRUPTED" or event=="UNIT_SPELLCAST_FAILED" then
                HC.lastEnded=nil
                HC.ShowCastResult(event=="UNIT_SPELLCAST_INTERRUPTED" and "interrupted" or "failed",ended,GetTime())
                Wake()
            else
                HC.HideEffects();HC.frame:Hide()
                -- Allow a successful completion event to settle before labeling
                -- an early STOP. Never infer a successful cast from elapsed time.
                if event~="UNIT_SPELLCAST_FAILED_QUIET" and not record.succeeded and record.finish-GetTime()>0.08 then
                    C_Timer.After(0.08,function()
                        if not HC.cast and HC.lastEnded==record and not record.succeeded and not HC.preview
                            and GetTime()<=record.untilTime then
                            HC.ShowCastResult("cancelled",record,GetTime());Wake()
                        end
                    end)
                end
                if event=="UNIT_SPELLCAST_FAILED_QUIET" then HC.lastEnded=nil end
            end
            HC.UpdateBlizzard()
        end
        C_Timer.After(0,HC.Refresh)
    else
        HC.Refresh(event); QueueGCDRefresh(false)
    end
end)
HC.Register(events,"ADDON_LOADED")
