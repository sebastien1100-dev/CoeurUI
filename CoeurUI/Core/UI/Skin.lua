-- Habillage des fenêtres du jeu au style de CœurUI (« Givre ») : pièces communes, réutilisées par
-- chaque fenêtre du module « Skin Blizzard ». On ne remplace aucune fonction du jeu : son décor est
-- rendu invisible (pour de bon : il ne peut plus le remettre) et le nôtre est posé dessous ou dessus.
--
--   CUI:SkinHide(region)                 -- invisible pour de bon
--   CUI:SkinWindow(cadre)                -- cadre de fenêtre (NineSlice, portrait, fond) : panneau du thème
--   CUI:SkinCloseButton(bouton)          -- croix grise, blanche au survol
--   CUI:SkinScrollBar(barre)             -- barre de défilement fine (modèle « minimal » du jeu)
--   CUI:SkinButton(bouton)               -- bouton à texte du jeu : bouton de CœurUI
--   CUI:SkinIconButton(bouton, icone)    -- petit bouton carré à icône : case du thème
--   CUI:SkinItemSlot(bouton)             -- case d'objet (équipement) : case du thème, liseré de qualité
--   CUI:SkinSideTab(onglet)              -- onglet de côté à icône : case, liseré quand il est ouvert
local _, CUI = ...
local C = CUI.Colors

local WHITE = "Interface\\Buttons\\WHITE8x8"
local issecret = _G.issecretvalue or function() return false end

local hidden = setmetatable({}, { __mode = "k" })

function CUI:SkinHide(region)
    if not region or not region.SetAlpha or hidden[region] then return end
    if region.IsForbidden and region:IsForbidden() then return end
    hidden[region] = true
    region:SetAlpha(0)
    _G.hooksecurefunc(region, "SetAlpha", function(self, a)
        if a ~= 0 then self:SetAlpha(0) end
    end)
end

-- Toutes les textures d'un cadre (pas celles de ses enfants), sauf celles qu'on garde.
function CUI:SkinHideTextures(frame, keep)
    if not frame or not frame.GetRegions then return end
    for _, r in ipairs({ frame:GetRegions() }) do
        if r:GetObjectType() == "Texture" and not (keep and keep[r]) then self:SkinHide(r) end
    end
end

-- Fenêtre -----------------------------------------------------------------------------------------

function CUI:SkinWindow(frame)
    if not frame or frame.cuiPanel then return frame and frame.cuiPanel end
    for _, key in ipairs({ "NineSlice", "PortraitContainer", "Bg", "TitleBg", "TopTileStreaks", "Inset" }) do
        local part = frame[key]
        if part then self:SkinHide(part) end
    end
    local portrait = frame.GetName and frame:GetName() and _G[frame:GetName() .. "Portrait"]
    if portrait then self:SkinHide(portrait) end
    frame.cuiPanel = self:CreatePanel(frame, { fill = C.fenetre })
    return frame.cuiPanel
end

-- Croix : deux traits tournés, gris, blancs au survol (comme la fenêtre de CœurUI).
function CUI:SkinCloseButton(b)
    if not b or b.cuiSkinned then return end
    b.cuiSkinned = true
    self:SkinHideTextures(b)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t then self:SkinHide(t) end
    end
    local lines = {}
    for i, angle in ipairs({ 45, -45 }) do
        local t = b:CreateTexture(nil, "OVERLAY")
        t:SetTexture(WHITE)
        t:SetSize(13, 2)
        t:SetPoint("CENTER")
        t:SetRotation(math.rad(angle))
        lines[i] = t
    end
    local function paint(c)
        for _, t in ipairs(lines) do t:SetVertexColor(c[1], c[2], c[3], 1) end
    end
    paint(C.texteDiscret)
    b:HookScript("OnEnter", function() paint(C.texte) end)
    b:HookScript("OnLeave", function() paint(C.texteDiscret) end)
end

-- Défilement -------------------------------------------------------------------------------------

-- Barre « minimal » du jeu (Track, Thumb, Back, Forward) : rail sombre de 4 points, curseur gris clair.
function CUI:SkinScrollBar(bar)
    if not bar or bar.cuiSkinned then return end
    bar.cuiSkinned = true
    local track = bar.Track
    if track then
        self:SkinHideTextures(track)
        local rail = track:CreateTexture(nil, "BACKGROUND")
        rail:SetTexture(WHITE)
        rail:SetVertexColor(C.case[1], C.case[2], C.case[3], 1)
        rail:SetPoint("TOP", 0, 0)
        rail:SetPoint("BOTTOM", 0, 0)
        rail:SetWidth(4)
        local thumb = track.Thumb
        if thumb then
            self:SkinHideTextures(thumb)
            local t = thumb:CreateTexture(nil, "ARTWORK")
            t:SetTexture(WHITE)
            t:SetPoint("TOP", 0, 0)
            t:SetPoint("BOTTOM", 0, 0)
            t:SetWidth(4)
            local function paint(over)
                local c = over and C.texteDiscret or C.bordureDiscrete
                t:SetVertexColor(c[1], c[2], c[3], 1)
            end
            paint(false)
            thumb:HookScript("OnEnter", function() paint(true) end)
            thumb:HookScript("OnLeave", function() paint(false) end)
        end
    end
    -- Flèches : invisibles (la molette et le curseur suffisent), toujours cliquables.
    for _, key in ipairs({ "Back", "Forward" }) do
        local arrow = bar[key]
        if arrow then
            self:SkinHideTextures(arrow)
            if arrow.Texture then self:SkinHide(arrow.Texture) end
        end
    end
end

-- Boutons ------------------------------------------------------------------------------------------

-- Bouton à texte du jeu (gauche, centre, droite ou une texture d'état) : liseré et fond de CœurUI ;
-- survol au liseré de la couleur des boutons.
function CUI:SkinButton(b)
    if not b or b.cuiSkinned then return end
    b.cuiSkinned = true
    for _, key in ipairs({ "Left", "Right", "Middle", "Center", "StateTexture" }) do
        if b[key] then self:SkinHide(b[key]) end
    end
    local name = b.GetName and b:GetName()
    if name then
        for _, suffix in ipairs({ "Left", "Right", "Middle" }) do
            if _G[name .. suffix] then self:SkinHide(_G[name .. suffix]) end
        end
    end
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t then self:SkinHide(t) end
    end
    local border, fill = self:CreateBorderedRect(b, 4, C.bordure, C.graphite, "BACKGROUND", -7)
    local function paint(over)
        border:SetColor(over and C.or_ or C.bordure)
        fill:SetColor(over and C.graphiteClair or C.graphite)
    end
    paint(false)
    b:HookScript("OnEnter", function() paint(true) end)
    b:HookScript("OnLeave", function() paint(false) end)
end

-- Petit bouton carré à icône (zoom, rotation...) : case du thème, icône grise, blanche au survol.
function CUI:SkinIconButton(b, icon)
    if not b or b.cuiSkinned then return end
    b.cuiSkinned = true
    icon = icon or b.Icon
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t and t ~= icon then self:SkinHide(t) end
    end
    for _, key in ipairs({ "NormalTexture", "PushedTexture", "HighlightTexture" }) do
        if b[key] and b[key] ~= icon then self:SkinHide(b[key]) end
    end
    b.cuiPanel = self:CreatePanel(b, { radius = 3, fill = C.case, shadow = false, inset = 3 })
    local function paint(over)
        b.cuiPanel.border:SetColor(over and C.or_ or C.lisereSombre)
        if icon then
            local c = over and C.texte or C.texteSecondaire
            icon:SetDesaturated(true)
            icon:SetVertexColor(c[1], c[2], c[3], 1)
        end
    end
    paint(false)
    b:HookScript("OnEnter", function() paint(true) end)
    b:HookScript("OnLeave", function() paint(false) end)
end

-- Case d'objet ------------------------------------------------------------------------------------

-- Case d'équipement du jeu : icône rognée dans une case du thème ; le liseré extérieur prend la couleur
-- de la qualité que le jeu donne à son contour (recopiée telle quelle). Case vide : le dessin de
-- l'emplacement, très discret (CUI:SetItemSlotEmpty).
function CUI:SkinItemSlot(b)
    if not b or b.cuiSkinned then return end
    b.cuiSkinned = true
    local name = b:GetName()
    local icon = b.icon or b.Icon or (name and _G[name .. "IconTexture"])
    if icon then
        if b.Mask and icon.RemoveMaskTexture then pcall(icon.RemoveMaskTexture, icon, b.Mask) end
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        b.cuiIcon = icon
    end
    local normal = b.GetNormalTexture and b:GetNormalTexture()
    if normal then self:SkinHide(normal) end
    if b.BorderFrame then self:SkinHide(b.BorderFrame) end
    -- Décor ajouté par le jeu autour de certaines cases (munitions de Forever : cadre doré
    -- « UI-Character-Info-GearSlot... », flèche dans un cadre enfant, second contour « NormalTexture »).
    local function isDecor(r)
        if r:GetObjectType() ~= "Texture" then return false end
        local atlas = r.GetAtlas and r:GetAtlas()
        if type(atlas) == "string" and not issecret(atlas) and atlas:find("^UI%-Character%-Info%-GearSlot") then
            return true
        end
        return name ~= nil and r:GetName() == name .. "NormalTexture"
    end
    for _, r in ipairs({ b:GetRegions() }) do
        if isDecor(r) then self:SkinHide(r) end
    end
    for _, child in ipairs({ b:GetChildren() }) do
        for _, r in ipairs({ child:GetRegions() }) do
            if isDecor(r) then self:SkinHide(r) end
        end
    end
    b.cuiPanel = self:CreatePanel(b, { radius = 3, fill = C.case, shadow = false })
    local hl = b.GetHighlightTexture and b:GetHighlightTexture()
    if hl and icon then
        hl:SetColorTexture(1, 1, 1, 0.08)
        hl:SetAllPoints(icon)
    end
    local pushed = b.GetPushedTexture and b:GetPushedTexture()
    if pushed and icon then
        pushed:SetColorTexture(0, 0, 0, 0.3)
        pushed:SetAllPoints(icon)
    end
    -- Contour de qualité du jeu : invisible ; sa couleur passe à notre liseré.
    local qb = b.IconBorder
    local function sync()
        local r, g, bl
        if qb and qb:IsShown() then r, g, bl = qb:GetVertexColor() end
        -- Contour blanc ou gris (objet commun ou médiocre) : pas de liseré de qualité, comme dans les sacs
        -- (à partir de « Peu commun » seulement). Couleur cachée par le jeu : passée telle quelle.
        if r and not (issecret(r) or issecret(g) or issecret(bl))
            and math.abs(r - g) < 0.06 and math.abs(g - bl) < 0.06 then
            r = nil
        end
        if b.cuiOver then
            b.cuiPanel.border:SetColor(C.or_)
        elseif r then
            b.cuiPanel.border:SetColor({ r, g, bl, 1 })
        else
            b.cuiPanel.border:SetColor(C.lisereSombre)
        end
    end
    if qb then
        self:SkinHide(qb)
        _G.hooksecurefunc(qb, "SetVertexColor", sync)
        _G.hooksecurefunc(qb, "Show", sync)
        _G.hooksecurefunc(qb, "Hide", sync)
        if qb.SetShown then _G.hooksecurefunc(qb, "SetShown", sync) end
    end
    b:HookScript("OnEnter", function() b.cuiOver = true sync() end)
    b:HookScript("OnLeave", function() b.cuiOver = false sync() end)
    b.cuiSync = sync
    sync()
end

-- Case vide : le dessin de l'emplacement du jeu, très discret ; objet : icône pleine.
function CUI:SetItemSlotEmpty(b, empty)
    if b.cuiIcon then
        b.cuiIcon:SetDesaturated(empty and true or false)
        b.cuiIcon:SetAlpha(empty and 0.18 or 1)
    end
end

-- Onglets -------------------------------------------------------------------------------------------

-- Onglet de côté (icône) : case du thème avec ombre ; ouvert (texture « Selected » du jeu montrée) :
-- icône vive et liseré de la couleur des boutons ; fermé : icône un peu terne.
function CUI:SkinSideTab(tab)
    if not tab or tab.cuiSkinned then return end
    tab.cuiSkinned = true
    local icon = tab.Icon
    if icon and tab.Mask and icon.RemoveMaskTexture then pcall(icon.RemoveMaskTexture, icon, tab.Mask) end
    if icon then
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 4, -4)
        icon:SetPoint("BOTTOMRIGHT", -4, 4)
    end
    for _, key in ipairs({ "Background", "TabGlow", "HighlightTexture" }) do
        if tab[key] then self:SkinHide(tab[key]) end
    end
    local selected = tab.SelectedTexture
    tab.cuiPanel = self:CreatePanel(tab, { radius = 4, fill = C.case, inset = 1 })
    local function paint()
        local on = selected and selected:IsShown()
        local c = (on or tab.cuiOver) and C.or_ or C.lisereSombre
        tab.cuiPanel.border:SetColor(c)
        tab.cuiPanel:SetFillColor(on and C.panneau or C.case)
        if icon then
            local k = on and 1 or 0.7
            icon:SetVertexColor(k, k, k, 1)
        end
    end
    if selected then
        self:SkinHide(selected)
        _G.hooksecurefunc(selected, "Show", paint)
        _G.hooksecurefunc(selected, "Hide", paint)
        if selected.SetShown then _G.hooksecurefunc(selected, "SetShown", paint) end
    end
    tab:HookScript("OnEnter", function() tab.cuiOver = true paint() end)
    tab:HookScript("OnLeave", function() tab.cuiOver = false paint() end)
    paint()
end

-- Texte d'en-tête en petites capitales (accents compris) ; les textes cachés par le jeu restent tels quels.
local ACCENTS = { ["é"] = "É", ["è"] = "È", ["ê"] = "Ê", ["ë"] = "Ë", ["à"] = "À", ["â"] = "Â", ["ä"] = "Ä",
                  ["î"] = "Î", ["ï"] = "Ï", ["ô"] = "Ô", ["ö"] = "Ö", ["ù"] = "Ù", ["û"] = "Û", ["ü"] = "Ü",
                  ["ç"] = "Ç", ["œ"] = "Œ" }
function CUI:Upper(text)
    if type(text) ~= "string" or issecret(text) then return text end
    return (text:upper():gsub("[\195\197][\128-\191]", function(c) return ACCENTS[c] or c end))
end
