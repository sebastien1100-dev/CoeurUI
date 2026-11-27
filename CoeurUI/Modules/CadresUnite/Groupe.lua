-- Module « Cadres d'unité », page « Groupe » (maquette validée le 27/11/2026, « CœurUI · Maquette Cadres
-- de groupe »). Étape 1 : les cadres.
--   - un cadre par membre du groupe (toi compris, réglable), au style du cadre du joueur : liseré gris
--     fin, vie à la couleur de classe, ressource en trait fin dessous ;
--   - colonne (vers le bas ou le haut) ou ligne (vers la droite ou la gauche) ; tri par rôle (tank,
--     soigneur, dégâts), ordre du groupe, nom ou classe ;
--   - rôle en icône au trait, chef, marqueur de raid ; cadre pâli hors de portée ; « Mort »,
--     « Fantôme », « Déconnecté » à la place de la vie ; liseré blanc sur la cible, rouge sur la menace ;
--   - cadenas ouvert : un groupe de test animé à la place du vrai, pour placer et régler les cadres.
-- Étape 2 : les effets. Soins à venir (prolongement vert clair de la vie), mes soins sur la durée
-- (liseré vert) et affaiblissements à dissiper (liseré de leur type), seulement ceux que ma classe dissipe
-- (réglable), en petites icônes ; chaque sorte à sa place (un coin du cadre ou le centre, réglable).
-- Étape 3 : les familiers des équipiers, un petit cadre sous chaque maître qui en a un (réglable).
--
-- Les cadres sont créés par un en-tête protégé du jeu (SecureGroupHeaderTemplate) : lui seul peut
-- montrer, cacher et ranger les cadres en combat quand le groupe change. Nous ne faisons que dessiner
-- dedans. Réglages qui touchent aux cadres protégés (taille, sens, tri) : appliqués hors combat.
-- Valeurs « secrètes » : comme dans CadresUnite.lua, jamais comparées ni calculées (known()).
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local M = CUI:GetModule("CadresUnite")
if not M then return end

-- Réglages : M.db.groupe (sous-module « groupe »).
M.defaults.groupe = {
    actif = true, sens = "bas", tri = "role", moi = true,
    largeur = 210, hauteur = 30, espacement = 14,
    texteVie = "p", couleur = "classe",
    role = true, ressource = true, chef = true, marqueur = true, familiers = true,
    palir = true, opacitePortee = 45, etats = true,
    soinsAVenir = true, hots = true, dissipes = true, dissipesClasse = true, effetsMax = 3, tailleDissipes = 18, tailleHots = 14,
    lisereDissipe = true,
    placeDissipes = "centre", placeHots = "basDroite",
}

local SENS = {
    { value = "bas", text = "CU_GR_BAS" }, { value = "haut", text = "CU_GR_HAUT" },
    { value = "droite", text = "CU_GR_DROITE" }, { value = "gauche", text = "CU_GR_GAUCHE" },
}
local TRI = {
    { value = "role", text = "CU_GR_TRI_ROLE" }, { value = "groupe", text = "CU_GR_TRI_GROUPE" },
    { value = "nom", text = "CU_GR_TRI_NOM" }, { value = "classe", text = "CU_GR_TRI_CLASSE" },
}
local TEXTE_VIE = {
    { value = "vp", text = "CU_VIE_VP" }, { value = "p", text = "CU_VIE_P" },
    { value = "v", text = "CU_VIE_V" }, { value = "aucun", text = "CU_VIE_AUCUN" },
}
local function on(read) return read("actif") end
local function palirOn(read) return read("actif") and read("palir") end
local function dissipesOn(read) return read("actif") and read("dissipes") end
local function hotsOn(read) return read("actif") and read("hots") end
local PLACES = {
    { value = "basDroite", text = "CU_GR_PLACE_BAS_DROITE" }, { value = "basGauche", text = "CU_GR_PLACE_BAS_GAUCHE" },
    { value = "hautDroite", text = "CU_GR_PLACE_HAUT_DROITE" }, { value = "hautGauche", text = "CU_GR_PLACE_HAUT_GAUCHE" },
    { value = "centre", text = "CU_GR_PLACE_CENTRE" },
}

M.subs[#M.subs + 1] = {
    key = "groupe", name = "CU_GROUPE", intro = false,
    settings = {
        { type = "section", text = "CU_GR_DISPOSITION" },
        { type = "toggle", key = "actif", label = "CU_GR_AFFICHER", description = "CU_GR_AFFICHER_NOTE" },
        { type = "dropdown", key = "sens", label = "CU_GR_SENS", options = SENS, enabledIf = on },
        { type = "dropdown", key = "tri", label = "CU_GR_TRI", options = TRI, enabledIf = on },
        { type = "toggle", key = "moi", label = "CU_GR_MOI", enabledIf = on },
        { type = "section", text = "CU_TAILLE" },
        { type = "slider", key = "largeur", label = "CU_LARGEUR", min = 80, max = 300, step = 10, format = "%d",
          enabledIf = on },
        { type = "slider", key = "hauteur", label = "CU_HAUTEUR", min = 16, max = 60, step = 2, format = "%d",
          enabledIf = on },
        { type = "slider", key = "espacement", label = "CU_GR_ESPACEMENT", min = 0, max = 30, step = 1, format = "%d",
          enabledIf = on },
        { type = "section", text = "CU_TEXTES" },
        { type = "dropdown", key = "texteVie", label = "CU_TEXTE_VIE", options = TEXTE_VIE, enabledIf = on },
        { type = "dropdown", key = "couleur", label = "CU_COULEUR", enabledIf = on, options = {
            { value = "classe", text = "CU_COULEUR_CLASSE" }, { value = "vert", text = "CU_VERT" },
        } },
        { type = "column" },
        { type = "section", text = "CU_ELEMENTS" },
        { type = "toggle", key = "role", label = "CU_GR_ROLE", enabledIf = on },
        { type = "toggle", key = "ressource", label = "CU_RESSOURCE", enabledIf = on },
        { type = "toggle", key = "chef", label = "CU_GR_CHEF", enabledIf = on },
        { type = "toggle", key = "marqueur", label = "CU_GR_MARQUEUR", enabledIf = on },
        { type = "toggle", key = "familiers", label = "CU_GR_FAMILIERS", enabledIf = on },
        { type = "section", text = "CU_GR_PORTEE_ETAT" },
        { type = "toggle", key = "palir", label = "CU_GR_PALIR", enabledIf = on },
        { type = "slider", key = "opacitePortee", label = "CU_GR_OPACITE", min = 10, max = 90, step = 5,
          format = "%d %%", enabledIf = palirOn },
        { type = "toggle", key = "etats", label = "CU_GR_ETATS", description = "CU_GR_ETATS_NOTE", enabledIf = on },
        { type = "section", text = "CU_GR_EFFETS" },
        { type = "toggle", key = "soinsAVenir", label = "CU_GR_SOINS_A_VENIR", enabledIf = on },
        { type = "toggle", key = "hots", label = "CU_GR_HOTS", enabledIf = on },
        { type = "dropdown", key = "placeHots", label = "CU_GR_PLACE", options = PLACES, enabledIf = hotsOn },
        { type = "slider", key = "tailleHots", label = "CU_GR_TAILLE_ICONES", min = 10, max = 32, step = 1, format = "%d",
          enabledIf = hotsOn },
        { type = "toggle", key = "dissipes", label = "CU_GR_DISSIPES", enabledIf = on },
        { type = "toggle", key = "dissipesClasse", label = "CU_GR_DISSIPES_CLASSE", description = "CU_GR_DISSIPES_CLASSE_NOTE",
          enabledIf = dissipesOn },
        { type = "dropdown", key = "placeDissipes", label = "CU_GR_PLACE", options = PLACES, enabledIf = dissipesOn },
        { type = "slider", key = "tailleDissipes", label = "CU_GR_TAILLE_ICONES", min = 10, max = 32, step = 1,
          format = "%d", enabledIf = dissipesOn },
        { type = "toggle", key = "lisereDissipe", label = "CU_GR_LISERE_DISSIPE", description = "CU_GR_LISERE_DISSIPE_NOTE",
          enabledIf = dissipesOn },
        { type = "slider", key = "effetsMax", label = "CU_GR_EFFETS_MAX_CHACUN", min = 1, max = 6, step = 1, format = "%d",
          enabledIf = function(read) return read("actif") and (read("hots") or read("dissipes")) end },
    },
}

local G = {}      -- propriétaire de nos inscriptions aux évènements (le module garde les siennes)
M.groupe = G

local ROLE_ICONS = { TANK = "RoleTank", HEALER = "RoleSoin", DAMAGER = "RoleDegats" }
local ORDRE_CLASSES = "WARRIOR,DEATHKNIGHT,PALADIN,MONK,PRIEST,SHAMAN,DRUID,ROGUE,MAGE,WARLOCK,HUNTER,"
    .. "DEMONHUNTER,EVOKER"
local MAX = 5

local header, anchor, test
local buttons = {}   -- cadres créés par l'en-tête
local hiddenParent

local function sh() return M.shared end
local function db() return M.db.groupe end

-- Dessin d'un cadre ----------------------------------------------------------------------------

local function newText(parent)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetShadowColor(0, 0, 0, 0.9)
    fs:SetShadowOffset(1, -1)
    fs:SetWordWrap(false)
    fs:SetJustifyV("MIDDLE")
    return fs
end

local function createVisual(f)
    local v = {}
    v.border, v.fill = CUI:CreateBorderedRect(f, 3, C.graphite, C.fond)
    v.health = _G.CreateFrame("StatusBar", nil, f)
    v.health:SetMinMaxValues(0, 1)
    v.power = _G.CreateFrame("StatusBar", nil, f)
    v.power:SetMinMaxValues(0, 1)
    -- Trait de 1 point juste sous le contour et léger voile sur tout le cadre, par-dessus les barres : la
    -- couleur d'un affaiblissement à dissiper (cachés sinon).
    local glow = _G.CreateFrame("Frame", nil, f)
    glow:SetPoint("TOPLEFT", 1, -1)
    glow:SetPoint("BOTTOMRIGHT", -1, 1)
    glow:SetFrameLevel(v.health:GetFrameLevel() + 3)
    glow.lines = {}
    for i = 1, 4 do
        local t = glow:CreateTexture(nil, "OVERLAY")
        t:SetTexture("Interface\\Buttons\\WHITE8x8")
        glow.lines[i] = t
    end
    local l = glow.lines
    l[1]:SetPoint("TOPLEFT"); l[1]:SetPoint("TOPRIGHT"); l[1]:SetHeight(1)
    l[2]:SetPoint("BOTTOMLEFT"); l[2]:SetPoint("BOTTOMRIGHT"); l[2]:SetHeight(1)
    l[3]:SetPoint("TOPLEFT"); l[3]:SetPoint("BOTTOMLEFT"); l[3]:SetWidth(1)
    l[4]:SetPoint("TOPRIGHT"); l[4]:SetPoint("BOTTOMRIGHT"); l[4]:SetWidth(1)
    glow.veil = glow:CreateTexture(nil, "ARTWORK")
    glow.veil:SetTexture("Interface\\Buttons\\WHITE8x8")
    glow.veil:SetAllPoints()
    glow:Hide()
    v.glow = glow
    local texts = _G.CreateFrame("Frame", nil, v.health)
    texts:SetAllPoints()
    texts:SetFrameLevel(v.health:GetFrameLevel() + 2)
    v.role = texts:CreateTexture(nil, "OVERLAY")
    v.name, v.hp = newText(texts), newText(texts)
    v.name:SetJustifyH("LEFT")
    v.hp:SetJustifyH("RIGHT")
    v.leader = texts:CreateTexture(nil, "OVERLAY")
    v.leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
    v.mark = texts:CreateTexture(nil, "OVERLAY")
    v.mark:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    -- Soins à venir : une barre qui part du bout de la vie, rognée au bord de la barre de vie.
    v.health:SetClipsChildren(true)
    v.incoming = _G.CreateFrame("StatusBar", nil, v.health)
    v.incoming:SetFrameLevel(v.health:GetFrameLevel() + 1)
    v.incoming:SetMinMaxValues(0, 1)
    v.incoming:SetValue(0)
    v.incoming:Hide()
    v.auras = { dispel = {}, hot = {} } -- icônes de chaque sorte (affaiblissements, soins sur la durée)
    v.owner = f
    return v
end

-- Place des pièces dans un cadre de largeur w et hauteur h.
local function layoutVisual(f, v)
    local s, g = db(), M.db.general
    local power = s.ressource
    v.health:ClearAllPoints()
    v.health:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
    v.health:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -1)
    v.health:SetHeight(math.max(4, s.hauteur - 2 - (power and 5 or 0)))
    v.power:SetShown(power)
    v.power:ClearAllPoints()
    v.power:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, 1)
    v.power:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
    v.power:SetHeight(4)
    local texture = CUI:GetBarTexture(g.texture)
    v.health:SetStatusBarTexture(texture)
    v.power:SetStatusBarTexture(texture)

    local font = CUI:GetFont()
    v.name:SetFont(font, g.tailleNom, "")
    v.hp:SetFont(font, g.tailleVie, "")
    local icon = g.tailleNom + 1
    v.role:SetSize(icon, icon)
    v.role:ClearAllPoints()
    v.role:SetPoint("LEFT", v.health, "LEFT", 5, 0)
    v.hp:ClearAllPoints()
    v.hp:SetPoint("RIGHT", v.health, "RIGHT", -6, 0)
    v.name:ClearAllPoints()
    if s.role then
        v.name:SetPoint("LEFT", v.role, "RIGHT", 4, 0)
    else
        v.name:SetPoint("LEFT", v.health, "LEFT", 6, 0)
    end
    v.name:SetPoint("RIGHT", v.hp, "LEFT", -4, 0)
    v.leader:SetSize(12, 12)
    v.leader:ClearAllPoints()
    v.leader:SetPoint("CENTER", f, "TOPLEFT", 3, 0)
    v.mark:SetSize(14, 14)
    v.mark:ClearAllPoints()
    v.mark:SetPoint("CENTER", f, "TOPRIGHT", -2, 0)
    v.incoming:SetStatusBarTexture(texture)
    -- Accrochée au bout de la vie : à refaire après chaque changement de texture de la barre de vie
    -- (sans texture, il n'y a pas de bout où s'accrocher).
    local fillTex = v.health:GetStatusBarTexture()
    v.incoming:ClearAllPoints()
    if fillTex then
        v.incoming:SetPoint("TOPLEFT", fillTex, "TOPRIGHT")
        v.incoming:SetPoint("BOTTOMLEFT", fillTex, "BOTTOMRIGHT")
    end
    local inc = C.actif
    v.incoming:SetStatusBarColor(inc[1], inc[2], inc[3], 0.45)
    v.incoming:SetWidth(math.max(1, s.largeur - 2))
end

local function setRole(v, role)
    local icon = db().role and ROLE_ICONS[role]
    if icon then
        v.role:SetTexture(CUI.MEDIA .. "Icones\\" .. icon)
        local c = C.texte
        v.role:SetVertexColor(c[1], c[2], c[3], 1)
    end
    v.role:SetShown(icon ~= nil)
end

local function setMark(v, index)
    if db().marqueur and index and _G.SetRaidTargetIconTexture then
        _G.SetRaidTargetIconTexture(v.mark, index)
        v.mark:Show()
    else
        v.mark:Hide()
    end
end

-- Liseré du cadre : couleur d'un affaiblissement à dissiper (réglage), sinon blanc sur la cible, rouge sur
-- qui a la menace, gris fin.
local function setBorder(v, target, threat, dispel)
    local glow = dispel and db().lisereDissipe
    v.glow:SetShown(glow and true or false)
    if glow then
        for _, t in ipairs(v.glow.lines) do t:SetVertexColor(dispel[1], dispel[2], dispel[3], 1) end
        v.glow.veil:SetVertexColor(dispel[1], dispel[2], dispel[3], 0.18)
        v.border:SetColor(dispel)
    else
        v.border:SetColor(target and C.texte or (threat and C.coeur or C.graphite))
    end
end

-- Effets ------------------------------------------------------------------------------------------
-- Lus avec les filtres du jeu : « HELPFUL|PLAYER » (mes effets bénéfiques), « HARMFUL|RAID » (ceux que
-- je peux dissiper), « HARMFUL » (tous, gardés s'ils ont un type de dissipation). En combat, le jeu peut
-- cacher les détails (valeurs secrètes) : l'icône et la durée passent telles quelles au jeu, les tris
-- qui demandent de les lire ne se font que si elles sont connues.

local HOT = { 0.31, 0.62, 0.29 }
local DISPEL_COLORS = {
    Magic = { 0.18, 0.48, 0.88 }, Curse = { 0.61, 0.31, 0.82 },
    Poison = { 0.31, 0.62, 0.29 }, Disease = { 0.65, 0.49, 0.23 },
}
local HOT_MAX_DURATION = 60 -- au-delà : une amélioration longue (endurance...), pas un soin sur la durée

local function auraButton(v, kind, i)
    local list = v.auras[kind]
    local a = list[i]
    if a then return a end
    local f = v.owner
    a = _G.CreateFrame("Frame", nil, f)
    a:SetFrameLevel(f:GetFrameLevel() + 8)
    a.border, a.fill = CUI:CreateBorderedRect(a, 2, C.graphite, C.fond)
    a.icon = a:CreateTexture(nil, "ARTWORK")
    a.icon:SetPoint("TOPLEFT", 1, -1)
    a.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    a.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    a.cd = _G.CreateFrame("Cooldown", nil, a, "CooldownFrameTemplate")
    a.cd:SetAllPoints(a.icon)
    a.cd:SetReverse(true)
    if a.cd.SetHideCountdownNumbers then a.cd:SetHideCountdownNumbers(true) end
    local top = _G.CreateFrame("Frame", nil, a)
    top:SetAllPoints()
    top:SetFrameLevel(a.cd:GetFrameLevel() + 1)
    a.count = top:CreateFontString(nil, "OVERLAY")
    a.count:SetPoint("BOTTOMRIGHT", 1, 0)
    -- Police posée tout de suite : un texte sans police ne s'affiche pas (et fait une erreur).
    a.count:SetFont(CUI:GetFont(), math.max(7, math.floor(db().tailleHots / 2)), "OUTLINE")
    a:Hide()
    list[i] = a
    return a
end

-- Place de chaque sorte d'icônes (réglage) : un coin du cadre, à cheval sur son bord, les icônes en
-- rang vers l'intérieur ; ou au centre, le rang centré.
local CORNERS = {
    basDroite = { point = "BOTTOMRIGHT", x = -4, y = -0.5, step = -1 },
    basGauche = { point = "BOTTOMLEFT", x = 4, y = -0.5, step = 1 },
    hautDroite = { point = "TOPRIGHT", x = -4, y = 0.5, step = -1 },
    hautGauche = { point = "TOPLEFT", x = 4, y = 0.5, step = 1 },
}

-- Les n premières icônes d'une sorte, placées selon le réglage place ; les autres cachées.
local function placeAuras(v, kind, n, place)
    local size = kind == "dispel" and db().tailleDissipes or db().tailleHots
    local font = CUI:GetFont()
    local corner = CORNERS[place]
    for i, a in ipairs(v.auras[kind]) do
        if i > n then
            a:Hide()
        else
            a:SetSize(size, size)
            a:ClearAllPoints()
            if corner then
                a:SetPoint(corner.point, v.owner, corner.point, corner.x + corner.step * (i - 1) * (size + 2),
                    math.floor(corner.y * size))
            else
                a:SetPoint("CENTER", v.owner, "CENTER", (i - 1 - (n - 1) / 2) * (size + 2), 0)
            end
            a.count:SetFont(font, math.max(7, math.floor(size / 2)), "OUTLINE")
        end
    end
end

-- Une icône : image, durée et nombre (valeurs possiblement secrètes : passées au jeu), liseré.
local function showAura(a, unit, data, color)
    local known = sh().known
    a.icon:SetTexture(data.icon)
    a.border:SetColor(color)
    local CU = _G.C_UnitAuras
    local done = false
    if CU and CU.GetAuraDuration and a.cd.SetCooldownFromDurationObject and data.auraInstanceID then
        done = pcall(function() a.cd:SetCooldownFromDurationObject(CU.GetAuraDuration(unit, data.auraInstanceID)) end)
    end
    if not done then
        local dur, exp = data.duration, data.expirationTime
        if known(dur) and known(exp) and dur > 0 then
            _G.CooldownFrame_Set(a.cd, exp - dur, dur, true)
        else
            a.cd:Clear()
        end
    end
    local stacks = data.applications
    if known(stacks) then
        a.count:SetText(stacks > 1 and stacks or "")
    elseif CU and CU.GetAuraApplicationDisplayCount and data.auraInstanceID then
        local ok, text = pcall(CU.GetAuraApplicationDisplayCount, unit, data.auraInstanceID, 2, 99)
        a.count:SetText(ok and text or "")
    else
        a.count:SetText("")
    end
    a:Show()
end

-- Effets lus au jeu avec un filtre ; keep(data) choisit ceux à garder.
local function collect(unit, filter, out, max, keep)
    local get = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataByIndex
    if not get then return end
    for i = 1, 40 do
        if #out >= max then return end
        local ok, data = pcall(get, unit, i, filter)
        if not ok or not data then return end
        if keep(data) then out[#out + 1] = data end
    end
end

local function isHot(data)
    local known, dur = sh().known, data.duration
    if not known(dur) then return true end -- durée cachée (combat) : on ne peut pas trier
    return dur > 0 and dur <= HOT_MAX_DURATION
end

local function hasDispelType(data)
    local known, kind = sh().known, data.dispelName
    return known(kind) and DISPEL_COLORS[kind] ~= nil
end

local function always() return true end

local function updateAuras(f)
    local v, unit, s = f.visual, f.unit, db()
    local dispels, hots = {}, {}
    if unit and s.dissipes then
        if s.dissipesClasse then
            collect(unit, "HARMFUL|RAID", dispels, s.effetsMax, always)
        else
            collect(unit, "HARMFUL", dispels, s.effetsMax, hasDispelType)
        end
    end
    if unit and s.hots then collect(unit, "HELPFUL|PLAYER", hots, s.effetsMax, isHot) end
    local known = sh().known
    local first -- couleur du premier affaiblissement à dissiper (liseré du cadre)
    for i, data in ipairs(dispels) do
        local kind = data.dispelName
        local color = known(kind) and DISPEL_COLORS[kind] or C.coeur
        first = first or color
        showAura(auraButton(v, "dispel", i), unit, data, color)
    end
    for i, data in ipairs(hots) do
        showAura(auraButton(v, "hot", i), unit, data, HOT)
    end
    placeAuras(v, "dispel", #dispels, s.placeDissipes)
    placeAuras(v, "hot", #hots, s.placeHots)
    return first
end

-- Soins à venir (valeurs possiblement secrètes : passées telles quelles à la barre).
local function updateIncoming(v, unit, maxHp, dead)
    local amount = (db().soinsAVenir and not dead and _G.UnitGetIncomingHeals) and _G.UnitGetIncomingHeals(unit) or nil
    if amount == nil then
        v.incoming:Hide()
        return
    end
    v.incoming:SetMinMaxValues(0, maxHp)
    v.incoming:SetValue(amount)
    v.incoming:Show()
end

-- Vrais cadres ----------------------------------------------------------------------------------

local function update(f)
    local unit, v = f.unit, f.visual
    if not v or not unit or not _G.UnitExists(unit) then return end
    local S, s = sh(), db()
    local known = S.known

    v.name:SetText(_G.UnitName(unit))
    local hp, maxHp = _G.UnitHealth(unit), _G.UnitHealthMax(unit)
    v.health:SetMinMaxValues(0, maxHp)
    v.health:SetValue(hp)
    local color = S.healthColor(unit, s.couleur)

    local state
    if s.etats then
        local connected = _G.UnitIsConnected(unit)
        local ghost = _G.UnitIsGhost(unit)
        local dead = _G.UnitIsDead(unit)
        if known(connected) and not connected then
            state = L.CU_GR_DECONNECTE
        elseif known(ghost) and ghost then
            state = L.CU_GR_FANTOME
        elseif known(dead) and dead then
            state = L.CU_MORT
        end
    end
    if state then
        color = S.GRIS
        v.health:SetMinMaxValues(0, 1)
        v.health:SetValue(1)
        v.hp:SetText(state)
    else
        S.setHealthText(v.hp, s.texteVie, hp, S.healthPercent(unit, hp, maxHp))
    end
    v.health:SetStatusBarColor(color[1], color[2], color[3])

    if s.ressource then
        v.power:SetMinMaxValues(0, _G.UnitPowerMax(unit))
        v.power:SetValue(_G.UnitPower(unit))
        local pc = S.powerColor(unit)
        v.power:SetStatusBarColor(pc[1], pc[2], pc[3])
    end

    local role = _G.UnitGroupRolesAssigned and _G.UnitGroupRolesAssigned(unit)
    setRole(v, known(role) and role or nil)
    local leader = _G.UnitIsGroupLeader(unit)
    v.leader:SetShown(s.chef and known(leader) and leader or false)
    local mark = _G.GetRaidTargetIndex(unit)
    setMark(v, known(mark) and mark or nil)

    local isTarget = _G.UnitIsUnit(unit, "target")
    local threat = _G.UnitThreatSituation(unit)
    updateIncoming(v, unit, maxHp, state ~= nil)
    local dispel = updateAuras(f)
    setBorder(v, known(isTarget) and isTarget, known(threat) and threat and threat >= 2, dispel)
end

-- Portée : relue souvent (le jeu ne prévient pas toujours). Valeur cachée : le jeu pose l'opacité.
local function updateRange(f)
    local s = db()
    if not (s.palir and f.unit) then
        f:SetAlpha(1)
        return
    end
    local low = s.opacitePortee / 100
    local inRange, checked = _G.UnitInRange(f.unit)
    local known = sh().known
    if known(inRange) and known(checked) then
        f:SetAlpha((checked and not inRange) and low or 1)
    elseif not known(inRange) and f.SetAlphaFromBoolean then
        pcall(f.SetAlphaFromBoolean, f, inRange, 1, low)
    else
        f:SetAlpha(1)
    end
end

local updatePetFor -- plus bas (familiers)

local function updateAll()
    for _, f in ipairs(buttons) do
        if f:IsShown() then
            update(f)
            updateRange(f)
            updatePetFor(f)
        end
    end
end

local function updateUnit(unit)
    for _, f in ipairs(buttons) do
        if f:IsShown() then
            if f.unit == unit then update(f) end
            if f.petUnit == unit then updatePetFor(f) end
        end
    end
end

-- Familiers des équipiers --------------------------------------------------------------------------
-- Un petit cadre protégé sous chaque cadre de l'en-tête : son unité est celle de son parent + « pet »
-- (le jeu la suit tout seul, même en combat) ; montré seulement quand le familier existe.

local PET_INDENT = 18

local function petHeight()
    return math.max(12, math.floor(db().hauteur * 0.5))
end

-- Place réservée sous chaque cadre pour son familier (réglage actif).
local function petExtra()
    return db().familiers and (petHeight() + 3) or 0
end

-- Unité du familier, telle que les évènements du jeu la donnent.
local function petUnitOf(unit)
    if unit == "player" then return "pet" end
    local n = unit and unit:match("^party(%d)$")
    return n and ("partypet" .. n) or nil
end

local function createPetVisual(p)
    local v = {}
    v.border, v.fill = CUI:CreateBorderedRect(p, 2, C.graphite, C.fond)
    v.health = _G.CreateFrame("StatusBar", nil, p)
    v.health:SetPoint("TOPLEFT", 1, -1)
    v.health:SetPoint("BOTTOMRIGHT", -1, 1)
    v.health:SetMinMaxValues(0, 1)
    local texts = _G.CreateFrame("Frame", nil, v.health)
    texts:SetAllPoints()
    texts:SetFrameLevel(v.health:GetFrameLevel() + 2)
    v.name = newText(texts)
    v.name:SetJustifyH("LEFT")
    v.name:SetPoint("LEFT", 5, 0)
    v.name:SetPoint("RIGHT", -5, 0)
    return v
end

local function layoutPet(owner, p)
    local s, g = db(), M.db.general
    p:SetSize(math.max(20, s.largeur - PET_INDENT), petHeight())
    p:ClearAllPoints()
    p:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", PET_INDENT, -3)
    p.visual.health:SetStatusBarTexture(CUI:GetBarTexture(g.texture))
    p.visual.name:SetFont(CUI:GetFont(), math.max(8, g.tailleNom - 2), "")
end

local function updatePet(f)
    f.petUnit = petUnitOf(f.unit)
    local p = f.pet
    if not (p and p:IsShown()) then return end
    local unit = petUnitOf(f.unit)
    if not unit or not _G.UnitExists(unit) then return end
    local v = p.visual
    v.name:SetText(_G.UnitName(unit))
    v.health:SetMinMaxValues(0, _G.UnitHealthMax(unit))
    v.health:SetValue(_G.UnitHealth(unit))
    local color = sh().healthColor(unit, db().couleur)
    v.health:SetStatusBarColor(color[1], color[2], color[3])
end

updatePetFor = updatePet

-- Montré par le jeu quand le familier existe (réglage actif), sinon caché. Hors combat seulement.
local function watchPet(f)
    local p = f.pet
    if not p then return end
    if db().familiers then
        _G.RegisterUnitWatch(p)
    else
        _G.UnregisterUnitWatch(p)
        p:Hide()
    end
end

local function createPet(f)
    local p = _G.CreateFrame("Button", nil, f, "SecureUnitButtonTemplate")
    p:SetAttribute("useparent-unit", true)
    p:SetAttribute("unitsuffix", "pet")
    p:SetAttribute("type1", "target")
    p:SetAttribute("type2", "togglemenu")
    p:RegisterForClicks("AnyUp")
    p.visual = createPetVisual(p)
    layoutPet(f, p)
    p:HookScript("OnShow", function() updatePet(f) end)
    p:HookScript("OnEnter", function(self)
        local tip, unit = _G.GameTooltip, petUnitOf(f.unit)
        if not tip or not unit then return end
        _G.GameTooltip_SetDefaultAnchor(tip, self)
        tip:SetUnit(unit)
        tip:Show()
    end)
    p:HookScript("OnLeave", function()
        if _G.GameTooltip then _G.GameTooltip:Hide() end
    end)
    f.pet = p
    watchPet(f)
end

-- Un cadre créé par l'en-tête : notre dessin, l'infobulle, le suivi de son unité.
local function setupButton(f)
    if f.visual then return end
    f:RegisterForClicks("AnyUp")
    f:SetFrameStrata("LOW")
    f.visual = createVisual(f)
    layoutVisual(f, f.visual)
    f:HookScript("OnAttributeChanged", function(self, name, value)
        if name == "unit" then
            self.unit = value
            update(self)
            updateRange(self)
            updatePet(self)
        end
    end)
    f:HookScript("OnShow", function(self)
        self.unit = self:GetAttribute("unit")
        update(self)
        updateRange(self)
    end)
    f:HookScript("OnEnter", function(self)
        local tip = _G.GameTooltip
        if not tip or not self.unit then return end
        _G.GameTooltip_SetDefaultAnchor(tip, self)
        tip:SetUnit(self.unit)
        tip:Show()
    end)
    f:HookScript("OnLeave", function()
        if _G.GameTooltip then _G.GameTooltip:Hide() end
    end)
    f.unit = f:GetAttribute("unit")
    createPet(f)
    buttons[#buttons + 1] = f
end

-- Disposition ---------------------------------------------------------------------------------

-- Point de départ (dans l'ancre) et attributs de l'en-tête selon le sens.
local DIRECTIONS = {
    bas = { corner = "TOPLEFT", point = "TOP", x = 0, y = -1 },
    haut = { corner = "BOTTOMLEFT", point = "BOTTOM", x = 0, y = 1 },
    droite = { corner = "TOPLEFT", point = "LEFT", x = 1, y = 0 },
    gauche = { corner = "TOPRIGHT", point = "RIGHT", x = -1, y = 0 },
}

-- Place d'un cadre n (1 à 5) dans l'ancre, pour le groupe de test.
local function slotOffset(n)
    local s = db()
    local d = DIRECTIONS[s.sens] or DIRECTIONS.bas
    local step = (n - 1)
    local dx = d.x * step * (s.largeur + s.espacement)
    local dy = d.y * step * (s.hauteur + s.espacement + petExtra())
    return d.corner, dx, dy
end

-- Taille de l'ancre : la place de cinq cadres.
local function anchorSize()
    local s = db()
    local vertical = s.sens == "bas" or s.sens == "haut"
    local pet = petExtra()
    if vertical then
        return s.largeur, MAX * (s.hauteur + pet) + (MAX - 1) * s.espacement
    end
    return MAX * s.largeur + (MAX - 1) * s.espacement, s.hauteur + pet
end

-- Attributs de l'en-tête (hors combat) : qui montrer, dans quel ordre, dans quel sens.
local function configureHeader()
    local s = db()
    local d = DIRECTIONS[s.sens] or DIRECTIONS.bas
    header:SetAttribute("cuiLargeur", s.largeur)
    header:SetAttribute("cuiHauteur", s.hauteur)
    for _, f in ipairs(buttons) do
        f:SetSize(s.largeur, s.hauteur)
        if f.pet then
            layoutPet(f, f.pet)
            watchPet(f)
        end
    end
    header:SetAttribute("showPlayer", s.moi)
    if s.tri == "role" then
        header:SetAttribute("groupBy", "ASSIGNEDROLE")
        header:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
        header:SetAttribute("sortMethod", "INDEX")
    elseif s.tri == "classe" then
        header:SetAttribute("groupBy", "CLASS")
        header:SetAttribute("groupingOrder", ORDRE_CLASSES)
        header:SetAttribute("sortMethod", "NAME")
    else
        header:SetAttribute("groupBy", nil)
        header:SetAttribute("groupingOrder", nil)
        header:SetAttribute("sortMethod", s.tri == "nom" and "NAME" or "INDEX")
    end
    header:SetAttribute("xOffset", d.x * s.espacement)
    -- En colonne, la place du familier s'ajoute entre deux cadres.
    header:SetAttribute("yOffset", d.y * (s.espacement + petExtra()))
    header:ClearAllPoints()
    header:SetPoint(d.corner, anchor, d.corner, 0, 0)
    header:SetAttribute("point", d.point) -- en dernier : l'en-tête se range de nouveau
end

local function applyLayout()
    if not anchor then return end
    local w, h = anchorSize()
    anchor:SetSize(w, h)
    for _, f in ipairs(buttons) do layoutVisual(f, f.visual) end
    if test then
        for i, t in ipairs(test.frames) do
            t:SetSize(db().largeur, db().hauteur)
            local corner, dx, dy = slotOffset(i)
            t:ClearAllPoints()
            t:SetPoint(corner, anchor, corner, dx, dy)
            layoutVisual(t, t.visual)
            layoutPet(t, t.pet)
        end
    end
    CUI:AfterCombat(function()
        configureHeader()
        -- Groupe de test affiché (cadenas ouvert) : le vrai reste caché.
        header:SetShown(not (test and test:IsShown()))
        updateAll()
    end)
end

-- Groupe de test (cadenas ouvert) ---------------------------------------------------------------

local TEST_HOT = "Interface\\Icons\\Spell_Holy_Renew"
local TEST_MAGIE = "Interface\\Icons\\Spell_Frost_FrostNova"
local TEST_POISON = "Interface\\Icons\\Spell_Nature_CorrosiveBreath"
local TEST = {
    { class = "WARRIOR", role = "TANK", phase = 0.0, leader = true, threat = true,
      auras = { { icon = TEST_HOT, kind = "hot" } } },
    { class = "PRIEST", role = "HEALER", phase = 1.3, target = true,
      auras = { { icon = TEST_POISON, kind = "dispel", dispelName = "Poison" } } },
    { class = "MAGE", role = "DAMAGER", phase = 2.1, mark = 1, incoming = 20,
      auras = { { icon = TEST_MAGIE, kind = "dispel", dispelName = "Magic" }, { icon = TEST_HOT, kind = "hot" } } },
    { class = "HUNTER", role = "DAMAGER", phase = 3.4, far = true, pet = true },
    { class = "WARLOCK", role = "DAMAGER", phase = 4.6, dies = true, pet = true },
}

local function testName(class)
    local names = _G.LOCALIZED_CLASS_NAMES_MALE
    return names and names[class] or class
end

-- Une image de l'animation : la vie monte et descend, l'un passe hors de portée, un autre meurt
-- puis revient.
local function animateTest(t)
    local s, S = db(), sh()
    for i, f in ipairs(test.frames) do
        local d, v = TEST[i], f.visual
        local pct = 55 + 40 * math.sin(t * 0.7 + d.phase)
        local dead = s.etats and d.dies and (t % 10) > 7
        local color = s.couleur == "vert" and S.VERT or (S.classColor(d.class) or S.VERT)
        if dead then
            color = S.GRIS
            v.health:SetMinMaxValues(0, 1)
            v.health:SetValue(1)
            v.hp:SetText(L.CU_MORT)
        else
            v.health:SetMinMaxValues(0, 100)
            v.health:SetValue(pct)
            S.setHealthText(v.hp, s.texteVie, math.floor(pct * 120), pct)
        end
        v.health:SetStatusBarColor(color[1], color[2], color[3])
        if s.ressource then
            v.power:SetMinMaxValues(0, 100)
            v.power:SetValue(50 + 30 * math.sin(t * 0.4 + d.phase))
            local pc = d.class == "WARRIOR" and { 0.79, 0.28, 0.23 } or { 0.24, 0.48, 0.85 }
            v.power:SetStatusBarColor(pc[1], pc[2], pc[3])
        end
        local far = s.palir and d.far and math.floor(t / 3) % 2 == 1
        f:SetAlpha(far and s.opacitePortee / 100 or 1)
        -- Soins à venir : un peu de vie en plus, en vert clair.
        local inc = s.soinsAVenir and not dead and d.incoming
        v.incoming:SetShown(inc and true or false)
        if inc then
            v.incoming:SetMinMaxValues(0, 100)
            v.incoming:SetValue(inc)
        end
    end
    -- Toutes les 12 secondes, les durées des effets d'exemple repartent.
    local cycle = math.floor(t / 12)
    if cycle ~= test.cycle then
        test.cycle = cycle
        for _, f in ipairs(test.frames) do
            for _, list in pairs(f.visual.auras) do
                for _, a in ipairs(list) do
                    if a:IsShown() then _G.CooldownFrame_Set(a.cd, _G.GetTime(), 12, true) end
                end
            end
        end
    end
end

-- Effets d'exemple selon les réglages (« seulement ma classe » : ils sont tous censés l'être).
local function fillTestAuras(f, d)
    local s, v = db(), f.visual
    local n = { dispel = 0, hot = 0 }
    for _, e in ipairs(d.auras or {}) do
        local wanted = (e.kind == "hot" and s.hots) or (e.kind == "dispel" and s.dissipes)
        if wanted and n[e.kind] < s.effetsMax then
            n[e.kind] = n[e.kind] + 1
            local a = auraButton(v, e.kind, n[e.kind])
            a.icon:SetTexture(e.icon)
            a.border:SetColor(e.kind == "hot" and HOT or DISPEL_COLORS[e.dispelName])
            a.count:SetText("")
            _G.CooldownFrame_Set(a.cd, _G.GetTime(), 12, true)
            a:Show()
        end
    end
    placeAuras(v, "dispel", n.dispel, s.placeDissipes)
    placeAuras(v, "hot", n.hot, s.placeHots)
    local first
    for _, e in ipairs(d.auras or {}) do
        if e.kind == "dispel" and s.dissipes then
            first = DISPEL_COLORS[e.dispelName]
            break
        end
    end
    return first
end

local function fillTest()
    local s = db()
    for i, f in ipairs(test.frames) do
        local d, v = TEST[i], f.visual
        -- « M'afficher dans le groupe » coupé : un cadre de moins.
        f:SetShown(s.moi or i < MAX)
        v.name:SetText(testName(d.class))
        setRole(v, d.role)
        v.leader:SetShown(s.chef and d.leader or false)
        setMark(v, d.mark)
        setBorder(v, d.target, d.threat, fillTestAuras(f, d))
        -- Familier d'exemple (chasseur, démoniste).
        local pet = f.pet
        pet:SetShown(s.familiers and d.pet or false)
        if pet:IsShown() then
            local pv, green = pet.visual, sh().VERT
            pv.name:SetText(L.CU_FAMILIER)
            pv.health:SetMinMaxValues(0, 100)
            pv.health:SetValue(i == 4 and 85 or 60)
            pv.health:SetStatusBarColor(green[1], green[2], green[3])
        end
    end
    test.cycle = math.floor((test.elapsed or 0) / 12)
    animateTest(test.elapsed or 0)
end

local function buildTest()
    if test then return end
    test = _G.CreateFrame("Frame", nil, anchor)
    test:SetAllPoints()
    test:Hide()
    test.frames = {}
    for i = 1, MAX do
        local f = _G.CreateFrame("Frame", nil, test)
        f.visual = createVisual(f)
        f.pet = _G.CreateFrame("Frame", nil, f)
        f.pet.visual = createPetVisual(f.pet)
        f.pet:Hide()
        test.frames[i] = f
    end
    test.elapsed = 0
    test:SetScript("OnUpdate", function(self, dt)
        self.elapsed = self.elapsed + dt
        animateTest(self.elapsed)
    end)
end

local function showTest(shown)
    if shown then
        buildTest()
        applyLayout()
        fillTest()
        test:Show()
        CUI:AfterCombat(function() if header then header:Hide() end end)
    else
        if test then test:Hide() end
        CUI:AfterCombat(function() if header and db().actif then header:Show() end end)
    end
end

-- Construction (hors combat) --------------------------------------------------------------------

-- Cadres de groupe du jeu : rangés dans un cadre invisible tant que les nôtres sont actifs.
local function hideBlizzardParty()
    hiddenParent = hiddenParent or _G.CreateFrame("Frame")
    hiddenParent:Hide()
    -- Selon la version du jeu : un cadre qui les contient tous, ou un cadre par équipier.
    local names = { "PartyFrame", "CompactPartyFrame", "PartyMemberFrame1", "PartyMemberFrame2",
                    "PartyMemberFrame3", "PartyMemberFrame4" }
    for _, name in ipairs(names) do
        local frame = _G[name]
        if frame then
            frame:SetParent(hiddenParent)
            _G.hooksecurefunc(frame, "SetParent", function(self, parent)
                if parent ~= hiddenParent and M.enabled and db().actif then
                    CUI:AfterCombat(function() self:SetParent(hiddenParent) end)
                end
            end)
        end
    end
end

local function build()
    if header or not db().actif then return end
    hideBlizzardParty()

    anchor = _G.CreateFrame("Frame", "CoeurUIGroupeAncre", _G.UIParent)
    anchor:SetSize(anchorSize())

    header = _G.CreateFrame("Frame", "CoeurUIGroupe", _G.UIParent, "SecureGroupHeaderTemplate")
    header:SetFrameStrata("LOW")
    header:SetAttribute("template", "SecureUnitButtonTemplate")
    header:SetAttribute("showParty", true)
    header:SetAttribute("showRaid", false)
    header:SetAttribute("showSolo", false)
    -- Chaque cadre créé par l'en-tête : clic gauche cibler, clic droit menu, sa taille. (Les clics
    -- qu'il écoute sont posés ensuite, hors de ce code protégé qui ne le permet pas : setupButton.)
    header:SetAttribute("initialConfigFunction", [[
        self:SetAttribute("type1", "target")
        self:SetAttribute("type2", "togglemenu")
        local h = self:GetParent()
        self:SetWidth(h:GetAttribute("cuiLargeur"))
        self:SetHeight(h:GetAttribute("cuiHauteur"))
    ]])
    local s = db()
    header:SetAttribute("cuiLargeur", s.largeur)
    header:SetAttribute("cuiHauteur", s.hauteur)
    -- Les cinq cadres sont créés tout de suite (hors combat) : l'en-tête n'en crée plus en combat.
    -- Seul, il ne montrerait rien : on le laisse montrer le joueur le temps de les créer.
    header:SetAttribute("showPlayer", true)
    header:SetAttribute("showSolo", true)
    header:SetAttribute("startingIndex", 1 - MAX)
    header:Show()
    header:SetAttribute("startingIndex", 1)
    header:SetAttribute("showSolo", false)
    for i = 1, MAX do
        local f = header:GetAttribute("child" .. i) or _G["CoeurUIGroupeUnitButton" .. i]
        if f then setupButton(f) end
    end
    configureHeader()

    CUI:RegisterMover({
        key = "cadre_groupe", frame = anchor, label = "CU_GROUPE", default = { "TOPLEFT", "TOPLEFT", 30, -260 },
        onUnlock = function() showTest(true) end,
        onLock = function() showTest(false) end,
    })
    updateAll()
end

-- Appelés par CadresUnite.lua ------------------------------------------------------------------

local UNIT_EVENTS = { "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER",
                      "UNIT_NAME_UPDATE", "UNIT_CONNECTION", "UNIT_FLAGS", "UNIT_THREAT_SITUATION_UPDATE",
                      "UNIT_AURA", "UNIT_HEAL_PREDICTION" }
local ALL_EVENTS = { "GROUP_ROSTER_UPDATE", "PARTY_LEADER_CHANGED", "PLAYER_ROLES_ASSIGNED", "RAID_TARGET_UPDATE",
                     "PLAYER_TARGET_CHANGED", "PLAYER_ENTERING_WORLD" }

function G.Enable()
    CUI:AfterCombat(build)
    for _, event in ipairs(UNIT_EVENTS) do
        pcall(CUI.On, CUI, event, G, function(_, unit)
            if M.enabled then updateUnit(unit) end
        end)
    end
    pcall(CUI.On, CUI, "UNIT_PET", G, function(_, owner)
        if not M.enabled then return end
        for _, f in ipairs(buttons) do
            if f.unit == owner and f:IsShown() then updatePet(f) end
        end
    end)
    for _, event in ipairs(ALL_EVENTS) do
        pcall(CUI.On, CUI, event, G, function()
            if M.enabled then updateAll() end
        end)
    end
    M:Every(0.2, function()
        for _, f in ipairs(buttons) do
            if f:IsShown() then updateRange(f) end
        end
    end)
end

-- Réglage changé (ou police) : tout est redessiné ; ce qui touche aux cadres protégés, hors combat.
function G.Apply()
    if not db().actif then
        CUI:AfterCombat(function() if header then header:Hide() end end)
        return
    end
    if not header then
        CUI:AfterCombat(build)
        return
    end
    applyLayout()
    if test and test:IsShown() then fillTest() end
end
