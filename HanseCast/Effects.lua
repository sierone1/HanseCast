local _, HC = ...
local min,max,sin,PI=math.min,math.max,math.sin,math.pi
local MEDIA="Interface\\AddOns\\HanseCast\\Media\\"
-- Artwork can be replaced independently from the small shared light primitives.
local ART=MEDIA.."V2\\"
local MAGE_ART=MEDIA.."V3\\Mage\\"
local STATIC_ART=MEDIA.."V3\\MageStatic\\"
HC.mageStaticRenderer=true
HC.classStaticRenderer=true
local CLASS_STATIC_ART=MEDIA.."V3\\ClassStatic\\"
-- Uneven, independently breathing knots; positions match the pulse artwork.
local PULSE_NODES={
    {x=.15,w=5.8,h=2.6,period=4.1,offset=.07,span=.21,alpha=.25},
    {x=.37,w=3.7,h=3.9,period=4.9,offset=.38,span=.16,alpha=.34},
    {x=.61,w=7.6,h=2.2,period=3.7,offset=.69,span=.27,alpha=.22},
    {x=.84,w=4.5,h=3.3,period=5.3,offset=.91,span=.18,alpha=.29},
}
local EMISSION_SIZES={.8,1.1,.9,1.2}
local FIRE_EMISSIONS={"PulseFlame","PulseFlame1","PulseFlame3","PulseFlame1"}
local MOTION={
    element={period=3.8,width=0.12,light=0.20,flow=0.16,motes=3},
    splinter={period=3.1,width=0.08,light=0.22,flow=0.18,motes=6},
    silk={period=5.2,width=0.24,light=0.15,flow=0.12,motes=1},
    pulse={period=3.0,width=0.06,light=0.25,flow=0.10,motes=2},
    mist={period=6.4,width=0.32,light=0.13,flow=0.14,motes=2},
}
-- Nine class materials share the same atlas contract. Categories deliberately
-- provide five restrained presentations of each material, not five repaints.
local CLASS_STYLE={
    element={height=.92,opacity=1,speed=1,light=.12,motes=0},
    splinter={height=.84,opacity=1,speed=1.06,light=.09,motes=6},
    silk={height=.76,opacity=.98,speed=.84,light=.06,motes=0},
    pulse={height=.58,opacity=1,speed=.94,light=0,motes=4},
    mist={height=1,opacity=.86,speed=.72,light=0,motes=0},
}
HC.textureFailures=HC.textureFailures or {}
function HC.GetTextureFailureCount()
    local count=0
    for _ in pairs(HC.textureFailures) do count=count+1 end
    return count
end
function HC.IsMaterialAvailable(instance)
    local e=instance or HC.effects
    return not (e and e.materialUnavailable)
end
local function SetAsset(region,asset,wrapH,wrapV,filterMode)
    local success=region:SetTexture(asset,wrapH,wrapV,filterMode)
    region.hcTextureAsset=asset;region.hcTextureWrapH=wrapH;region.hcTextureWrapV=wrapV;region.hcTextureFilter=filterMode
    -- Only an explicit engine result is evidence. Nil means unknown; nil
    -- assets intentionally clear unused regions and are never failures.
    if asset~=nil then
        if success==false then HC.textureFailures[asset]=true
        elseif success==true then HC.textureFailures[asset]=nil end
    end
    region.hcTextureUnavailable=asset~=nil and HC.textureFailures[asset]==true
    if region.hcTextureUnavailable and region.Hide then region:Hide();region.hcShown=false end
    return success
end
local function RequiredAsset(e,region,asset,wrapH,wrapV,filterMode)
    local success=SetAsset(region,asset,wrapH,wrapV,filterMode)
    if region.hcTextureUnavailable then e.materialUnavailable=true end
    return success
end
-- These caches belong only to addon-owned regions. Avoid native mutations
-- when a frame's visibility or opacity has not actually changed.
local function Visible(t,shown)
    shown=shown and not t.hcTextureUnavailable
    if t.hcShown==shown then return end
    t.hcShown=shown
    if shown then t:Show() else t:Hide() end
end
local function Alpha(t,value)
    if t.hcAlpha==value then return end
    t.hcAlpha=value;t:SetAlpha(value)
end
local function SmoothTexture(t)
    if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
    if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
end
local function Texture(parent,layer,file,blend)
    local t=parent:CreateTexture(nil,layer);SmoothTexture(t)
    if file then SetAsset(t,MEDIA..file..".tga","CLAMP","CLAMP","LINEAR") end
    t:SetBlendMode(blend or "BLEND");return t
end
local function Rect(t,parent,x,y,w,h)
    -- Own texture objects only. Keep stable anchors/sizes untouched between
    -- frames; changing the reveal edge must never resize the painted material.
    if t.hcAnchor~=parent then t:ClearAllPoints();t.hcAnchor=parent;t.hcX=nil end
    if t.hcX~=x or t.hcY~=y then
        t:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT",x,y);t.hcX=x;t.hcY=y
    end
    if t.hcW~=w or t.hcH~=h then t:SetSize(w,h);t.hcW=w;t.hcH=h end
end
function HC.CreateEffects(parent, independent)
    if not independent and HC.effects then return HC.effects end
    local e={parent=parent,width=300,height=24,sweeps={},motes={},flow={},emissionGlows={}}
    if not independent then HC.effects=e end
    e.arcaneGlowDivisor=2
    e.arcaneFrameCount=64;e.arcaneAtlasRows=16;e.arcaneFPS=24
    -- Only the viewport changes with progress. Material coordinates stay fixed.
    e.clip=CreateFrame("Frame",nil,parent);e.clip:SetClipsChildren(true)
    e.clip:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT",0,0)
    e.canvas=CreateFrame("Frame",nil,e.clip)
    e.canvas:SetPoint("BOTTOMLEFT",e.clip,"BOTTOMLEFT",0,0)
    e.ghost=Texture(parent,"BACKGROUND",nil,"ADD")
    e.shadow=Texture(e.canvas,"BACKGROUND")
    e.materialGlow=Texture(e.canvas,"ARTWORK",nil,"ADD")
    e.body=Texture(e.canvas,"ARTWORK")
    e.mask=e.canvas:CreateMaskTexture(nil,"ARTWORK")
    e.reveal=e.canvas:CreateMaskTexture(nil,"ARTWORK")
    SmoothTexture(e.mask);SmoothTexture(e.reveal)
    SetAsset(e.reveal,MEDIA.."Reveal.tga","CLAMP","CLAMP","LINEAR")
    e.body:AddMaskTexture(e.reveal);e.shadow:AddMaskTexture(e.reveal)
    e.materialGlow:AddMaskTexture(e.reveal)
    for i=1,2 do
        local t=Texture(e.canvas,"OVERLAY",nil,"BLEND")
        t:AddMaskTexture(e.mask);t.hcShapeMask=true;t:AddMaskTexture(e.reveal);Visible(t,false);e.flow[i]=t
    end
    for i=1,2 do
        local t=Texture(e.canvas,"OVERLAY","Sheen","ADD")
        t:AddMaskTexture(e.mask);t:AddMaskTexture(e.reveal);e.sweeps[i]=t
    end
    e.cap=Texture(e.canvas,"OVERLAY")
    e.capNext=Texture(e.canvas,"OVERLAY");Visible(e.capNext,false)
    e.arcaneCap={e.cap,e.capNext}
    e.staticLight=Texture(e.canvas,"OVERLAY",nil,"ADD")
    e.staticLightMask=e.canvas:CreateMaskTexture(nil,"ARTWORK")
    SmoothTexture(e.staticLightMask)
    e.staticLight:AddMaskTexture(e.reveal);e.staticLight:AddMaskTexture(e.staticLightMask)
    Visible(e.staticLight,false)
    e.edge=Texture(e.canvas,"OVERLAY","Edge","ADD")
    for i=1,2 do
        e.emissionGlows[i]=Texture(e.canvas,"OVERLAY","Mote","ADD")
        Visible(e.emissionGlows[i],false)
    end
    for i=1,6 do e.motes[i]=Texture(e.canvas,"OVERLAY","Mote","ADD") end
    -- These two tiny lights sit outside the progress clip, so the point remains
    -- round instead of being cut vertically in half. They move only locally.
    e.tipFrame=CreateFrame("Frame",nil,parent)
    e.tipFrame:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT",0,0)
    e.tipFrame:SetFrameLevel(e.canvas:GetFrameLevel()+1)
    e.tipGlow=Texture(e.tipFrame,"OVERLAY","Mote","ADD")
    e.tipCore=Texture(e.tipFrame,"OVERLAY","Mote","ADD")
    Visible(e.tipGlow,false);Visible(e.tipCore,false)
    -- Native draw order exported for the independent preview and pixel checks.
    e.renderLayers={e.shadow,e.materialGlow,e.body,e.flow[1],e.flow[2],e.sweeps[1],e.sweeps[2],e.cap,e.capNext,e.staticLight,e.edge}
    for _,t in ipairs(e.emissionGlows) do e.renderLayers[#e.renderLayers+1]=t end
    for _,t in ipairs(e.motes) do e.renderLayers[#e.renderLayers+1]=t end
    e.tipLayers={e.tipGlow,e.tipCore}
    e.sharedTextureRegions={e.edge,e.tipGlow,e.tipCore,e.sweeps[1],e.sweeps[2],e.emissionGlows[1],e.emissionGlows[2]}
    Visible(e.clip,false);Visible(e.ghost,false);Visible(e.tipFrame,false);return e
end
function HC.LayoutEffects(width,height,instance)
    local e=instance or HC.effects;if not e then return end
    local scale=e.parent.GetEffectiveScale and e.parent:GetEffectiveScale() or 1
    e.softLOD=height*scale<=24 or (width*scale<=640 and height*scale<=64)
    e.arcaneCompact=height*scale<=24
    e.mageFireCompact=width*scale<=512 and height*scale<=64
    e.softLow=height*scale<=32
    e.width=width;e.height=height;e.canvas:SetSize(width,height);e.clip:SetHeight(height)
    e.tipFrame:SetSize(width,height)
    Rect(e.body,e.canvas,0,0,width,height)
    Rect(e.materialGlow,e.canvas,0,0,width,height)
    Rect(e.shadow,e.canvas,0,-1,width,height)
    Rect(e.mask,e.canvas,0,0,width,height)
    Rect(e.ghost,e.parent,0,0,width,height);e.key=nil
    for _,t in ipairs(e.flow) do Rect(t,e.canvas,0,0,width,height) end
end
local function SelectClassMaterial(e,theme)
    local path=ART.."Class\\"..theme.element
    local suffix=e.arcaneCompact and "-flow-small" or "-flow"
    e.classMaterial=true
    RequiredAsset(e,e.reveal,MEDIA.."ArcaneReveal.tga","CLAMP","CLAMP","LINEAR")
    RequiredAsset(e,e.mask,ART.."Class\\"..theme.family.."-mask.tga","CLAMP","CLAMP","LINEAR")
    e.mask:SetTexCoord(0,1,0,1)
    SetAsset(e.ghost,path..".tga","CLAMP","CLAMP","LINEAR")
    e.ghost:SetTexCoord(0,1,0,1);e.ghost:SetVertexColor(1,1,1,.025)
    SetAsset(e.materialGlow,path..suffix.."-glow.tga","CLAMP","CLAMP","LINEAR")
    e.materialGlow:SetVertexColor(1,1,1,1)
    Alpha(e.materialGlow,.50)
    -- The atlas supplies the silhouette; a subtle shared category mask gives
    -- the same energy a different presentation without duplicating atlases.
    for i,t in ipairs(e.flow) do
        if not t.hcShapeMask then t:AddMaskTexture(e.mask);t.hcShapeMask=true end
        if i==1 then RequiredAsset(e,t,path..suffix..".tga","CLAMP","CLAMP","LINEAR")
        else SetAsset(t,nil) end
        t:SetVertexColor(1,1,1,1);t.hcFrame=nil;Visible(t,false)
    end
    if not e.materialGlow.hcShapeMask then e.materialGlow:AddMaskTexture(e.mask);e.materialGlow.hcShapeMask=true end
    for _,t in ipairs(e.arcaneCap) do
        RequiredAsset(e,t,path.."-join.tga","CLAMP","CLAMP","LINEAR")
        t.hcSpatialFrame=nil;t:SetVertexColor(1,1,1,.82);t:SetBlendMode("ADD")
        if not t.hcShapeMask then t:AddMaskTexture(e.mask);t.hcShapeMask=true end
    end
    Visible(e.body,false);Visible(e.shadow,false);Visible(e.edge,false)
    for _,t in ipairs(e.sweeps) do Visible(t,false) end
    for _,t in ipairs(e.emissionGlows) do Visible(t,false) end
    for _,t in ipairs(e.motes) do
        SetAsset(t,MEDIA.."Mote.tga","CLAMP","CLAMP","LINEAR")
        t:SetTexCoord(0,1,0,1);t:SetVertexColor(unpack(theme.bright));Visible(t,false)
        t.hcEmissionFile="Mote";t.hcEmissionDirection=nil
    end
    e.tipGlow:SetVertexColor(unpack(theme.cast));e.tipCore:SetVertexColor(unpack(theme.bright))
end
local function SelectStaticMaterial(e,theme)
    local accent=theme.accentTint or {1,1,1,1}
    local suffix=e.mageFireCompact and "-small" or ""
    local folder=theme.classMaterial and CLASS_STATIC_ART or STATIC_ART
    local path=folder..theme.family.."-"..theme.element
    e.staticMaterial=true;e.mageStatic=not theme.classMaterial;e.classMaterial=theme.classMaterial==true
    e.mageFire=theme.family=="element" and theme.element=="fire"
    RequiredAsset(e,e.reveal,folder..theme.element.."-reveal.tga","CLAMP","CLAMP","LINEAR")
    e.reveal:SetTexCoord(0,1,0,1)
    RequiredAsset(e,e.body,path..suffix..".tga","CLAMP","CLAMP","LINEAR")
    SetAsset(e.materialGlow,path..suffix.."-glow.tga","CLAMP","CLAMP","LINEAR")
    SetAsset(e.ghost,path..".tga","CLAMP","CLAMP","LINEAR")
    e.body:SetVertexColor(1,1,1,1);Alpha(e.body,1)
    e.materialGlow:SetVertexColor(unpack(accent));Alpha(e.materialGlow,.30)
    e.ghost:SetTexCoord(0,1,0,1);e.ghost:SetVertexColor(1,1,1,.025)
    Rect(e.body,e.canvas,0,0,e.width,e.height)
    Rect(e.materialGlow,e.canvas,0,0,e.width,e.height)
    Rect(e.ghost,e.parent,0,0,e.width,e.height)
    e.body:SetTexCoord(0,1,0,1);e.materialGlow:SetTexCoord(0,1,0,1)
    SetAsset(e.staticLight,path..suffix.."-glow.tga","CLAMP","CLAMP","LINEAR")
    SetAsset(e.staticLightMask,STATIC_ART.."LightSweep.tga","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE","LINEAR")
    e.staticLight:SetTexCoord(0,1,0,1);e.staticLight:SetVertexColor(unpack(accent));Alpha(e.staticLight,.05)
    Rect(e.staticLight,e.canvas,0,0,e.width,e.height)
    Visible(e.staticLight,false)
    e.mageFireFrame=0;e.mageFirePage=0
    -- The master already contains its own flames and highlights. Generic
    -- overlays and a static convergence cap would obscure those exact forms.
    Visible(e.shadow,false);Visible(e.cap,false);Visible(e.capNext,false);Visible(e.edge,false)
    Visible(e.tipGlow,false);Visible(e.tipCore,false);Visible(e.tipFrame,false)
    for _,t in ipairs(e.flow) do Visible(t,false) end
    for _,t in ipairs(e.sweeps) do Visible(t,false) end
    for _,t in ipairs(e.motes) do
        SetAsset(t,MEDIA.."Mote.tga","CLAMP","CLAMP","LINEAR")
        t:SetTexCoord(0,1,0,1);t.hcEmissionFile="Mote";t.hcEmissionDirection=nil
        Visible(t,false)
    end
    for _,t in ipairs(e.emissionGlows) do Visible(t,false) end
end
local function SelectMaterial(e,theme)
    local key=theme.family.."-"..theme.element
    if e.key==key and e.theme==theme then return end
    e.key=key;e.theme=theme
    e.materialUnavailable=false
    -- Retry failed shared optional art only when a material selection changes.
    for _,t in ipairs(e.sharedTextureRegions) do
        if t.hcTextureUnavailable then
            SetAsset(t,t.hcTextureAsset,t.hcTextureWrapH,t.hcTextureWrapV,t.hcTextureFilter)
        end
    end
    if e.mageFire then
        -- SetTexture does not reset atlas coordinates. Legacy bodies need
        -- their full image restored when returning from the fire prototype.
        e.body:SetTexCoord(0,1,0,1)
    end
    e.mageFire=false;e.mageStatic=false;e.staticMaterial=false;Visible(e.staticLight,false)
    -- Class presentations use a narrower painted band. Restore full mage
    -- geometry and texture coordinates even when layout itself did not change.
    if e.classMaterial then
        for _,t in ipairs(e.flow) do Rect(t,e.canvas,0,0,e.width,e.height) end
        Rect(e.materialGlow,e.canvas,0,0,e.width,e.height)
        Rect(e.ghost,e.parent,0,0,e.width,e.height)
        if e.materialGlow.hcShapeMask then e.materialGlow:RemoveMaskTexture(e.mask);e.materialGlow.hcShapeMask=false end
        for _,t in ipairs(e.arcaneCap) do
            if t.hcShapeMask then t:RemoveMaskTexture(e.mask);t.hcShapeMask=false end
        end
    end
    e.classMaterial=false
    if theme.classMaterial or theme.element=="frost" or theme.element=="fire" or theme.element=="arcane" then SelectStaticMaterial(e,theme);return end
    local folder=theme.element~="arcane" and (e.softLow and "SoftLow\\" or (e.softLOD and "Soft\\" or "")) or ""
    local path=ART..folder..key
    -- Fade the old three strands before the local converging join takes over.
    RequiredAsset(e,e.reveal,MEDIA..(theme.element=="arcane" and "ArcaneReveal.tga" or "Reveal.tga"),"CLAMP","CLAMP","LINEAR")
    if theme.element=="arcane" then SetAsset(e.body,path..".tga","CLAMP","CLAMP","LINEAR")
    else RequiredAsset(e,e.body,path..".tga","CLAMP","CLAMP","LINEAR") end
    SetAsset(e.shadow,path..".tga","CLAMP","CLAMP","LINEAR");SetAsset(e.ghost,path..".tga","CLAMP","CLAMP","LINEAR")
    local glowSuffix=theme.element=="arcane" and (e.arcaneCompact and "-flow-small-glow.tga" or "-flow-glow.tga") or "-glow.tga"
    SetAsset(e.materialGlow,path..glowSuffix,"CLAMP","CLAMP","LINEAR")
    e.materialGlow:SetTexCoord(0,1,0,1)
    e.materialGlow:SetVertexColor(1,1,1,1)
    Alpha(e.materialGlow,theme.element=="arcane" and .65 or .50)
    RequiredAsset(e,e.mask,path.."-mask.tga","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE","LINEAR")
    if theme.element=="arcane" then
        RequiredAsset(e,e.cap,path.."-join.tga","CLAMP","CLAMP","LINEAR");RequiredAsset(e,e.capNext,path.."-join.tga","CLAMP","CLAMP","LINEAR")
    else
        RequiredAsset(e,e.cap,path.."-cap.tga","CLAMP","CLAMP","LINEAR");e.cap:SetTexCoord(0,1,0,1)
        e.cap.hcSpatialFrame=nil;e.capNext.hcSpatialFrame=nil;Visible(e.capNext,false)
    end
    e.body:SetVertexColor(1,1,1,1)
    e.shadow:SetVertexColor(0.025,0.04,0.075,0.16)
    -- Keep the source element hue. Dark BLEND multiplication caused the muddy
    -- unfilled streak on snow; a faint additive trace never darkens the world.
    e.ghost:SetVertexColor(1,1,1,0.025)
    e.cap:SetVertexColor(1,1,1,0.82);e.capNext:SetVertexColor(1,1,1,0.82)
    if theme.element=="arcane" then Visible(e.body,false);Visible(e.shadow,false) else Visible(e.body,true);Visible(e.shadow,true) end
    e.cap:SetBlendMode(theme.element=="arcane" and "ADD" or "BLEND")
    e.capNext:SetBlendMode("ADD")
    for i,t in ipairs(e.flow) do
        if theme.element=="arcane" then
            if t.hcShapeMask then t:RemoveMaskTexture(e.mask);t.hcShapeMask=false end
            if i==1 then RequiredAsset(e,t,path..(e.arcaneCompact and "-flow-small.tga" or "-flow.tga"),"CLAMP","CLAMP","LINEAR")
            else SetAsset(t,path..(e.arcaneCompact and "-flow-small.tga" or "-flow.tga"),"CLAMP","CLAMP","LINEAR") end
        else
            if not t.hcShapeMask then t:AddMaskTexture(e.mask);t.hcShapeMask=true end
            SetAsset(t,theme.element=="fire" and MEDIA.."FireFlow.tga" or nil,"CLAMP","CLAMP","LINEAR")
        end
        t.hcFrame=nil;t:SetVertexColor(1,1,1,1)
    end
    e.edge:SetVertexColor(unpack(theme.cast))
    e.tipGlow:SetVertexColor(unpack(theme.cast))
    e.tipCore:SetVertexColor(unpack(theme.bright))
    for _,t in ipairs(e.emissionGlows) do t:SetVertexColor(unpack(theme.cast));Visible(t,false) end
    for _,t in ipairs(e.sweeps) do t:SetVertexColor(unpack(theme.secondaryBright)) end
    for i,t in ipairs(e.motes) do
        local emission=theme.family=="pulse" and theme.element~="arcane" and i>=5
        local file=emission and (theme.element=="fire" and "PulseFlame" or "PulseShard") or "Mote"
        SetAsset(t,MEDIA..file..".tga","CLAMP","CLAMP","LINEAR")
        t.hcEmissionFile=file;t.hcEmissionDirection=nil
        t:SetTexCoord(0,1,0,1)
        t:SetVertexColor(unpack(emission and theme.element=="fire" and theme.cast or theme.bright))
    end
end
local function DrawClassMaterial(e,theme,progress,now)
    local style=CLASS_STYLE[theme.family] or CLASS_STYLE.element
    local w,h=e.width,e.height;local tip=w*progress
    local band=max(6,h*style.height);local y=(h-band)/2
    e.progress=progress;e.tip=tip;e.phase=now
    Rect(e.ghost,e.parent,0,y,w,band);Visible(e.ghost,true)
    if tip<=0 then
        Visible(e.clip,false);Visible(e.tipFrame,false);Visible(e.tipGlow,false);Visible(e.tipCore,false);Visible(e.materialGlow,false)
        return
    end
    if e.hcClipWidth~=tip then e.clip:SetWidth(tip);e.hcClipWidth=tip end
    Visible(e.clip,true);Visible(e.tipFrame,true)
    Rect(e.reveal,e.canvas,tip-w,0,w,h)
    local cell=math.floor(now*30*style.speed)%128
    local col,row=cell%4,math.floor(cell/4)
    local aw,ah=e.arcaneCompact and 1024 or 2048,e.arcaneCompact and 1024 or 2048
    local t=e.flow[1]
    if t.hcFrame~=cell then
        t:SetTexCoord(col/4+.5/aw,(col+1)/4-.5/aw,row/32+.5/ah,(row+1)/32-.5/ah)
        e.materialGlow:SetTexCoord(col/4+1/aw,(col+1)/4-1/aw,row/32+1/ah,(row+1)/32-1/ah)
        t.hcFrame=cell
    end
    Rect(t,e.canvas,0,y,w,band);Alpha(t,style.opacity);Visible(t,true)
    Rect(e.materialGlow,e.canvas,0,y,w,band);Alpha(e.materialGlow,.50*style.opacity);Visible(e.materialGlow,true)
    local capWidth=w*.10
    local spatial=max(0,min(1,(tip-capWidth)/w))*63
    local index=math.floor(spatial);local mix=spatial-index
    for i,cap in ipairs(e.arcaneCap) do
        local sample=min(index+i-1,63);local c,r=sample%8,math.floor(sample/8)
        if cap.hcSpatialFrame~=sample then
            cap:SetTexCoord(c/8+.5/1024,(c+1)/8-.5/1024,r/8+.5/512,(r+1)/8-.5/512)
            cap.hcSpatialFrame=sample
        end
        Rect(cap,e.canvas,tip-capWidth,y,capWidth,band)
        Alpha(cap,min(1,tip/capWidth)*style.opacity*(i==1 and (1-mix) or mix));Visible(cap,true)
    end
    local glowSize=max(6,min(12,h*.6));local coreSize=max(2.2,min(4.2,h*.17))
    local tipAlpha=min(1,tip/8)*style.opacity
    Rect(e.tipGlow,e.parent,tip-glowSize/2,(h-glowSize)/2,glowSize,glowSize)
    Rect(e.tipCore,e.parent,tip-coreSize/2,(h-coreSize)/2,coreSize,coreSize)
    Alpha(e.tipGlow,tipAlpha*(.56+.04*sin(now*2.4)));Alpha(e.tipCore,tipAlpha*.95)
    Visible(e.tipGlow,true);Visible(e.tipCore,true)
    e.localTipWidth=capWidth+glowSize/2
    -- Tiny uneven knots distinguish pulse from a simply thinner stream. Other
    -- categories use at most six low-alpha motes, bounded by the fill viewport.
    for i,mote in ipairs(e.motes) do
        if i>style.motes then Visible(mote,false)
        elseif theme.family=="pulse" then
            local node=PULSE_NODES[i];local phase=(now/node.period+node.offset)%1
            local light=phase<node.span and sin(PI*phase/node.span)^2 or 0
            local scale=max(.6,min(1.6,h/24))
            local mw,mh=node.w*scale,node.h*scale
            Rect(mote,e.canvas,w*node.x-mw/2,(h-mh)/2,mw,mh)
            Alpha(mote,.01+node.alpha*.65*light);Visible(mote,true)
        else
            local phase=(now/(3.1+i*.17)+i*.173)%1
            local size=max(1.2,min(2.8,h*.09))
            Rect(mote,e.canvas,w*((i*.271+phase*.08)%1),h*(.5+.13*sin(i*2.4+phase*PI))-size/2,size,size)
            Alpha(mote,.19*sin(PI*phase)^2);Visible(mote,true)
        end
    end
end
local function DrawStaticMaterial(e,progress,now)
    local w,h=e.width,e.height;local tip=w*progress
    e.progress=progress;e.tip=tip;e.phase=now
    Visible(e.ghost,true)
    if tip<=0 then Visible(e.clip,false);Visible(e.materialGlow,false);Visible(e.staticLight,false);return end
    if e.hcClipWidth~=tip then e.clip:SetWidth(tip);e.hcClipWidth=tip end
    Visible(e.clip,true)
    -- Progress moves only the reveal/viewport, never the painted body. The
    -- body and glow remain static; only the reveal edge follows the cast.
    Rect(e.reveal,e.canvas,tip-w,0,w,h)
    if e.mageFireFrame~=0 then
        e.body:SetTexCoord(0,1,0,1)
        e.materialGlow:SetTexCoord(0,1,0,1)
        e.mageFireFrame=0
    end
    Visible(e.body,true);Visible(e.materialGlow,true)
    -- Only a soft light mask travels. The source body, glow and their UVs never move.
    local phase=(now%7)/7
    Rect(e.staticLightMask,e.canvas,w*(-.35+phase*1.7),0,w*.35,h)
    Visible(e.staticLight,not e.staticLightMask.hcTextureUnavailable)
    e.localTipWidth=w*.03
end
function HC.DrawEffects(progress,now,instance,instanceTheme)
    local e=instance or HC.effects;if not e then return end
    progress=max(0,min(1,progress));now=now or 0
    local theme=instanceTheme or HC.GetTheme();SelectMaterial(e,theme)
    if e.materialUnavailable then HC.HideEffects(e);return end
    if e.staticMaterial then DrawStaticMaterial(e,progress,now);return end
    if theme.classMaterial then DrawClassMaterial(e,theme,progress,now);return end
    local motion=MOTION[theme.family] or MOTION.element
    local w,h=e.width,e.height;local tip=w*progress
    e.progress=progress;e.tip=tip;e.phase=now;Visible(e.ghost,true)
    if tip<=0 then
        Visible(e.clip,false);Visible(e.tipGlow,false);Visible(e.tipCore,false);Visible(e.tipFrame,false);Visible(e.materialGlow,false)
        for _,t in ipairs(e.emissionGlows) do Visible(t,false) end
        return
    end
    if theme.family~="pulse" or theme.element~="fire" then
        for _,t in ipairs(e.emissionGlows) do Visible(t,false) end
    end
    if e.hcClipWidth~=tip then e.clip:SetWidth(tip);e.hcClipWidth=tip end
    Visible(e.clip,true);Visible(e.tipFrame,true)
    Visible(e.materialGlow,true)
    Rect(e.reveal,e.canvas,tip-w,0,w,h)
    -- Two adjacent sprite frames crossfade; the sequence never controls fill.
    local frameTime=(now*10)%16
    local frameIndex=math.floor(frameTime)
    for i,t in ipairs(e.flow) do
        if theme.element=="arcane" then
            if i==1 then
                -- One coherent full-opacity frame avoids BLEND crossfade
                -- pumping. Material time remains independent of cast fill.
                local cell=math.floor(now*e.arcaneFPS)%e.arcaneFrameCount
                local col,row=cell%4,math.floor(cell/4)
                if t.hcFrame~=cell then
                    local atlasWidth=e.arcaneCompact and 1024 or 2048
                    local atlasHeight=(e.arcaneCompact and 32 or 64)*e.arcaneAtlasRows
                    t:SetTexCoord(col/4+0.5/atlasWidth,(col+1)/4-0.5/atlasWidth,row/e.arcaneAtlasRows+0.5/atlasHeight,(row+1)/e.arcaneAtlasRows-0.5/atlasHeight)
                    local glowWidth,glowHeight=atlasWidth/e.arcaneGlowDivisor,atlasHeight/e.arcaneGlowDivisor
                    e.materialGlow:SetTexCoord(col/4+0.5/glowWidth,(col+1)/4-0.5/glowWidth,row/e.arcaneAtlasRows+0.5/glowHeight,(row+1)/e.arcaneAtlasRows-0.5/glowHeight)
                    t.hcFrame=cell
                end
                Alpha(t,1);Visible(t,true)
            else Visible(t,false) end
        elseif theme.element=="fire" then
            local index=(frameIndex+i-1)%16
            local col,row=index%4,math.floor(index/4)
            if t.hcFrame~=index then
                t:SetTexCoord(col/4+0.5/2048,(col+1)/4-0.5/2048,row/4+0.5/512,(row+1)/4-0.5/512)
                t.hcFrame=index
            end
            Alpha(t,motion.flow*(i==1 and (1-frameTime+frameIndex) or (frameTime-frameIndex)))
            Visible(t,true)
        else Visible(t,false) end
    end
    -- The painted body never shrinks. Only its local end cap follows the edge.
    -- Keep the local painted transition at least as long as the reveal mask's
    -- final 1/16 fade, including very wide, low bars.
    local capWidth=theme.element=="arcane" and w*0.10 or min(w*0.18,max(w*0.08,18,h*1.1))
    Rect(e.cap,e.canvas,tip-capWidth,0,capWidth,h)
    if theme.element=="arcane" then
        -- Absolute spatial samples share each family's own shape, including
        -- angular and asymmetric motifs. Nothing rescales the painted body.
        local spatial=max(0,min(1,(tip-capWidth)/w))*63
        local index=math.floor(spatial);local mix=spatial-index
        -- The fixed-size join begins partly outside the viewport on short
        -- early fills. Reveal it through clipping instead of a point-only gap.
        local originFade=min(1,tip/capWidth)
        for i,t in ipairs(e.arcaneCap) do
            local cell=min(index+i-1,63);local col,row=cell%8,math.floor(cell/8)
            if t.hcSpatialFrame~=cell then
                t:SetTexCoord(col/8+0.5/1024,(col+1)/8-0.5/1024,row/8+0.5/512,(row+1)/8-0.5/512)
                t.hcSpatialFrame=cell
            end
            Rect(t,e.canvas,tip-capWidth,0,capWidth,h)
            Alpha(t,originFade*(i==1 and (1-mix) or mix));Visible(t,true)
        end
    else
        Alpha(e.cap,min(1,tip/capWidth));Visible(e.cap,true);Visible(e.capNext,false)
    end
    local edgeWidth=max(3,min(8,h*0.3));local edgeHeight=min(h*0.45,10)
    Rect(e.edge,e.canvas,tip-edgeWidth,(h-edgeHeight)/2,edgeWidth,edgeHeight)
    Alpha(e.edge,0.15+0.035*sin(now*3))
    Visible(e.edge,true)
    local glowSize=max(6,min(12,h*0.6));local coreSize=max(2.2,min(4.2,h*0.17))
    local tipAlpha=min(1,tip/8)
    Rect(e.tipGlow,e.parent,tip-glowSize/2,(h-glowSize)/2,glowSize,glowSize)
    Rect(e.tipCore,e.parent,tip-coreSize/2,(h-coreSize)/2,coreSize,coreSize)
    Alpha(e.tipGlow,tipAlpha*(0.56+0.04*sin(now*2.4)))
    Alpha(e.tipCore,tipAlpha*0.95);Visible(e.tipGlow,true);Visible(e.tipCore,true)
    e.localTipWidth=max(capWidth,w/16)+glowSize/2
    -- Illumination positions depend on time/layout, never on progress.
    local period=motion.period*(theme.element=="fire" and 0.62 or (theme.element=="arcane" and 0.86 or 1))
    local sweepWidth=max(18,w*motion.width)
    for i,t in ipairs(e.sweeps) do
        local phase=(now/period+(i-1)*0.5)%1
        Rect(t,e.canvas,-sweepWidth+(w+sweepWidth*2)*phase,0,sweepWidth,h)
        Alpha(t,motion.light*sin(PI*phase)^2)
        Visible(t,true)
    end
    local count=h<16 and min(2,motion.motes) or motion.motes
    for i,t in ipairs(e.motes) do
        if theme.family=="pulse" and theme.element=="arcane" then
            -- Its distinct rail lenses already carry independent light
            -- in the animated material; generic dots would obscure them.
            Visible(t,false)
        elseif theme.family=="pulse" then
            local node=PULSE_NODES[i]
            if not node then
                -- Two brief material emissions, not a particle burst. Source
                -- selection and motion depend on time only; fill merely clips.
                local cycle=now/(i==5 and 3.7 or 4.9)+(i==5 and .11 or .57)
                local phase=cycle%1
                if phase>=.42 then
                    Visible(t,false);Visible(e.emissionGlows[i-4],false)
                else
                    local life=phase/.42
                    local slot=(math.floor(cycle)+(i==5 and 0 or 2))%4+1
                    local origin=w*PULSE_NODES[slot].x
                    local direction=slot%2==1 and 1 or -1
                    local variation=EMISSION_SIZES[slot]
                    local nw,nh,x,y
                    if theme.element=="fire" then
                        local file=FIRE_EMISSIONS[slot]
                        if t.hcEmissionFile~=file then
                            SetAsset(t,MEDIA..file..".tga","CLAMP","CLAMP","LINEAR")
                            t.hcEmissionFile=file;t.hcEmissionDirection=nil
                        end
                        nw=h*(.20+.13*life)*variation*.5;nh=h*(.15+.18*life)*variation*.5
                        x=origin-nw/2+h*.06*sin(PI*life)
                        y=h*.5+direction*h*.06*life*variation-(direction<0 and nh or 0)
                    else
                        nw=h*.13*variation;nh=h*.19*variation
                        x=origin-nw/2+h*.045*life*(i==5 and 1 or -1)
                        y=h*(.5+direction*.18*life)-nh/2
                    end
                    if t.hcEmissionDirection~=direction then
                        t:SetTexCoord(0,1,direction<0 and 1 or 0,direction<0 and 0 or 1)
                        t.hcEmissionDirection=direction
                    end
                    Rect(t,e.canvas,x,y,nw,nh)
                    local emissionAlpha=(theme.element=="fire" and .32 or .42)*sin(PI*life)^1.3
                    Alpha(t,emissionAlpha)
                    Visible(t,true)
                    if theme.element=="fire" then
                        -- Small additive light follows this flame's exact fade.
                        -- The flame core keeps its requested half-size geometry.
                        local glow=e.emissionGlows[i-4]
                        local gw,gh=nw*1.8,nh*1.7
                        Rect(glow,e.canvas,x+(nw-gw)/2,y+(nh-gh)/2,gw,gh)
                        Alpha(glow,emissionAlpha*.45);Visible(glow,true)
                    end
                end
            else
                local phase=(now/node.period+node.offset)%1
                local light=phase<node.span and sin(PI*phase/node.span)^2 or 0
                local size=max(.6,min(1.6,h/24))
                local nw,nh=node.w*size,node.h*size
                if theme.element=="fire" then nw=nw*1.35;nh=nh*.72 end
                Rect(t,e.canvas,w*node.x-nw/2,(h-nh)/2,nw,nh)
                Alpha(t,.015+node.alpha*light);Visible(t,true)
            end
        elseif i>count then Visible(t,false) else
            local phase=(now/(theme.element=="fire" and 1.6 or 3.4)+i*0.173)%1
            local x=w*((i*0.271+phase*0.13)%1)
            local y=h*(0.4+0.22*sin(i*2.4+phase*PI))
            if theme.element=="fire" then y=h*(0.35+phase*0.4) end
            local size=max(1.4,min(3.2,h*0.105));Rect(t,e.canvas,x,y,size,size)
            Alpha(t,(theme.family=="mist" and 0.14 or 0.32)*sin(PI*phase)^2);Visible(t,true)
        end
    end
end
function HC.HideEffects(instance)
    local e=instance or HC.effects;if not e then return end
    Visible(e.clip,false);Visible(e.ghost,false);Visible(e.tipGlow,false);Visible(e.tipCore,false);Visible(e.tipFrame,false)
    Visible(e.materialGlow,false);Visible(e.staticLight,false)
    for _,t in ipairs(e.emissionGlows) do Visible(t,false) end
end
