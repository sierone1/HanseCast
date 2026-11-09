local _, HC = ...
local function L(t) return HC.L and HC.L(t) or t end
-- Duration objects go straight to the native widget. Never inspect their
-- methods, compare identities, format, or calculate with their payload.
function HC.CanUseUnitTimer(s)
    return s and s.timer and s.timerReady~=false and type(s.timer.SetTimerDuration)=='function'
        and type(issecretvalue)=='function' and type(UnitCastingDuration)=='function'
        and type(UnitChannelDuration)=='function' and Enum and Enum.StatusBarInterpolation
        and Enum.StatusBarTimerDirection
        and type(Enum.StatusBarInterpolation.Immediate)=='number'
        and type(Enum.StatusBarTimerDirection.ElapsedTime)=='number'
        and type(Enum.StatusBarTimerDirection.RemainingTime)=='number'
end
function HC.NativeUnitIdle(unit)
    if type(issecretvalue)~='function' then return false end
    for _,api in ipairs({UnitCastingDuration or false,UnitChannelDuration or false}) do
        if type(api)~='function' then return false end
        local ok,value=pcall(api,unit)
        if not ok or not HC.Accessible(value) or value~=nil then return false end
    end
    return true
end
function HC.ReadUnitTimer(s)
    if not HC.CanUseUnitTimer(s) then return nil,'timer-missing' end
    for _,channel in ipairs({false,true}) do
        local api=channel and UnitChannelDuration or UnitCastingDuration
        local ok,object=pcall(api,s.unit)
        if not ok then return nil,'timer-error' end
        local accessible=HC.Accessible(object)
        if not accessible or object~=nil then
            local direction=channel and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime
            local accepted=pcall(s.timer.SetTimerDuration,s.timer,object,Enum.StatusBarInterpolation.Immediate,direction)
            if not accepted then return nil,'timer-denied' end
            local c={native=true,channel=channel,name=L(channel and 'Kanalzauber' or 'Zauber'),icon=134400}
            local info=channel and UnitChannelInfo or UnitCastingInfo
            if type(info)=='function' then
                local read,name,_,icon,_,_,_,a7,a8=pcall(info,s.unit)
                if read then
                    if HC.Accessible(name) and type(name)=='string' then c.name=name end
                    if HC.Accessible(icon) and (type(icon)=='number' or type(icon)=='string') then c.icon=icon end
                    local blocked
                    if channel then blocked=a7 else blocked=a8 end
                    if HC.Accessible(blocked) and type(blocked)=='boolean' then c.interruptible=not blocked end
                end
            end
            return c,'timer-active'
        end
    end
    return nil,'timer-idle'
end

local reasons={active='aktiv',idle='kein Zauber',disabled='deaktiviert',visibility='außerhalb der gewählten Sichtbarkeit',
    absent='keine Einheit',restricted='Daten eingeschränkt',invalid='Zeitdaten ungültig',error='Abfragefehler',
    missing='Schnittstelle fehlt',unsupported='nicht unterstützt',ended='beendet',changed='Einheit gewechselt',
    ['material-unavailable']='Grafik nicht verfügbar',['timer-active']='nativer Timer aktiv',
    ['timer-idle']='kein Dauerobjekt',['timer-missing']='Timer-Schnittstelle fehlt',
    ['timer-error']='Dauerobjekt-Abfrage fehlgeschlagen',['timer-denied']='Timer-Übergabe abgelehnt'}
function HC.UnitReason(reason) return L(reasons[reason] or reason or 'unbekannt') end
function HC.PrintUnitStatus()
    HC.Print(L('Spieler')..': '..HC.UnitReason(HC.lastReason)..' | '..L('sichtbar')..': '..L(HC.frame:IsShown() and 'ja' or 'nein')..
        ' | '..L('geschützte Abfragen')..': '..HC.stats.restricted..' | '..L('API-Fehler')..': '..HC.stats.apiErrors)
    if HC.compact then
        HC.Print('Ziel & Fokus: kompakt | '..HC.compact.mode..' | '..HC.compact.style)
        HC.Print('Kompakt-Start: '..(HC.compactInitStatus or 'unknown')..' | Fehler: '..(HC.compactInitError and 'ja' or 'nein'))
        for _,row in ipairs(HC.compact.rows) do HC.Print(row.unit..': '..(row.reason or 'unknown')) end
        return
    end
    if HC.unitBarsInDevelopment then HC.Print(L('Ziel & Fokus: in Arbeit – deaktiviert'));return end
    for _,unit in ipairs({'target','focus'}) do
        local s=HC.unitBars and HC.unitBars[unit]
        if s then
            HC.Print(L(unit=='target' and 'Ziel' or 'Fokus')..': '..L(s.config.enabled and 'aktiviert' or 'deaktiviert')..
                ' | '..HC.UnitReason(s.reason)..' | '..L('sichtbar')..': '..L(s.frame:IsShown() and 'ja' or 'nein')..
                ' | '..L('letzte Abfrage')..': '..HC.UnitReason(s.readReason)..' | '..L('letzter Timerstatus')..': '..HC.UnitReason(s.timerReason))
            local scale=s.frame:GetEffectiveScale()
            HC.Print(L(unit=='target' and 'Ziel' or 'Fokus')..' | '..L('geschützte Abfragen')..': '..(s.restricted or 0)..
                ' | '..L('API-Fehler')..': '..(s.apiErrors or 0)..' | '..L('Darstellung')..': '..
                string.format('%.0f x %.0f px',s.config.width*scale,s.config.height*scale)..
                ' | '..L(s.cast and s.cast.native and 'schlichte Timerleiste' or 'gewählte Optik')..
                ' | '..L('Grafik')..': '..L(s.cast and s.cast.native and 'native Timertextur' or (HC.IsMaterialAvailable(s.effects) and 'verfügbar' or 'fehlt')))
        end
    end
end
