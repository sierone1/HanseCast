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

function HC.RememberTerminal(cast,now,confirmed)
    local record={id=cast.id,name=cast.name,start=cast.start,finish=cast.finish,spellID=cast.spellID,
        channel=cast.channel,succeeded=cast.succeeded,stoppedAt=cast.stoppedAt or now,untilTime=cast.untilTime or now+0.3}
    HC.lastEnded=record
    if confirmed~=false and cast.id~=nil then
        local history=HC.terminalCasts or {}
        HC.terminalCasts=history
        for i=#history,1,-1 do
            if history[i].untilTime<now or history[i].id==cast.id then table.remove(history,i) end
        end
        local terminal={id=cast.id,untilTime=math.max(now,cast.finish)+0.5}
        history[#history+1]=terminal
        -- Rapid cancels can leave more than one old API record in flight.
        -- Keep bounded identities only; this is not a cast/event log.
        if #history>16 then table.remove(history,1) end
        HC.terminalCast=terminal
    end
    return record
end

function HC.IsTerminated(cast,now)
    if HC.terminalCast and now>HC.terminalCast.untilTime then HC.terminalCast=nil end
    local history=HC.terminalCasts
    if not history then return false end
    local matched=false
    for i=#history,1,-1 do
        local terminal=history[i]
        if now>terminal.untilTime then table.remove(history,i)
        elseif cast and HC.Matches(cast,terminal.id) then matched=true end
    end
    return matched
end
