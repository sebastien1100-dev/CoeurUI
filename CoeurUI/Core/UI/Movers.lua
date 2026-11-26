-- Mode déplacement des cadres : commun à tous les modules qui ont des cadres à placer à l'écran.
-- Le cadenas de la barre de titre (fenêtre principale) l'ouvre et le ferme.
--
--   CUI:RegisterMover({
--       key = "joueur", frame = cadre, label = "CLE_DU_NOM",            -- nom affiché sur le cadre
--       default = { "CENTER", "CENTER", -200, -150 },                   -- point, point de UIParent, x, y
--       onUnlock = function(cadre) end, onLock = function(cadre) end,   -- ex. montrer un exemple
--       parent = autreCadre,  -- facultatif : position rattachée à ce cadre (default aussi), qu'il suit
--   })
--   CUI:ResetMover("joueur")        -- remet un seul cadre à sa place d'origine
--   CUI:UnregisterMover("joueur")   -- quand le module est coupé
--
-- Position gardée dans CUI.db.ui.movers[key]. Déplacement impossible en combat : un combat qui
-- commence verrouille tout seul (dernier moment où un cadre protégé peut encore être touché).
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local WHITE = "Interface\\Buttons\\WHITE8x8"

local movers = {}   -- clé -> définition
local unlocked = false
local panel

local function saved()
    if type(CUI.db.ui.movers) ~= "table" then
        CUI.db.ui.movers = {}
    end
    return CUI.db.ui.movers
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

    local tag = _G.CreateFrame("Frame", nil, o)
    tag:SetPoint("BOTTOMLEFT", o, "TOPLEFT", 0, 3)
    tag:SetHeight(16)
    local tagBg = solid(tag, "BACKGROUND", C.or_)
    tagBg:SetAllPoints()
    local tagText = CUI:CreateText(tag, "petit", "fond")
    tagText:SetJustifyV("MIDDLE")
    tagText:SetPoint("LEFT", 6, 0)
    o.tag, o.tagText = tag, tagText

    o:RegisterForDrag("LeftButton")
    o:RegisterForClicks("RightButtonUp")
    o:SetScript("OnDragStart", function()
        if _G.InCombatLockdown() then return end
        def.frame:SetMovable(true)
        def.frame:SetClampedToScreen(true)
        def.frame:StartMoving()
    end)
    o:SetScript("OnDragStop", function()
        def.frame:StopMovingOrSizing()
        def.frame:SetUserPlaced(false) -- la position est gardée par CœurUI, pas par le jeu
        savePosition(def)
    end)
    o:SetScript("OnClick", function() -- clic droit : place d'origine
        if _G.InCombatLockdown() then return end
        saved()[def.key] = nil
        applyPosition(def)
    end)
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

-- Petit panneau « Déplacement des cadres », affiché tant que les cadres sont déverrouillés
-- (même la fenêtre principale fermée).
local function createPanel()
    panel = _G.CreateFrame("Frame", "CoeurUIDeplacement", _G.UIParent)
    panel:SetSize(400, 112)
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
    help:SetWidth(372)
    help:SetWordWrap(true)
    panel.help = help

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
    panel.lock:SetLabel(L.VERROUILLER)
    panel.reset:SetLabel(L.DEPLACEMENT_TOUT)
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
    unlocked = on
    for _, def in pairs(movers) do
        if not on then
            def.frame:StopMovingOrSizing()
        end
        showOverlay(def, on)
    end
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
