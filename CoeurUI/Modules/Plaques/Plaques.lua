-- Module « Plaques de nom » (maquette validée le 27/11/2026, « CœurUI · Maquette Plaques de nom »).
-- Étape 1 : plaques ennemies. Barre de vie fine (fond sombre, liseré gris fin, pas d'or), nom
-- au-dessus avec le niveau en petit gris devant, pourcentage de vie dans la barre ; couleur
-- d'attitude (hostile rouge, neutre jaune, gris si le monstre est pris par un autre), couleur de
-- classe pour un joueur adverse. Cible plus grande. Menace sur le liseré (orange : ça bascule ;
-- rouge cœur : danger), selon le rôle (pris de la spécialisation, ou réglé). Monstre de quête :
-- nom en jaune, « ! » au trait jaune à gauche, ce qu'il reste à faire dessous.
-- Étapes suivantes : incantation, mes affaiblissements, plaques amies.
--
-- Les plaques du jeu restent en place (le jeu les crée, les place, les rend cliquables) : CœurUI
-- pose son dessin dessus et rend celui du jeu invisible. Les plaques amies (et les plaques interdites
-- aux addons) restent celles du jeu. Valeurs cachées par le jeu (vie en combat...) : passées telles
-- quelles aux barres et aux textes, jamais calculées. Couper le module demande un /reload.
local _, CUI = ...
local C = CUI.Colors

local issecret = _G.issecretvalue or function() return false end
local function known(v) return v ~= nil and not issecret(v) end

local WHITE = "Interface\\Buttons\\WHITE8x8"
local ROUGE = { 0.769, 0.278, 0.239 }   -- #C4473D
local JAUNE = { 0.851, 0.761, 0.290 }   -- #D9C24A
local GRIS = { 0.45, 0.47, 0.51 }
local VERT = { 0.31, 0.64, 0.29 }
local JAUNE_QUETE = { 0.890, 0.773, 0.290 } -- #E3C54A
local ORANGE = { 0.878, 0.541, 0.235 }  -- #E08A3C

local ROLES = {
    { value = "auto", text = "PN_ROLE_AUTO" }, { value = "tank", text = "PN_ROLE_TANK" },
    { value = "degats", text = "PN_ROLE_DEGATS" },
}
local function questsOn(read) return read("quetes") end

local M = CUI:RegisterModule({
    key = "Plaques",
    name = "PN_NOM",
    description = "PN_DESC",
    defaultEnabled = false,
    needsReload = true, -- les plaques du jeu ne reviennent entières qu'après un /reload
    defaults = {
        ennemis = {
            largeur = 150, hauteur = 10, cible = 125, niveau = true, pourcentage = true, tailleNom = 12,
            quetes = true, nomJaune = true, reste = true, menace = true, role = "auto",
        },
    },
    subs = {
        { key = "ennemis", name = "PN_ENNEMIS", intro = false, settings = {
            { type = "section", text = "PN_DISPOSITION" },
            { type = "slider", key = "largeur", label = "PN_LARGEUR", min = 60, max = 260, step = 2, format = "%d" },
            { type = "slider", key = "hauteur", label = "PN_HAUTEUR", min = 4, max = 24, step = 1, format = "%d" },
            { type = "slider", key = "cible", label = "PN_CIBLE", min = 100, max = 160, step = 5, format = "%d %%" },
            { type = "section", text = "PN_TEXTES" },
            { type = "toggle", key = "niveau", label = "PN_NIVEAU" },
            { type = "toggle", key = "pourcentage", label = "PN_POURCENTAGE" },
            { type = "slider", key = "tailleNom", label = "PN_TAILLE_NOM", min = 8, max = 18, step = 1, format = "%d pt" },
            { type = "column" },
            { type = "section", text = "PN_QUETES" },
            { type = "toggle", key = "quetes", label = "PN_QUETES_SIGNALER" },
            { type = "toggle", key = "nomJaune", label = "PN_QUETES_NOM_JAUNE", enabledIf = questsOn },
            { type = "toggle", key = "reste", label = "PN_QUETES_RESTE", enabledIf = questsOn },
            { type = "section", text = "PN_MENACE" },
            { type = "toggle", key = "menace", label = "PN_MENACE_LISERE" },
            { type = "dropdown", key = "role", label = "PN_ROLE", options = ROLES,
              enabledIf = function(read) return read("menace") end },
        } },
    },
})

local plates = {}   -- jeton de l'unité (nameplate3) -> notre plaque
local hooked = {}   -- cadres du jeu déjà accrochés

-- Couleurs ---------------------------------------------------------------------------------

local function classColor(classFile)
    if not known(classFile) then return nil end
    local c = _G.C_ClassColor and _G.C_ClassColor.GetClassColor and _G.C_ClassColor.GetClassColor(classFile)
    if not c and _G.RAID_CLASS_COLORS then c = _G.RAID_CLASS_COLORS[classFile] end
    if c then return { c.r, c.g, c.b } end
end

local function healthColor(unit)
    local isPlayer = _G.UnitIsPlayer(unit)
    if known(isPlayer) and isPlayer then
        local _, classFile = _G.UnitClass(unit)
        return classColor(classFile) or ROUGE
    end
    local tapped = _G.UnitIsTapDenied and _G.UnitIsTapDenied(unit)
    if known(tapped) and tapped then return GRIS end
    local reaction = _G.UnitReaction(unit, "player")
    if known(reaction) then
        if reaction <= 3 then return ROUGE elseif reaction == 4 then return JAUNE end
        return VERT
    end
    return ROUGE
end

-- Rôle pour la menace : celui réglé, ou celui de la spécialisation.
local function isTank()
    local role = M.db.ennemis.role
    if role ~= "auto" then return role == "tank" end
    local spec = _G.GetSpecialization and _G.GetSpecialization()
    local specRole = spec and _G.GetSpecializationRole and _G.GetSpecializationRole(spec)
    return specRole == "TANK"
end

-- Liseré selon la menace : nil (normal), "warn" (ça bascule) ou "danger".
local function threatState(unit)
    if not M.db.ennemis.menace then return nil end
    local status = _G.UnitThreatSituation("player", unit)
    if not known(status) then return nil end
    if isTank() then
        if status == 3 then return nil end
        if status == 2 then return "warn" end
        local inCombat = _G.UnitAffectingCombat(unit)
        if (status == 0 or status == 1) and known(inCombat) and inCombat then return "danger" end
        return nil
    end
    if status == 1 then return "warn" end
    if status == 2 or status == 3 then return "danger" end
    return nil
end

-- Quêtes : ce que dit l'infobulle du monstre (objectifs pas finis de mes quêtes) ------------

local LINE_OBJECTIVE = _G.Enum and _G.Enum.TooltipDataLineType and _G.Enum.TooltipDataLineType.QuestObjective
local LINE_PLAYER = _G.Enum and _G.Enum.TooltipDataLineType and _G.Enum.TooltipDataLineType.QuestPlayer

-- Renvoie false (pas de quête), ou true et le texte de ce qu'il reste (« 3/8 », « 45 % » ou "").
-- nil : on ne peut pas savoir (infobulle cachée par le jeu) ; garder ce qu'on savait.
local function questInfo(unit)
    local TI = _G.C_TooltipInfo
    if not (TI and TI.GetUnit and LINE_OBJECTIVE) then return false end
    local ok, data = pcall(TI.GetUnit, unit)
    if not ok or type(data) ~= "table" or type(data.lines) ~= "table" then return nil end
    for _, line in ipairs(data.lines) do
        if LINE_PLAYER and line.type == LINE_PLAYER then break end -- objectifs des autres joueurs du groupe
        if line.type == LINE_OBJECTIVE then
            local text = line.leftText
            if issecret(text) or issecret(line.completed) then return nil end
            if not line.completed and type(text) == "string" then
                local done, total = text:match("(%d+)%s*/%s*(%d+)")
                done, total = tonumber(done), tonumber(total)
                if done and total then
                    if done < total then return true, (total - done) .. "/" .. total end
                else
                    local pct = tonumber(text:match("(%d+)%s*%%"))
                    if pct then
                        if pct < 100 then return true, pct .. " %" end
                    else
                        return true, ""
                    end
                end
            end
        end
    end
    return false
end

-- Dessin d'une plaque ----------------------------------------------------------------------

local function texture(parent, layer, sub, color)
    local t = parent:CreateTexture(nil, layer, nil, sub)
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    return t
end

local function newText(parent)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetShadowColor(0, 0, 0, 0.9)
    fs:SetShadowOffset(1, -1)
    fs:SetWordWrap(false)
    return fs
end

local function setBorder(p, color)
    for _, line in ipairs(p.border) do line:SetVertexColor(color[1], color[2], color[3], 1) end
end

local function createPlate(base)
    local p = _G.CreateFrame("Frame", nil, base)
    p:SetPoint("CENTER", base, "CENTER", 0, 0)
    p:EnableMouse(false)
    -- Barre de vie : fond, barre, liseré de 1 point (4 traits).
    p.health = _G.CreateFrame("StatusBar", nil, p)
    p.health:SetStatusBarTexture(WHITE)
    p.health:SetMinMaxValues(0, 1)
    p.health:SetValue(1)
    p.health:SetPoint("TOPLEFT", p, "TOPLEFT", 1, -1)
    p.health:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", -1, 1)
    texture(p, "BACKGROUND", -8, C.fond):SetAllPoints()
    p.border = {}
    for i = 1, 4 do p.border[i] = texture(p, "OVERLAY", 6, C.bordureDiscrete) end
    p.border[1]:SetPoint("TOPLEFT"); p.border[1]:SetPoint("TOPRIGHT"); p.border[1]:SetHeight(1)
    p.border[2]:SetPoint("BOTTOMLEFT"); p.border[2]:SetPoint("BOTTOMRIGHT"); p.border[2]:SetHeight(1)
    p.border[3]:SetPoint("TOPLEFT"); p.border[3]:SetPoint("BOTTOMLEFT"); p.border[3]:SetWidth(1)
    p.border[4]:SetPoint("TOPRIGHT"); p.border[4]:SetPoint("BOTTOMRIGHT"); p.border[4]:SetWidth(1)
    -- Textes : nom au-dessus (niveau en petit gris devant), pourcentage dans la barre.
    p.name = newText(p)
    p.name:SetPoint("BOTTOM", p, "TOP", 0, 3)
    p.level = newText(p)
    p.level:SetPoint("BOTTOMRIGHT", p.name, "BOTTOMLEFT", -3, 0)
    p.level:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
    p.pct = newText(p.health)
    p.pct:SetPoint("RIGHT", p.health, "RIGHT", -2, 0)
    p.pct:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    -- Quête : « ! » au trait jaune à gauche, ce qu'il reste à faire dessous.
    p.quest = p:CreateTexture(nil, "OVERLAY")
    p.quest:SetTexture(CUI.MEDIA .. "Icones\\Quetes")
    p.quest:SetVertexColor(JAUNE_QUETE[1], JAUNE_QUETE[2], JAUNE_QUETE[3], 1)
    p.questText = newText(p)
    p.questText:SetPoint("TOP", p.quest, "BOTTOM", 0, 2)
    p.questText:SetTextColor(JAUNE_QUETE[1], JAUNE_QUETE[2], JAUNE_QUETE[3])
    return p
end

-- Taille, polices, échelle (cible plus grande).
local function layoutPlate(p)
    local s = M.db.ennemis
    p:SetSize(s.largeur, s.hauteur)
    local font = CUI:GetFont()
    p.name:SetFont(font, s.tailleNom, "OUTLINE")
    p.level:SetFont(font, math.max(7, s.tailleNom - 2), "OUTLINE")
    p.pct:SetFont(font, math.max(7, math.min(s.hauteur, s.tailleNom - 3)), "OUTLINE")
    p.questText:SetFont(font, math.max(7, s.tailleNom - 3), "OUTLINE")
    p.name:SetWidth(0)
    local icon = s.hauteur + s.tailleNom + 4
    p.quest:SetSize(icon, icon)
    p.quest:ClearAllPoints()
    p.quest:SetPoint("RIGHT", p, "LEFT", -2, (s.tailleNom + 3) / 2)
end

-- Le dessin du jeu, invisible sous le nôtre (et rendu quand la plaque redevient amie).
local function hideGame(base, hide)
    local uf = base.UnitFrame
    if not uf then return end
    uf.cuiHidden = hide
    if not hooked[uf] then
        hooked[uf] = true
        _G.hooksecurefunc(uf, "SetAlpha", function(self, a)
            if self.cuiHidden and a ~= 0 then self:SetAlpha(0) end
        end)
    end
    uf:SetAlpha(hide and 0 or 1)
end

local function updateHealth(p)
    local unit = p.unit
    local hp, maxHp = _G.UnitHealth(unit), _G.UnitHealthMax(unit)
    p.health:SetMinMaxValues(0, maxHp)
    p.health:SetValue(hp)
    if M.db.ennemis.pourcentage then
        local pct
        if _G.UnitHealthPercent and _G.CurveConstants then
            local ok, value = pcall(_G.UnitHealthPercent, unit, true, _G.CurveConstants.ScaleTo100)
            pct = ok and value or nil
        end
        if pct == nil and known(hp) and known(maxHp) and maxHp > 0 then pct = hp / maxHp * 100 end
        if pct ~= nil then
            if not pcall(p.pct.SetFormattedText, p.pct, "%.0f %%", pct) then p.pct:SetText("") end
        else
            p.pct:SetText("")
        end
        p.pct:Show()
    else
        p.pct:Hide()
    end
end

local function updateThreat(p)
    local state = threatState(p.unit)
    setBorder(p, state == "danger" and C.coeur or state == "warn" and ORANGE or C.bordureDiscrete)
end

local function updateQuest(p)
    local s = M.db.ennemis
    if s.quetes then
        local isQuest, rest = questInfo(p.unit)
        if isQuest ~= nil then p.isQuest, p.questRest = isQuest, rest end
    else
        p.isQuest = false
    end
    p.quest:SetShown(p.isQuest and true or false)
    p.questText:SetShown(p.isQuest and s.reste or false)
    p.questText:SetText(p.questRest or "")
    local nc = (p.isQuest and s.nomJaune) and JAUNE_QUETE or C.texte
    p.name:SetTextColor(nc[1], nc[2], nc[3])
end

local function updateTarget(p)
    local isTarget = _G.UnitIsUnit(p.unit, "target")
    local big = known(isTarget) and isTarget
    p:SetScale(big and M.db.ennemis.cible / 100 or 1)
end

local function updateAll(p)
    local unit = p.unit
    local s = M.db.ennemis
    p.name:SetText(_G.UnitName(unit))
    local level = _G.UnitLevel(unit)
    if s.niveau and known(level) then
        local classif = _G.UnitClassification(unit)
        local plus = known(classif) and (classif == "elite" or classif == "rareelite" or classif == "worldboss")
        p.level:SetText(level <= 0 and "??" or (level .. (plus and "+" or "")))
        p.level:Show()
    else
        p.level:Hide()
    end
    local color = healthColor(unit)
    p.health:SetStatusBarColor(color[1], color[2], color[3])
    updateHealth(p)
    updateThreat(p)
    updateQuest(p)
    updateTarget(p)
end

-- Plaques qui arrivent et qui partent ------------------------------------------------------

local function isEnemy(unit)
    local can = _G.UnitCanAttack("player", unit)
    return known(can) and can or false
end

local function release(unit)
    local p = plates[unit]
    if not p then return end
    plates[unit] = nil
    p:Hide()
    p.unit = nil
end

local function attach(unit)
    release(unit)
    local NP = _G.C_NamePlate
    local base = NP and NP.GetNamePlateForUnit and NP.GetNamePlateForUnit(unit)
    if not base or (base.IsForbidden and base:IsForbidden()) then return end
    if not isEnemy(unit) then
        hideGame(base, false)
        if base.cuiPlate then base.cuiPlate:Hide() end
        return
    end
    base.cuiPlate = base.cuiPlate or createPlate(base)
    local p = base.cuiPlate
    p.unit = unit
    p.isQuest, p.questRest = false, nil
    plates[unit] = p
    hideGame(base, true)
    layoutPlate(p)
    updateAll(p)
    p:Show()
end

local function forEach(fn)
    for _, p in pairs(plates) do CUI:SafeCall(CUI:Tr("PN_NOM"), fn, p) end
end

-- Journal de quêtes changé : relire les plaques un peu plus tard (une seule fois).
local questPending = false
local function refreshQuests()
    if questPending then return end
    questPending = true
    M:After(0.3, function()
        questPending = false
        forEach(updateQuest)
    end)
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    self:On("NAME_PLATE_UNIT_ADDED", function(_, unit) attach(unit) end)
    self:On("NAME_PLATE_UNIT_REMOVED", function(_, unit) release(unit) end)
    self:On("PLAYER_TARGET_CHANGED", function() forEach(updateTarget) end)
    local function onUnit(fn)
        return function(_, unit)
            local p = unit and plates[unit]
            if p then CUI:SafeCall(CUI:Tr("PN_NOM"), fn, p) end
        end
    end
    self:On("UNIT_HEALTH", onUnit(updateHealth))
    self:On("UNIT_MAXHEALTH", onUnit(updateHealth))
    self:On("UNIT_NAME_UPDATE", onUnit(updateAll))
    self:On("UNIT_FACTION", function(_, unit) if unit and plates[unit] then attach(unit) end end)
    self:On("UNIT_THREAT_LIST_UPDATE", onUnit(updateThreat))
    self:On("UNIT_THREAT_SITUATION_UPDATE", function() forEach(updateThreat) end)
    self:On("QUEST_LOG_UPDATE", refreshQuests)
    self:On("UNIT_QUEST_LOG_CHANGED", refreshQuests)
    self:On("PLAYER_REGEN_ENABLED", refreshQuests) -- infobulles lisibles de nouveau
    self:On("PLAYER_SPECIALIZATION_CHANGED", function() forEach(updateThreat) end)
    -- Plaques déjà là (module activé en jeu, /reload).
    local NP = _G.C_NamePlate
    if NP and NP.GetNamePlates then
        for _, base in ipairs(NP.GetNamePlates() or {}) do
            local unit = base.namePlateUnitToken or (base.UnitFrame and base.UnitFrame.unit)
            if unit then CUI:SafeCall(CUI:Tr("PN_NOM"), attach, unit) end
        end
    end
end

-- Coupé : tout reste en place jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged()
    forEach(function(p)
        layoutPlate(p)
        updateAll(p)
    end)
end

function M:OnFontChanged()
    forEach(layoutPlate)
end
