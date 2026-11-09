local _, HC = ...
local function L(text) return HC.L(text) end

-- Opt-in session trace. No event payload, names, GUIDs, spell IDs, profiles or
-- chat text enter this buffer. It never polls and is never saved to disk.
local capacity=80
local trace={enabled=false,entries={},next=1,count=0,total=0,started=0}
local allowedEvents={PLAYER_ENTERING_WORLD=true,PLAYER_REGEN_DISABLED=true,PLAYER_REGEN_ENABLED=true,
    UI_SCALE_CHANGED=true,DISPLAY_SIZE_CHANGED=true,UNIT_AURA=true,SPELL_UPDATE_COOLDOWN=true,
    SPELL_UPDATE_USABLE=true,UNIT_SPELLCAST_START=true,UNIT_SPELLCAST_DELAYED=true,
    UNIT_SPELLCAST_STOP=true,UNIT_SPELLCAST_CHANNEL_START=true,UNIT_SPELLCAST_CHANNEL_UPDATE=true,
    UNIT_SPELLCAST_CHANNEL_STOP=true,UNIT_SPELLCAST_FAILED=true,UNIT_SPELLCAST_FAILED_QUIET=true,
    UNIT_SPELLCAST_INTERRUPTED=true,UNIT_SPELLCAST_SUCCEEDED=true,UNIT_SPELLCAST_SENT=true}
local reasons={active=true,idle=true,disabled=true,visibility=true,absent=true,restricted=true,
    invalid=true,error=true,missing=true,unsupported=true,ended=true,changed=true,native=true}
local function Safe(value)
    return HC.Accessible(value)
end
local function Number(value,low,high)
    if Safe(value) and HC.ValidNumber(value,low or 0,high or 1000000000) then return value end
end
local function Count(value) return tostring(Number(value) or 0) end
local function Flag(value) return Safe(value) and value==true and 'on' or 'off' end
local function Reason(value)
    if Safe(value) and type(value)=='string' and reasons[value] then return value end
    return 'unknown'
end
local function Token(value)
    if Safe(value) and type(value)=='string' and #value<=48 and value:match('^[%w_.-]+$') then return value end
    return 'unknown'
end
local function Visible(frame)
    if not frame or type(frame.IsShown)~='function' then return 'off' end
    local ok,value=pcall(frame.IsShown,frame)
    return ok and Flag(value) or 'unknown'
end
function HC.IsDiagnosticTraceEnabled() return trace.enabled end
local function UpdateTraceControl()
    local f=HC.diagnosticWindow
    if f then HC.Localize(f.toggle,trace.enabled and 'Aufzeichnung stoppen' or 'Neue Aufzeichnung') end
end
function HC.SetDiagnosticTrace(enabled)
    trace.enabled=enabled==true
    if trace.enabled then
        trace.entries={};trace.next=1;trace.count=0;trace.total=0
        trace.started=Number(GetTime()) or 0
    end
    UpdateTraceControl()
end
function HC.ClearDiagnosticTrace()
    trace.enabled=false;trace.entries={};trace.next=1;trace.count=0;trace.total=0;trace.started=0
    UpdateTraceControl()
end
function HC.RecordDiagnosticEvent(event)
    if not trace.enabled or not Safe(event) or type(event)~='string' or not allowedEvents[event] then return end
    local now=Number(GetTime()) or trace.started
    trace.entries[trace.next]={time=math.max(0,now-trace.started),event=event,
        cast=Reason(HC.lastReason),gcd=Reason(HC.gcdReason),visible=Visible(HC.frame),
        preview=Flag(HC.preview),restricted=Number(HC.stats.restricted) or 0,errors=Number(HC.stats.apiErrors) or 0,
        gcdRestricted=Number(HC.gcdStats.restricted) or 0,gcdErrors=Number(HC.gcdStats.apiErrors) or 0,
        gcdDenied=Number(HC.gcdStats.nativeDenied) or 0,
        gcdAge=HC.gcdCheckedAt and math.max(0,now-HC.gcdCheckedAt) or 0}
    trace.next=trace.next%capacity+1
    trace.count=math.min(capacity,trace.count+1);trace.total=trace.total+1
end
function HC.BuildDiagnosticReport()
    local db=HC.db or {}
    local lines={'Hanse Cast '..Token(HC.version),L('Diagnosebericht'),
        L('Momentaufnahme; keine Namen, Zauberkennungen oder Profilnamen enthalten.')}
    local version,build,interface='unknown','unknown','unknown'
    if type(GetBuildInfo)=='function' then
        local ok,v,b,_,i=pcall(GetBuildInfo)
        if ok then version=Token(v);build=Token(b);interface=Count(i) end
    end
    lines[#lines+1]='Client: '..version..' / '..build..' / '..interface
    lines[#lines+1]='Player: '..Reason(HC.lastReason)..' | visible='..Visible(HC.frame)..' | preview='..Flag(HC.preview)
    lines[#lines+1]='GCD: '..Reason(HC.gcdReason)..' | enabled='..Flag(db.gcd)
    lines[#lines+1]='Player counters: restricted='..Count(HC.stats.restricted)..' | API errors='..Count(HC.stats.apiErrors)..
        ' | unregistered events='..Count(HC.stats.unknownEvents)
    local gs=HC.gcdStats
    lines[#lines+1]='GCD counters: reads='..Count(gs.reads)..' | restricted='..Count(gs.restricted)..' | API errors='..Count(gs.apiErrors)..
        ' | native submissions='..Count(gs.nativeSubmissions)..' | denied='..Count(gs.nativeDenied)
    lines[#lines+1]='GCD probes: '..HC.GetGCDPathDiagnostic()
    lines[#lines+1]='GCD cached-state age: '..(HC.gcdCheckedAt and string.format('%.3f s',math.max(0,GetTime()-HC.gcdCheckedAt)) or 'not-queried')
    lines[#lines+1]=L('GCD native: Timer übergeben; kein Nachweis einer aktuell laufenden GCD. Zähler zählen Abfragen, keine Zauber.')
    local textureErrors=0
    if HC.GetTextureFailureCount then local ok,n=pcall(HC.GetTextureFailureCount);if ok then textureErrors=Number(n) or 0 end end
    lines[#lines+1]='Textures: errors='..Count(textureErrors)
    lines[#lines+1]='Appearance: '..Token(db.family)..' / '..Token(db.element)..' | faction='..Token(db.faction)
    lines[#lines+1]='Layout: '..Count(db.width)..' x '..Count(db.height)..' | scale='..Count(db.scale)..
        ' | font='..Token(db.font)..' / '..Count(db.fontSize)..' | time='..Token(db.timeFormat)
    lines[#lines+1]='Comfort: quiet='..Flag(db.quietMode)..' | latency='..Flag(db.latency)..
        ' | start estimate='..Flag(db.castDelay)..' | queue='..Flag(db.queueWindow)..' | guides='..Flag(db.channelTicks)
    lines[#lines+1]='Blizzard: hide requested='..Flag(db.hideBlizzard)
    lines[#lines+1]='Target / focus: '..(HC.compact and ('compact / '..Token(HC.compact.mode)..' / '..Token(HC.compact.style)) or (HC.unitBarsInDevelopment and 'in development / disabled' or 'legacy test mode'))
    lines[#lines+1]='Compact initialization: '..Token(HC.compactInitStatus)..' | error='..Flag(HC.compactInitError)
    if HC.compact then
        local compact=HC.compact
        local hide=compact.hideBlizzard or {}
        local positions=compact.positions or {}
        local function Position(unit)
            local value=positions[unit]
            if not Safe(value) or type(value)~='table' then return 'automatic' end
            local x,y=Number(value.x,-100000,100000),Number(value.y,-100000,100000)
            if not x or not y then return 'automatic' end
            return string.format('%.1f / %.1f',x,y)
        end
        local function Status(value)
            if Safe(value) and type(value)=='string' and #value<=160 then return value end
            return 'unknown'
        end
        lines[#lines+1]='Compact positioning: '..(compact.positioning and Token(compact.positioning) or 'off')
        lines[#lines+1]='Compact time placement: '..Token(compact.timePlacement)
        for _,unit in ipairs({'target','focus'}) do
            local row=compact[unit]
            lines[#lines+1]='Compact '..unit..': '..Token(row and row.reason)..' | hide Blizzard requested='..Flag(hide[unit])..' | position='..Position(unit)
                ..' | time='..Token(row and row.timeReason)
                ..' | artwork='..(row and row.visualAvailable==false and 'failed' or (row and row.visualAvailable==true and 'available' or 'unknown'))
        end
        lines[#lines+1]='Blizzard target: '..Status(HC.blizzardTargetStatus)
        lines[#lines+1]='Blizzard focus: '..Status(HC.blizzardFocusStatus)
    end
    lines[#lines+1]='Trace: '..Flag(trace.enabled)..' | retained='..trace.count..'/'..capacity..' | events='..trace.total
    lines[#lines+1]=L('Aufzeichnung zeigt den Zustand vor dem jeweiligen Ereignis; kein Zeitmessungs-Benchmark.')
    for offset=0,trace.count-1 do
        local index=(trace.next-trace.count+offset-1)%capacity+1
        local e=trace.entries[index]
        lines[#lines+1]=string.format('+%.3f %s | player=%s gcd=%s visible=%s preview=%s playerRestricted=%d playerErrors=%d gcdRestricted=%d gcdErrors=%d gcdDenied=%d gcdAge=%.3f',
            e.time,e.event,e.cast,e.gcd,e.visible,e.preview,e.restricted,e.errors,e.gcdRestricted,e.gcdErrors,e.gcdDenied,e.gcdAge)
    end
    return table.concat(lines,'\n')
end

local function RefreshReport()
    local f=HC.diagnosticWindow
    if not f then return end
    local report=HC.BuildDiagnosticReport()
    local _,lineCount=report:gsub('\n','\n')
    -- Reserve room for wrapping so long recordings remain scrollable even on
    -- clients that do not automatically enlarge a multiline edit box.
    f.edit:SetHeight(math.max(300,(lineCount+1)*44))
    f.edit:SetText(report)
    f.scroll:SetVerticalScroll(0)
    UpdateTraceControl()
end
local function CreateReportWindow()
    local f=CreateFrame('Frame','HanseCastDiagnosticWindow',UIParent,'BackdropTemplate')
    HC.diagnosticWindow=f
    f:SetSize(680,470);f:SetPoint('CENTER');f:SetFrameStrata('DIALOG');f:SetClampedToScreen(true)
    f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
    f:SetBackdropColor(0.035,0.045,0.06,0.98);f:SetBackdropBorderColor(0.5,0.42,0.25,1)
    local title=f:CreateFontString(nil,'OVERLAY','GameFontNormalLarge')
    title:SetPoint('TOPLEFT',18,-16);HC.Localize(title,'Diagnosebericht')
    local hint=f:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    hint:SetPoint('TOPLEFT',18,-45);hint:SetWidth(640);hint:SetJustifyH('LEFT')
    HC.Localize(hint,'Text anklicken, Strg+A und Strg+C zum Kopieren. Aufzeichnung bleibt nur bis /reload erhalten.')
    local scroll=CreateFrame('ScrollFrame',nil,f,'UIPanelScrollFrameTemplate')
    scroll:SetPoint('TOPLEFT',18,-80);scroll:SetPoint('BOTTOMRIGHT',-38,62);f.scroll=scroll
    local edit=CreateFrame('EditBox',nil,scroll)
    edit:SetMultiLine(true);edit:SetAutoFocus(false);edit:SetFontObject('GameFontHighlightSmall')
    edit:SetWidth(610);edit:SetHeight(300);edit:SetMaxLetters(40000)
    edit:SetScript('OnEscapePressed',function() f:Hide() end)
    -- Report text may be selected and copied; edits never alter settings or trace.
    scroll:SetScrollChild(edit);f.edit=edit
    local function Button(label,x,width,callback)
        local b=CreateFrame('Button',nil,f,'UIPanelButtonTemplate')
        b:SetSize(width,26);b:SetPoint('BOTTOMLEFT',x,18);HC.Localize(b,label);b:SetScript('OnClick',callback)
        return b
    end
    f.toggle=Button('Neue Aufzeichnung',18,180,function() HC.SetDiagnosticTrace(not trace.enabled);RefreshReport() end)
    Button('Aktualisieren',208,125,RefreshReport)
    Button('Leeren',343,115,function() HC.ClearDiagnosticTrace();RefreshReport() end)
    Button('Schließen',468,170,function() f:Hide() end)
    f:SetScript('OnHide',function() edit:ClearFocus() end)
    if type(UISpecialFrames)=='table' then UISpecialFrames[#UISpecialFrames+1]='HanseCastDiagnosticWindow' end
    return f
end
function HC.ShowDiagnosticReport()
    if InCombatLockdown() then HC.Print(L('Diagnosebericht nur außerhalb des Kampfes öffnen.'));return end
    local f=HC.diagnosticWindow or CreateReportWindow()
    RefreshReport();f:Show()
end
function HC.HideDiagnosticReport()
    if HC.diagnosticWindow then HC.diagnosticWindow:Hide() end
end
