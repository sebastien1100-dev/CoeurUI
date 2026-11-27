-- Module « Suivi des quêtes » (maquette validée) : le suivi des quêtes du jeu (ObjectiveTrackerFrame),
-- habillé au style sobre de CœurUI. Le jeu garde tout le suivi (quêtes, campagne, objectifs bonus,
-- donjons...) ; CœurUI change l'apparence, la place, la taille, et ajoute :
--   - titres de section gris, titre de quête dans la couleur de sa difficulté, objectifs gris clair
--     (faits : verts), barres de progression sobres, décor du jeu invisible ;
--   - fond sombre léger derrière le contenu (opacité réglable) ;
--   - repli automatique en combat (juste avant : après, le jeu l'interdit) et en donjon ou raid ;
--   - « Lien Wowhead » dans le menu du clic droit d'une quête : une petite fenêtre avec l'adresse
--     prête à copier (un addon ne peut ni ouvrir une page web ni écrire dans le presse-papiers).
-- Le suivi se place avec le cadenas. Couper le module demande un /reload.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local M = CUI:RegisterModule({
    key = "SuiviQuetes",
    name = "SQ_NOM",
    description = "SQ_DESC",
    defaultEnabled = false,
    needsReload = true,
    defaults = {
        largeur = 280, hauteur = 500, tailleTitres = 13, tailleObjectifs = 12,
        replierCombat = false, replierDonjon = true, fond = true, opaciteFond = 55,
    },
    settings = {
        { type = "section", text = "SQ_PLACE" },
        { type = "slider", key = "largeur", label = "SQ_LARGEUR", min = 200, max = 420, step = 10, format = "%d" },
        { type = "slider", key = "hauteur", label = "SQ_HAUTEUR", min = 200, max = 900, step = 20, format = "%d",
          description = "SQ_HAUTEUR_NOTE" },
        { type = "section", text = "SQ_TEXTES" },
        { type = "slider", key = "tailleTitres", label = "SQ_TAILLE_TITRES", min = 10, max = 18, step = 1, format = "%d pt" },
        { type = "slider", key = "tailleObjectifs", label = "SQ_TAILLE_OBJECTIFS", min = 9, max = 16, step = 1, format = "%d pt" },
        { type = "column" },
        { type = "section", text = "SQ_REPLI" },
        { type = "toggle", key = "replierCombat", label = "SQ_REPLI_COMBAT" },
        { type = "toggle", key = "replierDonjon", label = "SQ_REPLI_DONJON", description = "SQ_REPLI_NOTE" },
        { type = "section", text = "SQ_FOND" },
        { type = "toggle", key = "fond", label = "SQ_FOND_AFFICHER" },
        { type = "slider", key = "opaciteFond", label = "SQ_OPACITE", min = 0, max = 100, step = 5, format = "%d %%",
          enabledIf = function(read) return read("fond") end },
    },
})

local WHITE = "Interface\\Buttons\\WHITE8x8"
local issecret = _G.issecretvalue or function() return false end

local built = false
local holder        -- cadre placé au cadenas ; le suivi du jeu y est accroché
local back          -- fond sombre
local placing = false
local autoCollapsed = false -- replié par CœurUI (on ne déplie jamais un suivi replié par le joueur)

local function tracker()
    local t = _G.ObjectiveTrackerFrame
    if t and not (t.IsForbidden and t:IsForbidden()) then return t end
end

-- Place et taille -------------------------------------------------------------------------------

-- Le suivi contient des boutons d'objets de quête protégés : placé hors combat seulement.
local function place()
    local t = tracker()
    if not t or not holder or _G.InCombatLockdown() then return end
    placing = true
    holder:SetSize(M.db.largeur, M.db.hauteur)
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    t:SetWidth(M.db.largeur)
    t:SetHeight(M.db.hauteur)
    placing = false
end

-- Polices du suivi du jeu : police de CœurUI aux tailles voulues (le jeu recalcule ses espacements).
local function applyFonts()
    local file = CUI:GetFont()
    local function set(name, size)
        local font = _G[name]
        if font and font.SetFont then
            local _, _, flags = font:GetFont()
            font:SetFont(file, size, flags or "")
        end
    end
    set("ObjectiveTrackerHeaderFont", M.db.tailleTitres)
    set("ObjectiveTrackerLineFont", M.db.tailleObjectifs)
end

-- Habillage -------------------------------------------------------------------------------------

local GREY = C.texteDiscret
local LIGHT = C.texteSecondaire
local DONE = C.actif

local function hide(region)
    if region and region.SetAlpha then region:SetAlpha(0) end
end

-- Couleur d'une quête selon sa difficulté (comme le journal du jeu).
local function questColor(id)
    if type(id) ~= "number" or issecret(id) then return nil end
    local index = _G.C_QuestLog and _G.C_QuestLog.GetLogIndexForQuestID and _G.C_QuestLog.GetLogIndexForQuestID(id)
    if not index then return nil end
    local info = _G.C_QuestLog.GetInfo(index)
    local level = info and info.level
    if not level or issecret(level) or type(_G.GetQuestDifficultyColor) ~= "function" then return nil end
    return _G.GetQuestDifficultyColor(level)
end

local function skinBar(bar)
    if not bar or not bar.GetStatusBarTexture then return end
    local fill = bar:GetStatusBarTexture()
    for _, region in ipairs({ bar:GetRegions() }) do
        if region:GetObjectType() == "Texture" and region ~= fill then region:SetAlpha(0) end
    end
    bar:SetStatusBarTexture(WHITE)
    bar:SetStatusBarColor(LIGHT[1], LIGHT[2], LIGHT[3], 1)
    if not bar.cuiBack then
        bar.cuiBack = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
        bar.cuiBack:SetTexture(WHITE)
        bar.cuiBack:SetVertexColor(C.graphite[1], C.graphite[2], C.graphite[3], 1)
        bar.cuiBack:SetAllPoints()
    end
end

-- Couleur d'avancée : rouge (rien), jaune (moitié), vert (fait), en dégradé entre les deux.
local ROUGE = { 0.88, 0.36, 0.36 }
local JAUNE = { 0.92, 0.78, 0.36 }
local function mix(a, b, t)
    return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t }
end
local function progressColor(ratio)
    ratio = math.max(0, math.min(1, ratio))
    if ratio < 0.5 then return mix(ROUGE, JAUNE, ratio * 2) end
    return mix(JAUNE, DONE, (ratio - 0.5) * 2)
end

-- Quête du bloc qui porte une ligne (en remontant les cadres).
local function questOfLine(frame)
    local f = frame
    while f do
        local id = rawget(f, "id")
        if f.parentModule and type(id) == "number" and not issecret(id) then return id end
        f = f.GetParent and f:GetParent()
    end
end

-- Couleur d'une ligne d'objectif : faite : verte ; « x/y » ou « n % » : selon l'avancée ; sans
-- nombre (« À rendre »...) : verte si la quête est terminée, sinon gris clair.
local function objectiveColor(frame, text, done)
    if done then return DONE end
    local s = text:GetText()
    if type(s) == "string" and not issecret(s) then
        local have, need = s:match("(%d+)%s*/%s*(%d+)")
        have, need = tonumber(have), tonumber(need)
        if have and need and need > 0 then return progressColor(have / need) end
        local pct = tonumber(s:match("(%d+)%s*%%"))
        if pct then return progressColor(pct / 100) end
    end
    local id = questOfLine(frame)
    local complete = id and _G.C_QuestLog.IsComplete and _G.C_QuestLog.IsComplete(id)
    if complete and not issecret(complete) then return DONE end
    return LIGHT
end

-- Contour du contenu visible (unités de l'écran), pour le fond : quêtes et leurs icônes comprises.
local bounds
local mainHeader -- « Tous les objectifs » : invisible, hors du contour

local function extend(frame)
    local l, b, w, h = frame:GetRect()
    if not l or w <= 1 or h <= 1 then return end
    local k = frame:GetEffectiveScale() / _G.UIParent:GetEffectiveScale()
    l, b, w, h = l * k, b * k, w * k, h * k
    if not bounds then
        bounds = { left = l, right = l + w, bottom = b, top = b + h }
    else
        bounds.left = math.min(bounds.left, l)
        bounds.right = math.max(bounds.right, l + w)
        bounds.bottom = math.min(bounds.bottom, b)
        bounds.top = math.max(bounds.top, b + h)
    end
end

local function skinFrame(frame, depth)
    if depth > 6 or not frame or frame == mainHeader then return end
    if (frame.IsForbidden and frame:IsForbidden()) or not frame:IsShown() then return end
    -- En-tête de section (Quêtes, Campagne, Objectifs bonus...) : décor invisible, texte gris.
    local header = rawget(frame, "Header")
    if type(header) == "table" and header.GetObjectType and header ~= mainHeader then
        hide(rawget(header, "Background"))
        local text = rawget(header, "Text")
        if text and text.SetTextColor then text:SetTextColor(GREY[1], GREY[2], GREY[3]) end
    end
    -- Bloc de quête : titre dans la couleur de sa difficulté.
    local title = rawget(frame, "HeaderText")
    if title and title.SetTextColor and frame.parentModule then
        local color = questColor(frame.id)
        if color then title:SetTextColor(color.r, color.g, color.b) end
    end
    -- Ligne d'objectif : couleur selon l'avancée (rouge, jaune, vert), verte si faite.
    local text = rawget(frame, "Text")
    if text and text.SetTextColor and rawget(frame, "Dash") ~= nil then
        local icon = rawget(frame, "Icon")
        local done = icon and icon.IsShown and icon:IsShown()
        local c = objectiveColor(frame, text, done)
        text:SetTextColor(c[1], c[2], c[3])
        local dash = rawget(frame, "Dash")
        if dash and dash.SetTextColor then dash:SetTextColor(GREY[1], GREY[2], GREY[3]) end
    end
    -- Barres de progression.
    local bar = rawget(frame, "Bar")
    if bar then skinBar(bar) end
    -- Le contour suit les en-têtes de section, les blocs et ce qu'ils portent (icônes, boutons).
    if depth >= 2 then extend(frame) end
    for _, child in ipairs({ frame:GetChildren() }) do
        skinFrame(child, depth + 1)
    end
end

-- Fond sombre derrière le contenu visible, même marge tout autour.
local PAD = 10
local function updateBack()
    local t = tracker()
    if not back or not t then return end
    if not M.db.fond or not bounds or not t:IsVisible() then
        back:Hide()
        return
    end
    local k = _G.UIParent:GetEffectiveScale() / back:GetEffectiveScale()
    back:ClearAllPoints()
    back:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", (bounds.left - PAD) * k, (bounds.bottom - PAD) * k)
    back:SetPoint("TOPRIGHT", _G.UIParent, "BOTTOMLEFT", (bounds.right + PAD) * k, (bounds.top + PAD) * k)
    back.fill:SetVertexColor(C.fond[1], C.fond[2], C.fond[3], M.db.opaciteFond / 100)
    back:Show()
end

local function skinAll()
    local t = tracker()
    if not t then return end
    -- « Tous les objectifs » : invisible et sans souris (chaque section garde son bouton de repli).
    local header = rawget(t, "Header")
    if type(header) == "table" and header.SetAlpha then
        mainHeader = header
        if header:GetAlpha() ~= 0 then header:SetAlpha(0) end
        local button = rawget(header, "MinimizeButton")
        if button and button.EnableMouse and button:IsMouseEnabled() then button:EnableMouse(false) end
        if header.EnableMouse and header:IsMouseEnabled() then header:EnableMouse(false) end
    end
    bounds = nil
    skinFrame(t, 0)
    updateBack()
end

-- Repli automatique -----------------------------------------------------------------------------

local function isCollapsed(t)
    if t.IsCollapsed then return t:IsCollapsed() end
    return t.isCollapsed or t.collapsed
end

local function setCollapsed(collapse)
    local t = tracker()
    if not t or not t.SetCollapsed then return end
    if collapse then
        if isCollapsed(t) then return end -- déjà replié (par le joueur ou par nous)
        t:SetCollapsed(true)
        autoCollapsed = true
    elseif autoCollapsed then
        autoCollapsed = false
        if isCollapsed(t) then t:SetCollapsed(false) end
    end
end

local function inGroupInstance()
    local inside, kind = _G.IsInInstance()
    return inside and (kind == "party" or kind == "raid")
end

local function updateInstanceCollapse()
    if _G.InCombatLockdown() then return end
    if M.db.replierDonjon and inGroupInstance() then
        setCollapsed(true)
    elseif not (M.db.replierCombat and _G.InCombatLockdown()) then
        setCollapsed(false)
    end
end

-- Lien Wowhead ----------------------------------------------------------------------------------

local linkFrame

local function showLink(id, title)
    if not linkFrame then
        local f = _G.CreateFrame("Frame", "CoeurUILienWowhead", _G.UIParent)
        f:SetSize(440, 150)
        f:SetPoint("CENTER", 0, 120)
        f:SetFrameStrata("DIALOG")
        f:SetToplevel(true)
        f:EnableMouse(true)
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        CUI:CreateBorderedRect(f, 6, C.or_, C.fenetre)
        local logo = f:CreateTexture(nil, "ARTWORK")
        logo:SetTexture(CUI.MEDIA .. "Logo")
        logo:SetSize(16, 16)
        logo:SetPoint("TOPLEFT", 14, -12)
        f.title = CUI:CreateText(f, "normal", "texte")
        f.title:SetPoint("LEFT", logo, "RIGHT", 8, 0)
        f.title:SetPoint("RIGHT", f, "RIGHT", -14, 0)
        f.title:SetWordWrap(false)
        f.label = CUI:CreateText(f, "petit", "texteDiscret")
        f.label:SetPoint("TOPLEFT", 14, -40)
        local box = _G.CreateFrame("EditBox", nil, f)
        box:SetPoint("TOPLEFT", 14, -56)
        box:SetPoint("TOPRIGHT", -14, -56)
        box:SetHeight(26)
        box:SetAutoFocus(false)
        box:SetFontObject(CUI.Fonts.normal)
        box:SetTextInsets(8, 8, 0, 0)
        CUI:CreateBorderedRect(box, 4, C.bordure, C.fond)
        -- Lecture seule : toute frappe remet l'adresse.
        box:SetScript("OnTextChanged", function(self, user)
            if user and self.url then
                self:SetText(self.url)
                self:HighlightText()
            end
        end)
        box:SetScript("OnEscapePressed", function() f:Hide() end)
        box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
        -- Un clic dans l'adresse la garde sélectionnée (plus de bouton « Sélectionner »).
        box:SetScript("OnMouseUp", function(self) self:HighlightText() end)
        f.box = box
        f.hint = CUI:CreateText(f, "petit", "texteSecondaire")
        f.hint:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -8)
        f.close = CUI:CreateButton(f, "")
        f.close:SetPoint("BOTTOMRIGHT", -12, 12)
        f.close:SetScript("OnClick", function() f:Hide() end)
        linkFrame = f
    end
    local f = linkFrame
    f.title:SetText(L.SQ_LIEN_TITRE:format(title or ""))
    f.label:SetText(L.SQ_LIEN_ADRESSE)
    f.hint:SetText(L.SQ_LIEN_AIDE)
    f.close:SetLabel(L.FERMER)
    f.box.url = L.SQ_WOWHEAD_URL:format(id)
    f.box:SetText(f.box.url)
    f:Show()
    f.box:SetFocus()
    f.box:HighlightText()
end

-- Quête du bloc sous la souris : le menu du jeu a pour propriétaire un conteneur, pas la quête.
local function questUnderMouse()
    local foci = _G.GetMouseFoci and _G.GetMouseFoci() or {}
    for _, focus in ipairs(foci) do
        local frame = focus
        while frame and not (frame.IsForbidden and frame:IsForbidden()) do
            local id = rawget(frame, "id")
            if frame.parentModule and type(id) == "number" and not issecret(id) and id > 0 then
                return id
            end
            frame = frame.GetParent and frame:GetParent()
        end
    end
end

local menuHooked = false
local function hookMenu()
    if menuHooked or not (_G.Menu and _G.Menu.ModifyMenu) then return end
    menuHooked = true
    _G.Menu.ModifyMenu("MENU_QUEST_OBJECTIVE_TRACKER", function(_, root)
        if not M.enabled then return end
        local id = questUnderMouse()
        if not id then return end
        local title = _G.C_QuestLog.GetTitleForQuestID and _G.C_QuestLog.GetTitleForQuestID(id)
        if issecret(title) then title = nil end
        if root.QueueDivider then root:QueueDivider() end
        root:CreateButton(L.SQ_WOWHEAD, function() showLink(id, title) end)
    end)
end

-- Construction ----------------------------------------------------------------------------------

local function build()
    if built then return end
    local t = tracker()
    if not t then return end
    built = true
    holder = _G.CreateFrame("Frame", "CoeurUISuiviQuetes", _G.UIParent)
    holder:SetSize(M.db.largeur, M.db.hauteur)
    back = _G.CreateFrame("Frame", nil, _G.UIParent)
    back:SetFrameStrata("BACKGROUND")
    back.fill = back:CreateTexture(nil, "BACKGROUND")
    back.fill:SetTexture(WHITE)
    back.fill:SetAllPoints()
    back:Hide()
    -- Le jeu replace son suivi (mode Édition, mise en page) : on le remet sur notre cadre.
    _G.hooksecurefunc(t, "SetPoint", function()
        if not placing and M.enabled then CUI:AfterCombat(place) end
    end)
    if t.Update then
        _G.hooksecurefunc(t, "Update", function() if M.enabled then CUI:SafeCall(CUI:Tr("SQ_NOM"), skinAll) end end)
    end
    CUI:RegisterMover({ key = "suivi_quetes", frame = holder, label = "SQ_NOM",
                        default = { "TOPRIGHT", "TOPRIGHT", -30, -290 } })
    place()
    applyFonts()
    hookMenu()
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    CUI:AfterCombat(build)
    -- Le suivi se met à jour souvent : on repasse l'habillage régulièrement (léger).
    self:Every(0.5, function() if built then skinAll() end end)
    self:On("PLAYER_REGEN_DISABLED", function()
        -- Dernier moment où l'on peut encore replier le suivi (objets de quête protégés).
        if self.db.replierCombat then setCollapsed(true) end
    end)
    self:On("PLAYER_REGEN_ENABLED", function()
        if self.db.replierCombat and not (self.db.replierDonjon and inGroupInstance()) then
            setCollapsed(false)
        end
    end)
    self:On("PLAYER_ENTERING_WORLD", function() self:After(1, updateInstanceCollapse) end)
    self:On("ZONE_CHANGED_NEW_AREA", function() self:After(1, updateInstanceCollapse) end)
end

-- Coupé : l'habillage reste jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged(key)
    if key == "largeur" or key == "hauteur" then
        CUI:AfterCombat(place)
    elseif key == "tailleTitres" or key == "tailleObjectifs" then
        applyFonts()
    elseif key == "replierDonjon" then
        CUI:AfterCombat(updateInstanceCollapse)
    end
    skinAll()
end

function M:OnFontChanged()
    applyFonts()
end
