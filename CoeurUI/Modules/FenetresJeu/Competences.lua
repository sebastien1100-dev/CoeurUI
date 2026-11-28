-- Fenêtres du jeu · Fiche du personnage · page Compétences (maquette « fiche complète » validée le
-- 28/11/2026, planche « 1 bis ») : même grammaire que la Réputation.
--   - liste : sections repliables (chevron, petites capitales, trait sombre), compétences en gris clair,
--     barre striée gris bleuté dans une case, ligne survolée ou choisie sur une bande plus claire ;
--   - détail à droite : nom en gras, traits sombres, même barre, description en gris clair.
-- La case de détail n'a pas été relevée : elle est habillée d'après ce qu'elle contient (textes, traits,
-- barres, défilement, cases à cocher, boutons).
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local function tr() return CUI:Tr("FJ_FICHE") end

-- Barre d'une ligne ou du détail : un cadre qui porte un remplissage « Fill ».
local function findBar(frame)
    if frame.SkillsBar then return frame.SkillsBar end
    for _, child in ipairs({ frame:GetChildren() }) do
        if child.Fill then return child end
    end
end

local function skinRow(row)
    if row.StateIcon then
        CUI:SkinListHeader(row)
        return
    end
    local content = row.Content
    if not content or row.cuiSkill then return end
    row.cuiSkill = true
    if content.Name then
        local c = C.texteSecondaire
        content.Name:SetTextColor(c[1], c[2], c[3])
    end
    CUI:SkinStatBar(findBar(content))
    CUI:SkinRowHighlight(content.BackgroundHighlight)
end

-- Traits du jeu (« ...ScrollLine... ») parmi les textures d'un cadre.
local function separators(frame)
    for _, r in ipairs({ frame:GetRegions() }) do
        if r:GetObjectType() == "Texture" then
            local atlas = r.GetAtlas and r:GetAtlas()
            if type(atlas) == "string" and atlas:find("ScrollLine", 1, true) then CUI:SkinSeparator(r) end
        end
    end
end

-- Case de détail, habillée d'après son contenu.
local function skinDetail(frame, depth)
    if depth > 4 or frame.cuiDetail then return end
    frame.cuiDetail = true
    separators(frame)
    if frame.Title then
        frame.Title:SetFont(CUI:GetFont(), 14, "")
        frame.Title:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    end
    if frame.Subtitle then
        local c = C.texteDiscret
        frame.Subtitle:SetTextColor(c[1], c[2], c[3])
    end
    for _, child in ipairs({ frame:GetChildren() }) do
        local kind = child:GetObjectType()
        if child.Fill then
            CUI:SkinStatBar(child)
        elseif child.Track then
            CUI:SkinScrollBar(child)
        elseif kind == "CheckButton" then
            CUI:SkinCheckbox(child)
        elseif kind == "Button" and (child.Left or child.Center or child.Middle) then
            CUI:SkinButton(child)
        else
            if child.Shadows then CUI:SkinHideTextures(child.Shadows) end
            skinDetail(child, depth + 1)
        end
    end
end

-- Textes du détail (description) : gris clair, sauf le titre.
local function paintTexts(frame, depth)
    if depth > 6 or frame.cuiTitle then return end -- intertitres : gardés en gris (skinDetailContent)
    for _, r in ipairs({ frame:GetRegions() }) do
        if r:GetObjectType() == "FontString" and r ~= frame.Title and r ~= frame.Subtitle and not r.cuiKeep then
            local c = C.texteSecondaire
            r:SetTextColor(c[1], c[2], c[3])
        end
    end
    for _, child in ipairs({ frame:GetChildren() }) do
        if not child.Fill and child:GetObjectType() ~= "CheckButton" and child:GetObjectType() ~= "Button" then
            paintTexts(child, depth + 1)
        end
    end
end

-- Contenu du détail (recréé à chaque compétence choisie) : intertitres du jeu (bandeau doré
-- « UI-Character-Info-Title » et libellé) en petites capitales grises sur un trait sombre ; textes en gris
-- clair (les mots que le jeu met en blanc restent blancs).
local function skinDetailContent(content)
    if not content then return end
    for _, block in ipairs({ content:GetChildren() }) do
        local bg, label = block.Background, block.Label
        local atlas = bg and bg.GetAtlas and bg:GetAtlas()
        if type(atlas) == "string" and atlas:find("Info%-Title") and not block.cuiTitle then
            block.cuiTitle = true
            CUI:SkinHide(bg)
            local line = block:CreateTexture(nil, "ARTWORK")
            line:SetColorTexture(C.lisereSombre[1], C.lisereSombre[2], C.lisereSombre[3], 1)
            line:SetHeight(1)
            line:SetPoint("BOTTOMLEFT", 2, 8)
            line:SetPoint("BOTTOMRIGHT", -2, 8)
            if label then
                label:SetFont(CUI:GetFont(), 10, "")
                local busy = false
                local function restyle(fs, text)
                    if busy or type(text) ~= "string" then return end
                    busy = true
                    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                    fs:SetText(CUI:Upper(text))
                    fs:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
                    busy = false
                end
                _G.hooksecurefunc(label, "SetText", restyle)
                restyle(label, label:GetText())
            end
        elseif label and not block.cuiTitle then
            local c = C.texteSecondaire
            label:SetTextColor(c[1], c[2], c[3])
        end
    end
end

local function skinSkills()
    local sf = _G.SkillsFrame or _G.SkillFrame
    if not sf or (sf.IsForbidden and sf:IsForbidden()) then return end
    CUI:SkinHideTextures(sf)
    CUI:SkinScrollBar(sf.ScrollBar)
    local box = sf.ScrollBox
    if box then
        if box.Shadows then CUI:SkinHideTextures(box.Shadows) end
        for _, child in ipairs({ box:GetChildren() }) do separators(child) end
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
    -- Détail : à chaque compétence choisie (son titre change), le contenu recréé est habillé, une fois
    -- que le jeu l'a posé.
    local detail = sf.SkillDetailFrame
    if detail then
        local function refresh()
            _G.C_Timer.After(0, function() CUI:SafeCall(tr(), skinDetailContent, detail.Content) end)
        end
        if detail.Title then _G.hooksecurefunc(detail.Title, "SetText", refresh) end
        detail:HookScript("OnShow", refresh)
        refresh()
    end
    -- Le reste de la page (case de détail) : tout ce qui n'est pas la liste.
    for _, child in ipairs({ sf:GetChildren() }) do
        if child ~= box and child ~= sf.ScrollBar then
            skinDetail(child, 0)
            local function repaint() CUI:SafeCall(tr(), paintTexts, child, 0) end
            child:HookScript("OnShow", repaint)
            for _, sub in ipairs({ child:GetChildren() }) do
                local inner = sub.ScrollBox
                if inner and inner.Update then _G.hooksecurefunc(inner, "Update", repaint) end
            end
            if box and box.Update then _G.hooksecurefunc(box, "Update", repaint) end
            repaint()
        end
    end
end

M.fichePages = M.fichePages or {}
M.fichePages[#M.fichePages + 1] = skinSkills
