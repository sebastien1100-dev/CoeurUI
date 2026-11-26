-- Mode déplacement des cadres : commun à tous les modules qui ont des cadres à placer à l'écran.
-- Le cadenas de la barre de titre (fenêtre principale) l'ouvre et le ferme.
--
--   CUI:RegisterMover({
--       key = "joueur", frame = cadre, label = "CLE_DU_NOM",            -- nom affiché sur le cadre
--       default = { "CENTER", "CENTER", -200, -150 },                   -- point, point de UIParent, x, y
--       onUnlock = function(cadre) end, onLock = function(cadre) end,   -- ex. montrer un exemple
--       parent = autreCadre,  -- facultatif : position rattachée à ce cadre (default aussi), qu'il suit
--       tagPoint = { "TOPLEFT", "BOTTOMLEFT", 0, -3 },  -- facultatif : étiquette ailleurs qu'au-dessus
--   On déplace un cadre en le glissant, ou en glissant son étiquette (son nom).
--   })
--   CUI:ResetMover("joueur")        -- remet un seul cadre à sa place d'origine
--   CUI:UnregisterMover("joueur")   -- quand le module est coupé
--
-- Grille aimantée (maquette validée) : tant que le cadenas est ouvert, une grille fine part du centre
-- de l'écran (axes du centre en doré). En glissant, un cadre est attiré (à moins de SNAP points)
-- par la grille (même cachée), les bords des autres cadres (alignés ou collés) et le centre de
-- l'écran ; un trait vert montre ce qui l'attire. Maj enfoncée : déplacement libre. Réglages
-- (grille affichée, taille, aimant) dans le panneau « Déplacement des cadres », gardés pour le
-- compte dans CUI.db.ui.grille.
--
-- Position gardée dans CUI.db.ui.movers[key]. Déplacement impossible en combat : un combat qui
-- commence verrouille tout seul (dernier moment où un cadre protégé peut encore être touché).
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local WHITE = "Interface\\Buttons\\WHITE8x8"
local GRID_SIZES = { 8, 16, 32, 48, 64 }
local SNAP = 8
local GRID_LINE = { 0.95, 0.95, 0.95, 0.07 }
local GRID_AXIS = { C.or_[1], C.or_[2], C.or_[3], 0.55 }

local movers = {}   -- clé -> définition
local unlocked = false
local panel
local drawGrid, stopDrag -- plus bas

local function saved()
    if type(CUI.db.ui.movers) ~= "table" then
        CUI.db.ui.movers = {}
    end
    return CUI.db.ui.movers
end

-- Réglages de la grille (créés à la première lecture).
local function gridSettings()
    local ui = CUI.db.ui
    if type(ui.grille) ~= "table" then ui.grille = {} end
    local g = ui.grille
    if g.afficher == nil then g.afficher = true end
    if type(g.taille) ~= "number" then g.taille = 32 end
    if g.aimant == nil then g.aimant = true end
    return g
end

local function solid(parent, layer, color)
    local t = parent:CreateTexture(nil, layer)
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    return t
end

-- Place le cadre à sa position gardée (ou par défaut). Jamais un cadre protégé en combat.
local function applyPosition(def)
    local frame = def.frame
    if _G.InCombatLockdown() and frame:IsProtected() then return end
    local pos = saved()[def.key] or def.default
    frame:ClearAllPoints()
    frame:SetPoint(pos[1], def.parent or _G.UIParent, pos[2] or pos[1], pos[3] or 0, pos[4] or 0)
end

local function savePosition(def)
    if def.parent then
        -- Écart entre le centre du cadre et celui du cadre de rattachement.
        local cx, cy = def.frame:GetCenter()
        local px, py = def.parent:GetCenter()
        if cx and px then
            local k = def.parent:GetEffectiveScale() / def.frame:GetEffectiveScale()
            saved()[def.key] = { "CENTER", "CENTER", math.floor(cx - px * k + 0.5), math.floor(cy - py * k + 0.5) }
        end
        applyPosition(def) -- de nouveau rattaché (le glisser l'avait accroché à l'écran)
        return
    end
    local point, _, relPoint, x, y = def.frame:GetPoint(1)
    if point then
        saved()[def.key] = { point, relPoint, math.floor(x + 0.5), math.floor(y + 0.5) }
    end
end

-- Coordonnées de l'écran (unités de UIParent) -------------------------------------------------

-- Rectangle d'un cadre : gauche, bas, largeur, hauteur.
local function uiRect(frame)
    local l, b, w, h = frame:GetRect()
    if not l then return end
    local k = frame:GetEffectiveScale() / _G.UIParent:GetEffectiveScale()
    return l * k, b * k, w * k, h * k
end

local function cursorUI()
    local x, y = _G.GetCursorPosition()
    local s = _G.UIParent:GetEffectiveScale()
    return x / s, y / s
end

-- Épaisseur d'un pixel de l'écran.
local function onePixel()
    local _, physicalHeight = _G.GetPhysicalScreenSize()
    if not physicalHeight or physicalHeight == 0 then return 1 end
    return 768 / physicalHeight / _G.UIParent:GetScale()
end

-- Grille et traits de l'aimant ------------------------------------------------------------------

local grid, guides
local gridLines = {}

drawGrid = function()
    if not grid then
        grid = _G.CreateFrame("Frame", nil, _G.UIParent)
        grid:SetAllPoints()
        grid:SetFrameStrata("BACKGROUND") -- sous toute l'interface
        grid:SetFrameLevel(0)
    end
    local g = gridSettings()
    local W, H = _G.UIParent:GetSize()
    local cx, cy = W / 2, H / 2
    local px = onePixel()
    local n = 0
    local function line(vertical, pos, color)
        n = n + 1
        local t = gridLines[n] or solid(grid, "BACKGROUND", color)
        gridLines[n] = t
        t:SetVertexColor(color[1], color[2], color[3], color[4])
        t:ClearAllPoints()
        if vertical then
            t:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", pos, 0)
            t:SetSize(px, H)
        else
            t:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", 0, pos)
            t:SetSize(W, px)
        end
        t:Show()
    end
    local size = g.taille
    for i = -math.ceil(cx / size), math.ceil(cx / size) do
        local x = cx + i * size
        if x >= 0 and x <= W then line(true, x, i == 0 and GRID_AXIS or GRID_LINE) end
    end
    for i = -math.ceil(cy / size), math.ceil(cy / size) do
        local y = cy + i * size
        if y >= 0 and y <= H then line(false, y, i == 0 and GRID_AXIS or GRID_LINE) end
    end
    for i = n + 1, #gridLines do
        gridLines[i]:Hide()
    end
    grid:SetShown(unlocked and g.afficher)
end

local function showGuides(x, y)
    if not guides then
        guides = _G.CreateFrame("Frame", nil, _G.UIParent)
        guides:SetAllPoints()
        guides:SetFrameStrata("DIALOG")
        guides:SetFrameLevel(5) -- sous les calques des cadres
        guides.v = solid(guides, "OVERLAY", C.actif)
        guides.h = solid(guides, "OVERLAY", C.actif)
    end
    local W, H = _G.UIParent:GetSize()
    local px = onePixel()
    guides.v:SetShown(x ~= nil)
    if x then
        guides.v:ClearAllPoints()
        guides.v:SetPoint("BOTTOMLEFT", guides, "BOTTOMLEFT", x, 0)
        guides.v:SetSize(px, H)
    end
    guides.h:SetShown(y ~= nil)
    if y then
        guides.h:ClearAllPoints()
        guides.h:SetPoint("BOTTOMLEFT", guides, "BOTTOMLEFT", 0, y)
        guides.h:SetSize(W, px)
    end
    guides:Show()
end

local function hideGuides()
    if guides then guides:Hide() end
end

-- Aimant ----------------------------------------------------------------------------------------

-- Meilleure attraction sur un axe. points : positions du cadre (bords, milieu) ; targets : liste
-- { pos, pour = "bords" | "milieu" } ; gridFor : grille pour les bords. Renvoie le décalage à
-- appliquer et la position du trait, ou nil.
local function bestSnap(low, size, targets, gridOrigin, gridStep)
    local best, shift, at = SNAP + 1, nil, nil
    local function try(p, target)
        local d = math.abs(target - p)
        if d < best then best, shift, at = d, target - p, target end
    end
    local edges = { low, low + size }
    for _, t in ipairs(targets) do
        if t.middle then
            try(low + size / 2, t.pos)
        else
            for _, p in ipairs(edges) do try(p, t.pos) end
        end
    end
    if gridStep then
        for _, p in ipairs(edges) do
            try(p, gridOrigin + math.floor((p - gridOrigin) / gridStep + 0.5) * gridStep)
        end
    end
    return shift, at
end

-- Cibles : bords des autres cadres visibles (sauf ceux qui suivent le cadre glissé) et centre.
local function targetsFor(def)
    local xs, ys = {}, {}
    for _, other in pairs(movers) do
        if other ~= def and other.parent ~= def.frame and other.frame:IsVisible() then
            local l, b, w, h = uiRect(other.frame)
            if l then
                xs[#xs + 1] = { pos = l }
                xs[#xs + 1] = { pos = l + w }
                ys[#ys + 1] = { pos = b }
                ys[#ys + 1] = { pos = b + h }
            end
        end
    end
    local W, H = _G.UIParent:GetSize()
    xs[#xs + 1] = { pos = W / 2, middle = true }
    ys[#ys + 1] = { pos = H / 2, middle = true }
    return xs, ys
end

-- Glisser ---------------------------------------------------------------------------------------

local drag -- { def, dx, dy, w, h, xs, ys }
local driver = _G.CreateFrame("Frame")

local function follow()
    local def = drag.def
    local frame = def.frame
    local cx, cy = cursorUI()
    local W, H = _G.UIParent:GetSize()
    local left, bottom = cx - drag.dx, cy - drag.dy
    local gx, gy
    local g = gridSettings()
    if g.aimant and not _G.IsShiftKeyDown() then
        local sx, ax = bestSnap(left, drag.w, drag.xs, W / 2, g.taille)
        local sy, ay = bestSnap(bottom, drag.h, drag.ys, H / 2, g.taille)
        if sx then left, gx = left + sx, ax end
        if sy then bottom, gy = bottom + sy, ay end
    end
    left = math.max(0, math.min(W - drag.w, left))
    bottom = math.max(0, math.min(H - drag.h, bottom))
    local k = frame:GetEffectiveScale() / _G.UIParent:GetEffectiveScale()
    frame:ClearAllPoints()
    frame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", left / k, bottom / k)
    if gx or gy then showGuides(gx, gy) else hideGuides() end
end

local function startDrag(def)
    if _G.InCombatLockdown() or drag then return end
    local l, b, w, h = uiRect(def.frame)
    if not l then return end
    local cx, cy = cursorUI()
    local xs, ys = targetsFor(def)
    drag = { def = def, dx = cx - l, dy = cy - b, w = w, h = h, xs = xs, ys = ys }
    driver:SetScript("OnUpdate", follow)
end

stopDrag = function()
    if not drag then return end
    local def = drag.def
    driver:SetScript("OnUpdate", nil)
    drag = nil
    hideGuides()
    savePosition(def)
end

-- Calques ----------------------------------------------------------------------------------------

-- Calque posé sur un cadre en mode déplacement : contour doré, voile, étiquette avec son nom.
local function createOverlay(def)
    local o = _G.CreateFrame("Button", nil, _G.UIParent)
    o:SetFrameStrata("DIALOG")
    o:SetAllPoints(def.frame)
    o:Hide()

    local veil = solid(o, "BACKGROUND", { C.or_[1], C.or_[2], C.or_[3], 0.12 })
    veil:SetAllPoints()
    for _, side in ipairs({ { "TOPLEFT", "TOPRIGHT", nil, 1 }, { "BOTTOMLEFT", "BOTTOMRIGHT", nil, 1 },
                            { "TOPLEFT", "BOTTOMLEFT", 1, nil }, { "TOPRIGHT", "BOTTOMRIGHT", 1, nil } }) do
        local t = solid(o, "BORDER", C.or_)
        t:SetPoint(side[1])
        t:SetPoint(side[2])
        if side[3] then t:SetWidth(side[3]) else t:SetHeight(side[4]) end
    end

    -- Un cadre rattaché à un autre (def.parent) passe au-dessus de lui : on peut l'attraper même
    -- posé sur son parent.
    o:SetFrameLevel(def.parent and 30 or 10)

    -- Étiquette avec le nom : c'est aussi une poignée (pratique pour les petits éléments).
    -- def.tagPoint = { point, point du calque, x, y } : sa place (par défaut au-dessus, à gauche).
    local tag = _G.CreateFrame("Button", nil, o)
    local tp = def.tagPoint or { "BOTTOMLEFT", "TOPLEFT", 0, 3 }
    tag:SetPoint(tp[1], o, tp[2], tp[3], tp[4])
    tag:SetHeight(16)
    local tagBg = solid(tag, "BACKGROUND", C.or_)
    tagBg:SetAllPoints()
    local tagText = CUI:CreateText(tag, "petit", "fond")
    tagText:SetJustifyV("MIDDLE")
    tagText:SetPoint("LEFT", 6, 0)
    o.tag, o.tagText = tag, tagText

    local function reset() -- clic droit : place d'origine
        if _G.InCombatLockdown() then return end
        saved()[def.key] = nil
        applyPosition(def)
    end
    for _, handle in ipairs({ o, tag }) do
        handle:RegisterForDrag("LeftButton")
        handle:RegisterForClicks("RightButtonUp")
        handle:SetScript("OnDragStart", function() startDrag(def) end)
        handle:SetScript("OnDragStop", stopDrag)
        handle:SetScript("OnClick", reset)
    end
    tag:SetScript("OnEnter", function() tagBg:SetVertexColor(C.orClair[1], C.orClair[2], C.orClair[3], 1) end)
    tag:SetScript("OnLeave", function() tagBg:SetVertexColor(C.or_[1], C.or_[2], C.or_[3], 1) end)
    def.overlay = o
end

local function showOverlay(def, shown)
    if not def.overlay then createOverlay(def) end
    def.overlay.tagText:SetText(CUI:Tr(def.label or def.key))
    def.overlay.tag:SetWidth(math.ceil(def.overlay.tagText:GetStringWidth()) + 12)
    def.overlay:SetShown(shown)
    local callback = shown and def.onUnlock or def.onLock
    if callback then
        CUI:SafeCall(CUI:Tr(def.label or def.key), callback, def.frame)
    end
end

-- Panneau « Déplacement des cadres » ------------------------------------------------------------

local ROW1, ROW2 = -92, -124 -- milieu des lignes Grille et Aimant

local function rowLabel(y)
    local t = CUI:CreateText(panel, "normal", "texte")
    t:SetJustifyV("MIDDLE")
    t:SetPoint("LEFT", panel, "TOPLEFT", 14, y)
    return t
end

local function refreshPanel()
    local g = gridSettings()
    panel.gridSwitch:SetChecked(g.afficher)
    panel.snapSwitch:SetChecked(g.aimant)
    for _, b in ipairs(panel.sizes) do
        b.principal = b.size == g.taille
        b:SetVisualState(false, false)
    end
    panel.snapNote:SetTextColor(unpack(g.aimant and C.texteSecondaire or C.texteDesactive))
end

-- Petit panneau affiché tant que les cadres sont déverrouillés (même la fenêtre principale fermée).
local function createPanel()
    panel = _G.CreateFrame("Frame", "CoeurUIDeplacement", _G.UIParent)
    panel:SetSize(420, 192)
    panel:SetPoint("TOP", 0, -60)
    panel:SetFrameStrata("DIALOG")
    panel:SetToplevel(true)
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()
    CUI:CreateBorderedRect(panel, 6, C.or_, C.fenetre)

    local logo = panel:CreateTexture(nil, "ARTWORK")
    logo:SetTexture(CUI.MEDIA .. "Logo")
    logo:SetSize(18, 18)
    logo:SetPoint("TOPLEFT", 14, -12)
    local title = CUI:CreateText(panel, "normal", "texte")
    title:SetPoint("LEFT", logo, "RIGHT", 8, 0)
    panel.title = title
    local help = CUI:CreateText(panel, "petit", "texteDiscret")
    help:SetPoint("TOPLEFT", 14, -38)
    help:SetWidth(392)
    help:SetWordWrap(true)
    panel.help = help

    -- Grille : afficher ou non, taille.
    panel.gridLabel = rowLabel(ROW1)
    panel.gridSwitch = CUI:CreateSwitch(panel, function(_, checked)
        gridSettings().afficher = checked
        drawGrid()
    end)
    panel.gridSwitch:SetPoint("LEFT", panel, "TOPLEFT", 84, ROW1)
    panel.sizeLabel = CUI:CreateText(panel, "petit", "texteDiscret")
    panel.sizeLabel:SetJustifyV("MIDDLE")
    panel.sizeLabel:SetPoint("LEFT", panel.gridSwitch, "RIGHT", 14, 0)
    panel.sizes = {}
    local anchor = panel.sizeLabel
    for _, size in ipairs(GRID_SIZES) do
        local b = CUI:CreateButton(panel, tostring(size), false, true)
        b.size = size
        b:SetPoint("LEFT", anchor, "RIGHT", anchor == panel.sizeLabel and 8 or 4, 0)
        b:SetScript("OnClick", function()
            local g = gridSettings()
            g.taille, g.afficher = size, true
            drawGrid()
            refreshPanel()
        end)
        panel.sizes[#panel.sizes + 1] = b
        anchor = b
    end

    -- Aimant : oui ou non.
    panel.snapLabel = rowLabel(ROW2)
    panel.snapSwitch = CUI:CreateSwitch(panel, function(_, checked)
        gridSettings().aimant = checked
        refreshPanel()
    end)
    panel.snapSwitch:SetPoint("LEFT", panel, "TOPLEFT", 84, ROW2)
    panel.snapNote = CUI:CreateText(panel, "petit", "texteSecondaire")
    panel.snapNote:SetJustifyV("MIDDLE")
    panel.snapNote:SetPoint("LEFT", panel.snapSwitch, "RIGHT", 14, 0)

    panel.lock = CUI:CreateButton(panel, "", true)
    panel.lock:SetPoint("BOTTOMRIGHT", -12, 12)
    panel.lock:SetScript("OnClick", function() CUI:SetMoversUnlocked(false) end)
    panel.reset = CUI:CreateButton(panel, "")
    panel.reset:SetPoint("RIGHT", panel.lock, "LEFT", -8, 0)
    panel.reset:SetScript("OnClick", function() CUI:ResetMovers() end)
end

local function showPanel(shown)
    if not panel then
        if not shown then return end
        createPanel()
    end
    panel.title:SetText(L.DEPLACEMENT_TITRE)
    panel.help:SetText(L.DEPLACEMENT_AIDE)
    panel.gridLabel:SetText(L.GRILLE)
    panel.sizeLabel:SetText(L.GRILLE_TAILLE)
    panel.snapLabel:SetText(L.AIMANT)
    panel.snapNote:SetText(L.AIMANT_NOTE)
    panel.lock:SetLabel(L.VERROUILLER)
    panel.reset:SetLabel(L.DEPLACEMENT_TOUT)
    refreshPanel()
    panel:SetShown(shown)
end

-- API ----------------------------------------------------------------------------------------

function CUI:RegisterMover(def)
    assert(type(def) == "table" and def.key and def.frame and def.default, "RegisterMover : définition incomplète")
    movers[def.key] = def
    applyPosition(def)
    if unlocked then
        showOverlay(def, true)
    end
end

function CUI:UnregisterMover(key)
    local def = movers[key]
    if not def then return end
    if drag and drag.def == def then stopDrag() end
    if def.overlay and def.overlay:IsShown() then
        showOverlay(def, false)
    end
    movers[key] = nil
    if unlocked and not self:HasMovers() then
        self:SetMoversUnlocked(false)
    end
end

function CUI:HasMovers()
    return next(movers) ~= nil
end

function CUI:AreMoversUnlocked()
    return unlocked
end

function CUI:SetMoversUnlocked(on)
    on = on and true or false
    if on == unlocked then return end
    if on and (_G.InCombatLockdown() or not self:HasMovers()) then
        if _G.InCombatLockdown() then self:Print(L.DEPLACEMENT_COMBAT) end
        return
    end
    if not on then stopDrag() end
    unlocked = on
    for _, def in pairs(movers) do
        showOverlay(def, on)
    end
    drawGrid()
    showPanel(on)
    self:RefreshModulesScreen()
end

-- Remet un cadre à sa place d'origine.
function CUI:ResetMover(key)
    local def = movers[key]
    if not def or _G.InCombatLockdown() then return end
    saved()[key] = nil
    applyPosition(def)
end

-- Remet tous les cadres à leur place d'origine.
function CUI:ResetMovers()
    if _G.InCombatLockdown() then return end
    for key, def in pairs(movers) do
        saved()[key] = nil
        applyPosition(def)
    end
end

-- Un combat qui commence verrouille tout seul.
CUI:On("PLAYER_REGEN_DISABLED", "core:movers", function()
    if unlocked then
        CUI:SetMoversUnlocked(false)
        CUI:Print(L.DEPLACEMENT_FERME_COMBAT)
    end
end)
