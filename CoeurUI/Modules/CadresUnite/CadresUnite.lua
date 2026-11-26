-- Module « Cadres d'unité » : cadres du joueur, de la cible et de la cible de la cible (maquette validée).
-- Remplace les cadres du jeu (cachés tant que le module est actif ; le couper demande un /reload).
-- Sous-onglets : Général (tailles des libellés, texture : communs à tous les cadres ; la police est
-- celle de CœurUI, page « Général » de la fenêtre), Joueur,
-- Cible, Cible de la cible. Les cadres se placent avec le cadenas de la fenêtre (mode déplacement).
--
-- Valeurs « secrètes » : sur ce client, la vie, le nom, le niveau... d'une unité peuvent être cachés
-- en combat. On ne les compare ni ne les calcule jamais en Lua : on les passe tels quels à une barre
-- (SetValue) ou à un texte (SetText, SetFormattedText). Toute décision passe par known().
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local issecret = _G.issecretvalue or function() return false end
local function known(v)
    return v ~= nil and not issecret(v)
end

-- Réglages ---------------------------------------------------------------------------------

local TEXTE_VIE = {
    { value = "vp", text = "CU_VIE_VP" },
    { value = "p", text = "CU_VIE_P" },
    { value = "v", text = "CU_VIE_V" },
    { value = "aucun", text = "CU_VIE_AUCUN" },
}

local function apercuItem(kind)
    return {
        type = "custom", height = 96,
        build = function(parent) return CUI.CadresUnite.BuildPreview(parent, kind) end,
        refresh = function(frame) CUI.CadresUnite.RefreshPreview(frame) end,
    }
end

local function couleurItem(textClasse)
    return { type = "dropdown", key = "couleur", label = "CU_COULEUR", options = {
        { value = "classe", text = textClasse },
        { value = "vert", text = "CU_VERT" },
    } }
end

local function framePage(kind, minW, maxW, minH, maxH, couleurTexte, elements)
    local items = {
        { type = "section", text = "CU_TAILLE" },
        { type = "slider", key = "largeur", label = "CU_LARGEUR", min = minW, max = maxW, step = 10, format = "%d" },
        { type = "slider", key = "hauteur", label = "CU_HAUTEUR", min = minH, max = maxH, step = 2, format = "%d" },
        { type = "section", text = "CU_TEXTES" },
        { type = "dropdown", key = "texteVie", label = "CU_TEXTE_VIE", options = TEXTE_VIE },
        couleurItem(couleurTexte),
        { type = "column" },
        { type = "section", text = "CU_APERCU" },
        apercuItem(kind),
    }
    if elements then
        items[#items + 1] = { type = "section", text = "CU_ELEMENTS" }
        items[#items + 1] = { type = "toggle", key = "ressource", label = "CU_RESSOURCE" }
        items[#items + 1] = { type = "toggle", key = "niveau", label = "CU_NIVEAU" }
        items[#items + 1] = { type = "toggle", key = "portrait", label = "CU_PORTRAIT" }
        items[#items + 1] = { type = "toggle", key = "chef", label = "CU_CHEF" }
    end
    return items
end

local M = CUI:RegisterModule({
    key = "CadresUnite",
    name = "CU_NOM",
    description = "CU_DESC",
    defaultEnabled = false,
    needsReload = true, -- les cadres du jeu ne reviennent qu'après un /reload
    defaults = {
        general = { tailleNom = 12, tailleNiveau = 12, tailleVie = 11, texture = "lisse" },
        joueur = { largeur = 230, hauteur = 34, texteVie = "vp", couleur = "classe",
                   ressource = true, niveau = true, portrait = false, chef = true },
        cible = { largeur = 230, hauteur = 34, texteVie = "p", couleur = "classe",
                  ressource = true, niveau = true, portrait = false, chef = true },
        tot = { largeur = 130, hauteur = 20, texteVie = "aucun", couleur = "classe" },
        fam = { largeur = 130, hauteur = 20, texteVie = "aucun", couleur = "classe" },
    },
    subs = {
        { key = "general", name = "CU_GENERAL", intro = false, settings = {
            { type = "section", text = "CU_TEXTE" },
            { type = "slider", key = "tailleNom", label = "CU_TAILLE_NOM", min = 8, max = 20, step = 1, format = "%d pt" },
            { type = "slider", key = "tailleNiveau", label = "CU_TAILLE_NIVEAU", min = 8, max = 20, step = 1, format = "%d pt" },
            { type = "slider", key = "tailleVie", label = "CU_TAILLE_VIE", min = 8, max = 20, step = 1, format = "%d pt" },
            { type = "column" },
            { type = "section", text = "CU_BARRES" },
            { type = "dropdown", key = "texture", label = "CU_TEXTURE", options = function() return CUI:BarTextureOptions() end },
            apercuItem("joueur"),
        } },
        { key = "joueur", name = "CU_JOUEUR", intro = false,
          settings = framePage("joueur", 120, 300, 20, 60, "CU_COULEUR_CLASSE", true) },
        { key = "cible", name = "CU_CIBLE", intro = false,
          settings = framePage("cible", 120, 300, 20, 60, "CU_COULEUR_ATTITUDE", true) },
        { key = "tot", name = "CU_CIBLE_CIBLE", intro = false,
          settings = framePage("tot", 80, 200, 14, 40, "CU_COULEUR_ATTITUDE", false) },
        { key = "fam", name = "CU_FAMILIER", intro = false,
          settings = framePage("fam", 80, 200, 14, 40, "CU_COULEUR_ATTITUDE", false) },
    },
})

-- Couleurs ---------------------------------------------------------------------------------

local VERT = { 0.31, 0.64, 0.29 }
local ROUGE = { 0.72, 0.26, 0.25 }
local JAUNE = { 0.85, 0.71, 0.29 }
local GRIS = { 0.45, 0.47, 0.51 }
local MANA = { 0.24, 0.48, 0.85 }

local function classColor(classFile)
    if not known(classFile) then return nil end
    local c = _G.C_ClassColor and _G.C_ClassColor.GetClassColor and _G.C_ClassColor.GetClassColor(classFile)
    if not c and _G.RAID_CLASS_COLORS then c = _G.RAID_CLASS_COLORS[classFile] end
    if c then return { c.r, c.g, c.b } end
end

local function healthColor(unit, mode)
    if mode == "vert" then return VERT end
    local isPlayer = _G.UnitIsPlayer(unit)
    if known(isPlayer) and isPlayer then
        local _, classFile = _G.UnitClass(unit)
        return classColor(classFile) or VERT
    end
    local tapped = _G.UnitIsTapDenied and _G.UnitIsTapDenied(unit)
    if known(tapped) and tapped then return GRIS end
    local reaction = _G.UnitReaction(unit, "player")
    if known(reaction) then
        if reaction <= 3 then return ROUGE elseif reaction == 4 then return JAUNE end
    end
    return VERT
end

local function powerColor(unit)
    local _, token = _G.UnitPowerType(unit)
    local c = known(token) and _G.PowerBarColor and _G.PowerBarColor[token]
    if c then return { c.r, c.g, c.b } end
    return MANA
end

-- Dessin d'un cadre (le même pour les vrais cadres et les aperçus) ---------------------------

local function newText(parent)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetShadowColor(0, 0, 0, 0.9)
    fs:SetShadowOffset(1, -1)
    fs:SetWordWrap(false)
    fs:SetJustifyV("MIDDLE")
    return fs
end

local function newBar(parent)
    local box = _G.CreateFrame("Frame", nil, parent)
    CUI:CreateBorderedRect(box, 3, C.graphite, C.fond)
    local bar = _G.CreateFrame("StatusBar", nil, box)
    bar:SetPoint("TOPLEFT", 1, -1)
    bar:SetPoint("BOTTOMRIGHT", -1, 1)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
    return box, bar
end

local function createVisual(parent)
    local v = { parent = parent }
    v.healthBox, v.health = newBar(parent)
    v.powerBox, v.power = newBar(parent)
    v.portraitBox = _G.CreateFrame("Frame", nil, parent)
    CUI:CreateBorderedRect(v.portraitBox, 3, C.graphite, C.desactiveFond)
    v.portrait = v.portraitBox:CreateTexture(nil, "ARTWORK")
    v.portrait:SetPoint("TOPLEFT", 1, -1)
    v.portrait:SetPoint("BOTTOMRIGHT", -1, 1)
    v.portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local texts = _G.CreateFrame("Frame", nil, v.health)
    texts:SetAllPoints()
    texts:SetFrameLevel(v.health:GetFrameLevel() + 2)
    v.level, v.name, v.hp = newText(texts), newText(texts), newText(texts)
    v.hp:SetJustifyH("RIGHT")
    v.name:SetJustifyH("LEFT")
    v.leader = texts:CreateTexture(nil, "OVERLAY")
    v.leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
    v.leader:SetSize(14, 14)
    return v
end

-- Taille et place des pièces selon les réglages (s : réglages du cadre, g : réglages généraux).
-- Renvoie la largeur et la hauteur totales.
-- Petits cadres (cible de la cible, familier) : nom et barre de vie, sans le reste.
local SMALL = { tot = true, fam = true }

local function layout(v, s, g, kind)
    local portrait = not SMALL[kind] and s.portrait
    local power = not SMALL[kind] and s.ressource
    local w, h = s.largeur, s.hauteur
    local x = portrait and (h + 4) or 0

    v.portraitBox:SetShown(portrait)
    v.portraitBox:ClearAllPoints()
    v.portraitBox:SetPoint("TOPLEFT", v.parent, "TOPLEFT", 0, 0)
    v.portraitBox:SetSize(h, h)

    v.healthBox:ClearAllPoints()
    v.healthBox:SetPoint("TOPLEFT", v.parent, "TOPLEFT", x, 0)
    v.healthBox:SetSize(w, h)

    v.powerBox:SetShown(power)
    v.powerBox:ClearAllPoints()
    v.powerBox:SetPoint("TOPLEFT", v.healthBox, "BOTTOMLEFT", 0, -3)
    v.powerBox:SetSize(w, 6)

    local texture = CUI:GetBarTexture(g.texture)
    v.health:SetStatusBarTexture(texture)
    v.power:SetStatusBarTexture(texture)

    local font = CUI:GetFont()
    v.level:SetFont(font, g.tailleNiveau, "")
    v.name:SetFont(font, g.tailleNom, "")
    v.hp:SetFont(font, g.tailleVie, "")

    local showLevel = not SMALL[kind] and s.niveau
    v.level:SetShown(showLevel)
    v.level:ClearAllPoints()
    v.level:SetPoint("LEFT", v.health, "LEFT", 7, 0)
    v.hp:ClearAllPoints()
    v.hp:SetPoint("RIGHT", v.health, "RIGHT", -7, 0)
    v.name:ClearAllPoints()
    v.name:SetPoint("LEFT", showLevel and v.level or v.health, showLevel and "RIGHT" or "LEFT", showLevel and 6 or 7, 0)
    v.name:SetPoint("RIGHT", v.hp, "LEFT", -6, 0)

    v.leader:ClearAllPoints()
    v.leader:SetPoint("CENTER", v.healthBox, "TOPLEFT", 2, 1)
    v.showLeader = not SMALL[kind] and s.chef

    return x + w, h + (power and 9 or 0)
end

-- Texte de la vie (valeurs possiblement secrètes : seulement des fonctions du jeu et des formats).
local function setHealthText(fs, mode, hp, pct)
    if mode == "aucun" then
        fs:SetText("")
        return
    end
    local value = _G.AbbreviateNumbers and _G.AbbreviateNumbers(hp) or hp
    local ok
    if mode == "p" then
        ok = pcall(fs.SetFormattedText, fs, "%.0f %%", pct)
    elseif mode == "v" then
        ok = pcall(fs.SetFormattedText, fs, "%s", value)
    else
        ok = pcall(fs.SetFormattedText, fs, "%s · %.0f %%", value, pct)
    end
    if not ok then fs:SetText("") end
end

-- Données d'exemple (aperçus, cadres sans unité en mode déplacement).
local function fillExample(v, s, kind, grey)
    local playerName = _G.UnitName("player")
    local name, level, color, leader
    if kind == "cible" then
        name, level = L.CU_EXEMPLE_CIBLE, "61 " .. L.CU_ELITE
        color = s.couleur == "vert" and VERT or ROUGE
    else
        name = known(playerName) and playerName or L.CU_EXEMPLE_NOM
        local lvl = _G.UnitLevel("player")
        level = known(lvl) and tostring(lvl) or "60"
        local _, classFile = _G.UnitClass("player")
        color = s.couleur == "vert" and VERT or (classColor(classFile) or VERT)
        leader = kind == "joueur"
    end
    if grey then
        local label = ({ cible = "CU_CIBLE", tot = "CU_CIBLE_CIBLE", fam = "CU_FAMILIER" })[kind] or "CU_CIBLE_CIBLE"
        name, color = L.CU_EXEMPLE:format(CUI:Tr(label)), GRIS
    end
    v.name:SetText(name)
    v.level:SetText(level)
    v.health:SetMinMaxValues(0, 100)
    v.health:SetValue(kind == "cible" and 64 or 78)
    v.health:SetStatusBarColor(color[1], color[2], color[3])
    setHealthText(v.hp, s.texteVie, kind == "cible" and 452300 or 18250, kind == "cible" and 64 or 78)
    v.power:SetMinMaxValues(0, 100)
    v.power:SetValue(kind == "cible" and 100 or 40)
    local pc = kind == "cible" and MANA or powerColor("player")
    v.power:SetStatusBarColor(pc[1], pc[2], pc[3])
    v.leader:SetShown(v.showLeader and leader or false)
    if v.portraitBox:IsShown() then
        _G.SetPortraitTexture(v.portrait, "player")
    end
end

-- Vrais cadres ------------------------------------------------------------------------------

local UNITS = {
    { kind = "joueur", unit = "player", name = "CoeurUICadreJoueur", label = "CU_JOUEUR",
      default = { "CENTER", "CENTER", -250, -180 } },
    { kind = "cible", unit = "target", name = "CoeurUICadreCible", label = "CU_CIBLE",
      default = { "CENTER", "CENTER", 250, -180 } },
    { kind = "tot", unit = "targettarget", name = "CoeurUICadreCibleCible", label = "CU_CIBLE_CIBLE",
      default = { "CENTER", "CENTER", 300, -222 } },
    { kind = "fam", unit = "pet", name = "CoeurUICadreFamilier", label = "CU_FAMILIER",
      default = { "CENTER", "CENTER", -300, -222 } },
}
local frames = {}   -- kind -> bouton
local built = false

local function update(f)
    local unit, v = f.unit, f.visual
    local s = M.db[f.kind]
    if f.example then
        fillExample(v, s, f.kind, true)
        return
    end
    if not _G.UnitExists(unit) then return end

    v.name:SetText(_G.UnitName(unit))

    local level = _G.UnitLevel(unit)
    local classif = _G.UnitClassification(unit)
    local suffix = ""
    if known(classif) then
        if classif == "elite" then suffix = " " .. L.CU_ELITE
        elseif classif == "rareelite" then suffix = " " .. L.CU_RARE_ELITE
        elseif classif == "rare" then suffix = " " .. L.CU_RARE
        elseif classif == "worldboss" then suffix = " " .. L.CU_BOSS end
    end
    if known(level) and level <= 0 then
        v.level:SetText("??" .. suffix)
    else
        pcall(v.level.SetFormattedText, v.level, "%s%s", level, suffix)
    end
    local lc = suffix ~= "" and C.or_ or C.texte
    v.level:SetTextColor(lc[1], lc[2], lc[3])

    local hp, maxHp = _G.UnitHealth(unit), _G.UnitHealthMax(unit)
    v.health:SetMinMaxValues(0, maxHp)
    v.health:SetValue(hp)
    local color = healthColor(unit, s.couleur)
    local dead = _G.UnitIsDeadOrGhost(unit)
    if known(dead) and dead then
        color = GRIS
        v.hp:SetText(L.CU_MORT)
    else
        local pct
        if _G.UnitHealthPercent and _G.CurveConstants then
            local ok, value = pcall(_G.UnitHealthPercent, unit, true, _G.CurveConstants.ScaleTo100)
            pct = ok and value or nil
        end
        if pct == nil then
            pct = (known(hp) and known(maxHp) and maxHp > 0) and (hp / maxHp * 100) or 0
        end
        setHealthText(v.hp, s.texteVie, hp, pct)
    end
    v.health:SetStatusBarColor(color[1], color[2], color[3])

    if v.powerBox:IsShown() then
        v.power:SetMinMaxValues(0, _G.UnitPowerMax(unit))
        v.power:SetValue(_G.UnitPower(unit))
        local pc = powerColor(unit)
        v.power:SetStatusBarColor(pc[1], pc[2], pc[3])
    end

    local leader = _G.UnitIsGroupLeader(unit)
    v.leader:SetShown(v.showLeader and known(leader) and leader or false)

    if v.portraitBox:IsShown() then
        _G.SetPortraitTexture(v.portrait, unit)
    end
end

-- Taille et apparence d'un cadre (cadre protégé : hors combat seulement).
local function relayout(f)
    local w, h = layout(f.visual, M.db[f.kind], M.db.general, f.kind)
    f:SetSize(w, h)
    update(f)
end

local function updateAll()
    for _, f in pairs(frames) do
        if f:IsShown() then update(f) end
    end
end

local function relayoutAll()
    CUI:AfterCombat(function()
        for _, f in pairs(frames) do relayout(f) end
    end)
end

local function createFrame(def)
    local f = _G.CreateFrame("Button", def.name, _G.UIParent, "SecureUnitButtonTemplate")
    f.unit, f.kind = def.unit, def.kind
    f:SetAttribute("unit", def.unit)
    f:SetAttribute("type1", "target")      -- clic gauche : cibler
    f:SetAttribute("type2", "togglemenu")  -- clic droit : menu de l'unité
    f:RegisterForClicks("AnyUp")
    f:SetFrameStrata("LOW")
    f.visual = createVisual(f)
    -- Survol : l'infobulle de l'unité (crochet ; pas sur un exemple). Sans la consigne verte des
    -- cadres du jeu (« Clic droit pour les paramètres de bordure »), qui ne vaut pas pour les nôtres.
    f:HookScript("OnEnter", function(self)
        local tip = _G.GameTooltip
        if self.example or not tip then return end
        _G.GameTooltip_SetDefaultAnchor(tip, self)
        tip:SetUnit(self.unit)
        tip:Show()
    end)
    f:HookScript("OnLeave", function()
        if _G.GameTooltip then _G.GameTooltip:Hide() end
    end)
    _G.RegisterUnitWatch(f) -- montré seulement quand l'unité existe (géré par le jeu, même en combat)
    frames[def.kind] = f
    relayout(f) -- police et tailles posées avant tout texte

    CUI:RegisterMover({
        key = "cadre_" .. def.kind, frame = f, label = def.label, default = def.default,
        onUnlock = function()
            if def.kind ~= "joueur" and not _G.UnitExists(def.unit) then
                _G.UnregisterUnitWatch(f)
                f.example = true
                f:Show()
                update(f)
            end
        end,
        onLock = function()
            if f.example then
                f.example = false
                _G.RegisterUnitWatch(f)
                update(f)
            end
        end,
    })
end

-- Cadres du jeu : cachés (rangés dans un cadre invisible) tant que le module est actif.
local hiddenParent
local function hideBlizzardFrames()
    hiddenParent = hiddenParent or _G.CreateFrame("Frame")
    hiddenParent:Hide()
    for _, frame in ipairs({ _G.PlayerFrame, _G.TargetFrame }) do
        frame:UnregisterAllEvents()
        frame:SetParent(hiddenParent)
        -- Si le jeu le replace ailleurs (mode édition...), on le range de nouveau. Crochet seulement.
        _G.hooksecurefunc(frame, "SetParent", function(self, parent)
            if parent ~= hiddenParent and M.enabled then
                CUI:AfterCombat(function() self:SetParent(hiddenParent) end)
            end
        end)
    end
end

local function build()
    if built then return end
    built = true
    hideBlizzardFrames()
    for _, def in ipairs(UNITS) do
        createFrame(def)
    end
end

-- Aperçus dans les pages de réglages ---------------------------------------------------------

CUI.CadresUnite = {}

function CUI.CadresUnite.BuildPreview(parent, kind)
    local box = _G.CreateFrame("Frame", nil, parent)
    box:SetHeight(96)
    CUI:CreateBorderedRect(box, 4, C.graphite, C.fond)
    local holder = _G.CreateFrame("Frame", nil, box)
    holder:SetPoint("CENTER")
    box.holder, box.kind = holder, kind
    box.visual = createVisual(holder)
    return box
end

function CUI.CadresUnite.RefreshPreview(box)
    local s, g = M.db[box.kind], M.db.general
    local w, h = layout(box.visual, s, g, box.kind)
    box.holder:SetSize(w, h)
    local room = math.max(1, box:GetWidth() - 20)
    box.holder:SetScale(math.min(1, room / w))
    fillExample(box.visual, s, box.kind, false)
end

-- Marche / arrêt ----------------------------------------------------------------------------

function M:OnEnable()
    CUI:AfterCombat(build) -- cadres protégés : jamais créés en combat

    self:On("PLAYER_ENTERING_WORLD", function() updateAll() end)
    self:On("PLAYER_TARGET_CHANGED", function()
        if frames.cible then update(frames.cible) end
        if frames.tot then update(frames.tot) end
    end)
    -- Familier appelé, renvoyé ou changé.
    self:On("UNIT_PET", function(_, unit)
        if unit == "player" and frames.fam then update(frames.fam) end
    end)
    self:On("UNIT_TARGET", function(_, unit)
        if unit == "target" and frames.tot then update(frames.tot) end
    end)
    for _, event in ipairs({ "GROUP_ROSTER_UPDATE", "PARTY_LEADER_CHANGED", "PLAYER_LEVEL_UP" }) do
        self:On(event, function() updateAll() end)
    end
    for _, event in ipairs({ "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER",
                             "UNIT_DISPLAYPOWER", "UNIT_NAME_UPDATE", "UNIT_LEVEL", "UNIT_FACTION",
                             "UNIT_PORTRAIT_UPDATE", "UNIT_CLASSIFICATION_CHANGED", "UNIT_FLAGS" }) do
        self:On(event, function(_, unit)
            for _, f in pairs(frames) do
                if f.unit == unit and f:IsShown() then update(f) end
            end
        end)
    end
    -- La cible de la cible n'a pas d'évènements à elle : on la relit souvent.
    self:Every(0.25, function()
        local f = frames.tot
        if f and f:IsShown() then update(f) end
    end)
end

-- Coupé : il reste en place jusqu'au /reload (needsReload), comme les cadres du jeu cachés.
function M:OnDisable()
end

function M:OnSettingChanged()
    relayoutAll()
end

-- Police de CœurUI changée (page « Général »).
function M:OnFontChanged()
    relayoutAll()
end
