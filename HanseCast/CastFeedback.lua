local _, HC = ...

-- These records contain only values already validated by Compatibility.lua.
-- The client remains authoritative for all duration changes, including auras.
function HC.TrackCastTiming(previous,current,event,now)
    if not current then return end
    local starting=event=="UNIT_SPELLCAST_START" or event=="UNIT_SPELLCAST_CHANNEL_START"
    local same=not starting and previous and previous.channel==current.channel
        and ((previous.id~=nil and current.id~=nil and previous.id==current.id)
            or (previous.id==nil and current.id==nil and previous.name==current.name and previous.start==current.start))
    if not same then return end
    current.succeeded=previous.succeeded
    current.timingDelta=previous.timingDelta
    current.timingUntil=previous.timingUntil
    local delta=current.finish-previous.finish
    if math.abs(delta)>=0.05 then
        -- Combine a short burst in one direction. Reversals start a new signed
        -- change, so removing a slowing aura can visibly shorten the cast too.
        if previous.timingUntil and now<previous.timingUntil and previous.timingDelta
            and previous.timingDelta*delta>0 then delta=delta+previous.timingDelta end
        current.timingDelta=delta
        current.timingUntil=now+1.1
    end
end

-- Compatibility wrappers keep presentation code independent of state storage.
function HC.RememberTerminal(cast,now,confirmed)
    return HC.CastState.Remember(HC,cast,now,confirmed)
end
function HC.IsTerminated(cast,now)
    return HC.CastState.IsTerminated(HC,cast,now)
end
