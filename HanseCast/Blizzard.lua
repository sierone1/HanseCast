local _, HC = ...

-- Do not modify Blizzard's showCastbar, event registrations, scripts or cast data.
-- Its own state machine continues to run while its pixels are suppressed.
local attached, suppressing, writing = nil, false, false
local cleanupPending = false
local nativeAlpha = 1
HC.blizzardStatus = "unverändert"

local function Accessible(value)
    return HC.Accessible and HC.Accessible(value)
end

local function Writable(frame)
    if not frame or type(frame.IsProtected) ~= "function" then return false end
    local ok, protected = pcall(frame.IsProtected, frame)
    return ok and Accessible(protected) and protected == false
end

local function WriteAlpha(frame, alpha)
    if not Writable(frame) or type(frame.SetAlpha) ~= "function" then return false end
    writing = true
    local ok = pcall(frame.SetAlpha, frame, alpha)
    writing = false
    return ok
end

local function Restore()
    if not suppressing then return true end
    -- Release ownership before writing: our post-hook must not undo restoration.
    suppressing = false
    if WriteAlpha(attached, nativeAlpha) then return true end
    -- Retry on a later refresh if another addon has changed protection meanwhile.
    suppressing = true
    return false
end

local function HideCompleted()
    -- Our zero alpha can prevent Blizzard's PlayFadeAnim from starting. Its
    -- OnFinished then never calls Hide. Complete only the visibility cleanup,
    -- after our unit query reports idle or a confirmed matching terminal event
    -- rejects its stale record; do not inspect native
    -- cast flags/GUIDs or interfere with an inaccessible active cast.
    if not cleanupPending or HC.cast ~= nil or (HC.lastReason ~= "idle" and HC.lastReason ~= "ended") then return true end
    if not Writable(attached) or type(attached.Hide) ~= "function" then return false end
    local ok = pcall(attached.Hide, attached)
    if ok then cleanupPending=false end
    return ok
end

local function Attach(frame)
    if attached == frame then return true end
    if attached or type(hooksecurefunc) ~= "function" or not Writable(frame) then return false end
    if type(frame.SetAlpha) ~= "function" or type(frame.GetAlpha) ~= "function" then return false end
    local ok = pcall(hooksecurefunc, frame, "SetAlpha", function(_, alpha)
        if writing or not suppressing then return end
        -- Alpha may itself be secret. Never branch on it before checking access.
        if Accessible(alpha) and HC.ValidNumber(alpha, 0, 1) then nativeAlpha = alpha end
        if not WriteAlpha(frame, 0) then HC.blizzardStatus = "Wiederherstellung ausstehend" end
    end)
    if not ok then return false end
    attached = frame
    return true
end

function HC.UpdateBlizzard()
    local materialAvailable=not HC.IsMaterialAvailable or HC.IsMaterialAvailable()
    local want = HC.db and HC.db.hideBlizzard == true and HC.cast ~= nil
        and HC.lastReason == "active" and not HC.preview and materialAvailable
    local frame = PlayerCastingBarFrame
    if not want then
        if suppressing and HC.cast == nil and HC.lastReason == "active" and not HC.preview
            and HC.db and HC.db.hideBlizzard then
            -- STOP may arrive before the native handler clears its own cast.
            -- Keep suppression until the controller's next-frame query.
            HC.blizzardStatus = "Zauberende wird abgeglichen"
            return
        end
        if not HideCompleted() then
            HC.blizzardStatus = "Wiederherstellung ausstehend"
            return
        end
        local restored = Restore()
        if not restored then HC.blizzardStatus = "Wiederherstellung ausstehend"
        elseif HC.db and HC.db.hideBlizzard and not materialAvailable then HC.blizzardStatus = "Grafikfehler: Standard nicht ausgeblendet"
        elseif HC.db and HC.db.hideBlizzard then HC.blizzardStatus = "Standard als Rückfall verfügbar"
        else HC.blizzardStatus = "unverändert" end
        return
    end
    if not frame or not Attach(frame) or not Writable(frame) then
        local restored = Restore()
        HC.blizzardStatus = restored and "Standard bleibt: Frame nicht sicher veränderbar"
            or "Wiederherstellung ausstehend"
        return
    end
    if not suppressing then
        local ok, alpha = pcall(frame.GetAlpha, frame)
        nativeAlpha = 1
        if ok and Accessible(alpha) and HC.ValidNumber(alpha, 0, 1) then nativeAlpha = alpha end
        suppressing = true
        cleanupPending = true
    end
    if WriteAlpha(frame, 0) then
        HC.blizzardStatus = "Standard bei aktivem Hanse-Zauber ausgeblendet"
    else
        local restored = Restore()
        HC.blizzardStatus = restored and "Standard bleibt: Änderung nicht möglich"
            or "Wiederherstellung ausstehend"
    end
end

function HC.RestoreBlizzard()
    local restored = Restore()
    HC.blizzardStatus = restored and "unverändert" or "Wiederherstellung ausstehend"
end

-- Focus owns a separate adapter. Never touch FocusFrame itself, target frames,
-- native event registrations, cast records or showCastbar.
local focusAttached, focusSuppressing, focusWriting
local focusAlpha=1
local focusCleanup=false
local focusCastID
local function FocusWrite(alpha)
    if not Writable(focusAttached) then return false end
    focusWriting=true
    local ok=pcall(focusAttached.SetAlpha,focusAttached,alpha)
    focusWriting=false
    return ok
end
local function FocusRestore(s)
    if not focusSuppressing then return true end
    if not Writable(focusAttached) then return false end
    -- Alpha zero can skip Blizzard's fade/OnFinished. Clean up only after a
    -- fresh readable query proves idle, or the same confirmed-ended cast.
    if focusCleanup and HC.ReadCurrent then
        local current,reason=HC.ReadCurrent('focus')
        local ended=s and s.reason=='ended' and current and current.id~=nil
            and focusCastID~=nil and current.id==focusCastID
        if ((reason~='active' and HC.NativeUnitIdle('focus')) or (reason=='idle' and type(UnitCastingDuration)~='function' and type(UnitChannelDuration)~='function')) or ended then
            if type(focusAttached.Hide)~='function' or not pcall(focusAttached.Hide,focusAttached) then return false end
        end
    end
    focusSuppressing=false
    if not FocusWrite(focusAlpha) then focusSuppressing=true;return false end
    focusCleanup=false;focusCastID=nil
    return true
end
local function FocusAttach(frame)
    if focusAttached==frame then return true end
    if focusAttached or not Writable(frame) or type(hooksecurefunc)~='function'
        or type(frame.SetAlpha)~='function' or type(frame.GetAlpha)~='function' then return false end
    local ok=pcall(hooksecurefunc,frame,'SetAlpha',function(_,alpha)
        if focusWriting or not focusSuppressing then return end
        if Accessible(alpha) and HC.ValidNumber(alpha,0,1) then focusAlpha=alpha end
        if not FocusWrite(0) then HC.blizzardFocusStatus='Fokus: Wiederherstellung ausstehend' end
    end)
    if not ok then return false end
    focusAttached=frame
    return true
end
function HC.UpdateBlizzardFocus()
    if HC.unitBarsInDevelopment then HC.blizzardFocusStatus='In Arbeit – deaktiviert';return end
    local s=HC.unitBars and HC.unitBars.focus
    local want=HC.db and HC.db.hideBlizzardFocus==true and s and s.config.enabled
        and not HC.unitBarsPreview and s.cast~=nil and s.reason=='active' and s.frame:IsShown()
        and (s.cast.native or not HC.IsMaterialAvailable or HC.IsMaterialAvailable(s.effects))
    if not want then
        HC.blizzardFocusStatus=FocusRestore(s) and 'Fokus: Standard als Rückfall verfügbar'
            or 'Fokus: Wiederherstellung ausstehend'
        return
    end
    local frame=FocusFrameSpellBar
    if not frame and FocusFrame then frame=FocusFrame.spellbar end
    if not frame or not FocusAttach(frame) or not Writable(frame) then
        HC.blizzardFocusStatus=FocusRestore(s) and 'Fokus: Standard bleibt, Frame nicht sicher veränderbar'
            or 'Fokus: Wiederherstellung ausstehend'
        return
    end
    if not focusSuppressing then
        local ok,alpha=pcall(frame.GetAlpha,frame)
        focusAlpha=1
        if ok and Accessible(alpha) and HC.ValidNumber(alpha,0,1) then focusAlpha=alpha end
        focusSuppressing=true;focusCleanup=true
    end
    focusCastID=s.cast.id
    -- Only first acquisition writes; native SetAlpha changes are post-hooked.
    -- Repeated calls during drawing remain cheap and keep fallback checks live.
    if not focusWriting then
        local ok,alpha=pcall(frame.GetAlpha,frame)
        if ok and Accessible(alpha) and alpha==0 then
            HC.blizzardFocusStatus='Fokus durch Hanse ersetzt';return
        end
    end
    if FocusWrite(0) then HC.blizzardFocusStatus='Fokus durch Hanse ersetzt'
    else
        HC.blizzardFocusStatus=FocusRestore(s) and 'Fokus: Standard als Rückfall verfügbar'
            or 'Fokus: Wiederherstellung ausstehend'
    end
end

-- Target owns a separate adapter. Never touch TargetFrame itself or nameplates,
-- native event registrations, cast records or showCastbar.
local targetAttached, targetSuppressing, targetWriting
local targetAlpha=1
local targetCleanup=false
local targetCastID
local function TargetWrite(alpha)
    if not Writable(targetAttached) then return false end
    targetWriting=true
    local ok=pcall(targetAttached.SetAlpha,targetAttached,alpha)
    targetWriting=false
    return ok
end
local function TargetRestore(s)
    if not targetSuppressing then return true end
    if not Writable(targetAttached) then return false end
    -- Alpha zero can skip Blizzard's fade/OnFinished. Clean up only after a
    -- fresh readable query proves idle, or the same confirmed-ended cast.
    if targetCleanup and HC.ReadCurrent then
        local current,reason=HC.ReadCurrent('target')
        local ended=s and s.reason=='ended' and current and current.id~=nil
            and targetCastID~=nil and current.id==targetCastID
        if ((reason~='active' and HC.NativeUnitIdle('target')) or (reason=='idle' and type(UnitCastingDuration)~='function' and type(UnitChannelDuration)~='function')) or ended then
            if type(targetAttached.Hide)~='function' or not pcall(targetAttached.Hide,targetAttached) then return false end
        end
    end
    targetSuppressing=false
    if not TargetWrite(targetAlpha) then targetSuppressing=true;return false end
    targetCleanup=false;targetCastID=nil
    return true
end
local function TargetAttach(frame)
    if targetAttached==frame then return true end
    if targetAttached or not Writable(frame) or type(hooksecurefunc)~='function'
        or type(frame.SetAlpha)~='function' or type(frame.GetAlpha)~='function' then return false end
    local ok=pcall(hooksecurefunc,frame,'SetAlpha',function(_,alpha)
        if targetWriting or not targetSuppressing then return end
        if Accessible(alpha) and HC.ValidNumber(alpha,0,1) then targetAlpha=alpha end
        if not TargetWrite(0) then HC.blizzardTargetStatus='Ziel: Wiederherstellung ausstehend' end
    end)
    if not ok then return false end
    targetAttached=frame
    return true
end
function HC.UpdateBlizzardTarget()
    if HC.unitBarsInDevelopment then HC.blizzardTargetStatus='In Arbeit – deaktiviert';return end
    local s=HC.unitBars and HC.unitBars.target
    local want=HC.db and HC.db.hideBlizzardTarget==true and s and s.config.enabled
        and not HC.unitBarsPreview and s.cast~=nil and s.reason=='active' and s.frame:IsShown()
        and (s.cast.native or not HC.IsMaterialAvailable or HC.IsMaterialAvailable(s.effects))
    if not want then
        HC.blizzardTargetStatus=TargetRestore(s) and 'Ziel: Standard als Rückfall verfügbar'
            or 'Ziel: Wiederherstellung ausstehend'
        return
    end
    local frame=TargetFrameSpellBar
    if not frame and TargetFrame then frame=TargetFrame.spellbar end
    if not frame or not TargetAttach(frame) or not Writable(frame) then
        HC.blizzardTargetStatus=TargetRestore(s) and 'Ziel: Standard bleibt, Frame nicht sicher veränderbar'
            or 'Ziel: Wiederherstellung ausstehend'
        return
    end
    if not targetSuppressing then
        local ok,alpha=pcall(frame.GetAlpha,frame)
        targetAlpha=1
        if ok and Accessible(alpha) and HC.ValidNumber(alpha,0,1) then targetAlpha=alpha end
        targetSuppressing=true;targetCleanup=true
    end
    targetCastID=s.cast.id
    -- Only first acquisition writes; native SetAlpha changes are post-hooked.
    -- Repeated calls during drawing remain cheap and keep fallback checks live.
    if not targetWriting then
        local ok,alpha=pcall(frame.GetAlpha,frame)
        if ok and Accessible(alpha) and alpha==0 then
            HC.blizzardTargetStatus='Ziel durch Hanse ersetzt';return
        end
    end
    if TargetWrite(0) then HC.blizzardTargetStatus='Ziel durch Hanse ersetzt'
    else
        HC.blizzardTargetStatus=TargetRestore(s) and 'Ziel: Standard als Rückfall verfügbar'
            or 'Ziel: Wiederherstellung ausstehend'
    end
end
