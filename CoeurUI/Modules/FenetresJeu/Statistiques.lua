-- Fenêtres du jeu · Fiche du personnage · page Statistiques (maquette « fiche complète » validée le
-- 28/11/2026, planche « 1 bis ») : même grammaire que la Réputation et les Compétences.
--   - sections repliables : chevron, petites capitales, trait sombre (pièce commune) ;
--   - sous-sections (« Boss »...) : leur « + » / « - » rouge devient une petite case du thème avec notre
--     chevron (vers le bas : ouverte, vers la droite : repliée) ;
--   - lignes : nom en gris clair, valeur en blanc, bande plus claire au survol ; défilement fin.
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local issecret = _G.issecretvalue or function() return false end
local function tr() return CUI:Tr("FJ_FICHE") end

-- Bouton de sous-section (« Campaign_HeaderIcon_Open » / « ..._Closed ») : petite case et chevron.
local function skinToggle(b)
    if not b or b.cuiToggle then return end
    b.cuiToggle = true
    local normal = b.GetNormalTexture and b:GetNormalTexture()
    CUI:SkinHideTextures(b)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture" }) do
        local t = b[getter] and b[getter](b)
        if t then CUI:SkinHide(t) end
    end
    local box = _G.CreateFrame("Frame", nil, b)
    box:SetSize(14, 14)
    box:SetPoint("CENTER")
    local panel = CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
    local chevron = CUI:CreateChevron(box, "OVERLAY")
    chevron:SetPoint(box, "CENTER", 0, 0)
    local function paint()
        local open = true
        local t = (b.GetNormalTexture and b:GetNormalTexture()) or normal
        local atlas = t and t.GetAtlas and t:GetAtlas()
        if type(atlas) == "string" and not issecret(atlas) then
            open = atlas:find("Open", 1, true) ~= nil
        end
        chevron:SetDirection(open and "down" or "right")
        local c = b.cuiOver and C.texte or C.texteSecondaire
        chevron:SetColor(c)
        panel.border:SetColor(b.cuiOver and C.texteDiscret or C.lisereSombre)
    end
    if normal and normal.SetAtlas then _G.hooksecurefunc(normal, "SetAtlas", paint) end
    if b.SetNormalAtlas then _G.hooksecurefunc(b, "SetNormalAtlas", paint) end
    b:HookScript("OnClick", function() _G.C_Timer.After(0, paint) end)
    b:HookScript("OnEnter", function() b.cuiOver = true paint() end)
    b:HookScript("OnLeave", function() b.cuiOver = false paint() end)
    b.cuiPaint = paint
    paint()
end

-- Une ligne (le jeu les recycle : une même ligne peut servir de statistique ou de sous-section).
local function skinRow(row)
    if row.StateIcon then
        CUI:SkinListHeader(row)
        return
    end
    local content = row.Content
    if not content then return end
    if not row.cuiStat then
        row.cuiStat = true
        CUI:SkinRowHighlight(content.BackgroundHighlight)
    end
    if row.ToggleCollapseButton then
        skinToggle(row.ToggleCollapseButton)
        if row.ToggleCollapseButton.cuiPaint then row.ToggleCollapseButton.cuiPaint() end
    end
    local sub = row.ToggleCollapseButton and row.ToggleCollapseButton:IsShown()
    if content.Name then
        local c = sub and C.texte or C.texteSecondaire
        content.Name:SetTextColor(c[1], c[2], c[3])
    end
    if content.Value then content.Value:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
end

-- Traits du jeu posés par-dessus la liste (« UI-Character-Info-ScrollLine-Long ») : traits sombres.
local function skinLines(frame)
    for _, child in ipairs({ frame:GetChildren() }) do
        for _, r in ipairs({ child:GetRegions() }) do
            if r:GetObjectType() == "Texture" then
                local atlas = r.GetAtlas and r:GetAtlas()
                if type(atlas) == "string" and atlas:find("ScrollLine", 1, true) then CUI:SkinSeparator(r) end
            end
        end
    end
end

local function skinStatistics()
    local sf = _G.StatisticsFrame
    if not sf or (sf.IsForbidden and sf:IsForbidden()) then return end
    CUI:SkinHideTextures(sf)
    CUI:SkinScrollBar(sf.ScrollBar)
    local box = sf.ScrollBox
    if not box then return end
    if box.Shadows then CUI:SkinHideTextures(box.Shadows) end
    skinLines(box)
    local function each()
        local target = box.ScrollTarget
        if not target then return end
        for _, row in ipairs({ target:GetChildren() }) do
            skinRow(row)
            if row.cuiPaint then row.cuiPaint() end
        end
    end
    if box.Update then _G.hooksecurefunc(box, "Update", function() CUI:SafeCall(tr(), each) end) end
    sf:HookScript("OnShow", function() CUI:SafeCall(tr(), each) end)
    each()
end

M.fichePages = M.fichePages or {}
M.fichePages[#M.fichePages + 1] = skinStatistics
