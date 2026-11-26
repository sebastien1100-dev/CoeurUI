-- Module « Barres d'actions » (maquette validée) : barres 1 à 8 en carrés sobres (icône rognée,
-- liseré gris fin, coins à peine arrondis, pas d'or), à la place des barres du jeu.
-- Étape 1 : barres 1 à 8. Plus tard (même module) : familier, postures, boutons spéciaux,
-- micro-menu et sacs.
--
-- Par barre : afficher ou non, nombre de boutons, boutons par rangée, sens (horizontale ou
-- verticale), taille, espacement, visibilité (toujours, au survol, en combat, jamais), opacité hors
-- survol, textes (raccourci, nom des macros, charges). Une seule page : un menu choisit la barre.
-- Les barres se placent avec le cadenas.
--
-- Les boutons sont des boutons d'action du jeu (modèle ActionBarButtonTemplate, protégés) créés par
-- CœurUI : rien n'est créé, déplacé ni caché en combat (réglage changé en combat : appliqué à la
-- sortie). Les raccourcis du jeu (barre 1 : ACTIONBUTTON1...) sont redirigés vers nos boutons
-- (SetOverrideBindingClick, hors combat). La barre 1 change de page comme celle du jeu (formes,
-- véhicule, barre de remplacement). Couper le module demande un /reload.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

-- Barres : numéros et raccourcis du jeu (« Barre d'action 2 » = MULTIACTIONBAR1, emplacements 61 à
-- 72, etc.). La barre 1 change de page (voir pageCondition).
local BARS = {
    { key = "b1", name = "BA_BARRE1", binding = "ACTIONBUTTON", main = true },
    { key = "b2", name = "BA_BARRE2", binding = "MULTIACTIONBAR1BUTTON", first = 61 },
    { key = "b3", name = "BA_BARRE3", binding = "MULTIACTIONBAR2BUTTON", first = 49 },
    { key = "b4", name = "BA_BARRE4", binding = "MULTIACTIONBAR3BUTTON", first = 25 },
    { key = "b5", name = "BA_BARRE5", binding = "MULTIACTIONBAR4BUTTON", first = 37 },
    { key = "b6", name = "BA_BARRE6", binding = "MULTIACTIONBAR5BUTTON", first = 145 },
    { key = "b7", name = "BA_BARRE7", binding = "MULTIACTIONBAR6BUTTON", first = 157 },
    { key = "b8", name = "BA_BARRE8", binding = "MULTIACTIONBAR7BUTTON", first = 169 },
}

local POSITIONS = {
    b1 = { "BOTTOM", "BOTTOM", 0, 16 },
    b2 = { "BOTTOM", "BOTTOM", 0, 59 },
    b3 = { "RIGHT", "RIGHT", -16, 0 },
    b4 = { "RIGHT", "RIGHT", -53, 0 },
    b5 = { "CENTER", "CENTER", 0, 120 },
    b6 = { "CENTER", "CENTER", 0, 80 },
    b7 = { "CENTER", "CENTER", 0, 40 },
    b8 = { "CENTER", "CENTER", 0, 0 },
}

local function barDefaults(shown, vertical)
    return {
        afficher = shown, nombre = 12, parLigne = 12, orientation = vertical and "vertical" or "horizontal",
        taille = vertical and 34 or 40, espacement = 3, visibilite = "toujours", opacite = 100,
        raccourci = true, macro = false, charges = true,
    }
end

local DEFAULTS = { choix = "b1" }
for i, def in ipairs(BARS) do
    DEFAULTS[def.key] = barDefaults(i <= 4, i == 3 or i == 4)
end

local M -- plus bas

-- Réglages de la barre choisie dans le menu « Barre ».
local function barStore()
    local key = M.db.choix
    return M.db[key], M.defaults[key]
end

local function barItem(t)
    t.store = barStore
    return t
end

local BAR_OPTIONS = {}
for _, def in ipairs(BARS) do
    BAR_OPTIONS[#BAR_OPTIONS + 1] = { value = def.key, text = def.name }
end

M = CUI:RegisterModule({
    key = "BarresActions",
    name = "BA_NOM",
    description = "BA_DESC",
    defaultEnabled = false,
    needsReload = true, -- les barres du jeu ne reviennent qu'après un /reload
    defaults = DEFAULTS,
    settings = {
        { type = "dropdown", key = "choix", label = "BA_BARRE", options = BAR_OPTIONS, refreshAll = true,
          noReset = true },
        { type = "section", text = "BA_DISPOSITION" },
        barItem({ type = "toggle", key = "afficher", label = "BA_AFFICHER" }),
        barItem({ type = "slider", key = "nombre", label = "BA_NOMBRE", min = 1, max = 12, step = 1, format = "%d" }),
        barItem({ type = "slider", key = "parLigne", label = "BA_PAR_LIGNE", min = 1, max = 12, step = 1, format = "%d" }),
        barItem({ type = "dropdown", key = "orientation", label = "BA_SENS", options = {
            { value = "horizontal", text = "BA_HORIZONTALE" },
            { value = "vertical", text = "BA_VERTICALE" },
        } }),
        barItem({ type = "slider", key = "taille", label = "BA_TAILLE", min = 20, max = 64, step = 2, format = "%d" }),
        barItem({ type = "slider", key = "espacement", label = "BA_ESPACEMENT", min = 0, max = 12, step = 1, format = "%d" }),
        { type = "column" },
        { type = "section", text = "BA_VISIBILITE" },
        barItem({ type = "dropdown", key = "visibilite", label = "BA_QUAND", options = {
            { value = "toujours", text = "BA_TOUJOURS" },
            { value = "survol", text = "BA_SURVOL" },
            { value = "combat", text = "BA_COMBAT" },
            { value = "cachee", text = "BA_JAMAIS" },
        } }),
        barItem({ type = "slider", key = "opacite", label = "BA_OPACITE", min = 0, max = 100, step = 5, format = "%d %%",
                  enabledIf = function(read) return read("visibilite") ~= "survol" end }),
        { type = "section", text = "BA_TEXTES" },
        barItem({ type = "toggle", key = "raccourci", label = "BA_RACCOURCI" }),
        barItem({ type = "toggle", key = "macro", label = "BA_MACRO" }),
        barItem({ type = "toggle", key = "charges", label = "BA_CHARGES" }),
        { type = "section", text = "BA_APERCU" },
        { type = "custom", height = 90,
          build = function(parent) return CUI.BarresActions.BuildPreview(parent) end,
          refresh = function(frame) CUI.BarresActions.RefreshPreview(frame) end },
    },
})

local FOND = { 0.063, 0.071, 0.094, 1 } -- #101218, derrière l'icône

local built = false
local bars = {}          -- clé -> cadre de barre
local ours = {}          -- bouton -> définition de sa barre
local hiddenParent
local bindOwner

-- Habillage d'un bouton ------------------------------------------------------------------------

local function fontText(fs, size)
    if fs then fs:SetFont(CUI:GetFont(), size, "OUTLINE") end
end

local function refreshTexts(b)
    local s = M.db[ours[b].key]
    if b.HotKey then
        b.HotKey:SetText(b.cuiKey or "")
        b.HotKey:SetAlpha(s.raccourci and 1 or 0)
    end
    if b.Name then b.Name:SetAlpha(s.macro and 1 or 0) end
    if b.Count then b.Count:SetAlpha(s.charges and 1 or 0) end
end

-- Couleur de l'icône : hors de portée en rouge, sinon celle que le jeu a mise (ressource : bleu,
-- indisponible : gris).
local function colorRange(b)
    if b.cuiOutOfRange and b.icon then
        b.icon:SetVertexColor(0.85, 0.3, 0.3)
    end
end

local function skin(b)
    local icon = b.icon
    if icon then
        if b.IconMask then icon:RemoveMaskTexture(b.IconMask) end
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
    end
    -- Habit du jeu (cadre, fond d'emplacement) : invisible.
    local normal = b:GetNormalTexture()
    if normal then normal:SetAlpha(0) end
    for _, key in ipairs({ "SlotBackground", "SlotArt", "FlyoutBorderShadow" }) do
        local t = b[key]
        if t and t.SetAlpha then t:SetAlpha(0) end
    end
    -- Notre habit : liseré gris fin, fond sombre.
    b.cuiBorder = CUI:CreateBorderedRect(b, 3, C.bordureDiscrete, FOND, "BACKGROUND", -8)
    -- Survol, appui, coché : voiles légers sur l'icône.
    local hl = b:GetHighlightTexture()
    if hl and icon then
        hl:SetColorTexture(1, 1, 1, 0.08)
        hl:SetAllPoints(icon)
    end
    local pushed = b:GetPushedTexture()
    if pushed and icon then
        pushed:SetColorTexture(0, 0, 0, 0.3)
        pushed:SetAllPoints(icon)
    end
    local checked = b.GetCheckedTexture and b:GetCheckedTexture()
    if checked and icon then
        checked:SetColorTexture(1, 1, 1, 0.15)
        checked:SetAllPoints(icon)
    end
    if b.cooldown and icon then
        b.cooldown:ClearAllPoints()
        b.cooldown:SetAllPoints(icon)
    end
    -- Textes : police de CœurUI ; raccourci en haut à droite, charges en bas à droite, macro en bas.
    if b.HotKey then
        fontText(b.HotKey, 10)
        b.HotKey:ClearAllPoints()
        b.HotKey:SetPoint("TOPRIGHT", -3, -3)
        b.HotKey:SetJustifyH("RIGHT")
    end
    if b.Count then
        fontText(b.Count, 11)
        b.Count:ClearAllPoints()
        b.Count:SetPoint("BOTTOMRIGHT", -3, 3)
    end
    if b.Name then
        fontText(b.Name, 9)
        b.Name:ClearAllPoints()
        b.Name:SetPoint("BOTTOMLEFT", 2, 3)
        b.Name:SetPoint("BOTTOMRIGHT", -2, 3)
    end
    b:HookScript("OnEnter", function(self) self.cuiBorder:SetColor(C.texteSecondaire) end)
    b:HookScript("OnLeave", function(self) self.cuiBorder:SetColor(C.bordureDiscrete) end)
    -- Le jeu remet son texte de raccourci et ses couleurs : on repasse derrière (crochets seulement).
    if b.UpdateHotkeys then
        _G.hooksecurefunc(b, "UpdateHotkeys", function(self) refreshTexts(self) end)
    end
    if b.UpdateUsable then
        _G.hooksecurefunc(b, "UpdateUsable", colorRange)
    end
end

-- Sort mis en avant par le jeu : halo blanc au lieu de doré.
local function whitenAlert(b)
    local alert = b.SpellActivationAlert
    if not alert then return end
    local function paint(frame, depth)
        for _, region in ipairs({ frame:GetRegions() }) do
            if region:GetObjectType() == "Texture" then
                region:SetDesaturated(true)
                region:SetVertexColor(1, 1, 1)
            end
        end
        if depth < 2 then
            for _, child in ipairs({ frame:GetChildren() }) do paint(child, depth + 1) end
        end
    end
    paint(alert, 0)
end

-- Raccourcis ------------------------------------------------------------------------------------

local function shortKey(key)
    local ok, text = pcall(_G.GetBindingText, key, true)
    return (ok and type(text) == "string" and text ~= "") and text or key
end

-- Les raccourcis du jeu vont vers nos boutons (seulement ceux qui sont affichés). Hors combat.
local function updateBindings()
    if not built or _G.InCombatLockdown() then return end
    _G.ClearOverrideBindings(bindOwner)
    for _, def in ipairs(BARS) do
        local bar, s = bars[def.key], M.db[def.key]
        for i, b in ipairs(bar.buttons) do
            local keys = { _G.GetBindingKey(def.binding .. i) }
            local active = s.afficher and s.visibilite ~= "cachee" and i <= s.nombre
            if active then
                for _, key in ipairs(keys) do
                    _G.SetOverrideBindingClick(bindOwner, false, key, b:GetName(), "LeftButton")
                end
            end
            b.cuiKey = keys[1] and shortKey(keys[1]) or ""
            refreshTexts(b)
        end
    end
end

-- Barres ------------------------------------------------------------------------------------------

-- Pages de la barre 1, comme celle du jeu : barre de remplacement, véhicule, formes, pages 2 à 6
-- choisies à la main, barres de forme (druide, voleur...), sinon la page 1.
local function pageCondition()
    local override = _G.GetOverrideBarIndex and _G.GetOverrideBarIndex() or 14
    local vehicle = _G.GetVehicleBarIndex and _G.GetVehicleBarIndex() or 12
    local temp = _G.GetTempShapeshiftBarIndex and _G.GetTempShapeshiftBarIndex() or 13
    return ("[overridebar] %d; [vehicleui][possessbar] %d; [shapeshift] %d; [bonusbar:5] 11; "
        .. "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; "
        .. "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10; 1"):format(override, vehicle, temp)
end

local function createBar(def, index)
    local bar = _G.CreateFrame("Frame", "CoeurUIBarre" .. index, _G.UIParent, "SecureHandlerStateTemplate")
    bar:SetFrameStrata("LOW")
    bar:SetSize(40, 40)
    bar.buttons = {}
    for i = 1, 12 do
        local b = _G.CreateFrame("CheckButton", "CoeurUIBarre" .. index .. "Bouton" .. i, bar, "ActionBarButtonTemplate")
        b:SetAttribute("index", i)
        b:SetAttribute("action", def.main and i or (def.first + i - 1))
        b:SetAttribute("showgrid", 1) -- emplacement vide visible (pour y poser un sort)
        b:RegisterForClicks("AnyUp", "AnyDown") -- le jeu ne déclenche qu'une fois (réglage « à l'appui »)
        if def.main then
            b:SetAttribute("_childupdate-actionpage", [[
                self:SetAttribute("action", (message - 1) * 12 + self:GetAttribute("index"))
            ]])
        end
        ours[b] = def
        skin(b)
        bar.buttons[i] = b
    end
    if def.main then
        bar:SetAttribute("_onstate-page", [[ control:ChildUpdate("actionpage", newstate) ]])
        _G.RegisterStateDriver(bar, "page", pageCondition())
    end
    bars[def.key] = bar
    CUI:RegisterMover({ key = "barre_" .. def.key, frame = bar, label = def.name, default = POSITIONS[def.key] })
end

local function visibilityCondition(s)
    if not s.afficher or s.visibilite == "cachee" then return "hide" end
    if s.visibilite == "combat" then return "[combat] show; hide" end
    return "show"
end

-- Place les boutons d'une barre selon ses réglages. Hors combat.
local function layoutBar(def)
    local bar, s = bars[def.key], M.db[def.key]
    local n = math.max(1, math.min(12, s.nombre))
    local per = math.max(1, math.min(n, s.parLigne))
    local lines = math.ceil(n / per)
    local size, gap = s.taille, s.espacement
    local vertical = s.orientation == "vertical"
    local long, short = per * size + (per - 1) * gap, lines * size + (lines - 1) * gap
    bar:SetSize(vertical and short or long, vertical and long or short)
    for i, b in ipairs(bar.buttons) do
        if i <= n then
            local a, c = (i - 1) % per, math.floor((i - 1) / per)
            local col, row = a, c
            if vertical then col, row = c, a end
            if b:GetParent() ~= bar then b:SetParent(bar) end
            b:ClearAllPoints()
            b:SetSize(size, size)
            b:SetPoint("TOPLEFT", bar, "TOPLEFT", col * (size + gap), -row * (size + gap))
        else
            b:SetParent(hiddenParent)
        end
        refreshTexts(b)
    end
    _G.RegisterStateDriver(bar, "visibility", visibilityCondition(s))
end

local function layoutAll()
    if not built then return end
    for _, def in ipairs(BARS) do layoutBar(def) end
    updateBindings()
end

-- Opacité : au survol, pleine ; sinon celle du réglage (« au survol seulement » : invisible).
-- L'opacité n'est pas protégée : elle change aussi en combat.
local function updateAlpha()
    for _, def in ipairs(BARS) do
        local bar, s = bars[def.key], M.db[def.key]
        if bar and bar:IsShown() then
            local over = bar:IsMouseOver(4, -4, -4, 4)
            local alpha = over and 1 or (s.visibilite == "survol" and 0 or s.opacite / 100)
            if bar:GetAlpha() ~= alpha then bar:SetAlpha(alpha) end
        end
    end
end

-- Barres du jeu : rangées dans un cadre invisible.
local BLIZZARD_BARS = { "MainMenuBar", "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight",
                        "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7" }
local function hideBlizzardBars()
    for _, name in ipairs(BLIZZARD_BARS) do
        local frame = _G[name]
        if frame and not (frame.IsForbidden and frame:IsForbidden()) then
            frame:SetParent(hiddenParent)
            _G.hooksecurefunc(frame, "SetParent", function(self, parent)
                if parent ~= hiddenParent and M.enabled then
                    CUI:AfterCombat(function() self:SetParent(hiddenParent) end)
                end
            end)
        end
    end
end

-- Barre 1 : après un changement de page, nos boutons relisent leur action (dessin seulement).
local function refreshMainBar()
    local bar = bars.b1
    if not bar then return end
    for _, b in ipairs(bar.buttons) do
        if b.UpdateAction then b:UpdateAction(true) end
    end
end

local function build()
    if built then return end
    built = true
    hiddenParent = _G.CreateFrame("Frame")
    hiddenParent:Hide()
    bindOwner = _G.CreateFrame("Frame")
    hideBlizzardBars()
    for i, def in ipairs(BARS) do
        createBar(def, i)
    end
    if type(_G.ActionButton_UpdateRangeIndicator) == "function" then
        _G.hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, checksRange, inRange)
            if ours[self] then
                self.cuiOutOfRange = checksRange and not inRange
                if self.cuiOutOfRange then colorRange(self) elseif self.UpdateUsable then self:UpdateUsable() end
            end
        end)
    end
    local alerts = _G.ActionButtonSpellAlertManager
    if alerts and alerts.ShowAlert then
        _G.hooksecurefunc(alerts, "ShowAlert", function(_, b)
            if ours[b] then CUI:SafeCall(CUI:Tr("BA_NOM"), whitenAlert, b) end
        end)
    end
    layoutAll()
end

-- Aperçu de la barre choisie (page de réglages) -------------------------------------------------

CUI.BarresActions = {}

function CUI.BarresActions.BuildPreview(parent)
    local box = _G.CreateFrame("Frame", nil, parent)
    box:SetHeight(90)
    CUI:CreateBorderedRect(box, 4, C.graphite, C.fond)
    box.cells = {}
    for i = 1, 12 do
        local cell = _G.CreateFrame("Frame", nil, box)
        CUI:CreateBorderedRect(cell, 2, C.bordureDiscrete, C.graphiteClair)
        box.cells[i] = cell
    end
    return box
end

function CUI.BarresActions.RefreshPreview(box)
    local s = M.db[M.db.choix]
    local n = math.max(1, math.min(12, s.nombre))
    local per = math.max(1, math.min(n, s.parLigne))
    local lines = math.ceil(n / per)
    local vertical = s.orientation == "vertical"
    local cols, rows = per, lines
    if vertical then cols, rows = lines, per end
    -- Taille réduite pour tenir dans le cadre, proportions gardées.
    local room_w, room_h = math.max(1, box:GetWidth() - 20), 70
    local unit = s.taille + s.espacement
    local k = math.min(1, room_w / (cols * unit), room_h / (rows * unit))
    local size, gap = s.taille * k, s.espacement * k
    local w, h = cols * size + (cols - 1) * gap, rows * size + (rows - 1) * gap
    for i, cell in ipairs(box.cells) do
        if i <= n then
            local a, c = (i - 1) % per, math.floor((i - 1) / per)
            local col, row = a, c
            if vertical then col, row = c, a end
            cell:ClearAllPoints()
            cell:SetSize(size, size)
            cell:SetPoint("TOPLEFT", box, "CENTER", -w / 2 + col * (size + gap), h / 2 - row * (size + gap))
            cell:Show()
        else
            cell:Hide()
        end
    end
    box:SetAlpha(s.afficher and 1 or 0.4)
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    CUI:AfterCombat(build) -- boutons protégés : jamais créés en combat
    self:On("UPDATE_BINDINGS", function() CUI:AfterCombat(updateBindings) end)
    self:On("PLAYER_ENTERING_WORLD", function() CUI:AfterCombat(updateBindings) end)
    for _, event in ipairs({ "ACTIONBAR_PAGE_CHANGED", "UPDATE_BONUS_ACTIONBAR", "UPDATE_VEHICLE_ACTIONBAR",
                             "UPDATE_OVERRIDE_ACTIONBAR", "UPDATE_SHAPESHIFT_FORM", "UPDATE_POSSESS_BAR" }) do
        self:On(event, function() self:After(0, refreshMainBar) end)
    end
    self:Every(0.1, updateAlpha)
end

-- Coupé : tout reste en place jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged(key)
    if key == "choix" then return end
    CUI:AfterCombat(layoutAll)
end

function M:OnFontChanged()
    for b in pairs(ours) do
        fontText(b.HotKey, 10)
        fontText(b.Count, 11)
        fontText(b.Name, 9)
    end
end
