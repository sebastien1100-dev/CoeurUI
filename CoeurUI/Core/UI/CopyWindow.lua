-- Fenêtre « à copier » : un texte déjà sélectionné, à copier avec Ctrl+C. Un addon ne peut ni ouvrir
-- une page web ni écrire dans le presse-papiers : on montre le texte, le joueur copie.
--   CUI:ShowCopyWindow({
--       title = "Lien Wowhead · Le lien",       -- titre (déjà traduit)
--       label = "Adresse (déjà sélectionnée)",  -- petit texte au-dessus de la case
--       text = "https://...",                   -- le texte à copier
--       hint = "Ctrl+C pour copier...",         -- aide sous la case
--       multiline = true,                       -- plusieurs lignes (ex. discussion), avec défilement
--   })
-- Lecture seule : toute frappe remet le texte, qui reste sélectionné. Échap ou « Fermer » : fermée.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local window

local function readOnly(box)
    box:SetScript("OnTextChanged", function(self, user)
        if user and self.copyText then
            self:SetText(self.copyText)
            self:HighlightText()
        end
    end)
    box:SetScript("OnEscapePressed", function() window:Hide() end)
    box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    box:SetScript("OnMouseUp", function(self) self:HighlightText() end)
end

local function create()
    local f = _G.CreateFrame("Frame", "CoeurUICopie", _G.UIParent)
    f:SetPoint("CENTER", 0, 120)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    CUI:CreateBorderedRect(f, 6, C.or_, C.fenetre)

    local logo = f:CreateTexture(nil, "ARTWORK")
    logo:SetTexture(CUI.MEDIA .. "Logo")
    logo:SetSize(16, 16)
    logo:SetPoint("TOPLEFT", 14, -12)
    f.title = CUI:CreateText(f, "normal", "texte")
    f.title:SetPoint("LEFT", logo, "RIGHT", 8, 0)
    f.title:SetPoint("RIGHT", f, "RIGHT", -14, 0)
    f.title:SetWordWrap(false)
    f.label = CUI:CreateText(f, "petit", "texteDiscret")
    f.label:SetPoint("TOPLEFT", 14, -40)

    -- Une ligne.
    local box = _G.CreateFrame("EditBox", nil, f)
    box:SetPoint("TOPLEFT", 14, -56)
    box:SetPoint("TOPRIGHT", -14, -56)
    box:SetHeight(26)
    box:SetAutoFocus(false)
    box:SetFontObject(CUI.Fonts.normal)
    box:SetTextInsets(8, 8, 0, 0)
    CUI:CreateBorderedRect(box, 4, C.bordure, C.fond)
    readOnly(box)
    f.box = box

    -- Plusieurs lignes, dans une zone qui défile.
    local area = _G.CreateFrame("Frame", nil, f)
    area:SetPoint("TOPLEFT", 14, -56)
    area:SetPoint("BOTTOMRIGHT", -14, 72)
    CUI:CreateBorderedRect(area, 4, C.bordure, C.fond)
    local scroll = CUI:CreateScrollArea(area)
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -8, 6)
    local multi = _G.CreateFrame("EditBox", nil, scroll.child)
    multi:SetMultiLine(true)
    multi:SetAutoFocus(false)
    multi:SetFontObject(CUI.Fonts.petit)
    multi:SetPoint("TOPLEFT")
    readOnly(multi)
    -- Pour mesurer la hauteur du texte (la case n'a pas de taille d'elle-même : sans largeur ni
    -- hauteur posées, elle restait vide).
    local measure = scroll.child:CreateFontString(nil, "BACKGROUND")
    measure:SetFontObject(CUI.Fonts.petit)
    measure:SetWordWrap(true)
    measure:SetJustifyH("LEFT")
    measure:Hide()
    area:Hide()
    f.area, f.scroll, f.multi, f.measure = area, scroll, multi, measure

    f.hint = CUI:CreateText(f, "petit", "texteSecondaire")
    f.close = CUI:CreateButton(f, "")
    f.close:SetPoint("BOTTOMRIGHT", -12, 12)
    f.close:SetScript("OnClick", function() f:Hide() end)
    window = f
end

function CUI:ShowCopyWindow(opts)
    if not window then create() end
    local f = window
    local multiline = opts.multiline and true or false
    f:SetSize(multiline and 560 or 440, multiline and 380 or 150)
    f.title:SetText(opts.title or "")
    f.label:SetText(opts.label or "")
    f.close:SetLabel(L.FERMER)
    f.box:SetShown(not multiline)
    f.area:SetShown(multiline)
    f.hint:ClearAllPoints()
    if multiline then
        f.hint:SetPoint("TOPLEFT", f.area, "BOTTOMLEFT", 0, -8)
    else
        f.hint:SetPoint("TOPLEFT", f.box, "BOTTOMLEFT", 0, -8)
    end
    f.hint:SetText(opts.hint or "")
    local box = multiline and f.multi or f.box
    box.copyText = opts.text or ""
    box:SetText(box.copyText)
    f:Show()
    box:SetFocus()
    box:HighlightText()
    if multiline then
        -- Une fois la fenêtre affichée (tailles connues) : largeur et hauteur de la case posées
        -- d'après le texte, puis la zone descend en bas (les derniers messages sont en bas).
        _G.C_Timer.After(0, function()
            local width = math.max(100, f.scroll:GetWidth() - 8)
            f.measure:SetWidth(width)
            f.measure:SetText(box.copyText)
            local height = math.ceil(f.measure:GetStringHeight()) + 12
            f.multi:SetSize(width, height)
            f.multi:SetText(box.copyText)
            f.multi:HighlightText()
            f.scroll:SetContentHeight(height)
            local max = math.max(0, height - f.scroll:GetHeight())
            f.scroll:SetVerticalScroll(max)
        end)
    end
end

function CUI:HideCopyWindow()
    if window then window:Hide() end
end
