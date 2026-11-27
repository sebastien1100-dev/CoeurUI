-- Cadre de fenêtre commun : un seul fond pour toutes les fenêtres de CœurUI.
-- Barre de titre (logo, titre, croix), déplaçable, position gardée, Échap ferme.
--
--   local f = CUI:CreateWindow("Modules", "Modules", 560)
--   f.content : zone sous la barre de titre, où placer le contenu
--   f:SetHeight(...) selon le contenu ; f:SetTitle(texte) ; f:Show() / f:Hide() / f:SetShown()
local _, CUI = ...
local C = CUI.Colors

local HEADER_HEIGHT = 40
local windows = {} -- fenêtres créées (opacité du fond : page « Général »)

-- Opacité du fond des fenêtres de CœurUI (réglage « Général », de 20 à 100 %) : le fond et sa colonne
-- s'éclaircissent, textes, cartes et boutons restent nets. f.onOpacity(a) : ce qu'une fenêtre y ajoute.
function CUI:ApplyWindowOpacity()
    local a = (self.db and self.db.general.opaciteFenetre or 100) / 100
    for _, f in ipairs(windows) do
        f.panel:SetOpacity(a)
        if f.onOpacity then f.onOpacity(a) end
    end
end

local function savePosition(f)
    local point, _, _, x, y = f:GetPoint(1)
    if point and CUI.db then
        CUI.db.ui.positions[f.key] = { point, math.floor(x + 0.5), math.floor(y + 0.5) }
    end
end

local function restorePosition(f)
    f:ClearAllPoints()
    local pos = CUI.db and CUI.db.ui.positions[f.key]
    if type(pos) == "table" and type(pos[1]) == "string" then
        f:SetPoint(pos[1], _G.UIParent, pos[1], pos[2] or 0, pos[3] or 0)
    else
        f:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 60)
    end
end

local function createCloseButton(f, header)
    local b = _G.CreateFrame("Button", nil, header)
    b:SetSize(28, 28)
    b:SetPoint("RIGHT", -6, 0)
    b.bg = CUI:CreateRoundRect(b, 4, C.graphiteClair)
    b.bg:SetShown(false)

    -- La croix : deux traits tournés.
    b.lines = {}
    for i, angle in ipairs({ 45, -45 }) do
        local t = b:CreateTexture(nil, "ARTWORK")
        t:SetTexture("Interface\\Buttons\\WHITE8x8")
        t:SetSize(13, 2)
        t:SetPoint("CENTER")
        t:SetRotation(math.rad(angle))
        b.lines[i] = t
    end
    local function paint(color)
        for _, t in ipairs(b.lines) do
            t:SetVertexColor(color[1], color[2], color[3], 1)
        end
    end
    paint(C.texteDiscret)

    b:SetScript("OnEnter", function()
        b.bg:SetShown(true)
        paint(C.texte)
        CUI:ShowTooltip(b, CUI.L.FERMER)
    end)
    b:SetScript("OnLeave", function()
        b.bg:SetShown(false)
        paint(C.texteDiscret)
        CUI:HideTooltip(b)
    end)
    b:SetScript("OnClick", function() f:Hide() end)
    return b
end

function CUI:CreateWindow(key, title, width)
    local name = "CoeurUIFenetre" .. key
    local f = _G.CreateFrame("Frame", name, _G.UIParent)
    f.key = key
    f:SetSize(width, 200)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:Hide()

    -- Style du thème (« Givre ») : fond, double liseré très discret, ombre douce.
    f.panel = self:CreatePanel(f, { fill = C.fenetre })

    -- Barre de titre : fondue dans le fond (minimal plat), un trait très discret dessous.
    local header = _G.CreateFrame("Frame", nil, f)
    header:SetPoint("TOPLEFT", 2, -2)
    header:SetPoint("TOPRIGHT", -2, -2)
    header:SetHeight(HEADER_HEIGHT)
    f.header = header -- pour poser d'autres boutons à gauche de la croix (f.closeButton)
    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\Buttons\\WHITE8x8")
    line:SetVertexColor(unpack(C.lisereSombre))
    line:SetPoint("BOTTOMLEFT")
    line:SetPoint("BOTTOMRIGHT")
    line:SetHeight(1)

    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetTexture(self.MEDIA .. "Logo")
    logo:SetSize(22, 22)
    logo:SetPoint("LEFT", 13, 0)

    local titleText = self:CreateText(header, "titre", "texte")
    titleText:SetJustifyV("MIDDLE")
    titleText:SetPoint("LEFT", logo, "RIGHT", 9, 0)
    f.titleText = titleText
    function f:SetTitle(value)
        titleText:SetText(CUI:ColorCode(C.marque or C.or_) .. "Cœur|rUI " .. CUI:ColorCode(C.texteDiscret) .. "· " .. value .. "|r")
    end
    f:SetTitle(title)

    f.closeButton = createCloseButton(f, header)

    -- Déplacement par la barre de titre.
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() f:StartMoving() end)
    header:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        f:SetUserPlaced(false) -- la position est gardée par CœurUI, pas par le jeu
        savePosition(f)
    end)

    -- Zone de contenu.
    f.content = _G.CreateFrame("Frame", nil, f)
    f.content:SetPoint("TOPLEFT", 2, -2 - HEADER_HEIGHT)
    f.content:SetPoint("BOTTOMRIGHT", -2, 2)

    windows[#windows + 1] = f
    f:SetScript("OnShow", function()
        restorePosition(f)
        CUI:ApplyWindowOpacity()
    end)
    f:HookScript("OnHide", function() CUI:HideTooltip() end)

    -- Échap ferme la fenêtre.
    _G.tinsert(_G.UISpecialFrames, name)
    return f
end
