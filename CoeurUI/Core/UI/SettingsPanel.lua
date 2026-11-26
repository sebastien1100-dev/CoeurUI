-- Page de réglages, construite à partir d'une liste de réglages (voir Core/Modules.lua).
-- Sert aux pages des modules et à la page « Paramètres ». Chaque réglage s'applique tout de suite.
-- Les textes (label, description, section, options) sont traduits par CUI:Tr : un module peut
-- donner des clés des fichiers de Locales/.
local _, CUI = ...
local L = CUI.L

local GAP = 18 -- espace entre deux réglages

-- Interrupteur avec son texte, pour un réglage « toggle ».
local function createToggle(panel, item, width, set)
    local f = _G.CreateFrame("Frame", nil, panel)
    f:SetWidth(width)
    f.switch = CUI:CreateSwitch(f, function(_, checked)
        set(item, checked)
    end)
    f.switch:SetPoint("RIGHT")

    f.label = CUI:CreateText(f, "normal", "texte")
    f.label:SetPoint("TOPLEFT")
    f.label:SetText(CUI:Tr(item.label or item.key))
    local height = f.label:GetStringHeight()
    if item.description then
        f.desc = CUI:CreateText(f, "petit", "texteDiscret")
        f.desc:SetPoint("TOPLEFT", f.label, "BOTTOMLEFT", 0, -3)
        f.desc:SetWidth(width - 44 - 16)
        f.desc:SetWordWrap(true)
        f.desc:SetText(CUI:Tr(item.description))
        height = height + 3 + f.desc:GetStringHeight()
    end
    f:SetHeight(math.max(24, math.ceil(height)))

    function f:SetValue(value)
        self.switch:SetChecked(value)
    end
    return f
end

-- Petit texte sous un curseur ou un menu (item.description).
local function addNote(panel, control, item, width)
    if not item.description then return 0 end
    local note = CUI:CreateText(panel, "petit", "texteDiscret")
    note:SetPoint("TOPLEFT", control, "BOTTOMLEFT", 0, -4)
    note:SetWidth(width)
    note:SetWordWrap(true)
    note:SetText(CUI:Tr(item.description))
    return 4 + math.ceil(note:GetStringHeight())
end

-- Construit une page de réglages, large de width points.
--   items : liste de réglages ; intro : texte en tête (ou nil)
--   get(item) » valeur ; set(item, valeur)
-- Renvoie un cadre dont la hauteur suit le contenu, avec :Refresh() pour relire les valeurs.
function CUI:CreateSettingsPanel(parent, items, width, intro, get, set)
    local panel = _G.CreateFrame("Frame", nil, parent)
    panel:SetWidth(width)
    panel.controls = {}

    local y = 0
    if intro and intro ~= "" then
        local introText = self:CreateText(panel, "petit", "texteDiscret")
        introText:SetPoint("TOPLEFT")
        introText:SetWidth(width)
        introText:SetWordWrap(true)
        introText:SetText(intro)
        y = -math.ceil(introText:GetStringHeight()) - GAP
    end

    for _, item in ipairs(items) do
        local control, extra = nil, 0
        if item.type == "section" then
            control = self:CreateText(panel, "petit", "texteDiscret")
            control:SetText(self:Tr(item.text or ""))
            control:SetHeight(math.ceil(control:GetStringHeight()))
        elseif item.type == "toggle" then
            control = createToggle(panel, item, width, set)
        elseif item.type == "slider" then
            control = self:CreateSlider(panel, {
                label = self:Tr(item.label or item.key),
                min = item.min, max = item.max, step = item.step, format = item.format,
                onChange = function(value) set(item, value) end,
            })
            control:SetWidth(width)
        elseif item.type == "dropdown" then
            -- options : une liste, ou une fonction qui la renvoie (liste calculée à l'ouverture).
            local options = type(item.options) == "function" and item.options() or item.options or {}
            local translated = {}
            for i, option in ipairs(options) do
                translated[i] = { value = option.value, text = self:Tr(option.text) }
            end
            control = self:CreateDropdown(panel, {
                label = self:Tr(item.label or item.key),
                options = translated, width = item.width or 240,
                onSelect = function(value) set(item, value) end,
            })
            control:SetWidth(width)
        end

        if control then
            control:SetPoint("TOPLEFT", 0, y)
            if item.type == "slider" or item.type == "dropdown" then
                extra = addNote(panel, control, item, width)
            end
            y = y - control:GetHeight() - extra - GAP
            if item.key and control.SetValue then
                control.item = item
                panel.controls[#panel.controls + 1] = control
            end
        end
    end
    panel:SetHeight(-y - GAP)

    function panel:Refresh()
        for _, control in ipairs(self.controls) do
            control:SetValue(get(control.item))
        end
    end
    return panel
end

-- Page de réglages d'un module, ou d'un de ses sous-modules (sub).
function CUI:BuildSettingsPanel(parent, m, width, sub)
    local description = sub and sub.description or (not sub and m.description) or ""
    local intro = L.PANNEAU_INTRO
    if description ~= "" then
        intro = self:Tr(description) .. " " .. intro
    end
    return self:CreateSettingsPanel(parent, self:GetPageSettings(m, sub), width, intro,
        function(item) return CUI:GetModuleSetting(m, item, sub) end,
        function(item, value) CUI:SetModuleSetting(m, item, value, sub) end)
end
