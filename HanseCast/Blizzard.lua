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
