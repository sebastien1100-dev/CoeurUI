-- Écran « Modules » : activer ou couper chaque module. S'ouvre avec /cui.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local WIDTH = 560
local PAD = 8                 -- marge de la liste
local SWITCH_X = 8            -- interrupteur, depuis le bord de la ligne
local TEXT_X = SWITCH_X + 44 + 14
local STATE_WIDTH = 130
local ROW_GAP = 2

local window, intro, footer, summary, closeButton, emptyText
local rows = {}

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

local function onToggle(switch, checked)
    local m = switch.row.module
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

local function createRow(parent)
    local row = _G.CreateFrame("Frame", nil, parent)
    row.bg = CUI:CreateRoundRect(row, 4, C.ligne)

    row.switch = CUI:CreateSwitch(row, onToggle)
    row.switch.row = row
    row.switch:SetPoint("LEFT", SWITCH_X, 0)

    row.name = CUI:CreateText(row, "normal", "texte")
    row.name:SetPoint("TOPLEFT", TEXT_X, -10)

    row.desc = CUI:CreateText(row, "petit", "texteDiscret")
    row.desc:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -4)
    row.desc:SetWordWrap(true)

    -- L'état, à droite, avec une infobulle quand il y a quelque chose à expliquer.
    row.stateHit = _G.CreateFrame("Frame", nil, row)
    row.stateHit:SetPoint("RIGHT", -10, 0)
    row.stateHit:SetSize(STATE_WIDTH, 20)
    row.stateHit:EnableMouse(true)
    row.state = CUI:CreateText(row.stateHit, "petit", "texteDiscret")
    row.state:SetJustifyH("RIGHT")
    row.state:SetJustifyV("MIDDLE")
    row.state:SetAllPoints()
    CUI:AttachTooltip(row.stateHit, function(hit)
        return hit.tipTitle, hit.tipText
    end)
    return row
end

local function fillRow(row, m, textWidth)
    row.module = m
    row.switch:SetChecked(m:IsWanted())
    row.bg:SetShown(m:IsWanted())
    row.name:SetText(m.name)
    row.desc:SetWidth(textWidth)
    row.desc:SetText(m.description)

    local text, color, tipTitle, tipText = stateInfo(m)
    row.state:SetText(text)
    row.state:SetTextColor(color[1], color[2], color[3], 1)
    row.stateHit.tipTitle, row.stateHit.tipText = tipTitle, tipText

    local height = 10 + row.name:GetStringHeight() + 4 + row.desc:GetStringHeight() + 10
    row:SetHeight(math.max(44, math.ceil(height)))
end

local function createWindow()
    window = CUI:CreateWindow("Modules", L.ECRAN_MODULES_TITRE, WIDTH)
    local content = window.content

    intro = CUI:CreateText(content, "petit", "texteDiscret")
    intro:SetPoint("TOPLEFT", 16, -12)
    intro:SetWidth(WIDTH - 2 - 32)
    intro:SetWordWrap(true)
    intro:SetText(L.ECRAN_MODULES_INTRO)

    emptyText = CUI:CreateText(content, "normal", "texteDiscret")
    emptyText:SetText(L.MODULES_AUCUN_ECRAN)

    footer = _G.CreateFrame("Frame", nil, content)
    footer:SetPoint("BOTTOMLEFT")
    footer:SetPoint("BOTTOMRIGHT")
    footer:SetHeight(50)
    local line = footer:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\Buttons\\WHITE8x8")
    line:SetVertexColor(unpack(C.graphite))
    line:SetPoint("TOPLEFT")
    line:SetPoint("TOPRIGHT")
    line:SetHeight(1)

    closeButton = CUI:CreateButton(footer, L.FERMER)
    closeButton:SetPoint("RIGHT", -12, 0)
    closeButton:SetScript("OnClick", function() window:Hide() end)

    summary = CUI:CreateText(footer, "petit", "texteDiscret")
    summary:SetJustifyV("MIDDLE")
    summary:SetPoint("LEFT", 16, 0)
    summary:SetPoint("RIGHT", closeButton, "LEFT", -12, 0)

    window:HookScript("OnShow", function() CUI:RefreshModulesScreen() end)
end

local function plural(forms, n)
    return (n > 1 and forms[2] or forms[1]):format(n)
end

function CUI:RefreshModulesScreen()
    if not window or not window:IsShown() then return end
    local content = window.content
    local list = self:GetModules()
    local rowWidth = WIDTH - 2 - PAD * 2
    local textWidth = rowWidth - TEXT_X - STATE_WIDTH - 10 - 14

    local y = -12 - intro:GetStringHeight() - 10
    local active, waitReload = 0, false
    for i, m in ipairs(list) do
        local row = rows[i] or createRow(content)
        rows[i] = row
        fillRow(row, m, textWidth)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", PAD, y)
        row:SetWidth(rowWidth)
        row:Show()
        y = y - row:GetHeight() - ROW_GAP
        if m.enabled and not m.pendingReload then active = active + 1 end
        if m.pendingReload then waitReload = true end
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

    local text = plural(L.N_MODULES, #list) .. " · " .. plural(L.N_ACTIFS, active)
    if waitReload then
        text = text .. " · " .. self:ColorCode(C.or_) .. L.ECRAN_RELOAD_A_FAIRE .. "|r"
    end
    summary:SetText(text)

    window:SetHeight(1 + 40 + (-y) + 6 + footer:GetHeight() + 1)
end

function CUI:ToggleModulesScreen()
    if not window then createWindow() end
    window:SetShown(not window:IsShown())
end

-- Rafraîchit l'écran quand un module change d'état (commande /cui, sortie de combat...).
function CUI:OnModulesChanged()
    self:RefreshModulesScreen()
end
