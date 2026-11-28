-- Fenêtres du jeu · Fiche du personnage · page Réputation (maquette « fiche complète » validée le
-- 28/11/2026, planche « 1 bis ») :
--   - liste : sections repliables (chevron, petites capitales, trait sombre), factions en gris clair,
--     barre striée dans une case (couleur de l'attitude, celle du jeu), ligne survolée ou choisie sur une
--     bande un peu plus claire, défilement fin ;
--   - détail à droite : nom en gras, attitude en gris, traits sombres, même barre, description en gris
--     clair, cases à cocher de CœurUI, bouton « Afficher le renom » de CœurUI.
-- Les pièces viennent du noyau (Core/UI/Skin.lua). Rien n'est déplacé : seul l'aspect change.
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local function tr() return CUI:Tr("FJ_FICHE") end

-- Une ligne de la liste (le jeu les recycle) : en-tête de section ou faction.
local function skinRow(row)
    if row.StateIcon then
        CUI:SkinListHeader(row)
        return
    end
    local content = row.Content
    if not content or row.cuiFaction then return end
    row.cuiFaction = true
    if content.Name then
        local c = C.texteSecondaire
        content.Name:SetTextColor(c[1], c[2], c[3])
    end
    CUI:SkinStatBar(content.ReputationBar)
    CUI:SkinRowHighlight(content.BackgroundHighlight)
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

-- Texte de description (ScrollBox du détail) : gris clair.
local function paintDescription(box)
    local target = box and box.ScrollTarget
    if not target then return end
    for _, child in ipairs({ target:GetChildren() }) do
        for _, r in ipairs({ child:GetRegions() }) do
            if r:GetObjectType() == "FontString" then
                local c = C.texteSecondaire
                r:SetTextColor(c[1], c[2], c[3])
            end
        end
    end
end

local function skinDetail(detail)
    if not detail then return end
    if detail.Title then
        detail.Title:SetFont(CUI:GetFont(), 14, "")
        detail.Title:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    end
    if detail.Subtitle then
        local c = C.texteDiscret
        detail.Subtitle:SetTextColor(c[1], c[2], c[3])
    end
    if detail.Divider then CUI:SkinSeparator(detail.Divider) end
    CUI:SkinStatBar(detail.StandingBar)
    for _, key in ipairs({ "AtWarCheckbox", "MakeInactiveCheckbox", "WatchFactionCheckbox" }) do
        CUI:SkinCheckbox(detail[key])
    end
    CUI:SkinButton(detail.ViewRenownButton)
    CUI:SkinScrollBar(detail.DescriptionScrollBar)
    local desc = detail.Description and detail.Description.ScrollBox
    if desc then
        if desc.Shadows then CUI:SkinHideTextures(desc.Shadows) end
        if desc.Update then
            _G.hooksecurefunc(desc, "Update", function() CUI:SafeCall(tr(), paintDescription, desc) end)
        end
        detail:HookScript("OnShow", function() CUI:SafeCall(tr(), paintDescription, desc) end)
        paintDescription(desc)
    end
end

local function skinReputation()
    local rf = _G.ReputationFrame
    if not rf or (rf.IsForbidden and rf:IsForbidden()) then return end
    CUI:SkinHideTextures(rf)
    CUI:SkinScrollBar(rf.ScrollBar)
    local box = rf.ScrollBox
    if box then
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
        rf:HookScript("OnShow", function() CUI:SafeCall(tr(), each) end)
        each()
    end
    skinDetail(rf.ReputationDetailFrame)
end

M.fichePages = M.fichePages or {}
M.fichePages[#M.fichePages + 1] = skinReputation
