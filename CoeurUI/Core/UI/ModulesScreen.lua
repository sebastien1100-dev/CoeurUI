-- Fenêtre principale de CœurUI (maquettes A et C validées). S'ouvre avec /cui.
--   À gauche : « Tous les modules », « Général » (réglages communs à tout CœurUI : la police),
--   puis un tiroir par module ; un tiroir s'ouvre sur ses sous-modules ; tout en bas,
--   « Paramètres » (langue, bouton de minicarte). Ni « Général » ni « Paramètres » ne sont des modules.
--   À droite : l'accueil (une carte par module) ou la page de réglages choisie.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local WIDTH, HEIGHT = 900, 600
local FOOTER = 50                 -- pied de la zone de droite
local SIDE = 220                  -- colonne de gauche
local TOP = 70                    -- en-tête de la zone de droite
local PAD = 20                    -- marge de la zone de droite
local MAIN_W = WIDTH - 2 - SIDE - 1
local CARD_GAP, CARD_H = 6, 72 -- six rangées de cartes tiennent dans la fenêtre sans défiler
local PANEL_W = MAIN_W - PAD * 2  -- largeur des réglages d'une page (une colonne : 400 au plus)
local NAV_H = 32                  -- hauteur d'une ligne de la colonne de gauche

local window, side, sideScroll, main, body
local homeTitle, homeIntro, pageCrumb, pageTitle, pageState, pageSwitch, pageLine, emptyText
local footer, summary, closeButton, reloadButton, defaultsButton
local settingsItem, generalPanel, lookPanel, lockButton, lockLabel, versionText, reloadIcon
local navItems, cards, panels = {}, {}, {}
local paintLock, createLockButton -- plus bas (cadenas)
local keepPage = false -- fermée pour le mode déplacement : rouverte sur la même page
local selected = {}   -- { module = m, sub = s }, { settings = true } ou { general = true } ; vide : l'accueil
local expanded = {}   -- clé du module -> tiroir ouvert

-- Outils ----------------------------------------------------------------------------------

local function solid(parent, layer, sublevel, color)
    local t = parent:CreateTexture(nil, layer, nil, sublevel)
    t:SetTexture("Interface\\Buttons\\WHITE8x8")
    t:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    return t
end

local function setColor(fs, color)
    fs:SetTextColor(color[1], color[2], color[3], 1)
end

-- État d'un module : texte, couleur, infobulle (titre, texte), couleur de la pastille.
local function stateInfo(m)
    local state = CUI:ModuleState(m)
    local running = m.enabled and not m.pendingReload
    if CUI:InCombat() and state ~= "reload" and not m.failed and m:IsWanted() ~= running then
        return L.ECRAN_ETAT_COMBAT, C.texteDiscret, L.INFOBULLE_COMBAT_TITRE, L.INFOBULLE_COMBAT, C.texteDiscret
    elseif state == "reload" then
        return L.ECRAN_ETAT_RELOAD, C.or_, L.INFOBULLE_RELOAD_TITRE, L.INFOBULLE_RELOAD, C.or_
    elseif state == "erreur" then
        return L.ECRAN_ETAT_ERREUR, C.erreur, L.INFOBULLE_ERREUR_TITRE, L.INFOBULLE_ERREUR, C.erreur
    elseif state == "actif" then
        return L.ECRAN_ETAT_ACTIF, C.actif, nil, nil, C.actif
    end
    return L.ECRAN_ETAT_COUPE, C.texteDiscret, nil, nil, C.bordure
end

local function toggleModule(m, checked, switch)
    if CUI.resetPending then
        CUI:Print(L.RESET_ATTENTE)
        switch:SetChecked(m:IsWanted())
        return
    end
    if not CUI:SetModuleEnabled(m, checked) then
        CUI:Print(L.EN_COMBAT)
    end
    CUI:RefreshModulesScreen()
end

-- Ouvre une page (module, sous-module) ou l'accueil (sans argument).
local function openPage(m, sub)
    if m and not sub then
        sub = CUI:GetModuleSubs(m)[1]
    end
    if m and sub then
        expanded[m.key] = true
    end
    local changed = selected.settings or selected.general or selected.module ~= m or selected.sub ~= sub
    selected = { module = m, sub = sub }
    if changed and body then body:ScrollToTop() end
    CUI:RefreshModulesScreen()
end

local function openSettings()
    if not selected.settings and body then body:ScrollToTop() end
    selected = { settings = true }
    CUI:RefreshModulesScreen()
end

local function openGeneral()
    if not selected.general and body then body:ScrollToTop() end
    selected = { general = true }
    CUI:RefreshModulesScreen()
end

-- Clés de chaque page (pour « Valeurs par défaut »).
local SETTINGS_KEYS = { "langue", "boutonMinicarte" }
local GENERAL_KEYS = { "police", "accent", "opaciteFenetre" }

-- Réglages de la page « Général » (valeurs dans CUI.db.general) : communs à tout CœurUI.
local function lookItems()
    return {
        { type = "section", text = "SECTION_POLICE" },
        { type = "dropdown", key = "police", label = "POLICE", description = "POLICE_NOTE",
          options = function() return CUI:FontOptions() end },
        { type = "section", text = "SECTION_ACCENT" },
        { type = "dropdown", key = "accent", label = "ACCENT", description = "ACCENT_NOTE", options = {
            { value = "or", text = "ACCENT_OR" }, { value = "classe", text = "ACCENT_CLASSE" },
        } },
        { type = "section", text = "SECTION_FENETRE" },
        { type = "slider", key = "opaciteFenetre", label = "OPACITE_FENETRE", description = "OPACITE_FENETRE_NOTE",
          min = 20, max = 100, step = 5, format = "%d %%" },
    }
end

-- Réglages de la page « Paramètres » (valeurs dans CUI.db.general).
local function generalItems()
    return {
        { type = "section", text = "SECTION_LANGUE" },
        { type = "dropdown", key = "langue", label = "LANGUE", description = "LANGUE_NOTE", options = function()
            -- « Langue du jeu (...) » puis chaque langue déclarée dans Locales/ (ajoutée toute seule).
            local game = CUI:GetLocaleName(CUI:ResolveLanguage("auto"))
            local list = { { value = "auto", text = L.LANGUE_JEU:format(game) } }
            for _, info in ipairs(CUI:GetLocales()) do
                list[#list + 1] = { value = info.code, text = info.name }
            end
            return list
        end },
        { type = "section", text = "SECTION_MINICARTE" },
        { type = "toggle", key = "boutonMinicarte", label = "BOUTON_MINICARTE", description = "BOUTON_MINICARTE_DESC" },
    }
end

-- Colonne de gauche -----------------------------------------------------------------------

local function createNavItem(parent)
    local b = _G.CreateFrame("Button", nil, parent or sideScroll.child)
    b.bg = CUI:CreateRoundRect(b, 4, C.graphite)
    b.mark = solid(b, "ARTWORK", 0, C.or_) -- trait doré du sous-onglet choisi
    b.mark:SetPoint("TOPLEFT")
    b.mark:SetPoint("BOTTOMLEFT")
    b.mark:SetWidth(3)
    b.chevron = CUI:CreateChevron(b)
    b.chevron:SetPoint(b, "LEFT", 14, 0)
    b.text = CUI:CreateText(b, "normal", "texte")
    b.text:SetJustifyV("MIDDLE")
    b.text:SetWordWrap(false)
    b.dot = b:CreateTexture(nil, "ARTWORK")
    b.dot:SetTexture(CUI.MEDIA .. "Cercle")
    b.dot:SetSize(8, 8)
    b.dot:SetPoint("RIGHT", -8, 0)

    local function paint()
        b.bg:SetShown(b.isSelected or b.hover)
        b.bg:SetColor(b.isSelected and C.graphite or C.graphiteClair)
        local color = b.isSelected and C.or_ or (b.level == 1 and C.texteSecondaire or C.texte)
        setColor(b.text, color)
        if b.icon then
            b.icon:SetVertexColor(color[1], color[2], color[3], 1)
        end
    end
    b.paint = paint
    b:SetScript("OnEnter", function() b.hover = true; paint() end)
    b:SetScript("OnLeave", function() b.hover = false; paint() end)
    b:SetScript("OnClick", function() if b.onClick then b.onClick() end end)
    return b
end

-- Remplit la colonne de gauche ; une ligne par entrée visible.
local function refreshSide()
    local entries = {}
    entries[1] = { kind = "home" }
    entries[2] = { kind = "general" }
    for _, m in ipairs(CUI:GetModules()) do
        local subs = CUI:GetModuleSubs(m)
        entries[#entries + 1] = { kind = "module", module = m, subs = subs }
        if #subs > 0 and expanded[m.key] then
            for _, sub in ipairs(subs) do
                entries[#entries + 1] = { kind = "sub", module = m, sub = sub }
            end
        end
    end

    local y = 0
    for i, e in ipairs(entries) do
        local b = navItems[i] or createNavItem()
        navItems[i] = b
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", 0, -y)
        b:SetPoint("RIGHT", sideScroll.child, "RIGHT", 0, 0)
        b.mark:Hide()
        b.dot:Hide()
        b.chevron:SetColor(C.texteDiscret)
        for _, t in ipairs(b.chevron.lines) do t:Hide() end
        b.text:ClearAllPoints()

        if e.kind == "home" then
            b.level = 0
            b:SetHeight(32)
            b.text:SetText(L.TOUS_LES_MODULES)
            b.text:SetPoint("LEFT", 10, 0)
            b.text:SetPoint("RIGHT", -10, 0)
            b.isSelected = selected.module == nil and not selected.settings and not selected.general
            b.onClick = function() openPage() end
        elseif e.kind == "general" then
            b.level = 0
            b:SetHeight(32)
            b.text:SetText(L.GENERAL)
            b.text:SetPoint("LEFT", 26, 0)
            b.text:SetPoint("RIGHT", -10, 0)
            b.isSelected = selected.general or false
            b.onClick = openGeneral
        elseif e.kind == "module" then
            local m = e.module
            b.level = 0
            b:SetHeight(32)
            b.text:SetText(CUI:Tr(m.name))
            b.text:SetPoint("LEFT", 26, 0)
            b.text:SetPoint("RIGHT", -22, 0)
            local _, _, _, _, dotColor = stateInfo(m)
            b.dot:SetVertexColor(dotColor[1], dotColor[2], dotColor[3], 1)
            b.dot:Show()
            if #e.subs > 0 then
                for _, t in ipairs(b.chevron.lines) do t:Show() end
                b.chevron:SetDirection(expanded[m.key] and "down" or "right")
                b.isSelected = false
                b.onClick = function()
                    expanded[m.key] = not expanded[m.key]
                    if expanded[m.key] and selected.module ~= m then
                        openPage(m)
                    else
                        CUI:RefreshModulesScreen()
                    end
                end
            else
                b.isSelected = selected.module == m
                b.onClick = function() openPage(m) end
            end
        else
            b.level = 1
            b:SetHeight(28)
            b.text:SetText(CUI:Tr(e.sub.name))
            b.text:SetPoint("LEFT", 30, 0)
            b.text:SetPoint("RIGHT", -10, 0)
            b.isSelected = selected.module == e.module and selected.sub == e.sub
            b.mark:SetShown(b.isSelected)
            b.onClick = function() openPage(e.module, e.sub) end
        end
        b.paint()
        b:Show()
        y = y + b:GetHeight() + 2
        if e.kind == "home" then
            y = y + 12 -- place pour le trait de séparation
        end
    end
    for i = #entries + 1, #navItems do
        navItems[i]:Hide()
    end
    sideScroll:SetContentHeight(y)
end

-- Accueil : une carte par module ----------------------------------------------------------

local function createCard()
    local card = _G.CreateFrame("Frame", nil, body.child)
    card:SetSize(math.floor((MAIN_W - PAD * 2 - CARD_GAP) / 2), CARD_H)
    card.panel = CUI:CreatePanel(card, { shadow = false, fill = C.carte })
    card.border, card.fill = card.panel.border, card.panel.fill
    card.switch = CUI:CreateSwitch(card, function(switch, checked)
        toggleModule(card.module, checked, switch)
    end)
    card.switch:SetPoint("TOPRIGHT", -10, -7)
    card.name = CUI:CreateText(card, "normal", "texte")
    card.name:SetPoint("TOPLEFT", 12, -12)
    card.name:SetPoint("RIGHT", card.switch, "LEFT", -10, 0)
    card.name:SetWordWrap(false)
    card.state = CUI:CreateText(card, "petit", "texteDiscret")
    card.state:SetJustifyH("RIGHT")
    card.state:SetPoint("RIGHT", card.switch, "LEFT", -10, 0)
    card.desc = CUI:CreateText(card, "petit", "texteDiscret")
    card.desc:SetPoint("TOPLEFT", 12, -34)
    card.desc:SetPoint("RIGHT", -12, 0)
    card.desc:SetWordWrap(true)
    card.desc:SetMaxLines(2)
    -- Clic sur la carte (ailleurs que sur l'interrupteur) : la page de réglages du module, s'il en a.
    -- Survol : liseré plus clair, pour montrer qu'elle s'ouvre.
    card:EnableMouse(true)
    card:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.hasSettings and self:IsMouseOver() then openPage(self.module) end
    end)
    card:SetScript("OnEnter", function(self)
        if self.hasSettings then self.border:SetColor(C.bordure) end
    end)
    card:SetScript("OnLeave", function(self)
        self.border:SetColor(C.lisereSombre)
    end)
    return card
end

local function refreshHome()
    local list = CUI:GetModules()
    local y = 0
    for i, m in ipairs(list) do
        local card = cards[i] or createCard()
        cards[i] = card
        card.module = m
        local wanted = m:IsWanted()
        card.switch:SetChecked(wanted)
        card.border:SetColor(C.lisereSombre)
        card.panel:SetFillColor(wanted and C.ligne or C.carte)
        card.name:SetText(CUI:Tr(m.name))
        card.desc:SetText(CUI:Tr(m.description))
        card.hasSettings = CUI:HasModuleSettings(m)

        -- État écrit seulement quand il y a quelque chose à signaler.
        local text, color = stateInfo(m)
        local special = text ~= L.ECRAN_ETAT_ACTIF and text ~= L.ECRAN_ETAT_COUPE
        card.state:SetShown(special)
        card.name:SetPoint("RIGHT", special and card.state or card.switch, "LEFT", -10, 0)
        if special then
            card.state:SetText(text)
            setColor(card.state, color)
        end

        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", PAD + col * (card:GetWidth() + CARD_GAP), -(row * (CARD_H + CARD_GAP)))
        card:Show()
        y = (row + 1) * (CARD_H + CARD_GAP)
    end
    for i = #list + 1, #cards do
        cards[i]:Hide()
    end
    emptyText:SetShown(#list == 0)
    return y + 8
end

-- Page d'un module ou sous-module ---------------------------------------------------------

local function refreshPage(m, sub)
    for _, p in pairs(panels) do
        p:Hide()
    end
    local height = 0
    if #CUI:GetPageSettings(m, sub) > 0 then
        local key = m.key .. "/" .. (sub and sub.key or "")
        local panel = panels[key]
        if not panel then
            panel = CUI:BuildSettingsPanel(body.child, m, PANEL_W, sub)
            panel:SetPoint("TOPLEFT", PAD, -4)
            panels[key] = panel
        end
        panel:Refresh()
        panel:Show()
        emptyText:Hide()
        height = panel:GetHeight() + 24
    else
        emptyText:SetText(L.AUCUN_REGLAGE)
        emptyText:Show()
        height = 40
    end

    local text, color, tipTitle, tipText = stateInfo(m)
    pageState:SetText(text)
    setColor(pageState, color)
    pageState.tipTitle, pageState.tipText = tipTitle, tipText
    pageSwitch:SetChecked(m:IsWanted())
    return height
end

-- Cadenas de la barre de titre : déverrouiller les cadres (mode déplacement, Movers.lua) -------

local function lockTooltip()
    if CUI:InCombat() then
        return L.DEVERROUILLER_CADRES, L.INFOBULLE_CADENAS_COMBAT
    elseif not CUI:HasMovers() then
        return L.DEVERROUILLER_CADRES, L.INFOBULLE_CADENAS_AUCUN
    elseif CUI:AreMoversUnlocked() then
        return L.VERROUILLER_CADRES, L.INFOBULLE_CADENAS
    end
    return L.DEVERROUILLER_CADRES, L.INFOBULLE_CADENAS
end

paintLock = function()
    if not lockButton then return end
    local open = CUI:AreMoversUnlocked()
    local usable = not CUI:InCombat() and CUI:HasMovers()
    lockButton.icon:SetTexture(CUI.MEDIA .. (open and "CadenasOuvert" or "Cadenas"))
    local color = open and C.or_ or (not usable and C.bordure or (lockButton.hover and C.texte or C.texteDiscret))
    lockButton.icon:SetVertexColor(color[1], color[2], color[3], 1)
    lockButton.border:SetShown(open)
    lockButton.fill:SetShown(open)
    lockButton.hoverBg:SetShown(lockButton.hover and not open and usable)
    lockLabel:SetShown(open)
    lockLabel:SetText(L.CADRES_DEVERROUILLES)
end

createLockButton = function()
    lockButton = _G.CreateFrame("Button", nil, window.header)
    lockButton:SetSize(28, 28)
    lockButton:SetPoint("RIGHT", window.closeButton, "LEFT", -4, 0)
    lockButton.hoverBg = CUI:CreateRoundRect(lockButton, 4, C.graphiteClair)
    lockButton.border, lockButton.fill = CUI:CreateBorderedRect(lockButton, 4, C.or_, C.railActif, "BACKGROUND", 1)
    lockButton.icon = lockButton:CreateTexture(nil, "ARTWORK")
    lockButton.icon:SetSize(16, 16)
    lockButton.icon:SetPoint("CENTER")

    -- Recharger l'interface : icône à gauche du cadenas. Le clic est reçu par un bouton protégé
    -- posé dessus (ReloadButton.lua) ; en combat, l'icône est grisée.
    reloadIcon = _G.CreateFrame("Button", nil, window.header)
    reloadIcon:SetSize(28, 28)
    reloadIcon:SetPoint("RIGHT", lockButton, "LEFT", -2, 0)
    reloadIcon.hoverBg = CUI:CreateRoundRect(reloadIcon, 4, C.graphiteClair)
    reloadIcon.icon = reloadIcon:CreateTexture(nil, "ARTWORK")
    reloadIcon.icon:SetTexture(CUI.MEDIA .. "Icones\\Recharger")
    reloadIcon.icon:SetSize(16, 16)
    reloadIcon.icon:SetPoint("CENTER")
    local function paintReload()
        local usable = reloadIcon:IsEnabled()
        local color = not usable and C.bordure or (reloadIcon.hover and C.texte or C.texteDiscret)
        reloadIcon.icon:SetVertexColor(color[1], color[2], color[3], 1)
        reloadIcon.hoverBg:SetShown(reloadIcon.hover and usable)
    end
    function reloadIcon:SetVisualState(hover, pressed)
        self.hover, self.pressed = hover and true or false, pressed and true or false
        paintReload()
    end
    reloadIcon:SetScript("OnEnter", function(self) self:SetVisualState(true, false) end)
    reloadIcon:SetScript("OnLeave", function(self) self:SetVisualState(false, false) end)
    reloadIcon:SetScript("OnEnable", paintReload)
    reloadIcon:SetScript("OnDisable", paintReload)
    CUI:AttachReload(reloadIcon)
    paintReload()

    -- Version de CœurUI, discrète, pour savoir laquelle tourne.
    versionText = CUI:CreateText(window.header, "petit", "texteDiscret")
    versionText:SetJustifyV("MIDDLE")
    versionText:SetPoint("RIGHT", reloadIcon, "LEFT", -8, 0)
    versionText:SetText("v" .. CUI.version)
    lockLabel = CUI:CreateText(window.header, "petit", "or_")
    lockLabel:SetJustifyV("MIDDLE")
    lockLabel:SetPoint("RIGHT", versionText, "LEFT", -10, 0)

    lockButton:SetScript("OnClick", function()
        CUI:SetMoversUnlocked(not CUI:AreMoversUnlocked())
        paintLock()
    end)
    lockButton:SetScript("OnEnter", function(self)
        self.hover = true
        paintLock()
        CUI:ShowTooltip(self, lockTooltip())
    end)
    lockButton:SetScript("OnLeave", function(self)
        self.hover = false
        paintLock()
        CUI:HideTooltip(self)
    end)
    paintLock()
end

-- Fenêtre ---------------------------------------------------------------------------------

local function createWindow()
    window = CUI:CreateWindow("Modules", L.ECRAN_MODULES_TITRE, WIDTH)
    window:SetHeight(HEIGHT)
    createLockButton()
    local content = window.content

    -- Colonne de gauche : fond sombre, coin bas gauche arrondi comme la fenêtre.
    side = _G.CreateFrame("Frame", nil, content)
    side:SetPoint("TOPLEFT")
    side:SetPoint("BOTTOMLEFT")
    side:SetWidth(SIDE)
    local sideRound = CUI:CreateRoundRect(side, 5, C.colonne)
    local squareTop = solid(side, "BACKGROUND", 1, C.colonne)
    squareTop:SetPoint("TOPLEFT")
    squareTop:SetPoint("TOPRIGHT")
    squareTop:SetHeight(8)
    local squareRight = solid(side, "BACKGROUND", 1, C.colonne)
    squareRight:SetPoint("TOPRIGHT")
    squareRight:SetPoint("BOTTOMRIGHT")
    squareRight:SetWidth(8)
    -- Opacité du fond de la fenêtre (« Général ») : la colonne suit.
    window.onOpacity = function(a)
        local c = C.colonne
        sideRound:SetColor({ c[1], c[2], c[3], a })
        squareTop:SetVertexColor(c[1], c[2], c[3], a)
        squareRight:SetVertexColor(c[1], c[2], c[3], a)
    end
    local sideLine = solid(content, "ARTWORK", 0, C.lisereSombre)
    sideLine:SetPoint("TOPLEFT", side, "TOPRIGHT")
    sideLine:SetPoint("BOTTOMLEFT", side, "BOTTOMRIGHT")
    sideLine:SetWidth(1)

    -- « Paramètres », fixé en bas de la colonne, sous un trait.
    settingsItem = createNavItem(side)
    settingsItem:SetPoint("BOTTOMLEFT", 8, 10)
    settingsItem:SetPoint("BOTTOMRIGHT", -8, 10)
    settingsItem:SetHeight(NAV_H)
    settingsItem.level = 0
    for _, t in ipairs(settingsItem.chevron.lines) do t:Hide() end
    settingsItem.dot:Hide() -- pas un module : pas de pastille d'état
    settingsItem.mark:Hide() -- le trait doré est réservé aux sous-onglets
    settingsItem.icon =settingsItem:CreateTexture(nil, "ARTWORK")
    settingsItem.icon:SetTexture(CUI.MEDIA .. "Engrenage")
    settingsItem.icon:SetSize(14, 14)
    settingsItem.icon:SetPoint("LEFT", 10, 0)
    settingsItem.text:SetPoint("LEFT", 30, 0)
    settingsItem.text:SetPoint("RIGHT", -10, 0)
    settingsItem.text:SetText(L.PARAMETRES)
    settingsItem.onClick = openSettings
    local sepBottom = solid(side, "ARTWORK", 0, C.graphite)
    sepBottom:SetPoint("BOTTOMLEFT", 12, 10 + NAV_H + 6)
    sepBottom:SetPoint("BOTTOMRIGHT", -12, 10 + NAV_H + 6)
    sepBottom:SetHeight(1)

    sideScroll = CUI:CreateScrollArea(side)
    sideScroll:SetPoint("TOPLEFT", 8, -10)
    sideScroll:SetPoint("BOTTOMRIGHT", -8, 10 + NAV_H + 13)
    local sep = solid(sideScroll.child, "ARTWORK", 0, C.graphite) -- sous « Tous les modules »
    sep:SetPoint("TOPLEFT", 4, -39)
    sep:SetPoint("TOPRIGHT", -4, -39)
    sep:SetHeight(1)

    -- Zone de droite.
    main = _G.CreateFrame("Frame", nil, content)
    main:SetPoint("TOPLEFT", side, "TOPRIGHT", 1, 0)
    main:SetPoint("BOTTOMRIGHT")

    homeTitle = CUI:CreateText(main, "grand", "texte")
    homeTitle:SetPoint("TOPLEFT", PAD, -18)
    homeTitle:SetText(L.TOUS_LES_MODULES)
    homeIntro = CUI:CreateText(main, "petit", "texteDiscret")
    homeIntro:SetPoint("TOPLEFT", homeTitle, "BOTTOMLEFT", 0, -6)
    homeIntro:SetWidth(MAIN_W - PAD * 2)
    homeIntro:SetText(L.ECRAN_MODULES_INTRO)

    pageCrumb = CUI:CreateText(main, "petit", "texteDiscret")
    pageCrumb:SetPoint("TOPLEFT", PAD, -16)
    pageTitle = CUI:CreateText(main, "grand", "texte")
    pageSwitch = CUI:CreateSwitch(main, function(switch, checked)
        toggleModule(selected.module, checked, switch)
    end)
    pageSwitch:SetPoint("TOPRIGHT", -PAD, -23)
    local stateHit = _G.CreateFrame("Frame", nil, main)
    stateHit:SetPoint("RIGHT", pageSwitch, "LEFT", -10, 0)
    stateHit:SetSize(160, 20)
    stateHit:EnableMouse(true)
    pageState = CUI:CreateText(stateHit, "petit", "texteDiscret")
    pageState:SetJustifyH("RIGHT")
    pageState:SetJustifyV("MIDDLE")
    pageState:SetAllPoints()
    CUI:AttachTooltip(stateHit, function() return pageState.tipTitle, pageState.tipText end)
    pageLine = solid(main, "ARTWORK", 0, C.graphite)
    pageLine:SetPoint("TOPLEFT", 0, -TOP)
    pageLine:SetPoint("TOPRIGHT", 0, -TOP)
    pageLine:SetHeight(1)

    footer = _G.CreateFrame("Frame", nil, main)
    footer:SetPoint("BOTTOMLEFT")
    footer:SetPoint("BOTTOMRIGHT")
    footer:SetHeight(FOOTER)
    local footerLine = solid(footer, "ARTWORK", 0, C.graphite)
    footerLine:SetPoint("TOPLEFT")
    footerLine:SetPoint("TOPRIGHT")
    footerLine:SetHeight(1)

    body = CUI:CreateScrollArea(main)
    body:SetPoint("TOPLEFT", 0, -TOP - 14)
    body:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT", 0, 6)
    emptyText = CUI:CreateText(body.child, "normal", "texteDiscret")
    emptyText:SetPoint("TOPLEFT", PAD, -4)

    closeButton = CUI:CreateButton(footer, L.FERMER)
    closeButton:SetPoint("RIGHT", -12, 0)
    closeButton:SetScript("OnClick", function() window:Hide() end)
    reloadButton = CUI:CreateReloadButton(footer)
    reloadButton:Hide()
    defaultsButton = CUI:CreateButton(footer, L.VALEURS_DEFAUT)
    defaultsButton:SetScript("OnClick", function()
        if selected.settings then
            CUI:ResetGeneral(SETTINGS_KEYS)
        elseif selected.general then
            CUI:ResetGeneral(GENERAL_KEYS)
        elseif selected.module then
            CUI:ResetModuleSettings(selected.module, selected.sub)
        end
        CUI:RefreshModulesScreen()
    end)
    summary = CUI:CreateText(footer, "petit", "texteDiscret")
    summary:SetJustifyV("MIDDLE")

    window:HookScript("OnShow", function() CUI:RefreshModulesScreen() end)
    -- On rouvre sur l'accueil, sauf après le mode déplacement (même page qu'avant).
    window:HookScript("OnHide", function()
        if not keepPage then selected = {} end
        keepPage = false
    end)
end

local function plural(forms, n)
    return (n > 1 and forms[2] or forms[1]):format(n)
end

-- Pied : de droite à gauche, Fermer, Recharger (si besoin), Valeurs par défaut (page).
local function layoutFooter(waitReload, withDefaults, summaryText)
    local anchor = closeButton
    -- Le bouton visible n'est pas protégé : on peut le montrer ou le cacher même en combat.
    -- Le bouton protégé qui le recouvre suit tout seul, hors combat.
    reloadButton:SetShown(waitReload)
    if waitReload then
        reloadButton:ClearAllPoints()
        reloadButton:SetPoint("RIGHT", anchor, "LEFT", -8, 0)
        anchor = reloadButton
    end
    defaultsButton:SetShown(withDefaults)
    if withDefaults then
        defaultsButton:ClearAllPoints()
        defaultsButton:SetPoint("RIGHT", anchor, "LEFT", -8, 0)
        anchor = defaultsButton
    end
    summary:SetText(summaryText or "")
    summary:ClearAllPoints()
    summary:SetPoint("LEFT", PAD, 0)
    summary:SetPoint("RIGHT", anchor, "LEFT", -12, 0)
end

function CUI:RefreshModulesScreen()
    if not window or not window:IsShown() then return end

    local list = self:GetModules()
    local active, waitReload = 0, self:LanguagePending() or self:AccentPending()
    for _, m in ipairs(list) do
        if m.enabled and not m.pendingReload then active = active + 1 end
        if m.pendingReload then waitReload = true end
    end

    refreshSide()
    paintLock()
    settingsItem.isSelected = selected.settings or false
    settingsItem.paint()

    local m, sub = selected.module, selected.sub
    local settings = selected.settings
    local general = selected.general
    local home = m == nil and not settings and not general
    -- En-tête : titre + texte (accueil, Paramètres) ou fil + titre + état (page d'un module).
    homeTitle:SetShown(m == nil)
    homeIntro:SetShown(m == nil)
    pageCrumb:SetShown(m ~= nil)
    pageTitle:SetShown(m ~= nil)
    pageSwitch:SetShown(m ~= nil)
    pageState:GetParent():SetShown(m ~= nil)
    pageLine:SetShown(not home)
    for _, card in ipairs(cards) do
        card:SetShown(home)
    end
    for _, p in pairs(panels) do
        p:Hide()
    end
    if generalPanel then
        generalPanel:SetShown(settings or false)
    end
    if lookPanel then
        lookPanel:SetShown(general or false)
    end

    local height
    if home then
        window:SetTitle(L.ECRAN_MODULES_TITRE)
        homeTitle:SetText(L.TOUS_LES_MODULES)
        homeIntro:SetText(L.ECRAN_MODULES_INTRO)
        emptyText:SetText(L.MODULES_AUCUN_ECRAN)
        height = refreshHome()
        layoutFooter(waitReload, false, plural(L.N_MODULES, #list) .. " · " .. plural(L.N_ACTIFS, active))
    elseif settings then
        window:SetTitle(L.PARAMETRES)
        homeTitle:SetText(L.PARAMETRES)
        homeIntro:SetText(L.PARAMETRES_INTRO)
        emptyText:Hide()
        if not generalPanel then
            generalPanel = self:CreateSettingsPanel(body.child, generalItems(), PANEL_W, nil,
                function(item) return CUI:GetGeneral(item.key) end,
                function(item, value)
                    CUI:SetGeneral(item.key, value)
                    CUI:RefreshModulesScreen() -- langue changée : bouton « Recharger l'interface »
                end)
            generalPanel:SetPoint("TOPLEFT", PAD, -4)
        end
        generalPanel:Refresh()
        generalPanel:Show()
        height = generalPanel:GetHeight() + 24
        layoutFooter(waitReload, true, nil)
    elseif general then
        window:SetTitle(L.GENERAL)
        homeTitle:SetText(L.GENERAL)
        homeIntro:SetText(L.GENERAL_INTRO)
        emptyText:Hide()
        if not lookPanel then
            lookPanel = self:CreateSettingsPanel(body.child, lookItems(), PANEL_W, nil,
                function(item) return CUI:GetGeneral(item.key) end,
                function(item, value)
                    CUI:SetGeneral(item.key, value)
                    if item.key == "opaciteFenetre" then
                        CUI:ApplyWindowOpacity()
                        return
                    end
                    CUI:RefreshModulesScreen() -- couleur changée : bouton « Recharger l'interface »
                end)
            lookPanel:SetPoint("TOPLEFT", PAD, -4)
        end
        lookPanel:Refresh()
        lookPanel:Show()
        height = lookPanel:GetHeight() + 24
        layoutFooter(waitReload, true, nil)
    else
        local name = self:Tr(m.name)
        window:SetTitle(name)
        -- Fil : le module au-dessus du titre du sous-module.
        pageCrumb:SetText(sub and name or L.MODULE)
        pageTitle:ClearAllPoints()
        pageTitle:SetPoint("TOPLEFT", pageCrumb, "BOTTOMLEFT", 0, -4)
        pageTitle:SetText(sub and self:Tr(sub.name) or name)
        height = refreshPage(m, sub)
        layoutFooter(waitReload, #self:GetPageSettings(m, sub) > 0, nil)
    end
    body:SetContentHeight(height)
end

-- Combat : la fenêtre se cache (en gardant sa page) et revient à la fin du combat. Ouverte pendant
-- un combat (/cui, bouton de minicarte...) : elle s'ouvrira à la fin du combat.
local inCombat = false
local reopenAfterCombat = false

local function openLater()
    if not reopenAfterCombat then CUI:Print(L.FENETRE_APRES_COMBAT) end
    reopenAfterCombat = true
end

function CUI:ToggleModulesScreen()
    if inCombat then
        if reopenAfterCombat then
            reopenAfterCombat = false -- deuxième appui : on n'ouvre plus
        else
            openLater()
        end
        return
    end
    if not window then createWindow() end
    window:SetShown(not window:IsShown())
end

-- Mode déplacement : la fenêtre se cache (en gardant sa page) puis revient au verrouillage.
function CUI:IsModulesScreenShown()
    return window ~= nil and window:IsShown()
end

function CUI:SetModulesScreenShown(shown, samePage)
    if shown and inCombat then
        reopenAfterCombat = true
        return
    end
    if not window then
        if not shown then return end
        createWindow()
    end
    if not shown and samePage then keepPage = true end
    window:SetShown(shown)
end

-- Rafraîchit la fenêtre quand un module change d'état (commande /cui, sortie de combat...).
function CUI:OnModulesChanged()
    self:RefreshModulesScreen()
end

-- Le cadenas se grise en combat et revient après.
CUI:On("PLAYER_REGEN_DISABLED", "core:cadenas", function()
    paintLock()
    inCombat = true
    if window and window:IsShown() then
        reopenAfterCombat = true
        keepPage = true
        window:Hide()
    end
end)
CUI:On("PLAYER_REGEN_ENABLED", "core:cadenas", function()
    inCombat = false
    paintLock()
    if reopenAfterCombat then
        reopenAfterCombat = false
        CUI:SetModulesScreenShown(true)
    end
end)
