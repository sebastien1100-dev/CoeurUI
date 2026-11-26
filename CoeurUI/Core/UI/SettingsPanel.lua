-- Panneau de réglages d'un module, construit à partir de sa liste « settings »
-- (voir Core/Modules.lua). Chaque réglage s'applique tout de suite.
local _, CUI = ...
local L = CUI.L

local GAP = 18 -- espace entre deux réglages

-- Interrupteur avec son texte, pour un réglage « toggle ».
local function createToggle(panel, m, item, width)
    local f = _G.CreateFrame("Frame", nil, panel)
    f:SetWidth(width)
    f.switch = CUI:CreateSwitch(f, function(_, checked)
        CUI:SetModuleSetting(m, item, checked)
    end)
    f.switch:SetPoint("RIGHT")

    f.label = CUI:CreateText(f, "normal", "texte")
    f.label:SetPoint("TOPLEFT")
    f.label:SetText(item.label or item.key)
    local height = f.label:GetStringHeight()
    if item.description then
        f.desc = CUI:CreateText(f, "petit", "texteDiscret")
        f.desc:SetPoint("TOPLEFT", f.label, "BOTTOMLEFT", 0, -3)
        f.desc:SetWidth(width - 44 - 16)
        f.desc:SetWordWrap(true)
        f.desc:SetText(item.description)
        height = height + 3 + f.desc:GetStringHeight()
    end
    f:SetHeight(math.max(24, math.ceil(height)))

    function f:SetValue(value)
        self.switch:SetChecked(value)
    end
    return f
end

-- Construit le contenu du panneau (une fois par module), large de width points.
-- Renvoie un cadre dont la hauteur suit le contenu, avec :Refresh() pour relire les valeurs.
function CUI:BuildSettingsPanel(parent, m, width)
    local panel = _G.CreateFrame("Frame", nil, parent)
    panel:SetWidth(width)
    panel.controls = {}

    local intro = self:CreateText(panel, "petit", "texteDiscret")
    intro:SetPoint("TOPLEFT")
    intro:SetWidth(width)
    intro:SetWordWrap(true)
    local text = L.PANNEAU_INTRO
    if m.description ~= "" then
        text = m.description .. " " .. text
    end
    intro:SetText(text)
    local y = -math.ceil(intro:GetStringHeight()) - GAP

    for _, item in ipairs(m.settings) do
        local control
        if item.type == "section" then
            control = self:CreateText(panel, "petit", "texteDiscret")
            control:SetText(item.text or "")
            control:SetHeight(math.ceil(control:GetStringHeight()))
        elseif item.type == "toggle" then
            control = createToggle(panel, m, item, width)
        elseif item.type == "slider" then
            control = self:CreateSlider(panel, {
                label = item.label or item.key,
                min = item.min, max = item.max, step = item.step, format = item.format,
                onChange = function(value) CUI:SetModuleSetting(m, item, value) end,
            })
            control:SetWidth(width)
        elseif item.type == "dropdown" then
            control = self:CreateDropdown(panel, {
                label = item.label or item.key,
                options = item.options, width = item.width or 240,
                onSelect = function(value) CUI:SetModuleSetting(m, item, value) end,
            })
            control:SetWidth(width)
        end

        if control then
            control:SetPoint("TOPLEFT", 0, y)
            y = y - control:GetHeight() - GAP
            if item.key and control.SetValue then
                control.item = item
                panel.controls[#panel.controls + 1] = control
            end
        end
    end
    panel:SetHeight(-y - GAP)

    function panel:Refresh()
        for _, control in ipairs(self.controls) do
            control:SetValue(CUI:GetModuleSetting(m, control.item))
        end
    end
    return panel
end
