-- Pièces d'interface communes : rectangle à coins arrondis, bouton, interrupteur, infobulle.
local _, CUI = ...
local C = CUI.Colors

local CIRCLE = CUI.MEDIA .. "Cercle"
local WHITE = "Interface\\Buttons\\WHITE8x8"

-- Rectangle à coins arrondis -------------------------------------------------------------
-- Fait de 4 quarts de disque (les coins) et de 3 bandes. Il remplit son parent, en retrait de
-- inset points sur chaque bord. Pour un contour : un rectangle couleur du contour, puis un
-- second par-dessus (sublevel + 1), inset + 1 et radius - 1.

local RoundRect = {}
RoundRect.__index = RoundRect

function CUI:CreateRoundRect(parent, radius, color, inset, layer, sublevel)
    inset = inset or 0
    layer = layer or "BACKGROUND"
    sublevel = sublevel or 0
    local parts = {}
    local function piece(file)
        local t = parent:CreateTexture(nil, layer, nil, sublevel)
        t:SetTexture(file)
        parts[#parts + 1] = t
        return t
    end

    local corners = {
        { "TOPLEFT", inset, -inset, 0, 0.5, 0, 0.5 },
        { "TOPRIGHT", -inset, -inset, 0.5, 1, 0, 0.5 },
        { "BOTTOMLEFT", inset, inset, 0, 0.5, 0.5, 1 },
        { "BOTTOMRIGHT", -inset, inset, 0.5, 1, 0.5, 1 },
    }
    for _, c in ipairs(corners) do
        local t = piece(CIRCLE)
        t:SetTexCoord(c[4], c[5], c[6], c[7])
        t:SetSize(radius, radius)
        t:SetPoint(c[1], c[2], c[3])
    end

    local top = piece(WHITE)
    top:SetPoint("TOPLEFT", inset + radius, -inset)
    top:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", -inset - radius, -inset - radius)

    local middle = piece(WHITE)
    middle:SetPoint("TOPLEFT", inset, -inset - radius)
    middle:SetPoint("BOTTOMRIGHT", -inset, inset + radius)

    local bottom = piece(WHITE)
    bottom:SetPoint("BOTTOMLEFT", inset + radius, inset)
    bottom:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", -inset - radius, inset + radius)

    local rect = setmetatable({ parts = parts }, RoundRect)
    rect:SetColor(color or C.graphite)
    return rect
end

function RoundRect:SetColor(color)
    for _, t in ipairs(self.parts) do
        t:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    end
end

function RoundRect:SetShown(shown)
    for _, t in ipairs(self.parts) do
        t:SetShown(shown)
    end
end

-- Cadre avec contour : renvoie le contour et le fond (deux rectangles arrondis).
function CUI:CreateBorderedRect(parent, radius, borderColor, fillColor, layer, sublevel)
    sublevel = sublevel or 0
    local border = self:CreateRoundRect(parent, radius, borderColor, 0, layer, sublevel)
    local fill = self:CreateRoundRect(parent, radius - 1, fillColor, 1, layer, sublevel + 1)
    return border, fill
end

-- Bouton -----------------------------------------------------------------------------------
-- CUI:CreateButton(parent, texte, principal) ; b:SetScript("OnClick", ...) comme un bouton du jeu.
-- Un seul bouton principal (doré) par fenêtre, pour l'action attendue.

local function updateButton(b)
    local border, fill, text
    if not b:IsEnabled() then
        border, fill, text = C.desactiveBordure, C.desactiveFond, C.texteDesactive
    elseif b.principal then
        local c = b.hover and C.orClair or C.or_
        border, fill, text = c, c, C.fond
    elseif b.pressed then
        border, fill, text = C.or_, C.graphiteSombre, C.or_
    elseif b.hover then
        border, fill, text = C.or_, C.graphiteClair, C.texte
    else
        border, fill, text = C.bordure, C.graphite, C.texte
    end
    b.border:SetColor(border)
    b.fill:SetColor(fill)
    b.label:SetTextColor(text[1], text[2], text[3], text[4] or 1)
end

function CUI:CreateButton(parent, text, principal)
    local b = _G.CreateFrame("Button", nil, parent)
    b:SetHeight(26)
    b.principal = principal and true or false
    b.border, b.fill = self:CreateBorderedRect(b, 4, C.bordure, C.graphite)
    b.label = self:CreateText(b, "normal", "texte")
    b.label:SetJustifyV("MIDDLE")
    b.label:SetPoint("CENTER")

    function b:SetLabel(value)
        self.label:SetText(value)
        self:SetWidth(math.max(80, math.ceil(self.label:GetStringWidth()) + 28))
    end

    b:SetScript("OnEnter", function(btn) btn.hover = true; updateButton(btn) end)
    b:SetScript("OnLeave", function(btn) btn.hover = false; btn.pressed = false; updateButton(btn) end)
    b:SetScript("OnMouseDown", function(btn) btn.pressed = true; updateButton(btn) end)
    b:SetScript("OnMouseUp", function(btn) btn.pressed = false; updateButton(btn) end)
    b:SetScript("OnEnable", updateButton)
    b:SetScript("OnDisable", updateButton)

    -- Pour un bouton dont la souris est captée par un autre cadre posé dessus (bouton protégé).
    function b:SetVisualState(hover, pressed)
        self.hover, self.pressed = hover and true or false, pressed and true or false
        updateButton(self)
    end

    b:SetLabel(text or "")
    updateButton(b)
    return b
end

-- Interrupteur -----------------------------------------------------------------------------
-- CUI:CreateSwitch(parent, onToggle) ; onToggle(interrupteur, activé) après un clic du joueur.
-- s:SetChecked(bool) change l'affichage sans appeler onToggle.

local function updateSwitch(s)
    local border, fill, knob
    if not s:IsEnabled() then
        border, fill, knob = C.desactiveBordure, C.desactiveFond, C.bordure
    elseif s.checked then
        border, fill, knob = s.hover and C.orClair or C.or_, C.railActif, C.or_
    else
        border, fill, knob = s.hover and C.texteDiscret or C.bordure, C.graphite, C.texteDiscret
    end
    s.border:SetColor(border)
    s.fill:SetColor(fill)
    s.knob:SetVertexColor(knob[1], knob[2], knob[3], 1)
    s.knob:ClearAllPoints()
    s.knob:SetPoint("LEFT", s.checked and 23 or 3, 0)
end

function CUI:CreateSwitch(parent, onToggle)
    local s = _G.CreateFrame("Button", nil, parent)
    s:SetSize(44, 24)
    s.border, s.fill = self:CreateBorderedRect(s, 12, C.bordure, C.graphite, "ARTWORK")
    s.knob = s:CreateTexture(nil, "OVERLAY")
    s.knob:SetTexture(CIRCLE)
    s.knob:SetSize(16, 16)
    s.checked = false

    function s:SetChecked(value)
        self.checked = value and true or false
        updateSwitch(self)
    end

    function s:GetChecked()
        return self.checked
    end

    s:SetScript("OnClick", function(sw)
        sw:SetChecked(not sw.checked)
        if onToggle then
            CUI:SafeCall("interrupteur", onToggle, sw, sw.checked)
        end
    end)
    s:SetScript("OnEnter", function(sw) sw.hover = true; updateSwitch(sw) end)
    s:SetScript("OnLeave", function(sw) sw.hover = false; updateSwitch(sw) end)
    s:SetScript("OnEnable", updateSwitch)
    s:SetScript("OnDisable", updateSwitch)

    updateSwitch(s)
    return s
end

-- Infobulle --------------------------------------------------------------------------------
-- Toujours passer par ces fonctions : elles posent le propriétaire et habillent l'infobulle.
--   CUI:ShowTooltip(propriétaire, titre, texte, texteDiscret)
--   CUI:AttachTooltip(cadre, titre, texte, texteDiscret)  -- ou une fonction qui renvoie les trois

local TIP_WIDTH = 230 -- largeur maximale du texte
local tip

local function createTooltip()
    tip = _G.CreateFrame("Frame", "CoeurUIInfobulle", _G.UIParent)
    tip:SetFrameStrata("TOOLTIP")
    tip:SetClampedToScreen(true)
    tip:Hide()
    CUI:CreateBorderedRect(tip, 4, C.or_, C.fond)
    tip.title = CUI:CreateText(tip, "normal", "or_")
    tip.text = CUI:CreateText(tip, "petit", "texte")
    tip.extra = CUI:CreateText(tip, "petit", "texteDiscret")
    for _, fs in ipairs({ tip.title, tip.text, tip.extra }) do
        fs:SetWordWrap(true)
    end
end

function CUI:ShowTooltip(owner, title, text, extra)
    if not tip then createTooltip() end
    local lines = {}
    for _, item in ipairs({ { tip.title, title }, { tip.text, text }, { tip.extra, extra } }) do
        local fs, value = item[1], item[2]
        if value and value ~= "" then
            fs:SetText(value)
            fs:Show()
            lines[#lines + 1] = fs
        else
            fs:Hide()
        end
    end
    if #lines == 0 then
        tip:Hide()
        return
    end

    -- Largeur : celle du texte le plus long, sans dépasser TIP_WIDTH.
    local width = 0
    for _, fs in ipairs(lines) do
        fs:SetWidth(TIP_WIDTH)
        local natural = fs.GetUnboundedStringWidth and fs:GetUnboundedStringWidth() or fs:GetStringWidth()
        width = math.max(width, math.min(TIP_WIDTH, math.ceil(natural)))
    end
    local y = -9
    for i, fs in ipairs(lines) do
        fs:SetWidth(width)
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", 11, y)
        y = y - fs:GetStringHeight() - (i < #lines and 4 or 0)
    end
    tip:SetSize(width + 22, -y + 9)

    tip:ClearAllPoints()
    tip:SetPoint("BOTTOMLEFT", owner, "TOPRIGHT", 6, 4)
    tip.owner = owner
    tip:Show()
end

function CUI:HideTooltip(owner)
    if tip and (owner == nil or tip.owner == owner) then
        tip:Hide()
        tip.owner = nil
    end
end

function CUI:AttachTooltip(frame, title, text, extra)
    frame:HookScript("OnEnter", function(cadre)
        if type(title) == "function" then
            CUI:ShowTooltip(cadre, title(cadre))
        else
            CUI:ShowTooltip(cadre, title, text, extra)
        end
    end)
    frame:HookScript("OnLeave", function(cadre)
        CUI:HideTooltip(cadre)
    end)
end
