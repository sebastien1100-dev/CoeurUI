-- Module « Cadres d'unité », page « Boss » (maquette validée le 27/11/2026, « CœurUI · Maquette Cadres de
-- boss ») :
--   - jusqu'à 5 boss en colonne à droite de l'écran (vers le bas ou le haut), placés d'un bloc au cadenas ;
--   - même style que la cible : liseré gris fin, vie rouge (couleur d'attitude), pourcentage à droite ;
--   - marqueur de raid, liseré blanc sur le boss ciblé ;
--   - barre d'incantation sous chaque boss (celle de « Cadres d'unité » : gris et cadenas pour un sort
--     qu'on ne peut pas interrompre) ;
--   - mes affaiblissements à gauche du cadre, avec leur durée ;
--   - cadenas ouvert : 5 boss d'exemple animés.
-- Les cadres sont des boutons protégés (cibler, menu), montrés par le jeu quand le boss existe (même en
-- combat). Valeurs « secrètes » : comme dans CadresUnite.lua, jamais comparées ni calculées.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local M = CUI:GetModule("CadresUnite")
if not M then return end

-- Réglages : M.db.boss (sous-module « boss »).
M.defaults.boss = {
    actif = true, sens = "bas", largeur = 230, hauteur = 30, espacement = 18, texteVie = "p",
    marqueur = true, cibleLisere = true,
    incantation = true, incNom = true, incProtege = true, incHauteur = 16,
    incIcone = false, incTemps = "rt", incTics = true, incDetachee = false,
    debuffs = true, debuffsMax = 4, tailleDebuffs = 22,
}

local SENS = { { value = "bas", text = "CU_GR_BAS" }, { value = "haut", text = "CU_GR_HAUT" } }
local TEXTE_VIE = {
    { value = "vp", text = "CU_VIE_VP" }, { value = "p", text = "CU_VIE_P" },
    { value = "v", text = "CU_VIE_V" }, { value = "aucun", text = "CU_VIE_AUCUN" },
}
local function on(read) return read("actif") end
local function incOn(read) return read("actif") and read("incantation") end
local function debOn(read) return read("actif") and read("debuffs") end

M.subs[#M.subs + 1] = {
    key = "boss", name = "CU_BOSS", intro = false,
    settings = {
        { type = "section", text = "CU_GR_DISPOSITION" },
        { type = "toggle", key = "actif", label = "CU_BO_AFFICHER", description = "CU_BO_AFFICHER_NOTE" },
        { type = "dropdown", key = "sens", label = "CU_GR_SENS", options = SENS, enabledIf = on },
        { type = "section", text = "CU_TAILLE" },
        { type = "slider", key = "largeur", label = "CU_LARGEUR", min = 120, max = 320, step = 10, format = "%d",
          enabledIf = on },
        { type = "slider", key = "hauteur", label = "CU_HAUTEUR", min = 16, max = 60, step = 2, format = "%d",
          enabledIf = on },
        { type = "slider", key = "espacement", label = "CU_GR_ESPACEMENT", min = 0, max = 40, step = 1, format = "%d",
          enabledIf = on },
        { type = "section", text = "CU_TEXTES" },
        { type = "dropdown", key = "texteVie", label = "CU_TEXTE_VIE", options = TEXTE_VIE, enabledIf = on },
        { type = "column" },
        { type = "section", text = "CU_ELEMENTS" },
        { type = "toggle", key = "marqueur", label = "CU_GR_MARQUEUR", enabledIf = on },
        { type = "toggle", key = "cibleLisere", label = "CU_BO_CIBLE", enabledIf = on },
        { type = "section", text = "CU_INC" },
        { type = "toggle", key = "incantation", label = "CU_INC_AFFICHER", enabledIf = on },
        { type = "toggle", key = "incNom", label = "CU_BO_INC_NOM", enabledIf = incOn },
        { type = "toggle", key = "incProtege", label = "CU_INC_PROTEGE", enabledIf = incOn },
        { type = "slider", key = "incHauteur", label = "CU_BO_INC_HAUTEUR", min = 10, max = 30, step = 1, format = "%d",
          enabledIf = incOn },
        { type = "section", text = "CU_BO_DEBUFFS" },
        { type = "toggle", key = "debuffs", label = "CU_BO_DEBUFFS_AFFICHER", enabledIf = on },
        { type = "slider", key = "debuffsMax", label = "CU_BO_DEBUFFS_MAX", min = 1, max = 8, step = 1, format = "%d",
          enabledIf = debOn },
        { type = "slider", key = "tailleDebuffs", label = "CU_GR_TAILLE_ICONES", min = 14, max = 36, step = 1,
          format = "%d", enabledIf = debOn },
    },
}

local B = {}       -- propriétaire de nos inscriptions aux évènements
M.boss = B

local MAX = _G.MAX_BOSS_FRAMES or 5
local frames = {}  -- 1..MAX : cadres protégés des boss
local anchor, test, hiddenParent

local function sh() return M.shared end
local function db() return M.db.boss end

local function newText(parent)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetShadowColor(0, 0, 0, 0.9)
    fs:SetShadowOffset(1, -1)
    fs:SetWordWrap(false)
    fs:SetJustifyV("MIDDLE")
    return fs
end

-- Dessin d'un cadre ----------------------------------------------------------------------------

local function createVisual(f)
    local v = { owner = f, auras = {} }
    v.border, v.fill = CUI:CreateBorderedRect(f, 3, C.graphite, C.fond)
    v.health = _G.CreateFrame("StatusBar", nil, f)
    v.health:SetPoint("TOPLEFT", 1, -1)
    v.health:SetPoint("BOTTOMRIGHT", -1, 1)
    v.health:SetMinMaxValues(0, 1)
    local texts = _G.CreateFrame("Frame", nil, v.health)
    texts:SetAllPoints()
    texts:SetFrameLevel(v.health:GetFrameLevel() + 2)
    v.name, v.hp = newText(texts), newText(texts)
    v.name:SetJustifyH("LEFT")
    v.hp:SetJustifyH("RIGHT")
    v.mark = texts:CreateTexture(nil, "OVERLAY")
    v.mark:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    return v
end

local function layoutVisual(v)
    local g = M.db.general
    v.health:SetStatusBarTexture(CUI:GetBarTexture(g.texture))
    local font = CUI:GetFont()
    v.name:SetFont(font, g.tailleNom, "")
    v.hp:SetFont(font, g.tailleVie, "")
    v.hp:ClearAllPoints()
    v.hp:SetPoint("RIGHT", v.health, "RIGHT", -7, 0)
    v.name:ClearAllPoints()
    v.name:SetPoint("LEFT", v.health, "LEFT", 7, 0)
    v.name:SetPoint("RIGHT", v.hp, "LEFT", -6, 0)
    v.mark:SetSize(16, 16)
    v.mark:ClearAllPoints()
    v.mark:SetPoint("CENTER", v.owner, "TOPRIGHT", -2, 0)
end

local function setMark(v, index)
    if db().marqueur and index and _G.SetRaidTargetIconTexture then
        _G.SetRaidTargetIconTexture(v.mark, index)
        v.mark:Show()
    else
        v.mark:Hide()
    end
end

local function setBorder(v, target)
    v.border:SetColor((target and db().cibleLisere) and C.texte or C.graphite)
end

-- Mes affaiblissements : à gauche du cadre, de droite à gauche.
local function auraButton(v, i)
    local a = v.auras[i]
    if a then return a end
    local f = v.owner
    a = _G.CreateFrame("Frame", nil, f)
    a.border, a.fill = CUI:CreateBorderedRect(a, 2, C.graphite, C.fond)
    a.icon = a:CreateTexture(nil, "ARTWORK")
    a.icon:SetPoint("TOPLEFT", 1, -1)
    a.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    a.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    a.cd = _G.CreateFrame("Cooldown", nil, a, "CooldownFrameTemplate")
    a.cd:SetAllPoints(a.icon)
    a.cd:SetReverse(true)
    a:Hide()
    v.auras[i] = a
    return a
end

local function placeAuras(v, n)
    local size = db().tailleDebuffs
    for i, a in ipairs(v.auras) do
        if i > n then
            a:Hide()
        else
            a:SetSize(size, size)
            a:ClearAllPoints()
            a:SetPoint("RIGHT", v.owner, "LEFT", -4 - (i - 1) * (size + 3), 0)
            a:Show()
        end
    end
end

local function showAura(a, unit, data)
    local known = sh().known
    a.icon:SetTexture(data.icon)
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
end

local function updateAuras(f)
    local v, unit, s = f.visual, f.unit, db()
    local n = 0
    local get = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataByIndex
    if s.debuffs and get then
        for i = 1, 40 do
            if n >= s.debuffsMax then break end
            local ok, data = pcall(get, unit, i, "HARMFUL|PLAYER")
            if not ok or not data then break end
            n = n + 1
            showAura(auraButton(v, n), unit, data)
        end
    end
    placeAuras(v, n)
end

-- Vrais cadres ----------------------------------------------------------------------------------

local function update(f)
    local unit, v = f.unit, f.visual
    if not _G.UnitExists(unit) then return end
    local S, s = sh(), db()
    local known = S.known
    v.name:SetText(_G.UnitName(unit))
    local hp, maxHp = _G.UnitHealth(unit), _G.UnitHealthMax(unit)
    v.health:SetMinMaxValues(0, maxHp)
    v.health:SetValue(hp)
    local color = S.healthColor(unit, "classe")
    local dead = _G.UnitIsDead(unit)
    if known(dead) and dead then
        color = S.GRIS
        v.hp:SetText(L.CU_MORT)
    else
        S.setHealthText(v.hp, s.texteVie, hp, S.healthPercent(unit, hp, maxHp))
    end
    v.health:SetStatusBarColor(color[1], color[2], color[3])
    local mark = _G.GetRaidTargetIndex(unit)
    setMark(v, known(mark) and mark or nil)
    local isTarget = _G.UnitIsUnit(unit, "target")
    setBorder(v, known(isTarget) and isTarget)
    updateAuras(f)
end

local function updateAll()
    for _, f in ipairs(frames) do
        if f:IsShown() then update(f) end
    end
end

-- Place réservée sous chaque boss pour sa barre d'incantation.
local function castExtra()
    local s = db()
    return s.incantation and (s.incHauteur + 4) or 0
end

-- Décalage du boss n dans l'ancre (bord droit) : vers le bas depuis le haut, ou vers le haut depuis le bas.
local function slot(n)
    local s = db()
    local step = (n - 1) * (s.hauteur + castExtra() + s.espacement)
    if s.sens == "haut" then return "BOTTOMRIGHT", 0, step + castExtra() end
    return "TOPRIGHT", 0, -step
end

local function anchorSize()
    local s = db()
    return s.largeur, MAX * (s.hauteur + castExtra()) + (MAX - 1) * s.espacement
end

local function placeFrames()
    local s = db()
    anchor:SetSize(anchorSize())
    for i, f in ipairs(frames) do
        f:SetSize(s.largeur, s.hauteur)
        local point, x, y = slot(i)
        f:ClearAllPoints()
        f:SetPoint(point, anchor, point, x, y)
    end
end

-- Groupe de test (cadenas ouvert) ---------------------------------------------------------------

local TEST = {
    { phase = 0.0, mark = 8 },
    { phase = 1.5, target = true, spell = "CU_BO_EXEMPLE_SORT", castPct = 0.56 },
    { phase = 3.0, spell = "CU_BO_EXEMPLE_SORT2", castPct = 0.3, locked = true },
    { phase = 4.2 },
    { phase = 5.1 },
}
local TEST_ICONS = { "Interface\\Icons\\Spell_Shadow_ShadowWordPain", "Interface\\Icons\\Spell_Fire_Immolation" }

local function animateTest(t)
    local s, S = db(), sh()
    for i, f in ipairs(test.frames) do
        local d, v = TEST[i], f.visual
        local pct = 50 + 45 * math.sin(t * 0.3 + d.phase)
        v.health:SetMinMaxValues(0, 100)
        v.health:SetValue(pct)
        S.setHealthText(v.hp, s.texteVie, math.floor(pct * 45000), pct)
        local c = { 0.72, 0.26, 0.25 }
        v.health:SetStatusBarColor(c[1], c[2], c[3])
    end
end

local function fillTest()
    local s = db()
    for i, f in ipairs(test.frames) do
        local d, v = TEST[i], f.visual
        layoutVisual(v)
        v.name:SetText(L.CU_BO_EXEMPLE:format(i))
        setMark(v, d.mark)
        setBorder(v, d.target)
        -- Mes affaiblissements d'exemple : sur les deux premiers.
        local n = 0
        if s.debuffs and i <= 2 then
            for k = 1, math.min(s.debuffsMax, 3 - i) do
                n = n + 1
                local a = auraButton(v, n)
                a.icon:SetTexture(TEST_ICONS[k] or TEST_ICONS[1])
                _G.CooldownFrame_Set(a.cd, _G.GetTime(), 15, true)
            end
        end
        placeAuras(v, n)
        -- Incantation d'exemple (barre simple, immobile).
        local cast = f.cast
        cast:SetShown(s.incantation and d.spell ~= nil)
        if cast:IsShown() then
            cast:ClearAllPoints()
            cast:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, -4)
            cast:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 0, -4)
            cast:SetHeight(s.incHauteur)
            cast.bar:SetStatusBarTexture(CUI:GetBarTexture(M.db.general.texture))
            cast.bar:SetValue(d.castPct)
            local c = (d.locked and s.incProtege) and { 0.48, 0.49, 0.53 } or { 0.29, 0.47, 0.72 }
            cast.bar:SetStatusBarColor(c[1], c[2], c[3])
            local size = math.max(8, math.min(14, s.incHauteur - 6))
            cast.name:SetFont(CUI:GetFont(), size, "")
            cast.name:SetText(s.incNom and L[d.spell] or "")
        end
    end
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
        local cast = _G.CreateFrame("Frame", nil, f)
        CUI:CreateBorderedRect(cast, 3, C.graphite, C.fond)
        cast.bar = _G.CreateFrame("StatusBar", nil, cast)
        cast.bar:SetPoint("TOPLEFT", 1, -1)
        cast.bar:SetPoint("BOTTOMRIGHT", -1, 1)
        cast.bar:SetMinMaxValues(0, 1)
        cast.name = newText(cast.bar)
        cast.name:SetPoint("LEFT", 6, 0)
        f.cast = cast
        test.frames[i] = f
    end
    test.elapsed = 0
    test:SetScript("OnUpdate", function(self, dt)
        self.elapsed = self.elapsed + dt
        animateTest(self.elapsed)
    end)
end

local function placeTest()
    local s = db()
    for i, f in ipairs(test.frames) do
        f:SetSize(s.largeur, s.hauteur)
        local point, x, y = slot(i)
        f:ClearAllPoints()
        f:SetPoint(point, anchor, point, x, y)
    end
end

local function showTest(shown)
    if shown then
        buildTest()
        placeTest()
        fillTest()
        animateTest(test.elapsed)
        test:Show()
    elseif test then
        test:Hide()
    end
end

-- Construction (hors combat) --------------------------------------------------------------------

-- Cadres de boss du jeu : rangés dans un cadre invisible tant que les nôtres sont actifs.
local function hideBlizzardBoss()
    hiddenParent = hiddenParent or _G.CreateFrame("Frame")
    hiddenParent:Hide()
    local names = { "BossTargetFrameContainer" }
    for i = 1, MAX do names[#names + 1] = "Boss" .. i .. "TargetFrame" end
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

local function createFrame(i)
    local unit = "boss" .. i
    local f = _G.CreateFrame("Button", "CoeurUIBoss" .. i, _G.UIParent, "SecureUnitButtonTemplate")
    f.unit = unit
    f:SetAttribute("unit", unit)
    f:SetAttribute("type1", "target")
    f:SetAttribute("type2", "togglemenu")
    f:RegisterForClicks("AnyUp")
    f:SetFrameStrata("LOW")
    f.visual = createVisual(f)
    layoutVisual(f.visual)
    f:HookScript("OnShow", function(self) update(self) end)
    f:HookScript("OnEnter", function(self)
        local tip = _G.GameTooltip
        if not tip then return end
        _G.GameTooltip_SetDefaultAnchor(tip, self)
        tip:SetUnit(self.unit)
        tip:Show()
    end)
    f:HookScript("OnLeave", function()
        if _G.GameTooltip then _G.GameTooltip:Hide() end
    end)
    frames[i] = f
    -- Barre d'incantation : celle de « Cadres d'unité », sous le boss (enfant de son cadre : cachée avec lui).
    f.castBar = sh().createCastBar({ kind = unit, unit = unit, owner = f, parent = f, protege = true,
                                     settings = db })
    _G.RegisterUnitWatch(f)
end

local function build()
    if anchor or not db().actif then return end
    hideBlizzardBoss()
    anchor = _G.CreateFrame("Frame", "CoeurUIBossAncre", _G.UIParent)
    anchor:SetSize(anchorSize())
    for i = 1, MAX do createFrame(i) end
    placeFrames()
    CUI:RegisterMover({
        key = "cadre_boss", frame = anchor, label = "CU_BOSS", point = "TOPRIGHT",
        default = { "TOPRIGHT", "TOPRIGHT", -60, -260 },
        onUnlock = function() showTest(true) end,
        onLock = function() showTest(false) end,
    })
    updateAll()
end

-- Appelés par CadresUnite.lua ------------------------------------------------------------------

local UNIT_EVENTS = { "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_NAME_UPDATE", "UNIT_FLAGS", "UNIT_AURA" }
local ALL_EVENTS = { "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "PLAYER_TARGET_CHANGED", "RAID_TARGET_UPDATE",
                     "PLAYER_ENTERING_WORLD", "UNIT_TARGETABLE_CHANGED" }

function B.Enable()
    CUI:AfterCombat(build)
    for _, event in ipairs(UNIT_EVENTS) do
        pcall(CUI.On, CUI, event, B, function(_, unit)
            if not M.enabled then return end
            for _, f in ipairs(frames) do
                if f.unit == unit and f:IsShown() then update(f) end
            end
        end)
    end
    for _, event in ipairs(ALL_EVENTS) do
        pcall(CUI.On, CUI, event, B, function()
            if not M.enabled then return end
            updateAll()
            for _, f in ipairs(frames) do sh().resumeCast(f.castBar) end
        end)
    end
end

-- Réglage changé (ou police) : tout est redessiné ; place et taille des cadres protégés hors combat.
function B.Apply()
    if not anchor then
        if db().actif then CUI:AfterCombat(build) end
        return
    end
    for _, f in ipairs(frames) do
        layoutVisual(f.visual)
        sh().applyCast(f.castBar)
    end
    CUI:AfterCombat(function()
        placeFrames()
        for _, f in ipairs(frames) do
            if db().actif then
                _G.RegisterUnitWatch(f)
            else
                _G.UnregisterUnitWatch(f)
                f:Hide()
            end
        end
        updateAll()
    end)
    if test and test:IsShown() then
        placeTest()
        fillTest()
    end
end
