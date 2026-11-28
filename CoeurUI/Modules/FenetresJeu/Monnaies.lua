-- Fenêtres du jeu · Fiche du personnage · page Monnaies (maquette « fiche complète » validée le
-- 28/11/2026, planche « 1 bis ») : même grammaire que la Réputation.
--   - liste : sections repliables (chevron, petites capitales), monnaies : icône dans une petite case,
--     nom en gris clair, quantité en blanc, bande plus claire au survol ; défilement fin ;
--   - détail : titre en gras, trait sombre, textes gris, cases à cocher et bouton « Transférer » de CœurUI ;
--   - journal des transferts : fenêtre au cadre de CœurUI, croix grise.
-- Les lignes de monnaie n'ont pas été relevées (personnage sans monnaie) : habillées d'après les champs
-- habituels (Name, Count, CurrencyIcon / Icon, BackgroundHighlight).
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local function tr() return CUI:Tr("FJ_FICHE") end

local function iconOf(content)
    return content.CurrencyIcon or content.Icon or content.icon
end

local function skinRow(row)
    if row.StateIcon then
        CUI:SkinListHeader(row)
        return
    end
    local content = row.Content or row
    if row.cuiToken then return end
    row.cuiToken = true
    if content.BackgroundHighlight then CUI:SkinRowHighlight(content.BackgroundHighlight) end
    local name = content.Name
    if name then name:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3]) end
    local count = content.Count or content.Quantity
    if count then count:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
    local icon = iconOf(content)
    if icon and icon.GetObjectType and icon:GetObjectType() == "Texture" then
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        _G.hooksecurefunc(icon, "SetTexture", function(t) t:SetTexCoord(0.08, 0.92, 0.08, 0.92) end)
        local box = _G.CreateFrame("Frame", nil, content)
        box:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
        box:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
        box:SetFrameLevel(math.max(0, content:GetFrameLevel() - 1))
        CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
    end
end

-- Traits du jeu posés par-dessus la liste (« ...ScrollLine... ») : traits sombres.
local function skinLines(frame)
    for _, child in ipairs({ frame:GetChildren() }) do
        for _, r in ipairs({ child:GetRegions() }) do
            if r:GetObjectType() == "Texture" then
                local atlas = r.GetAtlas and r:GetAtlas()
                if type(atlas) == "string" and atlas:find("ScrollLine", 1, true) then CUI:SkinSeparator(r) end
            end
        end
    end
end

-- Texte gris clair, pour de bon : le jeu le recolore ou y met du blanc (« |cFFFFFFFF ») ; couleurs du
-- texte retirées et gris remis à chaque changement.
local function grey(fs)
    if fs.cuiGrey then return end
    fs.cuiGrey = true
    local busy = false
    local function apply()
        if busy then return end
        busy = true
        local text = fs:GetText()
        if type(text) == "string" and not (_G.issecretvalue and _G.issecretvalue(text)) and text:find("|c") then
            fs:SetText((text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:]*:", ""):gsub("|r", "")))
        end
        local c = C.texteSecondaire
        fs:SetTextColor(c[1], c[2], c[3])
        busy = false
    end
    _G.hooksecurefunc(fs, "SetText", apply)
    _G.hooksecurefunc(fs, "SetTextColor", apply)
    if fs.SetFormattedText then _G.hooksecurefunc(fs, "SetFormattedText", apply) end
    apply()
end

local function paintTexts(frame)
    if not frame then return end
    for _, r in ipairs({ frame:GetRegions() }) do
        if r:GetObjectType() == "FontString" then grey(r) end
    end
    for _, child in ipairs({ frame:GetChildren() }) do paintTexts(child) end
end

local function skinDetail(detail)
    if not detail then return end
    if detail.Title then
        detail.Title:SetFont(CUI:GetFont(), 14, "")
        detail.Title:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    end
    if detail.Subtitle then
        local c = C.texteDiscret
        detail.Subtitle:SetTextColor(c[1], c[2], c[3])
    end
    if detail.EmptyText then
        local c = C.texteDiscret
        detail.EmptyText:SetTextColor(c[1], c[2], c[3])
    end
    if detail.Divider then CUI:SkinSeparator(detail.Divider) end
    CUI:SkinScrollBar(detail.DescriptionScrollBar)
    CUI:SkinCheckbox(detail.InactiveCheckbox)
    CUI:SkinCheckbox(detail.BackpackCheckbox)
    CUI:SkinButton(detail.CurrencyTransferToggleButton)
    local desc = detail.Description and detail.Description.ScrollBox
    if desc and desc.Shadows then CUI:SkinHideTextures(desc.Shadows) end
    local function refresh()
        _G.C_Timer.After(0, function()
            CUI:SafeCall(tr(), paintTexts, desc and desc.ScrollTarget)
            CUI:SafeCall(tr(), paintTexts, detail.Content)
        end)
    end
    if desc and desc.Update then _G.hooksecurefunc(desc, "Update", refresh) end
    if detail.Title then _G.hooksecurefunc(detail.Title, "SetText", refresh) end
    detail:HookScript("OnShow", refresh)
    refresh()
end

-- Journal des transferts : petite fenêtre du jeu au cadre métallique » cadre de CœurUI.
local function skinTransferLog(log)
    if not log or (log.IsForbidden and log:IsForbidden()) or log.cuiPanel then return end
    CUI:SkinHideTextures(log)
    CUI:SkinWindow(log)
    CUI:SkinCloseButton(_G.CurrencyTransferLogCloseButton or log.CloseButton)
    local inset = _G.CurrencyTransferLogInset or log.Inset
    if inset then
        CUI:SkinHideTextures(inset)
        if inset.NineSlice then CUI:SkinHide(inset.NineSlice) end
    end
    if log.TitleContainer then
        local title = _G.CurrencyTransferLogTitleText
        if title then title:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
    end
    if log.FrameGlow then CUI:SkinHide(log.FrameGlow) end
    CUI:SkinScrollBar(log.ScrollBar)
    if log.ScrollBox and log.ScrollBox.Shadows then CUI:SkinHideTextures(log.ScrollBox.Shadows) end
    if log.EmptyLogMessage then
        local c = C.texteDiscret
        log.EmptyLogMessage:SetTextColor(c[1], c[2], c[3])
    end
end

local function skinTokens()
    local tf = _G.TokenFrame
    if not tf or (tf.IsForbidden and tf:IsForbidden()) then return end
    CUI:SkinHideTextures(tf)
    CUI:SkinScrollBar(tf.ScrollBar)
    local box = tf.ScrollBox
    if box then
        if box.Shadows then CUI:SkinHideTextures(box.Shadows) end
        skinLines(box)
        local function each()
            local target = box.ScrollTarget
            if not target then return end
            for _, row in ipairs({ target:GetChildren() }) do
                skinRow(row)
                if row.cuiPaint then row.cuiPaint() end
            end
        end
        if box.Update then _G.hooksecurefunc(box, "Update", function() CUI:SafeCall(tr(), each) end) end
        tf:HookScript("OnShow", function() CUI:SafeCall(tr(), each) end)
        each()
    end
    skinDetail(_G.TokenDetailFrame or tf.TokenDetailFrame)
    skinTransferLog(_G.CurrencyTransferLog)
end

M.fichePages = M.fichePages or {}
M.fichePages[#M.fichePages + 1] = skinTokens
