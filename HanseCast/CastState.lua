local _, HC = ...
-- Shared lifecycle for sanitized readable casts. No frames, registrations,
-- rendering, polling or duration-object inspection belong in this module.
local State = {}
HC.CastState = State
State.terminalEvents = {
    UNIT_SPELLCAST_STOP=true, UNIT_SPELLCAST_CHANNEL_STOP=true,
    UNIT_SPELLCAST_FAILED=true, UNIT_SPELLCAST_FAILED_QUIET=true,
    UNIT_SPELLCAST_INTERRUPTED=true,
}
function State.EventID(event, unit, ...)
    -- Both callers pass the complete event payload, including the unit slot.
    -- Unit, castGUID and spellID are deliberately not inspected here.
    local id
    if event=="UNIT_SPELLCAST_CHANNEL_STOP" or event=="UNIT_SPELLCAST_INTERRUPTED" then
        id=select(4,...)
    else id=select(3,...) end
    if not HC.Accessible(id) then return nil end
    if type(id)~="number" and type(id)~="string" then return nil end
    return id
end
function State.Remember(state, cast, now, confirmed)
    local record={id=cast.id,name=cast.name,start=cast.start,finish=cast.finish,spellID=cast.spellID,
        channel=cast.channel,succeeded=cast.succeeded,stoppedAt=cast.stoppedAt or now,
        untilTime=cast.untilTime or now+0.3}
    state.lastEnded=record
    if confirmed~=false and cast.id~=nil then
        local history=state.terminalCasts or {}
        state.terminalCasts=history
        for i=#history,1,-1 do
            if history[i].untilTime<now or history[i].id==cast.id then table.remove(history,i) end
        end
        local terminal={id=cast.id,untilTime=math.max(now+(state.terminalMinimum or 0),
            cast.finish)+(state.terminalGrace or 0.5)}
        history[#history+1]=terminal
        if #history>16 then table.remove(history,1) end
        state.terminalCast=terminal
    end
    return record
end
function State.IsTerminated(state, cast, now)
    if state.terminalCast and now>state.terminalCast.untilTime then state.terminalCast=nil end
    local history=state.terminalCasts
    if not history then return false end
    local matched=false
    for i=#history,1,-1 do
        local terminal=history[i]
        if now>terminal.untilTime then table.remove(history,i)
        elseif cast and HC.Matches(cast,terminal.id) then matched=true end
    end
    return matched
end
function State.Read(state, unit, now)
    local cast,reason=HC.ReadCurrent(unit)
    if State.IsTerminated(state,cast,now) then return nil,"ended" end
    return cast,reason
end
function State.Invalidate(state)
    state.generation=(state.generation or 0)+1
    state.reconcileToken=nil
end
function State.Reset(state)
    State.Invalidate(state)
    state.cast=nil;state.lastEnded=nil;state.terminalCast=nil;state.terminalCasts=nil
end
function State.Reconcile(state, callback)
    if state.reconcileToken then return end
    local token={generation=state.generation or 0}
    state.reconcileToken=token
    C_Timer.After(0,function()
        -- An older callback must not clear a newer queued reconciliation.
        if state.reconcileToken~=token then return end
        state.reconcileToken=nil
        if token.generation==(state.generation or 0) then callback() end
    end)
end
