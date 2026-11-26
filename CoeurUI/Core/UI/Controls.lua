-- Contrôles de réglages : bouton lien, curseur, menu déroulant.
local _, CUI = ...
local C = CUI.Colors

local WHITE = "Interface\\Buttons\\WHITE8x8"
local CIRCLE = CUI.MEDIA .. "Cercle"

local function solid(parent, layer, sublevel, color)
    local t = parent:CreateTexture(nil, layer, nil, sublevel)
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    return t
end

local function tint(texture, color)
    texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
end

-- Chevron ----------------------------------------------------------------------------------
-- Deux petits traits tournés. c:SetDirection("right" | "down" | "up") ; c:SetColor(couleur).

function CUI:CreateChevron(parent, layer)
    local c = { lines = {} }
    for i = 1, 2 do
        local t = solid(parent, layer or "ARTWORK", 0, C.texteDiscret)
        t:SetSize(6, 1.6)
        c.lines[i] = t
    end

    function c:SetPoint(...)
        self.point = { ... }
        self:SetDirection(self.direction or "down")
    end

    -- Chaque trait est placé à côté du point d'ancrage, puis tourné.
    local SHAPES = {
        down = { { -2, 0, -45 }, { 2, 0, 45 } },
        up = { { -2, 0, 45 }, { 2, 0, -45 } },
        right = { { 0, 2, -45 }, { 0, -2, 45 } },
    }
    function c:SetDirection(direction)
        self.direction = direction
        if not self.point then return end
        local p = self.point
        for i, shape in ipairs(SHAPES[direction]) do
            local t = self.lines[i]
            t:ClearAllPoints()
            t:SetPoint("CENTER", p[1], p[2], (p[3] or 0) + shape[1], (p[4] or 0) + shape[2])
            t:SetRotation(math.rad(shape[3]))
        end
    end

    function c:SetColor(color)
        for _, t in ipairs(self.lines) do
            tint(t, color)
        end
    end
    return c
end

-- Zone à faire défiler (molette) -------------------------------------------------------------
--   local zone = CUI:CreateScrollArea(parent) ; zone.child : le contenu (largeur = celle de la zone)
--   zone:SetContentHeight(h) après chaque mise en page ; zone:ScrollToTop()
-- Une fine barre à droite montre la position quand le contenu dépasse.

function CUI:CreateScrollArea(parent)
    local sf = _G.CreateFrame("ScrollFrame", nil, parent)
    local child = _G.CreateFrame("Frame", nil, sf)
    child:SetSize(1, 1)
    sf:SetScrollChild(child)
    sf.child = child

    local bar = solid(sf, "OVERLAY", 0, C.bordure)
    bar:SetWidth(3)
    bar:Hide()

    local function maxScroll()
        return math.max(0, child:GetHeight() - sf:GetHeight())
    end

    local function updateBar()
        local max = maxScroll()
        if max <= 0 then
            bar:Hide()
            return
        end
        local view = sf:GetHeight()
        local size = math.max(20, view * view / child:GetHeight())
        local pos = (view - size) * sf:GetVerticalScroll() / max
        bar:ClearAllPoints()
        bar:SetPoint("TOPRIGHT", sf, "TOPRIGHT", -2, -pos)
        bar:SetHeight(size)
        bar:Show()
    end

    local function scrollTo(value)
        sf:SetVerticalScroll(math.min(maxScroll(), math.max(0, value)))
        updateBar()
    end

    sf:EnableMouseWheel(true)
    sf:SetScript("OnMouseWheel", function(_, delta)
        scrollTo(sf:GetVerticalScroll() - delta * 40)
    end)
    sf:SetScript("OnSizeChanged", function(_, width)
        child:SetWidth(width)
        scrollTo(sf:GetVerticalScroll())
    end)

    function sf:SetContentHeight(height)
        child:SetWidth(self:GetWidth())
        child:SetHeight(math.max(1, height))
        scrollTo(self:GetVerticalScroll())
    end

    function sf:ScrollToTop()
        scrollTo(0)
    end
    return sf
end

-- Bouton lien ------------------------------------------------------------------------------
-- Texte doré sans cadre, fond au survol (ex. « « Modules », « Réglages » »).

function CUI:CreateLinkButton(parent, text, petit)
    local b = _G.CreateFrame("Button", nil, parent)
    b:SetHeight(petit and 22 or 26)
    b.bg = self:CreateRoundRect(b, 4, C.graphiteClair)
    b.bg:SetShown(false)
    b.label = self:CreateText(b, petit and "petit" or "normal", "or_")
    b.label:SetJustifyV("MIDDLE")
    b.label:SetPoint("CENTER")
    b.label:SetText(text)
    b:SetWidth(math.ceil(b.label:GetStringWidth()) + 20)
    b:SetScript("OnEnter", function() b.bg:SetShown(true) end)
    b:SetScript("OnLeave", function() b.bg:SetShown(false) end)
    return b
end

-- Curseur ----------------------------------------------------------------------------------
--   local s = CUI:CreateSlider(parent, {
--       label = "Taille", min = 50, max = 200, step = 5, format = "%d %%",
--       onChange = function(valeur) end,  -- seulement quand le joueur bouge le curseur
--   })
--   s:SetValue(v) (sans appeler onChange) ; s:GetValue() ; s:SetEnabled(bool)
-- Hauteur fixe : s:GetHeight(). La molette avance d'un cran.

local function updateSlider(f)
    local enabled = f.slider:IsEnabled()
    local accent = not enabled and C.bordure or (f.hover and C.orClair or C.or_)
    tint(f.rail, enabled and C.bordure or C.desactiveBordure)
    tint(f.fill, accent)
    tint(f.thumb, accent)
    local text = enabled and C.texte or C.texteDesactive
    f.label:SetTextColor(text[1], text[2], text[3], 1)
    local value = enabled and C.or_ or C.texteDesactive
    f.valueText:SetTextColor(value[1], value[2], value[3], 1)
    local bounds = enabled and C.texteDiscret or C.texteDesactive
    f.minText:SetTextColor(bounds[1], bounds[2], bounds[3], 1)
    f.maxText:SetTextColor(bounds[1], bounds[2], bounds[3], 1)
end

function CUI:CreateSlider(parent, opts)
    local min, max, step = opts.min or 0, opts.max or 100, opts.step or 1
    local format = opts.format or "%s"

    local f = _G.CreateFrame("Frame", nil, parent)
    f:SetHeight(58)

    f.label = self:CreateText(f, "normal", "texte")
    f.label:SetPoint("TOPLEFT")
    f.label:SetText(opts.label or "")
    f.valueText = self:CreateText(f, "normal", "or_")
    f.valueText:SetJustifyH("RIGHT")
    f.valueText:SetPoint("TOPRIGHT")

    local s = _G.CreateFrame("Slider", nil, f)
    s:SetOrientation("HORIZONTAL")
    s:SetPoint("TOPLEFT", 0, -22)
    s:SetPoint("TOPRIGHT", 0, -22)
    s:SetHeight(16)
    s:SetHitRectInsets(0, 0, -4, -4)
    s:SetMinMaxValues(min, max)
    s:SetValueStep(step)
    s:SetObeyStepOnDrag(true)
    f.slider = s

    f.rail = solid(s, "BACKGROUND", 0, C.bordure)
    f.rail:SetHeight(4)
    f.rail:SetPoint("LEFT")
    f.rail:SetPoint("RIGHT")

    f.thumb = s:CreateTexture(nil, "OVERLAY", nil, 1)
    f.thumb:SetTexture(CIRCLE)
    f.thumb:SetSize(14, 14)
    s:SetThumbTexture(f.thumb)
    -- SetThumbTexture replace la texture sur une couche basse : on la remet au-dessus du liseré.
    f.thumb:SetDrawLayer("OVERLAY", 2)
    local ring = s:CreateTexture(nil, "OVERLAY", nil, 0) -- liseré sombre autour du bouton
    ring:SetTexture(CIRCLE)
    ring:SetSize(18, 18)
    ring:SetPoint("CENTER", f.thumb, "CENTER")
    tint(ring, C.fenetre)

    f.fill = solid(s, "ARTWORK", 0, C.or_)
    f.fill:SetHeight(4)
    f.fill:SetPoint("LEFT", f.rail, "LEFT")
    f.fill:SetPoint("RIGHT", f.thumb, "CENTER")

    f.minText = self:CreateText(f, "petit", "texteDiscret")
    f.minText:SetPoint("TOPLEFT", 0, -44)
    f.minText:SetText(format:format(min))
    f.maxText = self:CreateText(f, "petit", "texteDiscret")
    f.maxText:SetJustifyH("RIGHT")
    f.maxText:SetPoint("TOPRIGHT", 0, -44)
    f.maxText:SetText(format:format(max))

    local function snap(v)
        v = math.min(max, math.max(min, v))
        return min + math.floor((v - min) / step + 0.5) * step
    end

    s:SetScript("OnValueChanged", function(_, raw)
        local v = snap(raw)
        f.valueText:SetText(format:format(v))
        if f.silent or v == f.current then return end
        f.current = v
        if opts.onChange then
            CUI:SafeCall("curseur", opts.onChange, v)
        end
    end)
    s:EnableMouseWheel(true)
    s:SetScript("OnMouseWheel", function(_, delta)
        if s:IsEnabled() then
            s:SetValue(snap((f.current or min) + delta * step))
        end
    end)
    s:SetScript("OnEnter", function() f.hover = true; updateSlider(f) end)
    s:SetScript("OnLeave", function() f.hover = false; updateSlider(f) end)

    function f:SetValue(v)
        v = snap(tonumber(v) or min)
        self.silent = true
        self.current = v
        s:SetValue(v)
        self.valueText:SetText(format:format(v))
        self.silent = false
    end

    function f:GetValue()
        return self.current
    end

    function f:SetEnabled(enabled)
        s:SetEnabled(enabled)
        updateSlider(self)
    end

    f:SetValue(opts.value or min)
    updateSlider(f)
    return f
end

-- Menu déroulant ---------------------------------------------------------------------------
--   local d = CUI:CreateDropdown(parent, {
--       label = "Position", width = 240,
--       options = { { value = "hg", text = "En haut à gauche" }, ... },
--       onSelect = function(valeur) end,  -- seulement quand le joueur choisit
--   })
--   d:SetValue(v) (sans appeler onSelect) ; d:GetValue() ; d:SetEnabled(bool)
-- Une seule liste ouverte à la fois ; un clic ailleurs la ferme.

local menu, catcher

local function updateDropdown(b)
    local border, fill, text, arrow
    if not b:IsEnabled() then
        border, fill, text, arrow = C.desactiveBordure, C.desactiveFond, C.texteDesactive, C.bordure
    elseif b.open then
        border, fill, text, arrow = C.or_, C.graphite, C.texte, C.or_
    elseif b.hover then
        border, fill, text, arrow = C.or_, C.graphiteClair, C.texte, C.texte
    else
        border, fill, text, arrow = C.bordure, C.graphite, C.texte, C.texteDiscret
    end
    b.border:SetColor(border)
    b.fill:SetColor(fill)
    b.text:SetTextColor(text[1], text[2], text[3], 1)
    -- Chevron : vers le bas fermé, vers le haut ouvert.
    b.chevron:SetDirection(b.open and "up" or "down")
    b.chevron:SetColor(arrow)
end

local function closeMenu()
    if not menu or not menu.owner then return end
    local owner = menu.owner
    menu.owner = nil
    menu:Hide()
    catcher:Hide()
    owner.open = false
    updateDropdown(owner)
end

local function createMenu()
    -- Capte un clic n'importe où ailleurs pour fermer la liste.
    catcher = _G.CreateFrame("Frame", nil, _G.UIParent)
    catcher:SetAllPoints(_G.UIParent)
    catcher:SetFrameStrata("FULLSCREEN_DIALOG")
    catcher:EnableMouse(true)
    catcher:SetScript("OnMouseDown", closeMenu)
    catcher:EnableMouseWheel(true) -- la molette ferme aussi la liste (sinon le contenu défile dessous)
    catcher:SetScript("OnMouseWheel", closeMenu)
    catcher:Hide()

    menu = _G.CreateFrame("Frame", "CoeurUIMenuDeroulant", _G.UIParent)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetFrameLevel(catcher:GetFrameLevel() + 10)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu:Hide()
    CUI:CreateBorderedRect(menu, 4, C.or_, C.fond)
    menu.items = {}
end

local function menuItem(i)
    local item = menu.items[i]
    if item then return item end
    item = _G.CreateFrame("Button", nil, menu)
    item:SetHeight(26)
    item.bg = CUI:CreateRoundRect(item, 3, C.graphite)
    item.bullet = CUI:CreateText(item, "normal", "or_")
    item.bullet:SetJustifyV("MIDDLE")
    item.bullet:SetPoint("LEFT", 8, 0)
    item.bullet:SetText("•")
    item.text = CUI:CreateText(item, "normal", "texte")
    item.text:SetJustifyV("MIDDLE")
    item.text:SetPoint("LEFT", 22, 0)
    item.text:SetPoint("RIGHT", -8, 0)
    item.text:SetWordWrap(false)
    local function paint()
        if item.hover then
            item.bg:SetColor(C.graphiteClair)
            item.bg:SetShown(true)
        elseif item.selected then
            item.bg:SetColor(C.graphite)
            item.bg:SetShown(true)
        else
            item.bg:SetShown(false)
        end
        local color = item.selected and C.or_ or C.texte
        item.text:SetTextColor(color[1], color[2], color[3], 1)
        item.bullet:SetShown(item.selected)
    end
    item.paint = paint
    item:SetScript("OnEnter", function() item.hover = true; paint() end)
    item:SetScript("OnLeave", function() item.hover = false; paint() end)
    item:SetScript("OnClick", function()
        local owner = menu.owner
        closeMenu()
        if owner then owner.choose(item.value) end
    end)
    menu.items[i] = item
    return item
end

local function openMenu(b)
    if not menu then createMenu() end
    closeMenu()
    menu.owner = b
    b.open = true
    updateDropdown(b)

    local y = -4
    for i, option in ipairs(b.options) do
        local item = menuItem(i)
        item.value = option.value
        item.selected = option.value == b.value
        item.hover = false
        item.text:SetText(option.text)
        item:ClearAllPoints()
        item:SetPoint("TOPLEFT", 4, y)
        item:SetPoint("TOPRIGHT", -4, y)
        item.paint()
        item:Show()
        y = y - 26
    end
    for i = #b.options + 1, #menu.items do
        menu.items[i]:Hide()
    end
    menu:SetSize(b:GetWidth(), -y + 4)
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, -4)
    catcher:Show()
    menu:Show()
end

function CUI:CreateDropdown(parent, opts)
    local f = _G.CreateFrame("Frame", nil, parent)
    f:SetHeight(50)
    f.label = self:CreateText(f, "normal", "texte")
    f.label:SetPoint("TOPLEFT")
    f.label:SetText(opts.label or "")

    local b = _G.CreateFrame("Button", nil, f)
    b:SetSize(opts.width or 240, 28)
    b:SetPoint("TOPLEFT", 0, -22)
    b.border, b.fill = self:CreateBorderedRect(b, 4, C.bordure, C.graphite)
    b.text = self:CreateText(b, "normal", "texte")
    b.text:SetJustifyV("MIDDLE")
    b.text:SetPoint("LEFT", 10, 0)
    b.text:SetPoint("RIGHT", -28, 0)
    b.text:SetWordWrap(false)
    b.chevron = self:CreateChevron(b)
    b.chevron:SetPoint(b, "RIGHT", -14, 0)
    b.options = opts.options or {}
    f.button = b

    function f:SetValue(v)
        b.value = v
        local text = tostring(v)
        for _, option in ipairs(b.options) do
            if option.value == v then
                text = option.text
                break
            end
        end
        b.text:SetText(text)
    end

    function f:GetValue()
        return b.value
    end

    function f:SetEnabled(enabled)
        if not enabled and menu and menu.owner == b then closeMenu() end
        b:SetEnabled(enabled)
        f.label:SetTextColor(unpack(enabled and C.texte or C.texteDesactive))
        updateDropdown(b)
    end

    b.choose = function(v)
        if v == b.value then return end
        f:SetValue(v)
        if opts.onSelect then
            CUI:SafeCall("menu déroulant", opts.onSelect, v)
        end
    end

    b:SetScript("OnClick", function()
        if menu and menu.owner == b then
            closeMenu()
        else
            openMenu(b)
        end
    end)
    b:SetScript("OnEnter", function() b.hover = true; updateDropdown(b) end)
    b:SetScript("OnLeave", function() b.hover = false; updateDropdown(b) end)
    b:SetScript("OnHide", function()
        if menu and menu.owner == b then closeMenu() end
    end)
    b:SetScript("OnEnable", updateDropdown)
    b:SetScript("OnDisable", updateDropdown)

    f:SetValue(opts.value)
    updateDropdown(b)
    return f
end
