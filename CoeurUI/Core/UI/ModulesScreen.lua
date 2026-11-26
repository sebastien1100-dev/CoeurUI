-- Écran « Modules » : activer ou couper chaque module, et ouvrir le panneau de réglages d'un
-- module (même fenêtre, retour par « « Modules »). S'ouvre avec /cui.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local WIDTH = 560
local INNER = WIDTH - 2       -- largeur intérieure (sans le contour)
local HEADER = 40             -- barre de titre (voir Window.lua)
local FOOTER = 50
local PAD = 8                 -- marge de la liste
local SWITCH_X = 8            -- interrupteur, depuis le bord de la ligne
local TEXT_X = SWITCH_X + 44 + 14
local ROW_GAP = 2
local SUBBAR = 46             -- barre « « Modules » du panneau
local PANEL_PAD = 20

local window, listView, panelView, intro, emptyText
local footer, summary, closeButton, reloadButton, defaultsButton
local backButton, panelState, panelSwitch
local rows = {}
local panels = {}   -- clé du module -> contenu de son panneau
local current       -- module dont le panneau est ouvert (nil : la liste)

-- État affiché d'un module : texte, couleur, infobulle (titre, texte).
local function stateInfo(m)
    local state = CUI:ModuleState(m)
    local running = m.enabled and not m.pendingReload
    if CUI:InCombat() and state ~= "reload" and not m.failed and m:IsWanted() ~= running then
        return L.ECRAN_ETAT_COMBAT, C.texteDiscret, L.INFOBULLE_COMBAT_TITRE, L.INFOBULLE_COMBAT
    elseif state == "reload" then
        return L.ECRAN_ETAT_RELOAD, C.or_, L.INFOBULLE_RELOAD_TITRE, L.INFOBULLE_RELOAD
    elseif state == "erreur" then
        return L.ECRAN_ETAT_ERREUR, C.erreur, L.INFOBULLE_ERREUR_TITRE, L.INFOBULLE_ERREUR
    elseif state == "actif" then
        return L.ECRAN_ETAT_ACTIF, C.actif
    end
    return L.ECRAN_ETAT_COUPE, C.texteDiscret
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

local function showPanel(m)
    current = m
    CUI:RefreshModulesScreen()
end

local function showList()
    current = nil
    CUI:RefreshModulesScreen()
end

local function textWidth(fs)
    return fs.GetUnboundedStringWidth and fs:GetUnboundedStringWidth() or fs:GetStringWidth()
end

-- Liste ------------------------------------------------------------------------------------

local function createRow()
    local row = _G.CreateFrame("Frame", nil, listView)
    row.bg = CUI:CreateRoundRect(row, 4, C.ligne)

    row.switch = CUI:CreateSwitch(row, function(switch, checked)
        toggleModule(row.module, checked, switch)
    end)
    row.switch:SetPoint("LEFT", SWITCH_X, 0)

    row.name = CUI:CreateText(row, "normal", "texte")
    row.name:SetPoint("TOPLEFT", TEXT_X, -10)

    row.desc = CUI:CreateText(row, "petit", "texteDiscret")
    row.desc:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -4)
    row.desc:SetWordWrap(true)

    -- L'état, à droite, avec une infobulle quand il y a quelque chose à expliquer.
    row.stateHit = _G.CreateFrame("Frame", nil, row)
    row.stateHit:SetPoint("RIGHT", -10, 0)
    row.stateHit:SetHeight(20)
    row.stateHit:EnableMouse(true)
    row.state = CUI:CreateText(row.stateHit, "petit", "texteDiscret")
    row.state:SetJustifyH("RIGHT")
    row.state:SetJustifyV("MIDDLE")
    row.state:SetAllPoints()
    CUI:AttachTooltip(row.stateHit, function(hit)
        return hit.tipTitle, hit.tipText
    end)

    -- « Réglages », seulement pour un module qui en a.
    row.settingsButton = CUI:CreateButton(row, L.REGLAGES, false, true)
    row.settingsButton:SetPoint("RIGHT", row.stateHit, "LEFT", -12, 0)
    row.settingsButton:SetScript("OnClick", function() showPanel(row.module) end)
    return row
end

local function fillRow(row, m, rowWidth)
    row.module = m
    row.switch:SetChecked(m:IsWanted())
    row.bg:SetShown(m:IsWanted())
    row.name:SetText(m.name)

    local text, color, tipTitle, tipText = stateInfo(m)
    row.state:SetText(text)
    row.state:SetTextColor(color[1], color[2], color[3], 1)
    row.stateHit.tipTitle, row.stateHit.tipText = tipTitle, tipText
    local stateWidth = math.max(40, math.ceil(textWidth(row.state)))
    row.stateHit:SetWidth(stateWidth)

    local right = 10 + stateWidth
    local hasSettings = CUI:HasModuleSettings(m)
    row.settingsButton:SetShown(hasSettings)
    if hasSettings then
        right = right + 12 + row.settingsButton:GetWidth()
    end
    local width = rowWidth - TEXT_X - right - 14
    row.name:SetWidth(width)
    row.desc:SetWidth(width)
    row.desc:SetText(m.description)

    local height = 10 + row.name:GetStringHeight() + 4 + row.desc:GetStringHeight() + 10
    row:SetHeight(math.max(44, math.ceil(height)))
end

-- Remplit la liste ; renvoie sa hauteur.
local function refreshList()
    local list = CUI:GetModules()
    local rowWidth = INNER - PAD * 2
    local y = -12 - intro:GetStringHeight() - 10
    for i, m in ipairs(list) do
        local row = rows[i] or createRow()
        rows[i] = row
        row:SetWidth(rowWidth)
        fillRow(row, m, rowWidth)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", PAD, y)
        row:Show()
        y = y - row:GetHeight() - ROW_GAP
    end
    for i = #list + 1, #rows do
        rows[i]:Hide()
    end

    emptyText:SetShown(#list == 0)
    if #list == 0 then
        emptyText:ClearAllPoints()
        emptyText:SetPoint("TOPLEFT", 16, y - 4)
        y = y - 24
    end
    return -y + 6
end

-- Panneau ----------------------------------------------------------------------------------

-- Remplit le panneau du module ouvert ; renvoie sa hauteur.
local function refreshPanel(m)
    local panel = panels[m.key]
    if not panel then
        panel = CUI:BuildSettingsPanel(panelView, m, INNER - PANEL_PAD * 2)
        panel:SetPoint("TOPLEFT", PANEL_PAD, -SUBBAR - 16)
        panels[m.key] = panel
    end
    for key, p in pairs(panels) do
        p:SetShown(key == m.key)
    end
    panel:Refresh()

    panelSwitch:SetChecked(m:IsWanted())
    local text, color = stateInfo(m)
    panelState:SetText(text)
    panelState:SetTextColor(color[1], color[2], color[3], 1)
    return SUBBAR + 16 + panel:GetHeight() + 18
end

-- Fenêtre ----------------------------------------------------------------------------------

local function createWindow()
    window = CUI:CreateWindow("Modules", L.ECRAN_MODULES_TITRE, WIDTH)
    local content = window.content

    -- Vue « liste ».
    listView = _G.CreateFrame("Frame", nil, content)
    listView:SetPoint("TOPLEFT")
    listView:SetPoint("TOPRIGHT")
    intro = CUI:CreateText(listView, "petit", "texteDiscret")
    intro:SetPoint("TOPLEFT", 16, -12)
    intro:SetWidth(INNER - 32)
    intro:SetWordWrap(true)
    intro:SetText(L.ECRAN_MODULES_INTRO)
    emptyText = CUI:CreateText(listView, "normal", "texteDiscret")
    emptyText:SetText(L.MODULES_AUCUN_ECRAN)

    -- Vue « panneau ».
    panelView = _G.CreateFrame("Frame", nil, content)
    panelView:SetPoint("TOPLEFT")
    panelView:SetPoint("TOPRIGHT")
    backButton = CUI:CreateLinkButton(panelView, L.RETOUR_MODULES)
    backButton:SetPoint("TOPLEFT", 10, -10)
    backButton:SetScript("OnClick", showList)
    panelSwitch = CUI:CreateSwitch(panelView, function(switch, checked)
        toggleModule(current, checked, switch)
    end)
    panelSwitch:SetPoint("TOPRIGHT", -12, -11)
    panelState = CUI:CreateText(panelView, "petit", "texteDiscret")
    panelState:SetJustifyV("MIDDLE")
    panelState:SetPoint("RIGHT", panelSwitch, "LEFT", -10, 0)
    local line = panelView:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\Buttons\\WHITE8x8")
    line:SetVertexColor(unpack(C.graphite))
    line:SetPoint("TOPLEFT", 0, -SUBBAR)
    line:SetPoint("TOPRIGHT", 0, -SUBBAR)
    line:SetHeight(1)

    -- Pied commun aux deux vues.
    footer = _G.CreateFrame("Frame", nil, content)
    footer:SetPoint("BOTTOMLEFT")
    footer:SetPoint("BOTTOMRIGHT")
    footer:SetHeight(FOOTER)
    local footerLine = footer:CreateTexture(nil, "ARTWORK")
    footerLine:SetTexture("Interface\\Buttons\\WHITE8x8")
    footerLine:SetVertexColor(unpack(C.graphite))
    footerLine:SetPoint("TOPLEFT")
    footerLine:SetPoint("TOPRIGHT")
    footerLine:SetHeight(1)

    closeButton = CUI:CreateButton(footer, L.FERMER)
    closeButton:SetPoint("RIGHT", -12, 0)
    closeButton:SetScript("OnClick", function() window:Hide() end)

    reloadButton = CUI:CreateReloadButton(footer)
    reloadButton:Hide()

    defaultsButton = CUI:CreateButton(footer, L.VALEURS_DEFAUT)
    defaultsButton:SetScript("OnClick", function()
        if current then
            CUI:ResetModuleSettings(current)
            CUI:RefreshModulesScreen()
        end
    end)

    summary = CUI:CreateText(footer, "petit", "texteDiscret")
    summary:SetJustifyV("MIDDLE")

    window:HookScript("OnShow", function() CUI:RefreshModulesScreen() end)
    window:HookScript("OnHide", function() current = nil end) -- on rouvre sur la liste
end

local function plural(forms, n)
    return (n > 1 and forms[2] or forms[1]):format(n)
end

-- Pied : de droite à gauche, Fermer, Recharger (si besoin), Valeurs par défaut (panneau).
local function layoutFooter(waitReload)
    local anchor = closeButton
    -- Le bouton visible n'est pas protégé : on peut le montrer ou le cacher même en combat.
    -- Le bouton protégé qui le recouvre suit tout seul, hors combat.
    reloadButton:SetShown(waitReload)
    if waitReload then
        reloadButton:ClearAllPoints()
        reloadButton:SetPoint("RIGHT", anchor, "LEFT", -8, 0)
        anchor = reloadButton
    end
    defaultsButton:SetShown(current ~= nil)
    if current then
        defaultsButton:ClearAllPoints()
        defaultsButton:SetPoint("RIGHT", anchor, "LEFT", -8, 0)
        anchor = defaultsButton
    end
    summary:SetShown(current == nil)
    summary:ClearAllPoints()
    summary:SetPoint("LEFT", 16, 0)
    summary:SetPoint("RIGHT", anchor, "LEFT", -12, 0)
end

function CUI:RefreshModulesScreen()
    if not window or not window:IsShown() then return end

    local active, waitReload = 0, false
    for _, m in ipairs(self:GetModules()) do
        if m.enabled and not m.pendingReload then active = active + 1 end
        if m.pendingReload then waitReload = true end
    end

    local height
    if current then
        listView:Hide()
        panelView:Show()
        window:SetTitle(current.name)
        height = refreshPanel(current)
    else
        panelView:Hide()
        listView:Show()
        window:SetTitle(L.ECRAN_MODULES_TITRE)
        height = refreshList()
        summary:SetText(plural(L.N_MODULES, #self:GetModules()) .. " · " .. plural(L.N_ACTIFS, active))
    end
    listView:SetHeight(height)
    panelView:SetHeight(height)
    layoutFooter(waitReload)
    window:SetHeight(1 + HEADER + height + FOOTER + 1)
end

function CUI:ToggleModulesScreen()
    if not window then createWindow() end
    window:SetShown(not window:IsShown())
end

-- Rafraîchit l'écran quand un module change d'état (commande /cui, sortie de combat...).
function CUI:OnModulesChanged()
    self:RefreshModulesScreen()
end
