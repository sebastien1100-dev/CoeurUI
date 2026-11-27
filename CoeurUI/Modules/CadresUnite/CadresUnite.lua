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

-- Barre d'incantation (page « Joueur » seulement).
local TEMPS_INC = {
    { value = "rt", text = "CU_INC_TEMPS_RT" },
    { value = "r", text = "CU_INC_TEMPS_R" },
    { value = "aucun", text = "CU_VIE_AUCUN" },
}
local function incOn(read) return read("incantation") end
local function incDetachee(read) return read("incantation") and read("incDetachee") end

local function castPlace()
    return {
        { type = "section", text = "CU_INC" },
        { type = "toggle", key = "incantation", label = "CU_INC_AFFICHER" },
        { type = "toggle", key = "incDetachee", label = "CU_INC_DETACHER", description = "CU_INC_DETACHER_DESC",
          enabledIf = incOn },
        { type = "slider", key = "incHauteur", label = "CU_HAUTEUR", min = 10, max = 40, step = 1, format = "%d",
          enabledIf = incOn },
        { type = "slider", key = "incLargeur", label = "CU_INC_LARGEUR", min = 100, max = 500, step = 10, format = "%d",
          enabledIf = incDetachee },
        { type = "dropdown", key = "incTemps", label = "CU_INC_TEMPS", options = TEMPS_INC, enabledIf = incOn },
    }
end

local function castElements()
    return {
        { type = "section", text = "CU_INC_ELEMENTS" },
        { type = "toggle", key = "incIcone", label = "CU_INC_ICONE", enabledIf = incOn },
        { type = "toggle", key = "incNom", label = "CU_INC_NOM_SORT", enabledIf = incOn },
        { type = "toggle", key = "incLatence", label = "CU_INC_LATENCE", enabledIf = incOn },
        { type = "toggle", key = "incTics", label = "CU_INC_TICS", enabledIf = incOn },
    }
end

local function framePage(kind, minW, maxW, minH, maxH, couleurTexte, elements, cast)
    local items = {
        { type = "section", text = "CU_TAILLE" },
        { type = "slider", key = "largeur", label = "CU_LARGEUR", min = minW, max = maxW, step = 10, format = "%d" },
        { type = "slider", key = "hauteur", label = "CU_HAUTEUR", min = minH, max = maxH, step = 2, format = "%d" },
        { type = "section", text = "CU_TEXTES" },
        { type = "dropdown", key = "texteVie", label = "CU_TEXTE_VIE", options = TEXTE_VIE },
        couleurItem(couleurTexte),
    }
    local function add(list)
        for _, item in ipairs(list) do items[#items + 1] = item end
    end
    if cast then add(castPlace()) end
    add({
        { type = "column" },
        { type = "section", text = "CU_APERCU" },
        apercuItem(kind),
    })
    if elements then
        items[#items + 1] = { type = "section", text = "CU_ELEMENTS" }
        items[#items + 1] = { type = "toggle", key = "ressource", label = "CU_RESSOURCE" }
        items[#items + 1] = { type = "toggle", key = "niveau", label = "CU_NIVEAU" }
        items[#items + 1] = { type = "toggle", key = "portrait", label = "CU_PORTRAIT" }
        items[#items + 1] = { type = "toggle", key = "chef", label = "CU_CHEF" }
    end
    if cast then add(castElements()) end
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
                   ressource = true, niveau = true, portrait = false, chef = true,
                   incantation = true, incDetachee = false, incHauteur = 18, incLargeur = 270, incTemps = "rt",
                   incIcone = true, incNom = true, incLatence = true, incTics = true },
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
          settings = framePage("joueur", 120, 300, 20, 60, "CU_COULEUR_CLASSE", true, true) },
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
    -- Familier : rattaché au bas du cadre du joueur (barre d'incantation attachée comprise), qu'il suit.
    -- Nouvelle clé de position (l'ancienne était comptée depuis l'écran, pas depuis le joueur).
    { kind = "fam", unit = "pet", name = "CoeurUICadreFamilier", label = "CU_FAMILIER", moverKey = "cadre_familier",
      followsPlayer = true, default = { "TOPLEFT", "BOTTOMLEFT", 0, -4 } },
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

-- Point de rattachement du familier : sous le cadre du joueur, et sous la barre d'incantation quand
-- elle y est attachée. Ancré au seul cadre du joueur (protégé, jamais caché en combat) : un cadre
-- protégé ne s'ancre jamais à la barre d'incantation, qui se montre et se cache en combat.
local petAnchor
local function placePetAnchor()
    if not petAnchor or not frames.joueur then return end
    local s = M.db.joueur
    local y = (s.incantation and not s.incDetachee) and -(s.incHauteur + 4) or 0
    CUI:AfterCombat(function()
        petAnchor:ClearAllPoints()
        petAnchor:SetPoint("TOPLEFT", frames.joueur, "BOTTOMLEFT", 0, y)
        petAnchor:SetPoint("TOPRIGHT", frames.joueur, "BOTTOMRIGHT", 0, y)
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

    local parent
    if def.followsPlayer then
        petAnchor = petAnchor or _G.CreateFrame("Frame", nil, _G.UIParent)
        petAnchor:SetHeight(1)
        placePetAnchor()
        parent = petAnchor
    end
    CUI:RegisterMover({
        key = def.moverKey or ("cadre_" .. def.kind), frame = f, label = def.label, default = def.default,
        parent = parent,
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

-- Barre d'incantation du joueur (maquette validée le 27/11/2026) ----------------------------
-- Sous le cadre du joueur, à sa largeur, ou détachée (placée avec le cadenas). Cadre simple (pas
-- protégé) : il peut changer en combat. La barre du jeu est cachée tant que la nôtre est affichée
-- (rangée dans le cadre invisible, rendue à son parent quand on coupe l'option).
-- Valeurs possiblement secrètes (nom, temps) : nom et icône passés tels quels au jeu ; sans temps
-- connus, la barre reste pleine et sans chiffres.

local INC_MOVER = "cadre_incantation"
local INC_COULEURS = {
    cast = { 0.29, 0.47, 0.72 },   -- incantation : bleu acier
    canal = { 0.31, 0.60, 0.42 },  -- canalisation : vert
    fin = { 0.43, 0.60, 0.84 },    -- réussie : un instant plus clair
    echec = C.coeur,               -- interrompue, échec
}
local INC_TENUE = { fin = 0.15, echec = 0.6 } -- temps affiché avant de s'effacer
local INC_FONDU = 0.3

-- Intervalle des tics des canalisations connues (identifiant du premier rang » secondes).
-- Les autres rangs sont reconnus par le nom du sort, lu au jeu.
local TICS = {
    [5143] = 1,   -- Projectiles des arcanes
    [10] = 1,     -- Blizzard
    [12051] = 2,  -- Évocation
    [689] = 1,    -- Drain de vie
    [1120] = 3,   -- Siphon d'âme
    [5138] = 1,   -- Drain de mana
    [755] = 1,    -- Captation de vie
    [5740] = 2,   -- Pluie de feu
    [1949] = 1,   -- Flammes infernales
    [15407] = 1,  -- Fouet mental
    [16914] = 1,  -- Ouragan
    [740] = 2,    -- Tranquillité
    [1510] = 1,   -- Salve
}
local ticsByName

local function tickInterval(spellID, name)
    if known(spellID) and TICS[spellID] then return TICS[spellID] end
    if not known(name) then return nil end
    if not ticsByName then
        ticsByName = {}
        local getName = _G.C_Spell and _G.C_Spell.GetSpellName
        if getName then
            for id, sec in pairs(TICS) do
                local ok, n = pcall(getName, id)
                if ok and known(n) then ticsByName[n] = sec end
            end
        end
    end
    return ticsByName[name]
end

local cast = { mode = nil } -- mode : nil, "cast", "canal", "fin", "echec", "exemple"

local function decimal(x)
    return (("%.1f"):format(x):gsub("%.", L.CU_INC_DECIMALE))
end

local function setCastColor(c)
    cast.frame.bar:SetStatusBarColor(c[1], c[2], c[3])
end

local function setCastTime(remaining, total)
    local mode = M.db.joueur.incTemps
    local fs = cast.frame.time
    if mode == "aucun" or not remaining then
        fs:SetText("")
    elseif mode == "r" then
        fs:SetText(decimal(remaining))
    else
        fs:SetText(decimal(remaining) .. " / " .. decimal(total))
    end
end

local function hideTicks()
    for _, t in ipairs(cast.frame.ticks) do t:Hide() end
end

-- Fin de l'affichage : la barre se cache (ou l'exemple revient, cadenas ouvert).
local function hideCast()
    local f = cast.frame
    cast.mode = nil
    f.latency:Hide()
    hideTicks()
    if cast.example then
        cast.mode = "exemple"
        f.name:SetText(L.CU_INC_EXEMPLE)
        f.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        f.bar:SetMinMaxValues(0, 1)
        f.bar:SetValue(0.56)
        setCastColor(INC_COULEURS.cast)
        setCastTime(1.4, 2.5)
        f:SetAlpha(1)
        f:Show()
    else
        f:Hide()
    end
end

local function placeTicks(total, interval)
    hideTicks()
    if not (M.db.joueur.incTics and interval and total > 0) then return end
    local f = cast.frame
    local n = math.floor(total / interval + 0.5)
    if n < 2 or n > 20 then return end
    local width = f.bar:GetWidth()
    for k = 1, n - 1 do
        local t = f.ticks[k]
        if not t then
            t = f.bar:CreateTexture(nil, "OVERLAY")
            t:SetColorTexture(C.fond[1], C.fond[2], C.fond[3], 0.8)
            t:SetWidth(1)
            f.ticks[k] = t
        end
        t:ClearAllPoints()
        t:SetPoint("TOP", f.bar, "TOPLEFT", width * k / n, 0)
        t:SetPoint("BOTTOM", f.bar, "BOTTOMLEFT", width * k / n, 0)
        t:Show()
    end
end

-- Une incantation (ou canalisation) commence ou change : tout est relu au jeu.
local function startCast(channel)
    local f = cast.frame
    local name, texture, startMS, endMS, castID, spellID
    if channel then
        local n, _, tex, s, e, _, _, id = _G.UnitChannelInfo("player")
        name, texture, startMS, endMS, spellID = n, tex, s, e, id
    else
        local n, _, tex, s, e, _, cid, _, id = _G.UnitCastingInfo("player")
        name, texture, startMS, endMS, castID, spellID = n, tex, s, e, cid, id
    end
    if name == nil then return end
    cast.mode = channel and "canal" or "cast"
    cast.wasCast = not channel
    cast.castID = known(castID) and castID or nil
    f.name:SetText(name)
    f.icon:SetTexture(texture)
    setCastColor(channel and INC_COULEURS.canal or INC_COULEURS.cast)
    f.bar:SetMinMaxValues(0, 1)
    f.latency:Hide()
    hideTicks()
    if known(startMS) and known(endMS) and startMS and endMS and endMS > startMS then
        cast.start, cast.finish = startMS / 1000, endMS / 1000
        local total = cast.finish - cast.start
        if not channel and M.db.joueur.incLatence and _G.GetNetStats then
            local _, _, _, world = _G.GetNetStats()
            if known(world) and world and world > 0 then
                local frac = math.min(1, world / 1000 / total)
                f.latency:SetWidth(math.max(1, f.bar:GetWidth() * frac))
                f.latency:Show()
            end
        end
        if channel then placeTicks(total, tickInterval(spellID, name)) end
    else
        cast.start = nil -- temps cachés : barre pleine, sans chiffres
        f.bar:SetValue(1)
        setCastTime(nil)
    end
    f:SetAlpha(1)
    f:Show()
end

-- Fin d'une incantation : réussie (« fin ») ou ratée (« echec », avec son texte).
local function endCast(mode, text)
    local f = cast.frame
    cast.mode, cast.endTime = mode, _G.GetTime()
    f.latency:Hide()
    if mode == "echec" then
        hideTicks()
        f.bar:SetValue(1)
        f.name:SetText(text)
        setCastTime(nil)
        setCastColor(INC_COULEURS.echec)
    elseif cast.wasCast then
        f.bar:SetValue(1)
        setCastColor(INC_COULEURS.fin)
    end
end

local function sameCast(castGUID)
    if not cast.castID or castGUID == nil or not known(castGUID) then return true end
    return castGUID == cast.castID
end

local function onCastUpdate(f)
    local mode = cast.mode
    if (mode == "cast" or mode == "canal") and cast.start then
        local now = _G.GetTime()
        local total = cast.finish - cast.start
        local elapsed = math.min(math.max(now - cast.start, 0), total)
        local p = elapsed / total
        f.bar:SetValue(mode == "canal" and 1 - p or p)
        setCastTime(total - elapsed, total)
        -- Sans évènement de fin (rare) : effacée un peu après la fin prévue.
        if now > cast.finish + 1 then hideCast() end
    elseif mode == "fin" or mode == "echec" then
        local t = _G.GetTime() - cast.endTime - INC_TENUE[mode]
        if t >= INC_FONDU then
            hideCast()
        elseif t > 0 then
            f:SetAlpha(1 - t / INC_FONDU)
        end
    end
end

local function createCastBar()
    local f = _G.CreateFrame("Frame", "CoeurUIIncantation", _G.UIParent)
    f:SetFrameStrata("LOW")
    f:Hide()
    f.iconBox = _G.CreateFrame("Frame", nil, f)
    CUI:CreateBorderedRect(f.iconBox, 3, C.graphite, C.fond)
    f.icon = f.iconBox:CreateTexture(nil, "ARTWORK")
    f.icon:SetPoint("TOPLEFT", 1, -1)
    f.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.barBox, f.bar = newBar(f)
    f.latency = f.bar:CreateTexture(nil, "OVERLAY")
    f.latency:SetColorTexture(0.35, 0.37, 0.41, 0.75)
    f.latency:SetPoint("TOPRIGHT")
    f.latency:SetPoint("BOTTOMRIGHT")
    f.latency:Hide()
    f.ticks = {}
    local texts = _G.CreateFrame("Frame", nil, f.bar)
    texts:SetAllPoints()
    texts:SetFrameLevel(f.bar:GetFrameLevel() + 2)
    f.name, f.time = newText(texts), newText(texts)
    f.name:SetJustifyH("LEFT")
    f.time:SetJustifyH("RIGHT")
    f:SetScript("OnUpdate", onCastUpdate)
    cast.frame = f
end

-- Barre du jeu : rangée dans le cadre invisible (hide = true) ou rendue à son parent d'origine.
local castBarParents = {} -- barre du jeu -> parent d'origine
local blizzardCastHidden = false
local function setBlizzardCastBar(hide)
    blizzardCastHidden = hide
    -- Le cadre invisible porte les cadres protégés du jeu (joueur, cible) : jamais de Hide() dessus
    -- en combat. Il est déjà caché ; on ne le cache qu'à sa création.
    if not hiddenParent then
        hiddenParent = _G.CreateFrame("Frame")
        hiddenParent:Hide()
    end
    for _, frameName in ipairs({ "PlayerCastingBarFrame", "CastingBarFrame" }) do
        local bar = _G[frameName]
        if bar then
            if not castBarParents[bar] then
                castBarParents[bar] = bar:GetParent() or _G.UIParent
                -- Si le jeu la replace ailleurs, on la range de nouveau. Crochet seulement.
                _G.hooksecurefunc(bar, "SetParent", function(self, parent)
                    if blizzardCastHidden and M.enabled and parent ~= hiddenParent then
                        CUI:AfterCombat(function()
                            if blizzardCastHidden then self:SetParent(hiddenParent) end
                        end)
                    end
                end)
            end
            local target = hide and hiddenParent or castBarParents[bar]
            if bar:GetParent() ~= target then
                CUI:AfterCombat(function() bar:SetParent(target) end)
            end
        end
    end
end

-- Place, taille et pièces de la barre selon les réglages.
local function applyCast()
    local f = cast.frame
    if not f then return end
    local s, g = M.db.joueur, M.db.general
    setBlizzardCastBar(s.incantation)
    placePetAnchor() -- le familier descend sous la barre attachée, remonte sinon

    if s.incantation and s.incDetachee then
        f:SetSize(s.incLargeur, s.incHauteur)
        if not cast.mover then
            cast.mover = true
            CUI:RegisterMover({
                key = INC_MOVER, frame = f, label = "CU_INC_NOM", default = { "CENTER", "CENTER", 0, -120 },
                onUnlock = function()
                    cast.example = true
                    if not cast.mode then hideCast() end
                end,
                onLock = function()
                    cast.example = false
                    if cast.mode == "exemple" then hideCast() end
                end,
            })
        end
    else
        if cast.mover then
            cast.mover = false
            CUI:UnregisterMover(INC_MOVER)
            cast.example = false
            if cast.mode == "exemple" then hideCast() end
        end
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", frames.joueur, "BOTTOMLEFT", 0, -4)
        f:SetPoint("TOPRIGHT", frames.joueur, "BOTTOMRIGHT", 0, -4)
        f:SetHeight(s.incHauteur)
    end

    local h = s.incHauteur
    f.iconBox:SetShown(s.incIcone)
    f.iconBox:ClearAllPoints()
    f.iconBox:SetPoint("TOPLEFT")
    f.iconBox:SetSize(h, h)
    f.barBox:ClearAllPoints()
    f.barBox:SetPoint("TOPLEFT", s.incIcone and (h + 3) or 0, 0)
    f.barBox:SetPoint("BOTTOMRIGHT")
    f.bar:SetStatusBarTexture(CUI:GetBarTexture(g.texture))

    local size = math.max(8, math.min(14, h - 6))
    local font = CUI:GetFont()
    f.name:SetFont(font, size, "")
    f.time:SetFont(font, size, "")
    f.name:SetShown(s.incNom)
    f.time:ClearAllPoints()
    f.time:SetPoint("RIGHT", f.bar, "RIGHT", -6, 0)
    f.name:ClearAllPoints()
    f.name:SetPoint("LEFT", f.bar, "LEFT", 6, 0)
    f.name:SetPoint("RIGHT", f.time, "LEFT", -6, 0)

    if not s.incantation then
        cast.mode = nil
        f:Hide()
    elseif cast.mode == "exemple" then
        hideCast() -- exemple redessiné (temps affiché...)
    end
end

-- Évènements des sorts du joueur.
local function onSpellEvent(event, unit, castGUID)
    if unit ~= "player" or not cast.frame or not M.db.joueur.incantation then return end
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
        startCast(false)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        startCast(true)
    elseif event == "UNIT_SPELLCAST_STOP" then
        if cast.mode == "cast" and sameCast(castGUID) then endCast("fin") end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if cast.mode == "canal" then endCast("fin") end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        if (cast.mode == "cast" and sameCast(castGUID)) or cast.mode == "canal" then
            endCast("echec", L.CU_INC_INTERROMPU)
        end
    elseif event == "UNIT_SPELLCAST_FAILED" then
        if cast.mode == "cast" and sameCast(castGUID) then endCast("echec", L.CU_INC_ECHEC) end
    end
end

local INC_EVENTS = {
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_CHANNEL_STOP",
}

-- Après un écran de chargement : une incantation déjà en cours est reprise.
local function resumeCast()
    if not cast.frame or not M.db.joueur.incantation then return end
    if _G.UnitCastingInfo("player") ~= nil then
        startCast(false)
    elseif _G.UnitChannelInfo("player") ~= nil then
        startCast(true)
    elseif cast.mode == "cast" or cast.mode == "canal" then
        hideCast()
    end
end

local function build()
    if built then return end
    built = true
    hideBlizzardFrames()
    for _, def in ipairs(UNITS) do
        createFrame(def)
    end
    createCastBar()
    applyCast()
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

    self:On("PLAYER_ENTERING_WORLD", function()
        updateAll()
        resumeCast()
    end)
    for _, event in ipairs(INC_EVENTS) do
        self:On(event, onSpellEvent)
    end
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
    applyCast() -- cadre simple : tout de suite, même en combat
end

-- Police de CœurUI changée (page « Général »).
function M:OnFontChanged()
    relayoutAll()
    applyCast()
end
