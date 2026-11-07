local _,HC=...
-- Optional focused demo, reached through /hansecast demo. It never fires game
-- events, reads auras or changes the player's cast; all names are labeled preview.
local stages={
    {kind="longer",length=4.4,name="Vorschau · Verlängert",delta=.75},
    {kind="shorter",length=3.4,name="Vorschau · Verkürzt",delta=-.75},
    {kind="cancelled",length=2.7,name="Vorschau · Abbruch"},
    {kind="interrupted",length=2.9,name="Vorschau · Unterbrechung"},
    {kind="failed",length=2.9,name="Vorschau · Fehlgeschlagen"},
    {kind="channel",length=4.4,name="Vorschau · Kanal angepasst",delta=.75,channel=true},
}
local total=0;for _,stage in ipairs(stages) do total=total+stage.length end

function HC.DrawFeedbackPreview(now)
    HC.DrawGCD(nil,now)
    if HC.dragging then
        HC.ClearCastResult()
        HC.previewDragCast=HC.previewDragCast or {name=HC.L and HC.L("Vorschau · Ziehen") or "Vorschau · Ziehen",channel=false}
        HC.previewDragCast.start=now-1;HC.previewDragCast.finish=now+2
        HC.Draw(HC.previewDragCast,now)
        HC.feedbackPreviewKey=nil
        return
    end
    local elapsed=now-(HC.previewStart or now)
    local cycle=math.floor(elapsed/total)
    local phase=elapsed%total;local offset=0;local index=1
    for i,stage in ipairs(stages) do
        if phase<stage.length then index=i;break end
        phase=phase-stage.length;offset=offset+stage.length
    end
    local stage=stages[index];local start=(HC.previewStart or now)+cycle*total+offset
    local key=cycle*#stages+index
    if HC.feedbackPreviewKey~=key then
        HC.feedbackPreviewKey=key;HC.feedbackPreviewResult=false;HC.ClearCastResult()
        HC.previewCast={name=HC.L and HC.L(stage.name) or stage.name,start=start,finish=start+3,channel=stage.channel==true}
    end
    local sample=HC.previewCast
    if stage.delta then
        if phase>=1 then
            sample.finish=start+3+stage.delta
            sample.timingDelta=stage.delta;sample.timingUntil=start+2.1
        end
        if now<sample.finish then HC.Draw(sample,now)
        else HC.ClearCastResult();HC.HideEffects();HC.frame:Hide() end
    elseif phase<1.45 then HC.Draw(sample,now)
    else
        if not HC.feedbackPreviewResult then
            HC.feedbackPreviewResult=true
            HC.ShowCastResult(stage.kind,sample,start+1.45)
        end
        if HC.resultUntil and now<HC.resultUntil then HC.UpdateCastResult(now)
        else HC.ClearCastResult();HC.HideEffects();HC.frame:Hide() end
    end
end
