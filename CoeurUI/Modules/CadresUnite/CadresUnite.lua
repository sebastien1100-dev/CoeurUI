-- Module « Cadres d'unité » : cadres du joueur, de la cible et de la cible de la cible (maquette validée).
-- Remplace les cadres du jeu (cachés tant que le module est actif ; le couper demande un /reload).
-- Sous-onglets : Général (tailles des libellés, texture : communs à tous les cadres ; la police est
-- celle de CœurUI, page « Général » de la fenêtre), Joueur,
-- Cible, Cible de la cible, Familier, Groupe (Groupe.lua). Les cadres se placent avec le cadenas de la fenêtre (mode
-- déplacement). Barres d'incantation du joueur et de la cible : réglées dans leur page.
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

local function castElements(kind)
    local last = kind == "joueur"
        and { type = "toggle", key = "incLatence", label = "CU_INC_LATENCE", enabledIf = incOn }
        or { type = "toggle", key = "incProtege", label = "CU_INC_PROTEGE", enabledIf = incOn }
    return {
        { type = "section", text = "CU_INC_ELEMENTS" },
        { type = "toggle", key = "incIcone", label = "CU_INC_ICONE", enabledIf = incOn },
        { type = "toggle", key = "incNom", label = "CU_INC_NOM_SORT", enabledIf = incOn },
        { type = "toggle", key = "incTics", label = "CU_INC_TICS", enabledIf = incOn },
        last,
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
    if cast then add(castElements(kind)) end
    return items
end

local M = CUI:RegisterModule({
    key = "CadresUnite",
    name = "CU_NOM",
    description = "CU_DESC",
    defaultEnabled = false,
    needsReload = true, -- les cadres du jeu ne reviennent qu'après un /reload
    defaults = {
        general = { tailleNom = 12, tailleNiveau = 12, tailleVie = 11, texture = "striee", soinsAVenir = true },
        joueur = { largeur = 230, hauteur = 34, texteVie = "vp", couleur = "classe",
                   ressource = true, niveau = true, portrait = false, chef = true,
                   incantation = true, incDetachee = false, incHauteur = 18, incLargeur = 270, incTemps = "rt",
                   incIcone = true, incNom = true, incLatence = true, incTics = true },
        cible = { largeur = 230, hauteur = 34, texteVie = "p", couleur = "classe",
                  ressource = true, niveau = true, portrait = false, chef = true,
                  incantation = true, incDetachee = false, incHauteur = 18, incLargeur = 270, incTemps = "rt",
                  incIcone = true, incNom = true, incTics = true, incProtege = true },
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
            { type = "toggle", key = "soinsAVenir", label = "CU_GR_SOINS_A_VENIR", description = "CU_SOINS_A_VENIR_NOTE" },
            apercuItem("joueur"),
        } },
        { key = "joueur", name = "CU_JOUEUR", intro = false,
          settings = framePage("joueur", 120, 300, 20, 60, "CU_COULEUR_CLASSE", true, true) },
        { key = "cible", name = "CU_CIBLE", intro = false,
          settings = framePage("cible", 120, 300, 20, 60, "CU_COULEUR_ATTITUDE", true, true) },
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
    box.panel = CUI:CreatePanel(box) -- style du thème : fond, double liseré, ombre
    local bar = _G.CreateFrame("StatusBar", nil, box)
    bar:SetPoint("TOPLEFT", 2, -2)
    bar:SetPoint("BOTTOMRIGHT", -2, 2)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
    return box, bar
end

local function createVisual(parent)
    local v = { parent = parent }
    v.healthBox, v.health = newBar(parent)
    v.powerBox, v.power = newBar(parent)
    v.portraitBox = _G.CreateFrame("Frame", nil, parent)
    CUI:CreatePanel(v.portraitBox, { fill = C.desactiveFond })
    v.portrait = v.portraitBox:CreateTexture(nil, "ARTWORK")
    v.portrait:SetPoint("TOPLEFT", 2, -2)
    v.portrait:SetPoint("BOTTOMRIGHT", -2, 2)
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
    -- Soins à venir : une barre vert clair qui part du bout de la vie, rognée au bord de la barre.
    v.health:SetClipsChildren(true)
    v.incoming = _G.CreateFrame("StatusBar", nil, v.health)
    v.incoming:SetFrameLevel(v.health:GetFrameLevel() + 1)
    v.incoming:SetMinMaxValues(0, 1)
    v.incoming:Hide()
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

    CUI:SetBarTexture(v.health, g.texture)
    -- Soins à venir : accrochés au bout de la vie (à refaire après chaque changement de texture).
    CUI:SetBarTexture(v.incoming, g.texture)
    v.incoming:SetStatusBarColor(C.actif[1], C.actif[2], C.actif[3], 0.45)
    v.incoming:SetWidth(math.max(1, w - 2))
    local fillTex = v.health:GetStatusBarTexture()
    v.incoming:ClearAllPoints()
    if fillTex then
        v.incoming:SetPoint("TOPLEFT", fillTex, "TOPRIGHT")
        v.incoming:SetPoint("BOTTOMLEFT", fillTex, "BOTTOMRIGHT")
    end
    CUI:SetBarTexture(v.power, g.texture)

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

-- Pourcentage de vie (valeur possiblement secrète : rendue par le jeu quand il sait le faire).
local function healthPercent(unit, hp, maxHp)
    local pct
    if _G.UnitHealthPercent and _G.CurveConstants then
        local ok, value = pcall(_G.UnitHealthPercent, unit, true, _G.CurveConstants.ScaleTo100)
        pct = ok and value or nil
    end
    if pct == nil then
        pct = (known(hp) and known(maxHp) and maxHp > 0) and (hp / maxHp * 100) or 0
    end
    return pct
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
    -- Cible de la cible : rattachée au bas du cadre de la cible (barre d'incantation attachée comprise),
    -- qu'elle suit. Familier : pareil sous le joueur. Nouvelles clés de position (les anciennes étaient
    -- comptées depuis l'écran, pas depuis le cadre suivi).
    { kind = "tot", unit = "targettarget", name = "CoeurUICadreCibleCible", label = "CU_CIBLE_CIBLE",
      moverKey = "cadre_cible_cible", follows = "cible", default = { "TOPRIGHT", "BOTTOMRIGHT", 0, -4 } },
    { kind = "fam", unit = "pet", name = "CoeurUICadreFamilier", label = "CU_FAMILIER", moverKey = "cadre_familier",
      follows = "joueur", default = { "TOPLEFT", "BOTTOMLEFT", 0, -4 } },
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
        setHealthText(v.hp, s.texteVie, hp, healthPercent(unit, hp, maxHp))
    end
    v.health:SetStatusBarColor(color[1], color[2], color[3])
    -- Soins à venir (valeur possiblement secrète : passée telle quelle à la barre).
    local incoming = (M.db.general.soinsAVenir and not (known(dead) and dead) and _G.UnitGetIncomingHeals)
        and _G.UnitGetIncomingHeals(unit) or nil
    if incoming ~= nil then
        v.incoming:SetMinMaxValues(0, maxHp)
        v.incoming:SetValue(incoming)
        v.incoming:Show()
    else
        v.incoming:Hide()
    end

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

-- Points de rattachement : le familier sous le cadre du joueur, la cible de la cible sous celui de la
-- cible, et sous leur barre d'incantation quand elle y est attachée. Ancrés au seul cadre de l'unité
-- (protégé, jamais caché en combat) : un cadre protégé ne s'ancre jamais à une barre d'incantation,
-- qui se montre et se cache en combat.
local anchors = {} -- kind du cadre suivi (joueur, cible) -> point de rattachement
local function placeAnchor(kind)
    local anchor, owner = anchors[kind], frames[kind]
    if not anchor or not owner then return end
    local s = M.db[kind]
    local y = (s.incantation and not s.incDetachee) and -(s.incHauteur + 4) or 0
    CUI:AfterCombat(function()
        anchor:ClearAllPoints()
        anchor:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, y)
        anchor:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 0, y)
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
    if def.follows then
        local anchor = anchors[def.follows] or _G.CreateFrame("Frame", nil, _G.UIParent)
        anchor:SetHeight(1)
        anchors[def.follows] = anchor
        placeAnchor(def.follows)
        parent = anchor
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

-- Barres d'incantation du joueur et de la cible (maquettes validées le 27/11/2026) -------------
-- Sous le cadre de leur unité, à sa largeur, ou détachées (placées avec le cadenas). Cadres simples
-- (pas protégés) : ils peuvent changer en combat. La barre du jeu du joueur est cachée tant que la
-- nôtre est affichée ; celle de la cible part avec le cadre de la cible du jeu (déjà caché).
-- Valeurs possiblement secrètes (surtout la cible en combat : nom, temps, « ne peut pas être
-- interrompu ») : nom et icône passés tels quels au jeu ; sans temps connus, la barre avance seule
-- si le jeu sait le faire (durée du sort), sinon elle reste pleine ; jamais de chiffres.

local INC_COULEURS = {
    cast = { 0.29, 0.47, 0.72 },     -- incantation : bleu acier
    canal = { 0.31, 0.60, 0.42 },    -- canalisation : vert
    fin = { 0.43, 0.60, 0.84 },      -- réussie : un instant plus clair
    echec = C.coeur,                 -- interrompue, échec
    protege = { 0.48, 0.49, 0.53 },  -- la cible incante un sort qu'on ne peut pas interrompre : gris
}
local INC_TENUE = { fin = 0.15, echec = 0.6 } -- temps affiché avant de s'effacer
local INC_FONDU = 0.3

local CAST_DEFS = {
    { kind = "joueur", unit = "player", name = "CoeurUIIncantation", mover = "cadre_incantation",
      label = "CU_INC_NOM", default = { "CENTER", "CENTER", 0, -120 }, latence = true },
    { kind = "cible", unit = "target", name = "CoeurUIIncantationCible", mover = "cadre_incantation_cible",
      label = "CU_INC_NOM_CIBLE", default = { "CENTER", "CENTER", 0, 60 }, protege = true },
}
local bars = {}       -- kind -> barre
-- Réglages d'une barre : ceux de sa page (def.settings pour une barre d'un autre fichier, ex. les boss).
local function castSettings(b)
    return b.def.settings and b.def.settings() or M.db[b.kind]
end
local barByUnit = {}  -- unité -> barre

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

local function decimal(x)
    return (("%.1f"):format(x):gsub("%.", L.CU_INC_DECIMALE))
end

-- Nom de sort à afficher : certains sorts du jeu n'ont pas de nom traduit (« Opening - No Text » en
-- ouvrant un coffre, un sac de récolte...) ; on retire « - No Text » et on traduit les plus courants.
local SANS_TEXTE = { Opening = "CU_INC_OUVERTURE" }
local function castName(name)
    if not known(name) or type(name) ~= "string" then return name end
    local base = name:match("^(.-)%s*%-%s*No Text$")
    if not base then return name end
    local key = SANS_TEXTE[base]
    return key and L[key] or base
end

local function setCastColor(b, c)
    b.frame.bar:SetStatusBarColor(c[1], c[2], c[3])
end

local function setCastTime(b, remaining, total)
    local mode = castSettings(b).incTemps
    local fs = b.frame.time
    if mode == "aucun" or not remaining then
        fs:SetText("")
    elseif mode == "r" then
        fs:SetText(decimal(remaining))
    else
        fs:SetText(decimal(remaining) .. " / " .. decimal(total))
    end
end

local function hideTicks(b)
    for _, t in ipairs(b.frame.ticks) do t:Hide() end
end

-- Barre animée par le jeu (temps cachés) : arrêtée avant toute autre valeur.
local function stopTimer(b)
    local bar = b.frame.bar
    if b.timer and bar.ClearTimerDuration then pcall(bar.ClearTimerDuration, bar) end
    b.timer = false
end

-- Fin de l'affichage : la barre se cache (ou l'exemple revient, cadenas ouvert).
local function hideCast(b)
    local f = b.frame
    b.mode = nil
    stopTimer(b)
    f.latency:Hide()
    f.lock:Hide()
    f.name:SetPoint("LEFT", f.bar, "LEFT", 6, 0)
    hideTicks(b)
    if b.example then
        b.mode = "exemple"
        f.name:SetText(L.CU_INC_EXEMPLE)
        f.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        f.bar:SetMinMaxValues(0, 1)
        f.bar:SetValue(0.56)
        setCastColor(b, INC_COULEURS.cast)
        setCastTime(b, 1.4, 2.5)
        f:SetAlpha(1)
        f:Show()
    else
        f:Hide()
    end
end

local function placeTicks(b, total, interval)
    hideTicks(b)
    if not (castSettings(b).incTics and interval and total > 0) then return end
    local f = b.frame
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

-- Couleur selon que le sort peut être interrompu (cible seulement ; valeur cachée : bleu normal).
local function paintProtect(b, notInterruptible)
    local f = b.frame
    local protect = b.def.protege and castSettings(b).incProtege and known(notInterruptible) and notInterruptible
    if protect then
        setCastColor(b, INC_COULEURS.protege)
    else
        setCastColor(b, b.mode == "canal" and INC_COULEURS.canal or INC_COULEURS.cast)
    end
    local lock = protect and castSettings(b).incNom or false
    f.lock:SetShown(lock)
    -- Le nom laisse la place au cadenas quand il est là.
    f.name:SetPoint("LEFT", f.bar, "LEFT", lock and ((b.fontSize or 11) + 8) or 6, 0)
end

-- Une incantation (ou canalisation) commence ou change : tout est relu au jeu.
local function startCast(b, channel)
    local f, unit = b.frame, b.unit
    local name, texture, startMS, endMS, castID, notInterruptible, spellID
    if channel then
        local n, _, tex, s, e, _, ni, id = _G.UnitChannelInfo(unit)
        name, texture, startMS, endMS, notInterruptible, spellID = n, tex, s, e, ni, id
    else
        local n, _, tex, s, e, _, cid, ni, id = _G.UnitCastingInfo(unit)
        name, texture, startMS, endMS, castID, notInterruptible, spellID = n, tex, s, e, cid, ni, id
    end
    if name == nil then return end
    stopTimer(b)
    b.mode = channel and "canal" or "cast"
    b.wasCast = not channel
    b.castID = known(castID) and castID or nil
    f.name:SetText(castName(name))
    f.icon:SetTexture(texture)
    paintProtect(b, notInterruptible)
    f.bar:SetMinMaxValues(0, 1)
    f.latency:Hide()
    hideTicks(b)
    if known(startMS) and known(endMS) and startMS and endMS and endMS > startMS then
        b.start, b.finish = startMS / 1000, endMS / 1000
        local total = b.finish - b.start
        if b.def.latence and not channel and castSettings(b).incLatence and _G.GetNetStats then
            local _, _, _, world = _G.GetNetStats()
            if known(world) and world and world > 0 then
                local frac = math.min(1, world / 1000 / total)
                f.latency:SetWidth(math.max(1, f.bar:GetWidth() * frac))
                f.latency:Show()
            end
        end
        if channel then placeTicks(b, total, tickInterval(spellID, name)) end
    else
        -- Temps cachés : le jeu anime la barre s'il le sait, sinon elle reste pleine. Pas de chiffres.
        b.start = nil
        setCastTime(b, nil)
        local getDuration = channel and _G.UnitChannelDuration or _G.UnitCastingDuration
        local ok, duration = false, nil
        if getDuration and f.bar.SetTimerDuration then
            ok, duration = pcall(getDuration, unit)
        end
        if ok and duration and pcall(f.bar.SetTimerDuration, f.bar, duration) then
            b.timer = true
        else
            f.bar:SetValue(1)
        end
    end
    f:SetAlpha(1)
    f:Show()
end

-- Fin d'une incantation : réussie (« fin ») ou ratée (« echec », avec son texte).
local function endCast(b, mode, text)
    local f = b.frame
    stopTimer(b)
    b.mode, b.endTime = mode, _G.GetTime()
    f.latency:Hide()
    f.lock:Hide()
    f.name:SetPoint("LEFT", f.bar, "LEFT", 6, 0)
    if mode == "echec" then
        hideTicks(b)
        f.bar:SetValue(1)
        f.name:SetText(text)
        setCastTime(b, nil)
        setCastColor(b, INC_COULEURS.echec)
    elseif b.wasCast then
        f.bar:SetValue(1)
        setCastColor(b, INC_COULEURS.fin)
    end
end

local function sameCast(b, castGUID)
    if not b.castID or castGUID == nil or not known(castGUID) then return true end
    return castGUID == b.castID
end

local function onCastUpdate(b)
    local f, mode = b.frame, b.mode
    if (mode == "cast" or mode == "canal") and b.start then
        local now = _G.GetTime()
        local total = b.finish - b.start
        local elapsed = math.min(math.max(now - b.start, 0), total)
        local p = elapsed / total
        f.bar:SetValue(mode == "canal" and 1 - p or p)
        setCastTime(b, total - elapsed, total)
        -- Sans évènement de fin (rare) : effacée un peu après la fin prévue.
        if now > b.finish + 1 then hideCast(b) end
    elseif mode == "fin" or mode == "echec" then
        local t = _G.GetTime() - b.endTime - INC_TENUE[mode]
        if t >= INC_FONDU then
            hideCast(b)
        elseif t > 0 then
            f:SetAlpha(1 - t / INC_FONDU)
        end
    end
end

local function createCastBar(def)
    local b = { def = def, kind = def.kind, unit = def.unit }
    local f = _G.CreateFrame("Frame", def.name, def.parent or _G.UIParent)
    f:SetFrameStrata("LOW")
    f:Hide()
    f.iconBox = _G.CreateFrame("Frame", nil, f)
    CUI:CreatePanel(f.iconBox, { shadow = false })
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
    -- Petit cadenas devant le nom : sort qu'on ne peut pas interrompre.
    f.lock = texts:CreateTexture(nil, "OVERLAY")
    f.lock:SetTexture(CUI.MEDIA .. "Cadenas")
    f.lock:SetVertexColor(C.texte[1], C.texte[2], C.texte[3])
    f.lock:Hide()
    f.name:SetPoint("LEFT", f.bar, "LEFT", 6, 0)
    f:SetScript("OnUpdate", function() onCastUpdate(b) end)
    b.frame = f
    bars[def.kind], barByUnit[def.unit] = b, b
    return b
end

-- Barre du jeu du joueur : rangée dans le cadre invisible (hide = true) ou rendue à son parent.
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

-- Place, taille et pièces d'une barre selon les réglages.
local function applyCast(b)
    local f, def = b.frame, b.def
    local s, g = castSettings(b), M.db.general
    if b.kind == "joueur" then setBlizzardCastBar(s.incantation) end
    placeAnchor(b.kind) -- le cadre rattaché (familier, cible de la cible) passe sous la barre attachée

    if s.incantation and s.incDetachee then
        f:SetSize(s.incLargeur, s.incHauteur)
        if not b.mover then
            b.mover = true
            CUI:RegisterMover({
                key = def.mover, frame = f, label = def.label, default = def.default,
                onUnlock = function()
                    b.example = true
                    if not b.mode then hideCast(b) end
                end,
                onLock = function()
                    b.example = false
                    if b.mode == "exemple" then hideCast(b) end
                end,
            })
        end
    else
        if b.mover then
            b.mover = false
            CUI:UnregisterMover(def.mover)
            b.example = false
            if b.mode == "exemple" then hideCast(b) end
        end
        local owner = def.owner or frames[b.kind]
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -4)
        f:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 0, -4)
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
    CUI:SetBarTexture(f.bar, g.texture)

    local size = math.max(8, math.min(14, h - 6))
    local font = CUI:GetFont()
    f.name:SetFont(font, size, "")
    f.time:SetFont(font, size, "")
    f.name:SetShown(s.incNom)
    f.lock:SetSize(size, size)
    f.lock:ClearAllPoints()
    f.lock:SetPoint("LEFT", f.bar, "LEFT", 5, 0)
    f.time:ClearAllPoints()
    f.time:SetPoint("RIGHT", f.bar, "RIGHT", -6, 0)
    f.name:ClearAllPoints()
    b.fontSize = size
    f.name:SetPoint("LEFT", f.bar, "LEFT", f.lock:IsShown() and (size + 8) or 6, 0)
    f.name:SetPoint("RIGHT", f.time, "LEFT", -6, 0)

    if not s.incantation then
        stopTimer(b)
        b.mode = nil
        f:Hide()
    elseif b.mode == "exemple" then
        hideCast(b) -- exemple redessiné (temps affiché...)
    end
end

local function applyAllCasts()
    for _, b in pairs(bars) do applyCast(b) end
end

-- Évènements des sorts (joueur et cible).
local function onSpellEvent(event, unit, castGUID)
    local b = barByUnit[unit]
    if not b or not castSettings(b).incantation then return end
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
        startCast(b, false)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        startCast(b, true)
    elseif event == "UNIT_SPELLCAST_STOP" then
        if b.mode == "cast" and sameCast(b, castGUID) then endCast(b, "fin") end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if b.mode == "canal" then endCast(b, "fin") end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        if (b.mode == "cast" and sameCast(b, castGUID)) or b.mode == "canal" then
            endCast(b, "echec", L.CU_INC_INTERROMPU)
        end
    elseif event == "UNIT_SPELLCAST_FAILED" then
        if b.mode == "cast" and sameCast(b, castGUID) then endCast(b, "echec", L.CU_INC_ECHEC) end
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
        if b.mode == "cast" or b.mode == "canal" then paintProtect(b, false) end
    elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        if b.mode == "cast" or b.mode == "canal" then paintProtect(b, true) end
    end
end

local INC_EVENTS = {
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_CHANNEL_STOP",
}
-- Pas sur tous les clients : inscrits seulement s'ils existent.
local INC_EVENTS_OPTIONAL = { "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" }

-- Incantation déjà en cours (écran de chargement, nouvelle cible) : reprise ; sinon, barre cachée.
local function resumeCast(b)
    if not b or not castSettings(b).incantation then return end
    if _G.UnitCastingInfo(b.unit) ~= nil then
        startCast(b, false)
    elseif _G.UnitChannelInfo(b.unit) ~= nil then
        startCast(b, true)
    elseif b.mode and b.mode ~= "exemple" then
        hideCast(b)
    end
end

local function build()
    if built then return end
    built = true
    hideBlizzardFrames()
    for _, def in ipairs(UNITS) do
        createFrame(def)
    end
    for _, def in ipairs(CAST_DEFS) do
        applyCast(createCastBar(def))
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

-- Pièces partagées avec les cadres de groupe (Groupe.lua) ----------------------------------------

M.shared = {
    known = known, classColor = classColor, healthColor = healthColor, powerColor = powerColor,
    setHealthText = setHealthText, healthPercent = healthPercent, GRIS = GRIS, VERT = VERT,
    -- Barres d'incantation d'autres cadres (boss) : def = { kind, unit, owner, parent, settings, protege }.
    createCastBar = function(def)
        local b = createCastBar(def)
        applyCast(b)
        return b
    end,
    applyCast = applyCast, resumeCast = resumeCast,
}

-- Marche / arrêt ----------------------------------------------------------------------------

function M:OnEnable()
    -- Style « Givre » (0.43.0) : la texture lisse d'avant passe aux stries, une seule fois.
    if not M.db.general.styleGivre then
        if M.db.general.texture == "lisse" then M.db.general.texture = "striee" end
        M.db.general.styleGivre = true
    end
    CUI:AfterCombat(build) -- cadres protégés : jamais créés en combat
    if M.groupe then CUI:SafeCall(CUI:Tr("CU_GROUPE"), M.groupe.Enable) end -- Groupe.lua
    if M.boss then CUI:SafeCall(CUI:Tr("CU_BOSS"), M.boss.Enable) end -- Boss.lua

    self:On("PLAYER_ENTERING_WORLD", function()
        updateAll()
        for _, b in pairs(bars) do resumeCast(b) end
    end)
    for _, event in ipairs(INC_EVENTS) do
        self:On(event, onSpellEvent)
    end
    for _, event in ipairs(INC_EVENTS_OPTIONAL) do
        pcall(self.On, self, event, onSpellEvent) -- évènement inconnu de ce client : ignoré
    end
    self:On("PLAYER_TARGET_CHANGED", function()
        if frames.cible then update(frames.cible) end
        if frames.tot then update(frames.tot) end
        resumeCast(bars.cible) -- la nouvelle cible incante peut-être déjà
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
                             "UNIT_PORTRAIT_UPDATE", "UNIT_CLASSIFICATION_CHANGED", "UNIT_FLAGS",
                             "UNIT_HEAL_PREDICTION" }) do
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
    applyAllCasts() -- cadres simples : tout de suite, même en combat
    if M.groupe then M.groupe.Apply() end
    if M.boss then M.boss.Apply() end
end

-- Police de CœurUI changée (page « Général »).
function M:OnFontChanged()
    relayoutAll()
    applyAllCasts()
    if M.groupe then M.groupe.Apply() end
    if M.boss then M.boss.Apply() end
end
