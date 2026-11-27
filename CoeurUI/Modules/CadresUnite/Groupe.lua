-- Module « Cadres d'unité », page « Groupe » (maquette validée le 27/11/2026, « CœurUI · Maquette Cadres
-- de groupe »). Étape 1 : les cadres.
--   - un cadre par membre du groupe (toi compris, réglable), au style du cadre du joueur : liseré gris
--     fin, vie à la couleur de classe, ressource en trait fin dessous ;
--   - colonne (vers le bas ou le haut) ou ligne (vers la droite ou la gauche) ; tri par rôle (tank,
--     soigneur, dégâts), ordre du groupe, nom ou classe ;
--   - rôle en icône au trait, chef, marqueur de raid ; cadre pâli hors de portée ; « Mort »,
--     « Fantôme », « Déconnecté » à la place de la vie ; liseré blanc sur la cible, rouge sur la menace ;
--   - cadenas ouvert : un groupe de test animé à la place du vrai, pour placer et régler les cadres.
-- Étapes suivantes : effets (soins à venir, soins sur la durée, affaiblissements à dissiper), familiers.
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
    role = true, ressource = true, chef = true, marqueur = true,
    palir = true, opacitePortee = 45, etats = true,
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
        { type = "section", text = "CU_GR_PORTEE_ETAT" },
        { type = "toggle", key = "palir", label = "CU_GR_PALIR", enabledIf = on },
        { type = "slider", key = "opacitePortee", label = "CU_GR_OPACITE", min = 10, max = 90, step = 5,
          format = "%d %%", enabledIf = palirOn },
        { type = "toggle", key = "etats", label = "CU_GR_ETATS", description = "CU_GR_ETATS_NOTE", enabledIf = on },
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

local function setBorder(v, target, threat)
    v.border:SetColor(target and C.texte or (threat and C.coeur or C.graphite))
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
    setBorder(v, known(isTarget) and isTarget, known(threat) and threat and threat >= 2)
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

local function updateAll()
    for _, f in ipairs(buttons) do
        if f:IsShown() then
            update(f)
            updateRange(f)
        end
    end
end

local function updateUnit(unit)
    for _, f in ipairs(buttons) do
        if f.unit == unit and f:IsShown() then update(f) end
    end
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
    local dy = d.y * step * (s.hauteur + s.espacement)
    return d.corner, dx, dy
end

-- Taille de l'ancre : la place de cinq cadres.
local function anchorSize()
    local s = db()
    local vertical = s.sens == "bas" or s.sens == "haut"
    if vertical then
        return s.largeur, MAX * s.hauteur + (MAX - 1) * s.espacement
    end
    return MAX * s.largeur + (MAX - 1) * s.espacement, s.hauteur
end

-- Attributs de l'en-tête (hors combat) : qui montrer, dans quel ordre, dans quel sens.
local function configureHeader()
    local s = db()
    local d = DIRECTIONS[s.sens] or DIRECTIONS.bas
    header:SetAttribute("cuiLargeur", s.largeur)
    header:SetAttribute("cuiHauteur", s.hauteur)
    for _, f in ipairs(buttons) do f:SetSize(s.largeur, s.hauteur) end
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
    header:SetAttribute("yOffset", d.y * s.espacement)
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

local TEST = {
    { class = "WARRIOR", role = "TANK", phase = 0.0, leader = true, threat = true },
    { class = "PRIEST", role = "HEALER", phase = 1.3, target = true },
    { class = "MAGE", role = "DAMAGER", phase = 2.1, mark = 1 },
    { class = "HUNTER", role = "DAMAGER", phase = 3.4, far = true },
    { class = "WARLOCK", role = "DAMAGER", phase = 4.6, dies = true },
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
    end
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
        setBorder(v, d.target, d.threat)
    end
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
                      "UNIT_NAME_UPDATE", "UNIT_CONNECTION", "UNIT_FLAGS", "UNIT_THREAT_SITUATION_UPDATE" }
local ALL_EVENTS = { "GROUP_ROSTER_UPDATE", "PARTY_LEADER_CHANGED", "PLAYER_ROLES_ASSIGNED", "RAID_TARGET_UPDATE",
                     "PLAYER_TARGET_CHANGED", "PLAYER_ENTERING_WORLD" }

function G.Enable()
    CUI:AfterCombat(build)
    for _, event in ipairs(UNIT_EVENTS) do
        pcall(CUI.On, CUI, event, G, function(_, unit)
            if M.enabled then updateUnit(unit) end
        end)
    end
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
