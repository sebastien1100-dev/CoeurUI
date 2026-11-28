-- Fenêtres du jeu · Fiche du personnage (maquette validée le 28/11/2026, planche « Fenêtres du jeu · 1 ·
-- Fiche du personnage », fiche de WoW Forever) : la fiche du jeu (CharacterFrame) habillée, même
-- disposition :
--   - cadre des fenêtres de CœurUI, nom au centre, croix grise ; portrait, décor doré et fonds de pierre
--     invisibles ;
--   - personnage sur un fond de case ; boutons zoom, rotation, retour en petites cases ;
--   - cases d'équipement du thème (liseré de la qualité, survol de la couleur des boutons ; case vide :
--     le dessin de l'emplacement, très discret) ;
--   - statistiques : titres de section en petites capitales sur un trait sombre, une ligne sur deux plus
--     claire, barre de défilement fine ; mêmes habits pour les titres et les ensembles d'équipement ;
--   - onglets de côté en cases du thème (l'ouvert au liseré de la couleur des boutons).
-- Les pièces viennent du noyau (Core/UI/Skin.lua). Rien n'est déplacé : seul l'aspect change.
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local WHITE = "Interface\\Buttons\\WHITE8x8"

-- Lignes des statistiques ----------------------------------------------------------------------------

local function line(parent, color)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], 1)
    return t
end

-- Titre de section (« Général »...) : petites capitales grises sur un trait sombre.
local function skinCategory(row)
    if row.cuiSkinned then return end
    row.cuiSkinned = true
    if row.Background then CUI:SkinHide(row.Background) end
    local title = row.Title
    if title then
        title:SetFont(CUI:GetFont(), 10, "")
        title:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
        local busy = false
        local function upper(self, text)
            if busy or type(text) ~= "string" then return end
            busy = true
            self:SetText(CUI:Upper(text))
            self:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
            busy = false
        end
        _G.hooksecurefunc(title, "SetText", upper)
        upper(title, title:GetText())
        local l = line(row, C.lisereSombre)
        l:SetHeight(1)
        l:SetPoint("BOTTOMLEFT", 4, 6)
        l:SetPoint("BOTTOMRIGHT", -4, 6)
    end
end

-- Icône d'une ligne (résistances de Forever : atlas « UI-Character-Info-Resistance-... » avec son cadre
-- brun dessiné dedans, que le jeu redécoupe à chaque fois) : petite case du thème à la place de
-- l'icône ; l'icône y est agrandie dans un cadre qui coupe ce qui dépasse (le cadre brun).
local STAT_BOX, STAT_ZOOM = 18, 1.45
local function skinStatIcon(row)
    local icon = row.Icon
    -- Repère à l'endroit où le jeu a posé l'icône.
    local spot = _G.CreateFrame("Frame", nil, row)
    spot:SetSize(1, 1)
    for i = 1, icon:GetNumPoints() do
        local p, rel, rp, x, y = icon:GetPoint(i)
        if p then spot:SetPoint(p, rel, rp, x, y) end
    end
    local w, h = icon:GetSize()
    if not w or w <= 0 then w, h = STAT_BOX, STAT_BOX end
    spot:SetSize(w, h)
    local box = _G.CreateFrame("Frame", nil, row)
    box:SetSize(STAT_BOX, STAT_BOX)
    box:SetPoint("CENTER", spot, "CENTER")
    CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
    local clip = _G.CreateFrame("Frame", nil, box)
    clip:SetPoint("TOPLEFT", 2, -2)
    clip:SetPoint("BOTTOMRIGHT", -2, 2)
    clip:SetClipsChildren(true)
    local inner = STAT_BOX - 4
    local function place()
        icon:SetParent(clip)
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", clip, "CENTER")
        icon:SetSize(inner * STAT_ZOOM, inner * STAT_ZOOM)
    end
    _G.hooksecurefunc(icon, "SetAtlas", place)
    _G.hooksecurefunc(icon, "Show", function() box:Show() end)
    _G.hooksecurefunc(icon, "Hide", function() box:Hide() end)
    if icon.SetShown then _G.hooksecurefunc(icon, "SetShown", function(_, on) box:SetShown(on) end) end
    box:SetShown(icon:IsShown())
    place()
end

-- Ligne de statistique : son fond du jeu (une ligne sur deux) devient une bande un peu plus claire.
local function skinStat(row)
    if row.cuiSkinned then return end
    row.cuiSkinned = true
    local bg = row.Background
    if bg then
        local band = row:CreateTexture(nil, "BACKGROUND", nil, 1)
        band:SetTexture(WHITE)
        band:SetVertexColor(C.carte[1], C.carte[2], C.carte[3], 1)
        band:SetPoint("TOPLEFT", 2, 0)
        band:SetPoint("BOTTOMRIGHT", -2, 0)
        local function sync() band:SetShown(bg:IsShown()) end
        CUI:SkinHide(bg)
        _G.hooksecurefunc(bg, "Show", sync)
        _G.hooksecurefunc(bg, "Hide", sync)
        if bg.SetShown then _G.hooksecurefunc(bg, "SetShown", sync) end
        sync()
    end
    if row.Label then
        local c = C.texteSecondaire
        row.Label:SetTextColor(c[1], c[2], c[3])
    end
    if row.Icon then skinStatIcon(row) end
end

local function skinRow(row)
    if row.Title then skinCategory(row) elseif row.Label then skinStat(row) end
end

-- Liste qui défile (le jeu recycle ses lignes) : chaque ligne montrée est habillée.
local function skinScrollList(pane)
    if not pane then return end
    CUI:SkinHideTextures(pane)
    local box = pane.ScrollBox
    CUI:SkinScrollBar(pane.ScrollBar)
    if not box then return end
    if box.Shadows then CUI:SkinHideTextures(box.Shadows) end
    local function each()
        local target = box.ScrollTarget
        if not target then return end
        for _, row in ipairs({ target:GetChildren() }) do skinRow(row) end
    end
    if box.Update then _G.hooksecurefunc(box, "Update", function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), each) end) end
    pane:HookScript("OnShow", function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), each) end)
    each()
end

-- Équipement -----------------------------------------------------------------------------------------

local slots = {}

local function updateSlots()
    for _, b in ipairs(slots) do
        local id = b:GetID()
        local tex = id and _G.GetInventoryItemTexture("player", id)
        CUI:SetItemSlotEmpty(b, tex == nil)
        if b.cuiSync then b.cuiSync() end
    end
end

local function skinSlots()
    local items = _G.PaperDollItemsFrame
    if not items then return end
    local function add(b)
        if b and not b.cuiSkinned and b.GetObjectType and b:GetObjectType() == "Button" then
            CUI:SkinItemSlot(b)
            slots[#slots + 1] = b
        end
    end
    for _, b in ipairs({ items:GetChildren() }) do
        local name = b.GetName and b:GetName()
        if type(name) == "string" and name:find("^Character.+Slot$") then add(b) end
    end
    -- Munitions et relique (propres à Forever, rangées ailleurs dans la fiche).
    for _, name in ipairs({ "CharacterAmmoSlot", "CharacterRangedSlot", "CharacterRelicSlot" }) do
        add(_G[name])
    end
    if type(_G.PaperDollItemSlotButton_Update) == "function" then
        _G.hooksecurefunc("PaperDollItemSlotButton_Update", function()
            CUI:SafeCall(CUI:Tr("FJ_FICHE"), updateSlots)
        end)
    end
    M:On("PLAYER_EQUIPMENT_CHANGED", function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), updateSlots) end)
    updateSlots()
end

-- Bouton qui replie les statistiques : petite case, chevron vers la droite (replier) ou la gauche.
local function skinPaneToggle(b, pane)
    if not b then return end
    CUI:SkinHideTextures(b)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t then CUI:SkinHide(t) end
    end
    local panel = CUI:CreatePanel(b, { radius = 3, fill = C.case, shadow = false, inset = 4 })
    local icon = b:CreateTexture(nil, "OVERLAY")
    icon:SetTexture(CUI.MEDIA .. "Icones\\Chevron")
    icon:SetSize(12, 12)
    icon:SetPoint("CENTER")
    local function paint(over)
        local c = over and C.texte or C.texteSecondaire
        icon:SetVertexColor(c[1], c[2], c[3], 1)
        panel.border:SetColor(over and C.or_ or C.lisereSombre)
        local open = not pane or pane:IsShown()
        icon:SetRotation(open and (math.pi / 2) or (-math.pi / 2))
    end
    b:HookScript("OnEnter", function() paint(true) end)
    b:HookScript("OnLeave", function() paint(false) end)
    b:HookScript("OnClick", function() paint(b:IsMouseOver()) end)
    if pane then
        pane:HookScript("OnShow", function() paint(false) end)
        pane:HookScript("OnHide", function() paint(false) end)
    end
    paint(false)
end

-- Petits onglets en haut des statistiques (PaperDollSidebarTab1 à 3) : petites cases et nos icônes au
-- trait (celles du jeu ont leur cadre dessiné dedans) : gris clair, blanches au survol et sur l'onglet
-- ouvert (le jeu cache alors son voile « Hider »), au liseré plus clair.
-- Ordre de Forever : statistiques, ensembles d'équipement, titres.
local TAB_ICONS = { "Statistiques", "Ensembles", "Titre" }

local function tabIcon(_, i)
    return TAB_ICONS[i]
end

local function skinSidebarTabs()
    for i = 1, 5 do
        local tab = _G["PaperDollSidebarTab" .. i]
        if tab and not tab.cuiSkinned then
            tab.cuiSkinned = true
            local hider = tab.Hider
            for _, key in ipairs({ "TabBg", "Highlight", "Hider", "Icon" }) do
                if tab[key] then CUI:SkinHide(tab[key]) end
            end
            local hl = tab.GetHighlightTexture and tab:GetHighlightTexture()
            if hl then CUI:SkinHide(hl) end
            -- Tout le décor du jeu (cadres jaune, brun, gris selon l'état), sur l'onglet et ses enfants.
            CUI:SkinHideTextures(tab)
            for _, child in ipairs({ tab:GetChildren() }) do CUI:SkinHideTextures(child) end
            local name = tabIcon(tab, i)
            local icon
            if name then
                icon = tab:CreateTexture(nil, "OVERLAY")
                icon:SetTexture(CUI.MEDIA .. "Icones\\" .. name)
                icon:SetSize(18, 18)
                icon:SetPoint("CENTER")
            end
            local panel = CUI:CreatePanel(tab, { radius = 3, fill = C.case, shadow = false, inset = 1 })
            local function paint()
                local on = not (hider and hider:IsShown())
                -- Pas d'or sur les icônes (direction « trait + pastille ») : ouvert ou survolé, liseré clair.
                panel.border:SetColor((on or tab.cuiOver) and C.texteDiscret or C.lisereSombre)
                if icon then
                    local c = (on or tab.cuiOver) and C.texte or C.texteSecondaire
                    icon:SetVertexColor(c[1], c[2], c[3], 1)
                end
            end
            if hider then
                _G.hooksecurefunc(hider, "Show", paint)
                _G.hooksecurefunc(hider, "Hide", paint)
                if hider.SetShown then _G.hooksecurefunc(hider, "SetShown", paint) end
            end
            tab:HookScript("OnEnter", function() tab.cuiOver = true paint() end)
            tab:HookScript("OnLeave", function() tab.cuiOver = false paint() end)
            paint()
        end
    end
end

-- Fiche ------------------------------------------------------------------------------------------------

local function skinFiche()
    local f = _G.CharacterFrame
    if not f or (f.IsForbidden and f:IsForbidden()) then return end
    CUI:SkinWindow(f)
    CUI:SkinCloseButton(_G.CharacterFrameCloseButton)
    local title = _G.CharacterFrameTitleText
    if title then title:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
    -- Bandeau du titre : fondu dans le fond, un trait sombre dessous.
    local headerLine = line(f, C.lisereSombre)
    headerLine:SetHeight(1)
    headerLine:SetPoint("TOPLEFT", 2, -24)
    headerLine:SetPoint("TOPRIGHT", -2, -24)

    -- Colonnes : fonds de pierre invisibles ; un trait sombre entre les deux.
    CUI:SkinHideTextures(_G.CharacterFrameLeftPaneHost)
    local right = _G.CharacterFrameRightPaneHost
    if right then
        CUI:SkinHideTextures(right)
        for _, child in ipairs({ right:GetChildren() }) do CUI:SkinHideTextures(child) end
        local divider = line(right, C.lisereSombre)
        divider:SetWidth(1)
        divider:SetPoint("TOPLEFT", 0, 0)
        divider:SetPoint("BOTTOMLEFT", 0, 2)
    end
    local doll = _G.PaperDollFrame
    if doll and doll.TopBackgroundStripHost then CUI:SkinHideTextures(doll.TopBackgroundStripHost) end

    -- Statistiques, familier, titres, ensembles d'équipement.
    skinScrollList(_G.CharacterStatsPaneScrollBox)
    skinScrollList(_G.CharacterStatsPanePetScrollBox)
    if doll then
        skinScrollList(doll.TitleManagerPane)
        skinScrollList(doll.EquipmentManagerPane)
    end
    local statsPane = _G.CharacterStatsPane
    if statsPane then
        for _, child in ipairs({ statsPane:GetChildren() }) do skinRow(child) end
        if statsPane.ItemLevelFrame and statsPane.ItemLevelFrame.Background then
            CUI:SkinHide(statsPane.ItemLevelFrame.Background)
        end
    end
    for _, name in ipairs({ "PaperDollFrameEquipSet", "PaperDollFrameSaveSet", "PaperDollFrameNewSet" }) do
        CUI:SkinButton(_G[name])
    end

    -- Personnage : fond de case sombre, boutons en petites cases.
    local scene = _G.CharacterModelScene
    if scene then
        CUI:SkinHideTextures(scene)
        CUI:CreatePanel(scene, { radius = 3, fill = C.case, shadow = false })
        local controls = scene.ControlFrame
        if controls then
            for _, b in ipairs({ controls:GetChildren() }) do
                if b:GetObjectType() == "Button" then CUI:SkinIconButton(b, b.Icon) end
            end
        end
    end
    skinPaneToggle(_G.CharacterFrameRightPaneToggleButton, right)

    -- Onglets de côté.
    for i = 1, 10 do
        local tab = _G["CharacterFrameModeTab" .. i]
        if tab then CUI:SkinSideTab(tab) end
    end

    skinSidebarTabs()
    skinSlots()
    f:HookScript("OnShow", function()
        CUI:SafeCall(CUI:Tr("FJ_FICHE"), skinSidebarTabs) -- créés parfois après coup par le jeu
        CUI:SafeCall(CUI:Tr("FJ_FICHE"), updateSlots)
    end)
end

M.windows.fiche = { setup = skinFiche }
