-- Cadre de fenêtre commun : un seul fond pour toutes les fenêtres de CœurUI.
-- Barre de titre (logo, titre, croix), déplaçable, position gardée, Échap ferme.
--
--   local f = CUI:CreateWindow("Modules", "Modules", 560)
--   f.content : zone sous la barre de titre, où placer le contenu
--   f:SetHeight(...) selon le contenu ; f:SetTitle(texte) ; f:Show() / f:Hide() / f:SetShown()
local _, CUI = ...
local C = CUI.Colors

local HEADER_HEIGHT = 40

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

    -- Ombre légère, contour doré, fond.
    local shadow = self:CreateRoundRect(f, 8, C.ombre, -3, "BACKGROUND", -2)
    shadow:SetColor(C.ombre)
    self:CreateBorderedRect(f, 6, C.or_, C.fenetre, "BACKGROUND", 0)

    -- Barre de titre.
    local header = _G.CreateFrame("Frame", nil, f)
    header:SetPoint("TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", -1, -1)
    header:SetHeight(HEADER_HEIGHT)
    self:CreateRoundRect(header, 5, C.graphite, 0, "BACKGROUND", 0)
    local square = header:CreateTexture(nil, "BACKGROUND", nil, 1) -- coins du bas carrés
    square:SetTexture("Interface\\Buttons\\WHITE8x8")
    square:SetVertexColor(unpack(C.graphite))
    square:SetPoint("BOTTOMLEFT")
    square:SetPoint("BOTTOMRIGHT")
    square:SetHeight(6)
    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\Buttons\\WHITE8x8")
    line:SetVertexColor(unpack(C.bordureDiscrete))
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
        titleText:SetText(CUI:ColorCode(C.or_) .. "Cœur|rUI " .. CUI:ColorCode(C.texteDiscret) .. "· " .. value .. "|r")
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
    f.content:SetPoint("TOPLEFT", 1, -1 - HEADER_HEIGHT)
    f.content:SetPoint("BOTTOMRIGHT", -1, 1)

    f:SetScript("OnShow", function() restorePosition(f) end)
    f:HookScript("OnHide", function() CUI:HideTooltip() end)

    -- Échap ferme la fenêtre.
    _G.tinsert(_G.UISpecialFrames, name)
    return f
end
