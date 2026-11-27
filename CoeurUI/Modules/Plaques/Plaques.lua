-- Module « Plaques de nom » (maquette validée le 27/11/2026, « CœurUI · Maquette Plaques de nom »).
-- Étape 1 : plaques ennemies. Barre de vie fine (fond sombre, liseré gris fin, pas d'or), nom
-- au-dessus avec le niveau en petit gris devant, pourcentage de vie dans la barre ; couleur
-- d'attitude (hostile rouge, neutre jaune, gris si le monstre est pris par un autre), couleur de
-- classe pour un joueur adverse. Cible plus grande. Menace sur le liseré (orange : ça bascule ;
-- rouge cœur : danger), selon le rôle (pris de la spécialisation, ou réglé). Monstre de quête :
-- nom en jaune, « ! » au trait jaune à gauche, l'avancement dessous (« 0/8 » comme le journal). Marqueur de raid à droite.
-- Étape 2 : mes affaiblissements au-dessus du nom. Ce sont les icônes d'effets de la plaque du jeu
-- (le jeu les tient à jour, même en combat quand il cache les effets aux addons) : rendues visibles
-- malgré la plaque du jeu invisible, habillées (carrés, liseré gris fin, temps dessous) et rangées
-- par CœurUI. Marqueur de raid à droite de la barre.
-- Étape 3 : incantation sous la vie (bleu acier ; canalisation en vert ; grise avec un cadenas si on
-- ne peut pas l'interrompre ; rouge cœur un instant si elle est interrompue), nom du sort et temps.
-- Étape 4 : plaques amies (PNJ et joueurs alliés) : le nom seul, vert pour un PNJ, couleur de classe
-- pour un joueur ; barre fine seulement quand l'allié est blessé. En donjon et en raid, le jeu garde les
-- plaques amies pour lui (interdites aux addons) : elles restent les siennes. Ma propre plaque (barre de
-- ressources personnelle) reste celle du jeu.
--
-- Les plaques du jeu restent en place (le jeu les crée, les place, les rend cliquables) : CœurUI
-- pose son dessin dessus et rend celui du jeu invisible. Les plaques amies (et les plaques interdites
-- aux addons) restent celles du jeu. Valeurs cachées par le jeu (vie en combat...) : passées telles
-- quelles aux barres et aux textes, jamais calculées. Couper le module demande un /reload.
local _, CUI = ...
local L = CUI.L
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
local INC_CAST = { 0.310, 0.498, 0.722 }   -- #4F7FB8, bleu acier
local INC_CANAL = { 0.310, 0.600, 0.420 }  -- vert
local INC_PROTEGE = { 0.478, 0.494, 0.533 } -- #7A7E88, gris
local INC_TENUE = 0.6 -- secondes en rouge après une interruption

local ROLES = {
    { value = "auto", text = "PN_ROLE_AUTO" }, { value = "tank", text = "PN_ROLE_TANK" },
    { value = "degats", text = "PN_ROLE_DEGATS" },
}
local function questsOn(read) return read("quetes") end
local function effectsOn(read) return read("effets") end
local function friendsOn(read) return read("habiller") end

local M = CUI:RegisterModule({
    key = "Plaques",
    name = "PN_NOM",
    description = "PN_DESC",
    defaultEnabled = false,
    needsReload = true, -- les plaques du jeu ne reviennent entières qu'après un /reload
    defaults = {
        amis = { habiller = true, blesse = true, niveau = false, tailleNom = 11, largeur = 110, hauteur = 4 },
        ennemis = {
            largeur = 150, hauteur = 10, cible = 125, niveau = true, pourcentage = true, tailleNom = 12,
            quetes = true, nomJaune = true, reste = true, menace = true, role = "auto",
            effets = true, tailleEffets = 18, nombreEffets = 6,
            incantation = true, hauteurInc = 8,
        },
    },
    subs = {
        { key = "amis", name = "PN_AMIS", intro = false, settings = {
            { type = "section", text = "PN_AFFICHAGE" },
            { type = "toggle", key = "habiller", label = "PN_AMIS_HABILLER", description = "PN_AMIS_NOTE" },
            { type = "toggle", key = "blesse", label = "PN_AMIS_BLESSE", enabledIf = friendsOn },
            { type = "toggle", key = "niveau", label = "PN_AMIS_NIVEAU", enabledIf = friendsOn },
            { type = "column" },
            { type = "section", text = "PN_DISPOSITION" },
            { type = "slider", key = "tailleNom", label = "PN_TAILLE_NOM", min = 8, max = 18, step = 1, format = "%d pt",
              enabledIf = friendsOn },
            { type = "slider", key = "largeur", label = "PN_LARGEUR", min = 60, max = 260, step = 2, format = "%d",
              enabledIf = friendsOn },
            { type = "slider", key = "hauteur", label = "PN_HAUTEUR", min = 2, max = 16, step = 1, format = "%d",
              enabledIf = friendsOn },
        } },
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
            { type = "section", text = "PN_INC" },
            { type = "toggle", key = "incantation", label = "PN_INC_AFFICHER" },
            { type = "slider", key = "hauteurInc", label = "PN_INC_HAUTEUR", min = 4, max = 16, step = 1, format = "%d",
              enabledIf = function(read) return read("incantation") end },
            { type = "section", text = "PN_EFFETS" },
            { type = "toggle", key = "effets", label = "PN_EFFETS_AFFICHER" },
            { type = "slider", key = "tailleEffets", label = "PN_EFFETS_TAILLE", min = 12, max = 32, step = 1, format = "%d",
              enabledIf = effectsOn },
            { type = "slider", key = "nombreEffets", label = "PN_EFFETS_NOMBRE", min = 1, max = 10, step = 1, format = "%d",
              enabledIf = effectsOn },
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

-- Renvoie false (pas de quête), ou true et l'avancement (« 5/8 », « 45 % » ou ""), comme le journal.
-- nil : on ne peut pas savoir (infobulle cachée par le jeu) ; garder ce qu'on savait.
local function questInfo(unit)
    local TI = _G.C_TooltipInfo
    if not (TI and TI.GetUnit and LINE_OBJECTIVE) then return false end
    local ok, data = pcall(TI.GetUnit, unit)
    if not ok or type(data) ~= "table" or type(data.lines) ~= "table" then return nil end
    -- En groupe, les objectifs sont rangés sous le nom de chaque joueur (le mien compris) : seuls
    -- ceux d'avant le premier nom, ou sous mon nom, sont à moi.
    local me = _G.UnitName("player")
    local mine = true
    for _, line in ipairs(data.lines) do
        if LINE_PLAYER and line.type == LINE_PLAYER then
            local who = line.leftText
            if issecret(who) or not known(me) then return nil end
            mine = type(who) == "string" and who:find(me, 1, true) ~= nil
        elseif mine and line.type == LINE_OBJECTIVE then
            local text = line.leftText
            if issecret(text) or issecret(line.completed) then return nil end
            if not line.completed and type(text) == "string" then
                local done, total = text:match("(%d+)%s*/%s*(%d+)")
                done, total = tonumber(done), tonumber(total)
                if done and total then
                    if done < total then return true, done .. "/" .. total end
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

-- Barre de vie montrée ou cachée (plaque amie : seulement quand l'allié est blessé).
local function setBarShown(p, shown)
    p.health:SetShown(shown)
    p.bg:SetShown(shown)
    for _, line in ipairs(p.border) do line:SetShown(shown) end
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
    p.bg = texture(p, "BACKGROUND", -8, C.fond)
    p.bg:SetAllPoints()
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
    -- Quête : « ! » au trait jaune à gauche, l'avancement dessous.
    p.quest = p:CreateTexture(nil, "OVERLAY")
    p.quest:SetTexture(CUI.MEDIA .. "Icones\\Quetes")
    p.quest:SetVertexColor(JAUNE_QUETE[1], JAUNE_QUETE[2], JAUNE_QUETE[3], 1)
    p.questText = newText(p)
    p.questText:SetPoint("TOP", p.quest, "BOTTOM", 0, 2)
    p.questText:SetTextColor(JAUNE_QUETE[1], JAUNE_QUETE[2], JAUNE_QUETE[3])
    -- Incantation : barre sous la vie, cadenas, nom du sort et temps dessous.
    p.cast = _G.CreateFrame("Frame", nil, p)
    texture(p.cast, "BACKGROUND", -8, C.fond):SetAllPoints()
    p.cast.border = {}
    for i = 1, 4 do p.cast.border[i] = texture(p.cast, "OVERLAY", 6, C.bordureDiscrete) end
    local cb = p.cast.border
    cb[1]:SetPoint("TOPLEFT"); cb[1]:SetPoint("TOPRIGHT"); cb[1]:SetHeight(1)
    cb[2]:SetPoint("BOTTOMLEFT"); cb[2]:SetPoint("BOTTOMRIGHT"); cb[2]:SetHeight(1)
    cb[3]:SetPoint("TOPLEFT"); cb[3]:SetPoint("BOTTOMLEFT"); cb[3]:SetWidth(1)
    cb[4]:SetPoint("TOPRIGHT"); cb[4]:SetPoint("BOTTOMRIGHT"); cb[4]:SetWidth(1)
    p.cast.bar = _G.CreateFrame("StatusBar", nil, p.cast)
    p.cast.bar:SetStatusBarTexture(WHITE)
    p.cast.bar:SetPoint("TOPLEFT", 1, -1)
    p.cast.bar:SetPoint("BOTTOMRIGHT", -1, 1)
    p.cast.bar:SetMinMaxValues(0, 1)
    p.cast.lock = p.cast:CreateTexture(nil, "OVERLAY")
    p.cast.lock:SetTexture(CUI.MEDIA .. "Cadenas")
    p.cast.lock:SetVertexColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
    p.cast.name = newText(p.cast)
    p.cast.name:SetJustifyH("LEFT")
    p.cast.name:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
    p.cast.time = newText(p.cast)
    p.cast.time:SetJustifyH("RIGHT")
    p.cast.time:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
    p.cast:Hide()
    -- Marqueur de raid (crâne, croix...) : à droite de la barre.
    p.raid = p:CreateTexture(nil, "OVERLAY")
    p.raid:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    p.raid:Hide()
    return p
end

-- Taille, polices, échelle (cible plus grande).
local function layoutPlate(p)
    if p.friend then
        local a = M.db.amis
        p:SetSize(a.largeur, a.hauteur)
        p.name:SetFont(CUI:GetFont(), a.tailleNom, "OUTLINE")
        p.level:SetFont(CUI:GetFont(), math.max(7, a.tailleNom - 2), "OUTLINE")
        p.name:SetWidth(0)
        local icon = a.tailleNom + 6
        p.raid:SetSize(icon, icon)
        p.raid:ClearAllPoints()
        p.raid:SetPoint("LEFT", p.name, "RIGHT", 3, 0)
        return
    end
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
    p.raid:SetSize(icon, icon)
    p.raid:ClearAllPoints()
    p.raid:SetPoint("LEFT", p, "RIGHT", 4, (s.tailleNom + 3) / 2)
    -- Incantation : collée sous la vie, textes dessous.
    local small = math.max(7, s.tailleNom - 3)
    p.cast:ClearAllPoints()
    p.cast:SetPoint("TOPLEFT", p, "BOTTOMLEFT", 0, -2)
    p.cast:SetPoint("TOPRIGHT", p, "BOTTOMRIGHT", 0, -2)
    p.cast:SetHeight(s.hauteurInc)
    p.cast.lock:SetSize(small, small)
    p.cast.lock:ClearAllPoints()
    p.cast.lock:SetPoint("TOPLEFT", p.cast, "BOTTOMLEFT", 0, -2)
    p.cast.name:SetFont(font, small, "OUTLINE")
    p.cast.time:SetFont(font, small, "OUTLINE")
    p.cast.time:ClearAllPoints()
    p.cast.time:SetPoint("TOPRIGHT", p.cast, "BOTTOMRIGHT", 0, -2)
    p.cast.name:ClearAllPoints()
    p.cast.name:SetPoint("TOPLEFT", p.cast, "BOTTOMLEFT", p.cast.lock:IsShown() and (small + 3) or 0, -2)
    p.cast.name:SetPoint("TOPRIGHT", p.cast.time, "TOPLEFT", -4, 0)
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
    if p.friend then
        -- Vie cachée par le jeu : on ne sait pas si l'allié est blessé ; pas de barre.
        local wounded = known(hp) and known(maxHp) and hp < maxHp
        setBarShown(p, M.db.amis.blesse and wounded or false)
        p.pct:Hide()
        return
    end
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
    if p.friend then return end
    local state = threatState(p.unit)
    setBorder(p, state == "danger" and C.coeur or state == "warn" and ORANGE or C.bordureDiscrete)
end

local function updateQuest(p)
    if p.friend then return end
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

local function updateRaidMark(p)
    local index = _G.GetRaidTargetIndex(p.unit)
    if known(index) and index and index > 0 and _G.SetRaidTargetIconTexture then
        _G.SetRaidTargetIconTexture(p.raid, index)
        p.raid:Show()
    else
        p.raid:Hide()
    end
end

local function updateTarget(p)
    local isTarget = _G.UnitIsUnit(p.unit, "target")
    local big = not p.friend and known(isTarget) and isTarget
    p:SetScale(big and M.db.ennemis.cible / 100 or 1)
end

-- Plaque amie : le nom (vert pour un PNJ, couleur de classe pour un joueur), barre si blessé.
local function updateFriend(p)
    local unit = p.unit
    p.name:SetText(_G.UnitName(unit))
    local color = VERT
    local isPlayer = _G.UnitIsPlayer(unit)
    if known(isPlayer) and isPlayer then
        local _, classFile = _G.UnitClass(unit)
        color = classColor(classFile) or VERT
    end
    p.name:SetTextColor(color[1], color[2], color[3])
    p.health:SetStatusBarColor(color[1], color[2], color[3])
    setBorder(p, C.bordureDiscrete)
    -- Niveau : joueurs seulement (pas sur les PNJ alliés).
    local level = _G.UnitLevel(unit)
    if M.db.amis.niveau and known(isPlayer) and isPlayer and known(level) then
        p.level:SetText(level <= 0 and "??" or level)
        p.level:Show()
    else
        p.level:Hide()
    end
    p.pct:Hide()
    p.quest:Hide()
    p.questText:Hide()
    updateHealth(p)
    updateRaidMark(p)
    updateTarget(p)
end

local function updateAll(p)
    if p.friend then return updateFriend(p) end
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
    updateRaidMark(p)
    updateTarget(p)
end

-- Mes affaiblissements : les icônes de la plaque du jeu -----------------------------------

-- Cadre des effets de la plaque du jeu (selon la version du jeu).
local function auraContainer(base)
    local uf = base.UnitFrame
    return uf and (uf.AurasFrame or uf.BuffFrame)
end

-- Icônes d'effets affichées, dans l'ordre du jeu (recherche sur deux niveaux de cadres).
local function auraButtons(container)
    local list = {}
    local function scan(frame, depth)
        for _, child in ipairs({ frame:GetChildren() }) do
            if child.Icon and child.IsShown and child:IsShown() then
                list[#list + 1] = child
            elseif depth < 2 and child.GetChildren then
                scan(child, depth + 1)
            end
        end
    end
    scan(container, 0)
    table.sort(list, function(a, b)
        local ai, bi = rawget(a, "layoutIndex"), rawget(b, "layoutIndex")
        if type(ai) == "number" and type(bi) == "number" then return ai < bi end
        return false
    end)
    return list
end

local function hideRegion(r)
    if r and r.SetAlpha then r:SetAlpha(0) end
end

-- Habillage d'une icône (une fois) : icône rognée, liseré gris fin, temps sous l'icône.
local function skinAura(b)
    if b.cuiSkinned then return end
    b.cuiSkinned = true
    -- Sur ce client, « Icon » peut être un cadre qui porte la texture : on cherche la vraie.
    local icon = b.Icon
    if not (icon.GetObjectType and icon:GetObjectType() == "Texture") then
        local found
        for _, r in ipairs({ icon.Icon, icon.Texture }) do
            if r and r.GetObjectType and r:GetObjectType() == "Texture" then found = r break end
        end
        if not found and icon.GetRegions then
            for _, r in ipairs({ icon:GetRegions() }) do
                if r.GetObjectType and r:GetObjectType() == "Texture" then found = r break end
            end
        end
        icon = found
    end
    if icon then
        if icon.GetNumMaskTextures and icon.RemoveMaskTexture then
            for i = icon:GetNumMaskTextures(), 1, -1 do
                local mask = icon:GetMaskTexture(i)
                if mask then icon:RemoveMaskTexture(mask) end
            end
        end
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", b, "TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
    end
    hideRegion(b.Border)
    hideRegion(b.IconBorder)
    hideRegion(b.DebuffBorder)
    b.cuiBack = b:CreateTexture(nil, "BACKGROUND", nil, -8)
    b.cuiBack:SetTexture(WHITE)
    b.cuiBack:SetVertexColor(C.fond[1], C.fond[2], C.fond[3], 1)
    b.cuiBack:SetAllPoints()
    b.cuiLines = {}
    for i = 1, 4 do b.cuiLines[i] = texture(b, "OVERLAY", 6, C.graphite) end
    b.cuiLines[1]:SetPoint("TOPLEFT"); b.cuiLines[1]:SetPoint("TOPRIGHT"); b.cuiLines[1]:SetHeight(1)
    b.cuiLines[2]:SetPoint("BOTTOMLEFT"); b.cuiLines[2]:SetPoint("BOTTOMRIGHT"); b.cuiLines[2]:SetHeight(1)
    b.cuiLines[3]:SetPoint("TOPLEFT"); b.cuiLines[3]:SetPoint("BOTTOMLEFT"); b.cuiLines[3]:SetWidth(1)
    b.cuiLines[4]:SetPoint("TOPRIGHT"); b.cuiLines[4]:SetPoint("BOTTOMRIGHT"); b.cuiLines[4]:SetWidth(1)
    -- Temps restant : le décompte du jeu (il le tient à jour, même en combat), posé sous l'icône.
    local cd = b.Cooldown
    if cd then
        if cd.SetDrawSwipe then cd:SetDrawSwipe(false) end
        if cd.SetDrawEdge then cd:SetDrawEdge(false) end
        if cd.SetHideCountdownNumbers then cd:SetHideCountdownNumbers(false) end
        b.cuiTime = cd.GetCountdownFontString and cd:GetCountdownFontString()
    end
    local count = (b.CountFrame and b.CountFrame.Count) or b.Count
    if count and count.GetObjectType and count:GetObjectType() == "FontString" then b.cuiCount = count end
end

-- Range les icônes en une ligne centrée au-dessus du nom ; au-delà du nombre réglé : cachées.
local laying = false
local function layoutAuras(p)
    local base = p.base
    local container = base and auraContainer(base)
    if not container then return end
    if p.friend then
        -- Plaque amie : le nom seul, sans les effets du jeu.
        if container.SetIgnoreParentAlpha then container:SetIgnoreParentAlpha(false) end
        return
    end
    local s = M.db.ennemis
    if container.SetIgnoreParentAlpha then container:SetIgnoreParentAlpha(s.effets and true or false) end
    container:SetAlpha(s.effets and 1 or 0)
    if not s.effets then return end
    laying = true
    local size, gap = s.tailleEffets, 3
    local buttons = auraButtons(container)
    local n = math.min(#buttons, s.nombreEffets)
    local x = (s.largeur - (n * size + (n - 1) * gap)) / 2
    local font = CUI:GetFont()
    for i, b in ipairs(buttons) do
        skinAura(b)
        if i <= n then
            b:SetSize(size, size)
            b:ClearAllPoints()
            b:SetPoint("BOTTOMLEFT", p, "TOPLEFT", x + (i - 1) * (size + gap), s.tailleNom + 8 + math.floor(size / 2))
            b:SetAlpha(1)
            if b.cuiTime then
                b.cuiTime:ClearAllPoints()
                b.cuiTime:SetPoint("TOP", b, "BOTTOM", 0, -1)
                b.cuiTime:SetFont(font, math.max(7, math.floor(size / 2)), "OUTLINE")
                b.cuiTime:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
            end
            if b.cuiCount then
                b.cuiCount:ClearAllPoints()
                b.cuiCount:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
                b.cuiCount:SetFont(font, math.max(7, math.floor(size / 2)), "OUTLINE")
            end
        else
            b:SetAlpha(0)
        end
    end
    laying = false
end

-- Le jeu range ses icônes à chaque changement : on repasse derrière lui (crochets, une fois par cadre).
local auraHooked = {}
local function hookAuras(p)
    local container = auraContainer(p.base)
    if not container then return end
    local function hookFrame(frame)
        if auraHooked[frame] then return end
        auraHooked[frame] = true
        for _, method in ipairs({ "Layout", "MarkDirty", "UpdateBuffs", "RefreshList" }) do
            if type(frame[method]) == "function" then
                _G.hooksecurefunc(frame, method, function()
                    local plate = p.base.cuiPlate
                    if M.enabled and not laying and plate and plate.unit then
                        M:After(0, function() if plate.unit then layoutAuras(plate) end end)
                    end
                end)
            end
        end
    end
    hookFrame(container)
    for _, child in ipairs({ container:GetChildren() }) do hookFrame(child) end
end

-- Incantation ---------------------------------------------------------------------------------

local function castColor(cast, color)
    cast.bar:SetStatusBarColor(color[1], color[2], color[3])
end

-- Nom du sort : après le cadenas s'il est là.
local function placeCastName(cast, lock)
    cast.lock:SetShown(lock)
    cast.name:SetPoint("TOPLEFT", cast, "BOTTOMLEFT", lock and (cast.lock:GetWidth() + 3) or 0, -2)
end

local function paintProtect(p, notInterruptible)
    local cast = p.cast
    local protect = known(notInterruptible) and notInterruptible or false
    castColor(cast, protect and INC_PROTEGE or (cast.mode == "canal" and INC_CANAL or INC_CAST))
    placeCastName(cast, protect)
end

local function hideCast(p)
    local cast = p.cast
    cast.mode, cast.start = nil, nil
    if cast.timer and cast.bar.ClearTimerDuration then pcall(cast.bar.ClearTimerDuration, cast.bar) end
    cast.timer = nil
    cast:Hide()
end

-- Temps restant : « 1,2 s » (séparateur décimal de la langue).
local function setCastTime(cast, remaining)
    if not remaining then
        cast.time:SetText("")
        return
    end
    local text = ("%.1f"):format(math.max(0, remaining))
    if L.PN_INC_VIRGULE ~= "." then text = text:gsub("%.", L.PN_INC_VIRGULE) end
    cast.time:SetText(L.PN_INC_TEMPS:format(text))
end

local function onCastUpdate(p)
    local cast = p.cast
    if (cast.mode == "cast" or cast.mode == "canal") and cast.start then
        local now = _G.GetTime()
        local total = cast.finish - cast.start
        local elapsed = math.min(math.max(now - cast.start, 0), total)
        local f = total > 0 and elapsed / total or 1
        cast.bar:SetValue(cast.mode == "canal" and 1 - f or f)
        setCastTime(cast, total - elapsed)
        if now > cast.finish + 1 then hideCast(p) end -- sans évènement de fin (rare)
    elseif cast.mode == "echec" and _G.GetTime() - cast.endTime > INC_TENUE then
        hideCast(p)
    end
end

-- Une incantation (ou canalisation) commence ou change : tout est relu au jeu.
local function startCast(p, channel)
    if not M.db.ennemis.incantation then return end
    local unit, cast = p.unit, p.cast
    local name, startMS, endMS, notInterruptible, castID
    if channel then
        local n, _, _, st, en, _, ni = _G.UnitChannelInfo(unit)
        name, startMS, endMS, notInterruptible = n, st, en, ni
    else
        local n, _, _, st, en, _, cid, ni = _G.UnitCastingInfo(unit)
        name, startMS, endMS, castID, notInterruptible = n, st, en, cid, ni
    end
    if name == nil then return end
    hideCast(p)
    cast.mode = channel and "canal" or "cast"
    cast.castID = known(castID) and castID or nil
    cast.name:SetText(name)
    paintProtect(p, notInterruptible)
    cast.bar:SetMinMaxValues(0, 1)
    if known(startMS) and known(endMS) and startMS and endMS and endMS > startMS then
        cast.start, cast.finish = startMS / 1000, endMS / 1000
    else
        -- Temps cachés par le jeu : il anime la barre s'il le sait, sinon elle reste pleine. Pas de chiffres.
        setCastTime(cast, nil)
        local getDuration = channel and _G.UnitChannelDuration or _G.UnitCastingDuration
        local ok, duration = false, nil
        if getDuration and cast.bar.SetTimerDuration then ok, duration = pcall(getDuration, unit) end
        if ok and duration and pcall(cast.bar.SetTimerDuration, cast.bar, duration) then
            cast.timer = true
        else
            cast.bar:SetValue(1)
        end
    end
    cast:Show()
end

-- Interrompue : rouge cœur un instant, puis cachée.
local function failCast(p)
    local cast = p.cast
    if cast.timer and cast.bar.ClearTimerDuration then pcall(cast.bar.ClearTimerDuration, cast.bar) end
    cast.timer, cast.start = nil, nil
    cast.mode, cast.endTime = "echec", _G.GetTime()
    cast.bar:SetMinMaxValues(0, 1)
    cast.bar:SetValue(1)
    castColor(cast, C.coeur)
    placeCastName(cast, false)
    cast.name:SetText(L.PN_INC_INTERROMPU)
    setCastTime(cast, nil)
end

local function sameCast(cast, castGUID)
    if not cast.castID or castGUID == nil or not known(castGUID) then return true end
    return castGUID == cast.castID
end

local function onSpellEvent(event, unit, castGUID)
    local p = unit and plates[unit]
    if not p or p.friend then return end
    local cast = p.cast
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
        startCast(p, false)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        startCast(p, true)
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" then
        if cast.mode == "cast" and sameCast(cast, castGUID) then hideCast(p) end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if cast.mode == "canal" then hideCast(p) end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        if (cast.mode == "cast" and sameCast(cast, castGUID)) or cast.mode == "canal" then failCast(p) end
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
        if cast.mode == "cast" or cast.mode == "canal" then paintProtect(p, false) end
    elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        if cast.mode == "cast" or cast.mode == "canal" then paintProtect(p, true) end
    end
end

-- Incantation déjà en cours quand la plaque arrive.
local function resumeCast(p)
    hideCast(p)
    if p.friend or not M.db.ennemis.incantation then return end
    if _G.UnitCastingInfo(p.unit) ~= nil then
        startCast(p, false)
    elseif _G.UnitChannelInfo(p.unit) ~= nil then
        startCast(p, true)
    end
end

local SPELL_EVENTS = {
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_CHANNEL_STOP",
}
-- Pas sur tous les clients : inscrits seulement s'ils existent.
local SPELL_EVENTS_OPTIONAL = { "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" }

-- Plaques qui arrivent et qui partent ------------------------------------------------------

local function isEnemy(unit)
    local can = _G.UnitCanAttack("player", unit)
    return known(can) and can or false
end

local function release(unit)
    local p = plates[unit]
    if not p then return end
    plates[unit] = nil
    hideCast(p)
    p:Hide()
    p.unit = nil
end

local function attach(unit)
    release(unit)
    local NP = _G.C_NamePlate
    local base = NP and NP.GetNamePlateForUnit and NP.GetNamePlateForUnit(unit)
    if not base or (base.IsForbidden and base:IsForbidden()) then return end
    local friend = not isEnemy(unit)
    local isMe = _G.UnitIsUnit(unit, "player")
    if friend and (not M.db.amis.habiller or not known(isMe) or isMe) then
        hideGame(base, false)
        local container = auraContainer(base)
        if container then
            if container.SetIgnoreParentAlpha then container:SetIgnoreParentAlpha(false) end
            container:SetAlpha(1)
        end
        if base.cuiPlate then base.cuiPlate:Hide() end
        return
    end
    base.cuiPlate = base.cuiPlate or createPlate(base)
    local p = base.cuiPlate
    p.base = base
    p.unit = unit
    p.friend = friend
    p.isQuest, p.questRest = false, nil
    plates[unit] = p
    hideGame(base, true)
    setBarShown(p, not friend)
    layoutPlate(p)
    updateAll(p)
    p:Show()
    hookAuras(p)
    layoutAuras(p)
    resumeCast(p)
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

-- Toutes les plaques affichées, relues depuis le début.
local function rescan()
    local NP = _G.C_NamePlate
    if not (NP and NP.GetNamePlates) then return end
    for _, base in ipairs(NP.GetNamePlates() or {}) do
        local unit = base.namePlateUnitToken or (base.UnitFrame and base.UnitFrame.unit)
        if unit then CUI:SafeCall(CUI:Tr("PN_NOM"), attach, unit) end
    end
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    self:On("NAME_PLATE_UNIT_ADDED", function(_, unit) attach(unit) end)
    self:On("NAME_PLATE_UNIT_REMOVED", function(_, unit) release(unit) end)
    self:On("PLAYER_TARGET_CHANGED", function() forEach(updateTarget) end)
    self:On("RAID_TARGET_UPDATE", function() forEach(updateRaidMark) end)
    for _, event in ipairs(SPELL_EVENTS) do
        self:On(event, function(ev, unit, castGUID) onSpellEvent(ev, unit, castGUID) end)
    end
    for _, event in ipairs(SPELL_EVENTS_OPTIONAL) do
        pcall(self.On, self, event, function(ev, unit, castGUID) onSpellEvent(ev, unit, castGUID) end)
    end
    -- Temps de l'incantation : une seule minuterie pour toutes les plaques.
    self:Every(0.05, function()
        for _, p in pairs(plates) do
            if p.cast.mode then onCastUpdate(p) end
        end
    end)
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
    self:On("UNIT_AURA", function(_, unit)
        local p = unit and plates[unit]
        if p then self:After(0, function() if p.unit == unit then layoutAuras(p) end end) end
    end)
    self:On("UNIT_THREAT_SITUATION_UPDATE", function() forEach(updateThreat) end)
    self:On("QUEST_LOG_UPDATE", refreshQuests)
    self:On("UNIT_QUEST_LOG_CHANGED", refreshQuests)
    self:On("PLAYER_REGEN_ENABLED", refreshQuests) -- infobulles lisibles de nouveau
    self:On("PLAYER_SPECIALIZATION_CHANGED", function() forEach(updateThreat) end)
    rescan() -- plaques déjà là (module activé en jeu, /reload)
end

-- Coupé : tout reste en place jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged(key, _, subKey)
    if subKey == "amis" and key == "habiller" then
        rescan()
        return
    end
    forEach(function(p)
        layoutPlate(p)
        updateAll(p)
        layoutAuras(p)
        if key == "incantation" then resumeCast(p) end
    end)
end

function M:OnFontChanged()
    forEach(function(p)
        layoutPlate(p)
        layoutAuras(p)
    end)
end
