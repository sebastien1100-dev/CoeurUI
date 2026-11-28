-- Habillage des fenêtres du jeu au style de CœurUI (« Givre ») : pièces communes, réutilisées par
-- chaque fenêtre du module « Skin Blizzard ». On ne remplace aucune fonction du jeu : son décor est
-- rendu invisible (pour de bon : il ne peut plus le remettre) et le nôtre est posé dessous ou dessus.
--
--   CUI:SkinHide(region)                 -- invisible pour de bon
--   CUI:SkinWindow(cadre)                -- cadre de fenêtre (NineSlice, portrait, fond) : panneau du thème
--   CUI:SkinCloseButton(bouton)          -- croix grise, blanche au survol
--   CUI:SkinMovable(cadre, store, cle)   -- fenêtre déplaçable par son bandeau, place gardée
--   CUI:SkinScrollBar(barre)             -- barre de défilement fine (modèle « minimal » du jeu)
--   CUI:SkinButton(bouton)               -- bouton à texte du jeu : bouton de CœurUI
--   CUI:SkinIconButton(bouton, icone, picto) -- petit bouton carré à icône : case du thème ; picto : une
--                                            -- de nos icônes au trait (Media/Icones) à la place de celle du jeu
--   CUI:SkinItemSlot(bouton)             -- case d'objet (équipement) : case du thème, liseré de qualité
--   CUI:SquareItemIcon(bouton, icone)    -- icône d'un bouton d'objet du jeu sans ses coins arrondis
--   CUI:SkinSideTab(onglet, picto)       -- onglet de côté à icône : case, liseré clair quand il est ouvert
-- Pas d'or dans les fenêtres du jeu (direction des icônes) : survol et ouvert au liseré gris clair ; sauf
-- les cases d'objet, survolées en or comme les boutons des barres d'actions.
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

-- Fenêtre déplaçable : on la prend par son bandeau de titre (hauteur `height`, la croix à droite laissée
-- libre) ; sa place est gardée dans store[key] et remise à chaque ouverture, et après chaque fois que le
-- jeu range ses fenêtres (UpdateUIPanelPositions). Jamais en combat si le cadre est protégé.
--   CUI:SkinMovable(cadre, store, cle, hauteur)
function CUI:SkinMovable(frame, store, key, height)
    if not frame or frame.cuiMovable or type(store) ~= "table" then return end
    frame.cuiMovable = true
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    local function locked()
        return frame:IsProtected() and _G.InCombatLockdown()
    end
    local function apply()
        local pos = store[key]
        if type(pos) ~= "table" or locked() then return end
        frame:ClearAllPoints()
        frame:SetPoint(pos[1], _G.UIParent, pos[2], pos[3], pos[4])
    end
    local grip = _G.CreateFrame("Frame", nil, frame)
    grip:SetPoint("TOPLEFT", 0, 0)
    grip:SetPoint("TOPRIGHT", -32, 0)
    grip:SetHeight(height or 24)
    grip:EnableMouse(true)
    grip:RegisterForDrag("LeftButton")
    grip:SetScript("OnDragStart", function()
        if not locked() then frame:StartMoving() end
    end)
    grip:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        if frame.SetUserPlaced then frame:SetUserPlaced(false) end -- c'est nous qui gardons la place
        local point, _, relPoint, x, y = frame:GetPoint(1)
        if point then store[key] = { point, relPoint, x, y } end
    end)
    frame:HookScript("OnShow", apply)
    if type(_G.UpdateUIPanelPositions) == "function" then
        _G.hooksecurefunc("UpdateUIPanelPositions", function()
            if frame:IsShown() then apply() end
        end)
    end
    apply()
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

-- Une de nos icônes au trait, posée au centre d'un cadre (teinte donnée ensuite).
local function picto(frame, name, size)
    local t = frame:CreateTexture(nil, "OVERLAY")
    t:SetTexture(CUI.MEDIA .. "Icones\\" .. name)
    t:SetSize(size, size)
    t:SetPoint("CENTER")
    return t
end

-- Petit bouton carré à icône (zoom, rotation...) : case du thème, icône grise, blanche au survol.
function CUI:SkinIconButton(b, icon, pictoName)
    if not b or b.cuiSkinned then return end
    b.cuiSkinned = true
    icon = icon or b.Icon
    if pictoName then
        if icon then self:SkinHide(icon) end
        icon = picto(b, pictoName, 14)
        b.cuiPicto = icon
    end
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t and t ~= icon then self:SkinHide(t) end
    end
    for _, key in ipairs({ "NormalTexture", "PushedTexture", "HighlightTexture" }) do
        if b[key] and b[key] ~= icon then self:SkinHide(b[key]) end
    end
    b.cuiPanel = self:CreatePanel(b, { radius = 3, fill = C.case, shadow = false, inset = 3 })
    local function paint(over)
        b.cuiPanel.border:SetColor(over and C.texteDiscret or C.lisereSombre)
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

-- Icône carrée sur un bouton d'objet du jeu (équipement, sacs, banque...) : le jeu masque son icône
-- (coins arrondis) et ce masque résiste. L'icône du jeu devient donc invisible et une copie à nous, sans
-- masque, la remplace à la même place ; la copie suit tout ce que le jeu fait de l'icône (dessin, atlas,
-- grisé, teinte, transparence, montrée ou cachée). Rend la copie (à utiliser comme icône ensuite).
--   CUI:SquareItemIcon(bouton, icone)
function CUI:SquareItemIcon(b, icon)
    icon = icon or (b and (b.icon or b.Icon))
    if not b or not icon then return end
    if icon.cuiCopy then return icon.cuiCopy end
    local layer, sub = icon:GetDrawLayer()
    local copy = b:CreateTexture(nil, layer or "BORDER", nil, math.min(7, (sub or 0) + 1))
    copy:SetAllPoints(icon)
    icon.cuiCopy = copy
    local wanted = icon:GetAlpha()
    local inside = false
    local function sync()
        if inside then return end
        inside = true
        local atlas = icon.GetAtlas and icon:GetAtlas()
        if type(atlas) == "string" and atlas ~= "" and not issecret(atlas) then
            copy:SetAtlas(atlas)
        else
            -- Icône d'objet : le liseré sombre aux coins arrondis est dessiné dans l'image ; rogné de 8 %
            -- de chaque côté, toujours (le jeu remet l'image entière à chaque mise à jour).
            copy:SetTexture(icon:GetTexture())
            copy:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end
        if icon.IsDesaturated then copy:SetDesaturated(icon:IsDesaturated() and true or false) end
        local cr, cg, cb, ca = icon:GetVertexColor()
        if type(cr) == "number" and not issecret(cr) then copy:SetVertexColor(cr, cg, cb, ca or 1) end
        copy:SetShown(icon:IsShown())
        copy:SetAlpha(wanted)
        icon:SetAlpha(0)
        inside = false
    end
    -- La transparence voulue par le jeu va à la copie ; l'icône du jeu reste invisible.
    _G.hooksecurefunc(icon, "SetAlpha", function(_, a)
        if inside then return end
        if type(a) == "number" and not issecret(a) then wanted = a end
        sync()
    end)
    for _, method in ipairs({ "SetTexture", "SetAtlas", "SetTexCoord", "SetDesaturated", "SetDesaturation",
                              "SetVertexColor", "Show", "Hide", "SetShown" }) do
        if icon[method] then _G.hooksecurefunc(icon, method, sync) end
    end
    sync()
    return copy
end

-- Case d'équipement du jeu : icône rognée dans une case carrée du thème (le jeu fait ses cases en
-- 37 x 36 : la nôtre prend le plus petit côté, centrée) ; le liseré extérieur prend la couleur de la
-- qualité que le jeu donne à son contour (recopiée telle quelle). Case vide : unie (CUI:SetItemSlotEmpty).
function CUI:SkinItemSlot(b)
    if not b or b.cuiSkinned then return end
    b.cuiSkinned = true
    local name = b:GetName()
    local icon = b.icon or b.Icon or (name and _G[name .. "IconTexture"])
    local w, h = b:GetSize()
    local side = (w and h and w > 0 and h > 0) and math.floor(math.min(w, h)) or nil
    if icon then
        CUI:SquareItemIcon(b, icon)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:ClearAllPoints()
        if side then
            icon:SetPoint("CENTER")
            icon:SetSize(side - 4, side - 4)
        else
            icon:SetPoint("TOPLEFT", 2, -2)
            icon:SetPoint("BOTTOMRIGHT", -2, 2)
        end
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
    -- Case carrée : sur un cadre à la taille du plus petit côté, sous la case du jeu.
    local holder = b
    if side then
        holder = _G.CreateFrame("Frame", nil, b)
        holder:SetSize(side, side)
        holder:SetPoint("CENTER")
        holder:SetFrameLevel(math.max(0, b:GetFrameLevel() - 1))
    end
    b.cuiPanel = self:CreatePanel(holder, { radius = 3, fill = C.case, shadow = false })
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
        -- Comme les boutons des barres d'actions : appuyé, or clair ; survolé, or.
        if b.cuiDown then
            b.cuiPanel.border:SetColor(C.orClair)
        elseif b.cuiOver then
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
    b:HookScript("OnLeave", function() b.cuiOver = false b.cuiDown = false sync() end)
    b:HookScript("OnMouseDown", function() b.cuiDown = true sync() end)
    b:HookScript("OnMouseUp", function() b.cuiDown = false sync() end)
    b.cuiSync = sync
    sync()
end

-- Case vide : unie (le dessin de l'emplacement du jeu caché ; l'infobulle le nomme) ; objet : icône pleine.
function CUI:SetItemSlotEmpty(b, empty)
    if b.cuiIcon then
        b.cuiIcon:SetDesaturated(false)
        b.cuiIcon:SetAlpha(empty and 0 or 1)
    end
end

-- Onglets -------------------------------------------------------------------------------------------

-- Onglet de côté (icône) : case du thème avec ombre ; ouvert (texture « Selected » du jeu montrée) :
-- case plus claire, liseré gris clair. Avec picto : notre icône au trait (grise, blanche au survol et
-- ouvert) à la place de celle du jeu ; sans : celle du jeu, un peu terne quand l'onglet est fermé.
function CUI:SkinSideTab(tab, pictoName)
    if not tab or tab.cuiSkinned then return end
    tab.cuiSkinned = true
    local icon = tab.Icon
    local line
    if pictoName then
        if icon then self:SkinHide(icon) end
        icon = nil
        line = picto(tab, pictoName, 24)
    end
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
        tab.cuiPanel.border:SetColor(on and C.texteDiscret or (tab.cuiOver and C.bordureDiscrete or C.lisereSombre))
        tab.cuiPanel:SetFillColor(on and C.panneau or C.case)
        if icon then
            local k = on and 1 or 0.7
            icon:SetVertexColor(k, k, k, 1)
        end
        if line then
            local c = (on or tab.cuiOver) and C.texte or C.texteSecondaire
            line:SetVertexColor(c[1], c[2], c[3], 1)
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
