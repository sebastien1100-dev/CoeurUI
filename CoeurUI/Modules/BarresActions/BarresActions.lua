-- Module « Barres d'actions » (maquette validée) : barres 1 à 8 en carrés sobres (icône rognée,
-- liseré gris fin, coins à peine arrondis, pas d'or), à la place des barres du jeu.
-- Étape 1 : barres 1 à 8. Étape 2 : familier, postures, bouton d'action en plus, quitter le
-- véhicule (boutons du jeu réutilisés : le jeu les tient à jour). Étape 3 : micro-menu (icônes CœurUI
-- au trait posées sur les boutons du jeu) et sacs.
--
-- Par barre : afficher ou non, nombre de boutons, boutons par rangée, sens (horizontale ou
-- verticale), taille, espacement, visibilité (toujours, au survol, en combat, jamais), opacité hors
-- survol, textes (raccourci, nom des macros, charges). Une seule page : un menu choisit la barre.
-- Les barres se placent avec le cadenas.
--
-- Tous les boutons sont ceux du jeu (ActionButton1, MultiBarBottomLeftButton1...), rangés dans des
-- cadres CœurUI et habillés : c'est le jeu qui les tient à jour (sorts, recharges, raccourcis). Sur
-- ce client, certaines valeurs (recharges en combat) ne s'affichent que par le code du jeu : des
-- boutons créés par CœurUI provoquaient des erreurs. CœurUI ne demande donc jamais à un bouton de se
-- redessiner. Rien n'est déplacé ni caché en combat (réglage changé en combat : appliqué à la
-- sortie). La barre 1 change de page (formes, véhicule, barre de remplacement) : CœurUI donne la
-- page, les boutons du jeu suivent. Couper le module demande un /reload.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

-- Barres : numéros et raccourcis du jeu (« Barre d'action 2 » = MULTIACTIONBAR1, emplacements 61 à
-- 72, etc.). La barre 1 change de page (voir pageCondition).
local BARS = {
    { key = "b1", name = "BA_BARRE1", prefix = "ActionButton", main = true },
    { key = "b2", name = "BA_BARRE2", prefix = "MultiBarBottomLeftButton" },
    { key = "b3", name = "BA_BARRE3", prefix = "MultiBarBottomRightButton" },
    { key = "b4", name = "BA_BARRE4", prefix = "MultiBarRightButton" },
    { key = "b5", name = "BA_BARRE5", prefix = "MultiBarLeftButton" },
    { key = "b6", name = "BA_BARRE6", prefix = "MultiBar5Button" },
    { key = "b7", name = "BA_BARRE7", prefix = "MultiBar6Button" },
    { key = "b8", name = "BA_BARRE8", prefix = "MultiBar7Button" },
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
    fam = { "BOTTOM", "BOTTOM", 170, 102 },
    post = { "BOTTOM", "BOTTOM", -200, 102 },
    extra = { "BOTTOM", "BOTTOM", 0, 230 },
    vehicule = { "BOTTOM", "BOTTOM", 290, 16 },
    micro = { "BOTTOMRIGHT", "BOTTOMRIGHT", -16, 16 },
    sacs = { "BOTTOMRIGHT", "BOTTOMRIGHT", -16, 50 },
}

-- Familier et postures : boutons du jeu réutilisés (le jeu montre ceux qui servent : familier
-- présent, postures connues). CœurUI les range dans ses cadres, les habille et les place.
local GROUPS = {
    { key = "fam", name = "BA_FAMILIER", prefix = "PetActionButton", count = 10, blizzard = "PetActionBar", pet = true },
    { key = "post", name = "BA_POSTURES", prefix = "StanceButton", count = 10, blizzard = "StanceBar" },
}
-- Boutons spéciaux : seulement la taille et la place (le jeu les montre quand il en a besoin).
local SPECIAL = { extra = true, vehicule = true }
-- Micro-menu et sacs : le jeu décide combien de boutons ; pas de textes à régler.
local FIXED = { micro = true, sacs = true }

-- Le personnage a-t-il des postures ou des formes ? Sinon, leur barre n'est ni proposée ni placée.
local function hasStances()
    return (_G.GetNumShapeshiftForms and _G.GetNumShapeshiftForms() or 0) > 0
end

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
for _, g in ipairs(GROUPS) do
    DEFAULTS[g.key] = barDefaults(true, false)
    DEFAULTS[g.key].taille = 30
    DEFAULTS[g.key].nombre = 10
    DEFAULTS[g.key].parLigne = 10
end
DEFAULTS.extra = barDefaults(true, false)
DEFAULTS.extra.taille = 52
DEFAULTS.vehicule = barDefaults(true, false)
DEFAULTS.vehicule.taille = 32
DEFAULTS.micro = barDefaults(true, false)
DEFAULTS.micro.taille = 26
DEFAULTS.micro.espacement = 2
DEFAULTS.sacs = barDefaults(true, false)
DEFAULTS.sacs.taille = 30

local M -- plus bas

-- Page « Barres » : les réglages de la barre choisie dans le menu « Barre ».
local BAR_KEYS = {}
for _, def in ipairs(BARS) do BAR_KEYS[def.key] = true end

local function barStore()
    if not BAR_KEYS[M.db.choix] then M.db.choix = "b1" end
    local key = M.db.choix
    return M.db[key], M.defaults[key]
end

local function rootStore()
    return M.db, M.defaults
end

local function barItem(t)
    t.store = barStore
    return t
end

local BAR_OPTIONS = {}
for _, def in ipairs(BARS) do
    BAR_OPTIONS[#BAR_OPTIONS + 1] = { value = def.key, text = def.name }
end

-- Morceaux de pages communs.
local SENS = { { value = "horizontal", text = "BA_HORIZONTALE" }, { value = "vertical", text = "BA_VERTICALE" } }
local QUAND = {
    { value = "toujours", text = "BA_TOUJOURS" }, { value = "survol", text = "BA_SURVOL" },
    { value = "combat", text = "BA_COMBAT" }, { value = "cachee", text = "BA_JAMAIS" },
}
local function sensItem() return { type = "dropdown", key = "orientation", label = "BA_SENS", options = SENS } end
local function tailleItem() return { type = "slider", key = "taille", label = "BA_TAILLE", min = 20, max = 64, step = 2, format = "%d" } end
local function espacementItem() return { type = "slider", key = "espacement", label = "BA_ESPACEMENT", min = 0, max = 12, step = 1, format = "%d" } end
local function quandItem() return { type = "dropdown", key = "visibilite", label = "BA_QUAND", options = QUAND } end
local function opaciteItem()
    return { type = "slider", key = "opacite", label = "BA_OPACITE", min = 0, max = 100, step = 5, format = "%d %%",
             enabledIf = function(read) return read("visibilite") ~= "survol" end }
end
-- Barres 1 à 8, réunies : un menu choisit la barre.
local PAGE_BARRES = {
    { type = "dropdown", key = "choix", label = "BA_BARRE", options = BAR_OPTIONS, store = rootStore,
      refreshAll = true, noReset = true },
    { type = "section", text = "BA_DISPOSITION" },
    barItem({ type = "toggle", key = "afficher", label = "BA_AFFICHER" }),
    barItem({ type = "slider", key = "nombre", label = "BA_NOMBRE", min = 1, max = 12, step = 1, format = "%d" }),
    barItem({ type = "slider", key = "parLigne", label = "BA_PAR_LIGNE", min = 1, max = 12, step = 1, format = "%d" }),
    barItem(sensItem()), barItem(tailleItem()), barItem(espacementItem()),
    { type = "column" },
    { type = "section", text = "BA_VISIBILITE" },
    barItem(quandItem()), barItem(opaciteItem()),
    { type = "section", text = "BA_TEXTES" },
    barItem({ type = "toggle", key = "raccourci", label = "BA_RACCOURCI" }),
    barItem({ type = "toggle", key = "macro", label = "BA_MACRO" }),
    barItem({ type = "toggle", key = "charges", label = "BA_CHARGES" }),
}

-- Familier, postures : comme une barre, 10 boutons au plus, seul texte : le raccourci. Familier
-- (compte = false) : toujours ses 10 boutons sur une rangée, sans réglage de nombre.
local function pageGroupe(key, compte)
    local page = {
        { type = "section", text = "BA_DISPOSITION" },
        { type = "toggle", key = "afficher", label = "BA_AFFICHER" },
    }
    if compte then
        page[#page + 1] = { type = "slider", key = "nombre", label = "BA_NOMBRE", min = 1, max = 10, step = 1, format = "%d" }
        page[#page + 1] = { type = "slider", key = "parLigne", label = "BA_PAR_LIGNE", min = 1, max = 10, step = 1, format = "%d" }
    end
    for _, item in ipairs({
        sensItem(), tailleItem(), espacementItem(),
        { type = "column" },
        { type = "section", text = "BA_VISIBILITE" },
        quandItem(), opaciteItem(),
        { type = "section", text = "BA_TEXTES" },
        { type = "toggle", key = "raccourci", label = "BA_RACCOURCI" },
    }) do
        page[#page + 1] = item
    end
    return page
end

-- Bouton d'action en plus, quitter le véhicule : le jeu les montre quand il en a besoin ; la taille.
local function pageSpeciale()
    return {
        { type = "section", text = "BA_DISPOSITION" },
        tailleItem(),
    }
end

-- Micro-menu, sacs : le jeu décide combien de boutons ; pas de textes.
-- Micro-menu et sacs (simple = true) : une seule rangée (ou colonne), sans réglage de rangées.
local function pageFixe(key, simple)
    local page = { { type = "section", text = "BA_DISPOSITION" } }
    if not simple then
        page[#page + 1] = { type = "slider", key = "parLigne", label = "BA_PAR_LIGNE", min = 1, max = 12, step = 1, format = "%d" }
    end
    for _, item in ipairs({ sensItem(), tailleItem(), espacementItem(),
                            { type = "column" }, { type = "section", text = "BA_VISIBILITE" },
                            quandItem(), opaciteItem() }) do
        page[#page + 1] = item
    end
    return page
end

M = CUI:RegisterModule({
    key = "BarresActions",
    name = "BA_NOM",
    description = "BA_DESC",
    defaultEnabled = false,
    needsReload = true, -- les barres du jeu ne reviennent qu'après un /reload
    defaults = DEFAULTS,
    -- Un tiroir : les barres 1 à 8 réunies, puis une page pour chacun des autres.
    subs = {
        { key = "barres", name = "BA_BARRES", intro = false, settings = PAGE_BARRES },
        { key = "fam", name = "BA_FAMILIER", intro = false, settings = pageGroupe("fam") },
        { key = "post", name = "BA_POSTURES", intro = false, settings = pageGroupe("post", true), shown = hasStances },
        { key = "extra", name = "BA_EXTRA", intro = false, settings = pageSpeciale() },
        { key = "vehicule", name = "BA_VEHICULE", intro = false, settings = pageSpeciale() },
        { key = "micro", name = "BA_MICRO", intro = false, settings = pageFixe("micro", true) },
        { key = "sacs", name = "BA_SACS", intro = false, settings = pageFixe("sacs", true) },
    },
})

local FOND = { 0.063, 0.071, 0.094, 1 } -- #101218, derrière l'icône

local built = false
local bars = {}          -- clé -> cadre de barre
local ours = {}          -- bouton -> définition de sa barre
local hiddenParent
local layingOut = false -- vrai pendant que CœurUI range des boutons (ses crochets l'ignorent)

-- Habillage d'un bouton ------------------------------------------------------------------------

local function fontText(fs, size)
    if fs then fs:SetFont(CUI:GetFont(), size, "OUTLINE") end
end

local function refreshTexts(b)
    local s = M.db[ours[b].key]
    if b.HotKey then b.HotKey:SetAlpha(s.raccourci and 1 or 0) end
    if b.Name then b.Name:SetAlpha(s.macro and 1 or 0) end
    if b.Count then b.Count:SetAlpha(s.charges and 1 or 0) end
end

-- Hors de portée : un voile rouge à nous, par-dessus l'icône. La couleur de l'icône elle-même reste
-- celle du jeu (ressource : bleu, indisponible : gris). Voile seulement quand le jeu dit clairement
-- « hors de portée » ; à portée, sans cible ou valeur cachée par le jeu : pas de voile.
local function setRangeVeil(b, out)
    local veil = b.cuiRangeVeil
    if not veil then
        if not out or not b.icon then return end
        veil = b:CreateTexture(nil, "ARTWORK", nil, 7)
        veil:SetTexture("Interface\\Buttons\\WHITE8x8")
        veil:SetVertexColor(0.85, 0.2, 0.2, 0.4)
        veil:SetAllPoints(b.icon)
        b.cuiRangeVeil = veil
    end
    veil:SetShown(out)
end

-- Liseré de 1 point sur les quatre bords, au-dessus de tout ; :SetColor() pour le survol.
local function outline(b)
    local o = { lines = {} }
    for _, side in ipairs({ { "TOPLEFT", "TOPRIGHT", nil, 1 }, { "BOTTOMLEFT", "BOTTOMRIGHT", nil, 1 },
                            { "TOPLEFT", "BOTTOMLEFT", 1, nil }, { "TOPRIGHT", "BOTTOMRIGHT", 1, nil } }) do
        local t = b:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetTexture("Interface\\Buttons\\WHITE8x8")
        t:SetPoint(side[1])
        t:SetPoint(side[2])
        if side[3] then t:SetWidth(side[3]) else t:SetHeight(side[4]) end
        o.lines[#o.lines + 1] = t
    end
    function o:SetColor(c)
        for _, t in ipairs(self.lines) do t:SetVertexColor(c[1], c[2], c[3], 1) end
    end
    o:SetColor(C.bordureDiscrete)
    return o
end

local function skin(b)
    -- L'image : son champ (icon, Icon) ou son nom (…IconTexture, cas des sacs).
    local name = b:GetName()
    local icon = b.icon or b.Icon or (name and _G[name .. "IconTexture"])
    if icon and not icon.SetTexCoord then icon = nil end
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
    for _, key in ipairs({ "SlotBackground", "SlotArt", "FlyoutBorderShadow", "IconBorder" }) do
        local t = b[key]
        if t and t.SetAlpha then t:SetAlpha(0) end
    end
    -- Notre habit : liseré gris fin, fond sombre.
    -- Fond sombre dessous ; liseré au-dessus de l'image (toujours visible, même si le jeu agrandit
    -- l'image jusqu'aux bords du bouton).
    local back = b:CreateTexture(nil, "BACKGROUND", nil, -8)
    back:SetTexture("Interface\\Buttons\\WHITE8x8")
    back:SetVertexColor(FOND[1], FOND[2], FOND[3], FOND[4])
    back:SetAllPoints()
    b.cuiBorder = outline(b)
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

local layoutBar -- plus bas

local function createBar(def, index)
    local bar = _G.CreateFrame("Frame", "CoeurUIBarre" .. index, _G.UIParent, "SecureHandlerStateTemplate")
    bar:SetFrameStrata("LOW")
    bar:SetSize(40, 40)
    bar.buttons = {}
    for i = 1, 12 do
        local b = _G[def.prefix .. i]
        if b and not (b.IsForbidden and b:IsForbidden()) then
            ours[b] = def
            skin(b)
            if def.main then
                -- La page vient de notre cadre (voir plus bas), comme elle venait de la barre du jeu.
                b:SetAttribute("useparent-actionpage", true)
            end
            -- Le jeu replace ses boutons dans sa propre barre : on les remet dans la nôtre.
            _G.hooksecurefunc(b, "SetPoint", function()
                if not layingOut and M.enabled then
                    CUI:AfterCombat(function() layoutBar(def) end)
                end
            end)
            bar.buttons[i] = b
        end
    end
    if def.main then
        bar:SetAttribute("_onstate-page", [[ self:SetAttribute("actionpage", newstate) ]])
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

-- Range des boutons dans un cadre selon des réglages (nombre, rangées, sens, taille, espacement).
-- Hors combat. Ceux en trop vont dans le cadre invisible. keepParent : les boutons restent dans leur
-- cadre du jeu (seulement placés sur le nôtre).
local function placeButtons(bar, buttons, s, max, keepParent)
    layingOut = true
    local n = math.max(1, math.min(max, s.nombre))
    local per = math.max(1, math.min(n, s.parLigne))
    local lines = math.ceil(n / per)
    local size, gap = s.taille, s.espacement
    local vertical = s.orientation == "vertical"
    local long, short = per * size + (per - 1) * gap, lines * size + (lines - 1) * gap
    bar:SetSize(vertical and short or long, vertical and long or short)
    for i = 1, max do
        local b = buttons[i]
        if b then
            if i <= n then
                local a, c = (i - 1) % per, math.floor((i - 1) / per)
                local col, row = a, c
                if vertical then col, row = c, a end
                if not keepParent and b:GetParent() ~= bar then b:SetParent(bar) end
                if keepParent then
                    -- Resté dans un cadre du jeu à une autre échelle : on la corrige pour qu'il ait
                    -- la taille et la place voulues sur notre barre.
                    b:SetScale(1)
                    b:SetScale(bar:GetEffectiveScale() / b:GetEffectiveScale())
                end
                b:ClearAllPoints()
                b:SetSize(size, size)
                b:SetPoint("TOPLEFT", bar, "TOPLEFT", col * (size + gap), -row * (size + gap))
            else
                b:SetParent(hiddenParent)
            end
            refreshTexts(b)
        end
    end
    layingOut = false
end

-- Place les boutons d'une barre selon ses réglages. Hors combat.
layoutBar = function(def)
    local bar, s = bars[def.key], M.db[def.key]
    if not bar or _G.InCombatLockdown() then return end
    placeButtons(bar, bar.buttons, s, 12)
    _G.RegisterStateDriver(bar, "visibility", visibilityCondition(s))
end

-- Familier et postures ----------------------------------------------------------------------------

local function groupCondition(g, s)
    if not s.afficher or s.visibilite == "cachee" then return "hide" end
    local base = "[petbattle][overridebar][vehicleui] hide; "
    if s.visibilite == "combat" then
        return base .. (g.pet and "[pet,combat]" or "[combat]") .. " show; hide"
    end
    return base .. (g.pet and "[pet] show; hide" or "show")
end

-- Réglages d'une barre ; le familier a toujours ses 10 boutons sur une rangée, le micro-menu et les
-- sacs tous leurs boutons sur une rangée (pas de réglage).
local function settingsOf(key)
    local s = M.db[key]
    if key == "fam" then
        return setmetatable({ nombre = 10, parLigne = 10 }, { __index = s })
    elseif key == "micro" or key == "sacs" then
        return setmetatable({ parLigne = 99 }, { __index = s })
    end
    return s
end

local function layoutGroup(g)
    local frame = bars[g.key]
    if not frame or _G.InCombatLockdown() then return end
    local s = settingsOf(g.key)
    placeButtons(frame, frame.buttons, s, g.count)
    _G.RegisterStateDriver(frame, "visibility", groupCondition(g, s))
end

-- Range un cadre du jeu dans le cadre invisible (et l'y garde).
local function stash(frame)
    if not frame or (frame.IsForbidden and frame:IsForbidden()) then return end
    frame:SetParent(hiddenParent)
    _G.hooksecurefunc(frame, "SetParent", function(self, parent)
        if parent ~= hiddenParent and M.enabled then
            CUI:AfterCombat(function() self:SetParent(hiddenParent) end)
        end
    end)
end

local function createGroup(g)
    local frame = _G.CreateFrame("Frame", "CoeurUIBarre_" .. g.key, _G.UIParent, "SecureHandlerStateTemplate")
    frame:SetFrameStrata("LOW")
    frame:SetSize(30, 30)
    frame.buttons = {}
    for i = 1, g.count do
        local b = _G[g.prefix .. i]
        if b and not (b.IsForbidden and b:IsForbidden()) then
            ours[b] = g
            skin(b)
            -- Le jeu replace ses boutons dans sa propre barre : on les remet dans la nôtre.
            _G.hooksecurefunc(b, "SetPoint", function()
                if not layingOut and M.enabled then
                    CUI:AfterCombat(function() layoutGroup(g) end)
                end
            end)
            frame.buttons[i] = b
        end
    end
    bars[g.key] = frame
    stash(_G[g.blizzard])
    frame.mover = { key = "barre_" .. g.key, frame = frame, label = g.name, default = POSITIONS[g.key] }
    if g.key ~= "post" or hasStances() then
        CUI:RegisterMover(frame.mover)
        frame.moverOn = true
    end
end

-- Postures apprises ou perdues : leur étiquette au cadenas apparaît ou disparaît.
local function updateStanceMover()
    local frame = bars.post
    if not frame or _G.InCombatLockdown() then return end
    local wanted = hasStances()
    if wanted and not frame.moverOn then
        CUI:RegisterMover(frame.mover)
    elseif not wanted and frame.moverOn then
        CUI:UnregisterMover(frame.mover.key)
    end
    frame.moverOn = wanted
end

-- Boutons spéciaux ----------------------------------------------------------------------------------

local specials = {} -- clé -> cadre porteur (déplacé au cadenas)

-- Bouton d'action en plus (combats de boss, quêtes) et capacité de zone : leur cadre du jeu est
-- accroché au nôtre, à la taille voulue ; leur décor du jeu est rendu invisible.
local function layoutExtra()
    local holder, s = specials.extra, M.db.extra
    local container = _G.ExtraAbilityContainer or _G.ExtraActionBarFrame
    if not holder or not container or _G.InCombatLockdown() then return end
    holder:SetSize(s.taille, s.taille)
    layingOut = true
    container:SetScale(s.taille / 52)
    container:ClearAllPoints()
    container:SetPoint("CENTER", holder, "CENTER", 0, 0)
    layingOut = false
end

local function createExtra()
    local holder = _G.CreateFrame("Frame", "CoeurUIBarre_extra", _G.UIParent)
    holder:SetSize(52, 52)
    specials.extra = holder
    local container = _G.ExtraAbilityContainer or _G.ExtraActionBarFrame
    if container then
        _G.hooksecurefunc(container, "SetPoint", function()
            if not layingOut and M.enabled then CUI:AfterCombat(layoutExtra) end
        end)
    end
    local b = _G.ExtraActionButton1
    if b then
        if b.style then b.style:SetAlpha(0) end
        ours[b] = { key = "extra" }
        skin(b)
    end
    local zone = _G.ZoneAbilityFrame
    if zone and zone.Style then zone.Style:SetAlpha(0) end
    CUI:RegisterMover({ key = "barre_extra", frame = holder, label = "BA_EXTRA", default = POSITIONS.extra })
end

-- Quitter le véhicule : le bouton du jeu, invisible, posé sur notre carré avec l'icône CœurUI.
-- Notre carré n'apparaît que quand le jeu montre le bouton.
local function layoutVehicle()
    local holder, s = specials.vehicule, M.db.vehicule
    if not holder then return end
    holder:SetSize(s.taille, s.taille)
    holder.icon:SetSize(s.taille * 0.6, s.taille * 0.6)
end

local function createVehicle()
    local holder = _G.CreateFrame("Frame", "CoeurUIBarre_vehicule", _G.UIParent)
    holder:SetSize(32, 32)
    holder:SetFrameStrata("LOW")
    holder.border, holder.fill = CUI:CreateBorderedRect(holder, 3, C.bordureDiscrete, FOND)
    holder.icon = holder:CreateTexture(nil, "ARTWORK")
    holder.icon:SetTexture(CUI.MEDIA .. "Icones\\Sortie")
    holder.icon:SetPoint("CENTER")
    holder.icon:SetVertexColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3], 1)
    specials.vehicule = holder

    local b = _G.MainMenuBarVehicleLeaveButton
    local function sync()
        local shown = b ~= nil and b:IsShown()
        holder.border:SetShown(shown)
        holder.fill:SetShown(shown)
        holder.icon:SetShown(shown)
    end
    if b then
        local busy = false
        local function pin()
            if busy or _G.InCombatLockdown() then return end
            busy = true
            if b:GetParent() ~= holder then b:SetParent(holder) end
            b:ClearAllPoints()
            b:SetAllPoints(holder)
            b:SetFrameLevel(holder:GetFrameLevel() + 2)
            busy = false
        end
        _G.hooksecurefunc(b, "SetPoint", function() if M.enabled and not busy then CUI:AfterCombat(pin) end end)
        _G.hooksecurefunc(b, "SetParent", function() if M.enabled and not busy then CUI:AfterCombat(pin) end end)
        pin()
        b:SetAlpha(0)
        _G.hooksecurefunc(b, "SetAlpha", function(self, a)
            if a ~= 0 and M.enabled then self:SetAlpha(0) end
        end)
        b:HookScript("OnShow", sync)
        b:HookScript("OnHide", sync)
        b:HookScript("OnEnter", function()
            holder.icon:SetVertexColor(C.texte[1], C.texte[2], C.texte[3], 1)
            holder.border:SetColor(C.texteSecondaire)
        end)
        b:HookScript("OnLeave", function()
            holder.icon:SetVertexColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3], 1)
            holder.border:SetColor(C.bordureDiscrete)
        end)
    end
    sync()
    CUI:RegisterMover({ key = "barre_vehicule", frame = holder, label = "BA_VEHICULE", default = POSITIONS.vehicule })
end

-- Micro-menu et sacs -----------------------------------------------------------------------------

-- Icône de chaque bouton (WoW Forever : un bouton Héritage, LegacyMicroButton, à la place des hauts
-- faits ; grimoire et talents sont deux boutons, talents actifs au niveau 10).
local MICRO_ICONS = {
    CharacterMicroButton = "Personnage", ProfessionMicroButton = "Metiers", SpellbookMicroButton = "Sorts",
    TalentMicroButton = "Talents", PlayerSpellsMicroButton = "Talents", LegacyMicroButton = "Heritage",
    QuestLogMicroButton = "Quetes", GuildMicroButton = "Guilde", SocialsMicroButton = "Guilde",
    LFDMicroButton = "Groupes", CollectionsMicroButton = "Collections", StoreMicroButton = "Boutique",
    MainMenuMicroButton = "Menu", HelpMicroButton = "Aide",
}
-- Bouton inconnu (propre à Forever, par exemple l'Héritage) : icône devinée d'après son nom.
local MICRO_GUESS = {
    { "heritage", "Heritage" }, { "legacy", "Heritage" }, { "achievement", "Heritage" },
    { "talent", "Talents" }, { "spell", "Sorts" }, { "guild", "Guilde" }, { "social", "Guilde" },
    { "communit", "Guilde" }, { "quest", "Quetes" }, { "collection", "Collections" }, { "store", "Boutique" },
    { "shop", "Boutique" }, { "help", "Aide" }, { "support", "Aide" }, { "lfd", "Groupes" }, { "lfg", "Groupes" },
    { "group", "Groupes" }, { "profession", "Metiers" }, { "character", "Personnage" }, { "menu", "Menu" },
}
local function microIcon(name)
    if MICRO_ICONS[name] then return MICRO_ICONS[name] end
    local lower = name:lower()
    for _, guess in ipairs(MICRO_GUESS) do
        if lower:find(guess[1], 1, true) then return guess[2] end
    end
end

-- Boutons du jeu qui n'existent pas sur WoW Forever (Logis, Guide de l'aventurier, hauts faits) ou y
-- font doublon (PlayerSpellsMicroButton, « sorts et talents » récent : Forever a Grimoire et Talents
-- à part) : rendus invisibles et sans souris (les sortir du micro-menu du jeu le ferait planter).
local MICRO_EXCLUDED = { HousingMicroButton = true, EJMicroButton = true, PlayerSpellsMicroButton = true,
                         AchievementMicroButton = true }
-- Liste du jeu (MICRO_BUTTONS) complétée : sur Forever, elle oublie par exemple le grimoire.
local MICRO_KNOWN = { "CharacterMicroButton", "ProfessionMicroButton", "SpellbookMicroButton", "TalentMicroButton",
                      "PlayerSpellsMicroButton", "LegacyMicroButton", "QuestLogMicroButton", "GuildMicroButton",
                      "SocialsMicroButton", "LFDMicroButton", "CollectionsMicroButton", "StoreMicroButton",
                      "MainMenuMicroButton", "HelpMicroButton", "HousingMicroButton", "EJMicroButton",
                      "AchievementMicroButton" }
-- De gauche à droite : sac de composants, sacs 4 à 1, sac à dos.
local BAG_NAMES = { "CharacterReagentBag0Slot", "CharacterBag3Slot", "CharacterBag2Slot", "CharacterBag1Slot",
                    "CharacterBag0Slot", "MainMenuBarBackpackButton" }
local GRIS_SOMBRE = { 0.353, 0.369, 0.408 } -- #5A5E68 : bouton désactivé

-- Range la liste des boutons montrés par le jeu (le jeu décide combien).
local function layoutFixed(key)
    local frame = bars[key]
    if not frame or _G.InCombatLockdown() then return end
    local list = {}
    for _, b in ipairs(frame.all) do
        if b:IsShown() then list[#list + 1] = b end
    end
    local s = settingsOf(key)
    -- Micro-menu : ses boutons restent dans le micro-menu du jeu (il se réarrange quand l'un d'eux
    -- change de cadre, et se trompait sans eux) ; on les place seulement sur le nôtre.
    placeButtons(frame, list, setmetatable({ nombre = #list }, { __index = s }), math.max(1, #list),
        key == "micro")
    for _, b in ipairs(frame.all) do
        local tile = b.cuiTile
        if tile then
            tile.icon:SetSize(s.taille * 0.62, s.taille * 0.62)
            tile:SetShown(b:IsShown())
        end
    end
    _G.RegisterStateDriver(frame, "visibility", visibilityCondition(s))
end

-- Le jeu replace, montre ou cache ses boutons : on les remet dans notre barre.
local function follow(b, key)
    local function again()
        if not layingOut and M.enabled then CUI:AfterCombat(function() layoutFixed(key) end) end
    end
    _G.hooksecurefunc(b, "SetPoint", again)
    _G.hooksecurefunc(b, "SetParent", again)
    b:HookScript("OnShow", again)
    b:HookScript("OnHide", again)
end

-- Carré sobre et icône CœurUI posés sous un bouton du micro-menu rendu invisible (il garde son clic
-- et son infobulle).
local function dressMicro(b, frame, iconName)
    local tile = _G.CreateFrame("Frame", nil, frame)
    tile:SetAllPoints(b)
    tile:SetFrameLevel(frame:GetFrameLevel() + 1)
    tile.border, tile.fill = CUI:CreateBorderedRect(tile, 3, C.bordureDiscrete, FOND)
    tile.icon = tile:CreateTexture(nil, "ARTWORK")
    tile.icon:SetTexture(CUI.MEDIA .. "Icones\\" .. iconName)
    tile.icon:SetPoint("CENTER")
    -- Pastille rouge cœur : le jeu signale quelque chose sur ce bouton.
    tile.ring = tile:CreateTexture(nil, "OVERLAY", nil, 1)
    tile.ring:SetTexture(CUI.MEDIA .. "Cercle")
    tile.ring:SetVertexColor(0.08, 0.09, 0.1, 1)
    tile.ring:SetSize(9, 9)
    tile.ring:SetPoint("CENTER", tile, "TOPRIGHT", -3, -3)
    tile.dot = tile:CreateTexture(nil, "OVERLAY", nil, 2)
    tile.dot:SetTexture(CUI.MEDIA .. "Cercle")
    tile.dot:SetVertexColor(C.coeur[1], C.coeur[2], C.coeur[3], 1)
    tile.dot:SetSize(6, 6)
    tile.dot:SetPoint("CENTER", tile.ring)
    b.cuiTile = tile
    b:SetFrameLevel(frame:GetFrameLevel() + 3)
    b:SetAlpha(0)
    _G.hooksecurefunc(b, "SetAlpha", function(self, a)
        if a ~= 0 and M.enabled then self:SetAlpha(0) end
    end)
    b:HookScript("OnEnter", function(self) self.cuiHover = true end)
    b:HookScript("OnLeave", function(self) self.cuiHover = false end)
end

-- Couleur des icônes du micro-menu (survol, désactivé) et pastille d'alerte. Les boutons restés dans
-- le micro-menu du jeu ne se cachent pas avec notre barre : barre cachée, ils ne prennent plus la
-- souris (ils ne sont pas protégés : possible aussi en combat).
local function paintMicro()
    local frame = bars.micro
    if not frame then return end
    -- Le jeu réarrange souvent son micro-menu : un bouton qui n'est plus sur notre barre, et tout
    -- est replacé (hors combat).
    if not _G.InCombatLockdown() and not layingOut then
        for _, b in ipairs(frame.all) do
            local _, relative = b:GetPoint(1)
            if b:IsShown() and relative ~= frame then
                layoutFixed("micro")
                break
            end
        end
    end
    local visible = frame:IsVisible()
    for _, b in ipairs(frame.all) do
        if b:IsMouseEnabled() ~= visible then b:EnableMouse(visible) end
        local tile = b.cuiTile
        if tile and tile:IsShown() then
            local color = not b:IsEnabled() and GRIS_SOMBRE or (b.cuiHover and C.texte or C.texteSecondaire)
            tile.icon:SetVertexColor(color[1], color[2], color[3], 1)
            tile.border:SetColor(b.cuiHover and C.texteSecondaire or C.bordureDiscrete)
            local flash = (b.FlashBorder and b.FlashBorder:IsShown()) or (b.Flash and b.Flash:IsShown())
            tile.ring:SetShown(flash and true or false)
            tile.dot:SetShown(flash and true or false)
        end
    end
end

local function createFixed(key, label, names)
    local frame = _G.CreateFrame("Frame", "CoeurUIBarre_" .. key, _G.UIParent)
    frame:SetFrameStrata("LOW")
    frame:SetSize(30, 30)
    frame.all = {}
    frame.buttons = {}
    for _, name in ipairs(names) do
        local b = _G[name]
        if b and not (b.IsForbidden and b:IsForbidden()) then
            ours[b] = { key = key }
            if key == "micro" then
                local iconName = microIcon(name)
                if iconName then dressMicro(b, frame, iconName) end
            else
                skin(b)
            end
            follow(b, key)
            frame.all[#frame.all + 1] = b
        end
    end
    bars[key] = frame
    CUI:RegisterMover({ key = "barre_" .. key, frame = frame, label = label, default = POSITIONS[key] })
    return frame
end

-- Bouton exclu : invisible et sans souris, mais laissé dans le micro-menu du jeu.
local function ghostAway(b)
    b:SetAlpha(0)
    b:EnableMouse(false)
    _G.hooksecurefunc(b, "SetAlpha", function(self, a)
        if a ~= 0 and M.enabled then self:SetAlpha(0) end
    end)
end

local function createMicro()
    local names, seen = {}, {}
    local function add(name)
        if type(name) ~= "string" or seen[name] then return end
        seen[name] = true
        if MICRO_EXCLUDED[name] then
            if _G[name] then ghostAway(_G[name]) end
        else
            names[#names + 1] = name
        end
    end
    if type(_G.MICRO_BUTTONS) == "table" then
        for _, name in ipairs(_G.MICRO_BUTTONS) do add(name) end
    end
    for _, name in ipairs(MICRO_KNOWN) do add(name) end
    -- Et tout bouton présent dans le micro-menu du jeu (Forever a les siens, comme LegacyMicroButton).
    local menu = _G.MicroMenu
    if menu then
        for _, child in ipairs({ menu:GetChildren() }) do
            local name = child.GetName and child:GetName()
            if type(name) == "string" and name:find("MicroButton$") then add(name) end
        end
    end
    local frame = createFixed("micro", "BA_MICRO", names)
    -- Dans l'ordre du micro-menu du jeu. Un bouton sans place chez le jeu prend celle de notre liste :
    -- juste après le bouton connu qui le précède.
    local fallback, last = {}, 0
    for _, name in ipairs(MICRO_KNOWN) do
        local b = _G[name]
        if b and b.layoutIndex then
            last = b.layoutIndex
        else
            fallback[name] = last + 0.5
        end
    end
    local rank = {}
    for i, b in ipairs(frame.all) do
        rank[b] = (b.layoutIndex or fallback[b:GetName()] or 100) * 100 + i
    end
    table.sort(frame.all, function(a, b) return rank[a] < rank[b] end)
    -- Le micro-menu du jeu reste en place (ses boutons y vivent) : seuls son fond et son bord
    -- deviennent invisibles.
    local menu = _G.MicroMenu
    if menu then
        for _, key in ipairs({ "BackgroundArt", "BorderArt" }) do
            if menu[key] and menu[key].SetAlpha then menu[key]:SetAlpha(0) end
        end
    end
end

local function createBags()
    createFixed("sacs", "BA_SACS", BAG_NAMES)
    stash(_G.BagBarExpandToggle)
    stash(_G.BagsBar)
end

local function layoutAll()
    if not built then return end
    for _, def in ipairs(BARS) do layoutBar(def) end
    for _, g in ipairs(GROUPS) do layoutGroup(g) end
    layoutExtra()
    layoutVehicle()
    layoutFixed("micro")
    layoutFixed("sacs")
end

-- Opacité : au survol, pleine ; sinon celle du réglage (« au survol seulement » : invisible).
-- L'opacité n'est pas protégée : elle change aussi en combat.
local ALPHA_KEYS = {}
for _, def in ipairs(BARS) do ALPHA_KEYS[#ALPHA_KEYS + 1] = def.key end
for _, g in ipairs(GROUPS) do ALPHA_KEYS[#ALPHA_KEYS + 1] = g.key end
ALPHA_KEYS[#ALPHA_KEYS + 1] = "micro"
ALPHA_KEYS[#ALPHA_KEYS + 1] = "sacs"

local function updateAlpha()
    for _, key in ipairs(ALPHA_KEYS) do
        local bar, s = bars[key], M.db[key]
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

local function build()
    if built then return end
    built = true
    hiddenParent = _G.CreateFrame("Frame")
    hiddenParent:Hide()
    hideBlizzardBars()
    for i, def in ipairs(BARS) do
        createBar(def, i)
    end
    for _, g in ipairs(GROUPS) do
        CUI:SafeCall(CUI:Tr(g.name), createGroup, g)
    end
    CUI:SafeCall(CUI:Tr("BA_EXTRA"), createExtra)
    CUI:SafeCall(CUI:Tr("BA_VEHICULE"), createVehicle)
    CUI:SafeCall(CUI:Tr("BA_MICRO"), createMicro)
    CUI:SafeCall(CUI:Tr("BA_SACS"), createBags)
    if type(_G.ActionButton_UpdateRangeIndicator) == "function" then
        -- Seulement notre voile montré ou caché : aucune fonction du jeu appelée d'ici (valeurs secrètes).
        local issecret = _G.issecretvalue or function() return false end
        _G.hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, checksRange, inRange)
            if not ours[self] then return end
            if issecret(checksRange) or issecret(inRange) then
                setRangeVeil(self, false)
            else
                setRangeVeil(self, (checksRange and inRange == false) and true or false)
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

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    CUI:AfterCombat(build) -- boutons protégés : jamais rangés en combat
    self:Every(0.1, updateAlpha)
    self:On("UPDATE_SHAPESHIFT_FORMS", function() CUI:AfterCombat(updateStanceMover) end)
    self:Every(0.5, paintMicro)
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
