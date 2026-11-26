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
-- Mise en page : une colonne (400 points au plus), ou deux si la liste contient { type = "column" }
-- (les réglages qui suivent vont dans la colonne de droite).
-- { type = "custom", height = h, build = function(parent, largeur) return cadre end,
--   refresh = function(cadre) end } : un cadre fourni par le module (un aperçu par exemple),
-- rafraîchi à l'ouverture de la page et après chaque réglage changé.
-- { type = "button", label = "...", description = "...", onClick = function() end } : un bouton d'action.
-- enabledIf = function(lire) return lire("autreCle") end (sur un curseur ou un menu) : grisé quand
-- la fonction renvoie false ; lire(cle) donne la valeur d'un autre réglage de la même page.
-- Renvoie un cadre dont la hauteur suit le contenu, avec :Refresh() pour relire les valeurs.
local COLUMN_GAP = 28

function CUI:CreateSettingsPanel(parent, items, width, intro, get, set)
    local panel = _G.CreateFrame("Frame", nil, parent)
    panel:SetWidth(width)
    panel.controls, panel.customs = {}, {}

    local twoColumns = false
    for _, item in ipairs(items) do
        if item.type == "column" then twoColumns = true end
    end
    local colW = twoColumns and math.floor((width - COLUMN_GAP) / 2) or math.min(width, 400)

    local function changed(item, value)
        set(item, value)
        panel:RefreshEnabled()
        panel:RefreshCustoms() -- l'aperçu suit les réglages
    end

    local top = 0
    if intro and intro ~= "" then
        local introText = self:CreateText(panel, "petit", "texteDiscret")
        introText:SetPoint("TOPLEFT")
        introText:SetWidth(twoColumns and width or colW)
        introText:SetWordWrap(true)
        introText:SetText(intro)
        top = -math.ceil(introText:GetStringHeight()) - GAP
    end

    local x, y, lowest = 0, top, top
    for _, item in ipairs(items) do
        local control, extra = nil, 0
        if item.type == "column" then
            lowest = math.min(lowest, y + GAP)
            x, y = colW + COLUMN_GAP, top
        elseif item.type == "section" then
            control = self:CreateText(panel, "petit", "texteDiscret")
            control:SetText(self:Tr(item.text or ""))
            control:SetHeight(math.ceil(control:GetStringHeight()))
        elseif item.type == "toggle" then
            control = createToggle(panel, item, colW, changed)
        elseif item.type == "slider" then
            control = self:CreateSlider(panel, {
                label = self:Tr(item.label or item.key),
                min = item.min, max = item.max, step = item.step, format = item.format,
                onChange = function(value) changed(item, value) end,
            })
            control:SetWidth(colW)
        elseif item.type == "dropdown" then
            -- options : une liste, ou une fonction qui la renvoie (liste calculée à l'ouverture).
            local options = type(item.options) == "function" and item.options() or item.options or {}
            local translated = {}
            for i, option in ipairs(options) do
                translated[i] = { value = option.value, text = self:Tr(option.text), texture = option.texture }
            end
            control = self:CreateDropdown(panel, {
                label = self:Tr(item.label or item.key),
                options = translated, width = item.width or 240,
                onSelect = function(value) changed(item, value) end,
            })
            control:SetWidth(colW)
        elseif item.type == "button" then
            control = self:CreateButton(panel, self:Tr(item.label or ""))
            control:SetScript("OnClick", function()
                if item.onClick then CUI:SafeCall(self:Tr(item.label or ""), item.onClick) end
                panel:Refresh()
            end)
        elseif item.type == "custom" and item.build then
            control = item.build(panel, colW)
            control:SetSize(colW, item.height or control:GetHeight())
            control.refresh = item.refresh
            panel.customs[#panel.customs + 1] = control
        end

        if control then
            control:ClearAllPoints()
            control:SetPoint("TOPLEFT", x, y)
            if item.type == "slider" or item.type == "dropdown" or item.type == "button" then
                extra = addNote(panel, control, item, colW)
            end
            y = y - control:GetHeight() - extra - GAP
            if item.key and control.SetValue then
                control.item = item
                panel.controls[#panel.controls + 1] = control
            end
        end
    end
    lowest = math.min(lowest, y + GAP) -- bas de la colonne la plus longue
    panel:SetHeight(math.max(1, -lowest))

    function panel:RefreshCustoms()
        for _, custom in ipairs(self.customs) do
            if custom.refresh then
                CUI:SafeCall("aperçu", custom.refresh, custom)
            end
        end
    end

    local function read(key)
        for _, item in ipairs(items) do
            if item.key == key then return get(item) end
        end
    end

    function panel:RefreshEnabled()
        for _, control in ipairs(self.controls) do
            local test = control.item.enabledIf
            if test and control.SetEnabled then
                control:SetEnabled(test(read) and true or false)
            end
        end
    end

    function panel:Refresh()
        for _, control in ipairs(self.controls) do
            control:SetValue(get(control.item))
        end
        self:RefreshEnabled()
        self:RefreshCustoms()
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
    if sub and sub.intro == false then -- page sans texte d'introduction (choix de la maquette)
        intro = nil
    end
    return self:CreateSettingsPanel(parent, self:GetPageSettings(m, sub), width, intro,
        function(item) return CUI:GetModuleSetting(m, item, sub) end,
        function(item, value) CUI:SetModuleSetting(m, item, value, sub) end)
end
