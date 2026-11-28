-- Fenêtres du jeu · Courrier (maquette « 7 · Courrier » validée le 28/11/2026) : la boîte aux lettres du jeu
-- (MailFrame : réception et envoi ; OpenMailFrame : lettre ouverte), même disposition :
--   - cadres ardoise sans médaillon ni métal, titre blanc, croix au trait ; boîte déplaçable par l'en-tête ;
--     onglets du bas en petites cases ;
--   - réception : lettres sur une case ardoise, objet en case carrée (liseré de qualité), expéditeur blanc,
--     sujet gris, jours restants aux couleurs du jeu, bande au survol ; pages en petites cases à chevron ;
--   - lettre : « De », « Sujet » gris, texte sur une case sombre (plus de parchemin), objets joints en cases ;
--   - envoi : champs en cases sombres, pièces jointes en cases, montant en petites cases, argent ou
--     contre-remboursement en ronds ; boutons de CœurUI.
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local issecret = _G.issecretvalue or function() return false end
local WHITE = "Interface\\Buttons\\WHITE8x8"
local PAGE_FILL = { 0.082, 0.094, 0.122, 1 } -- #15181F

local function tr() return CUI:Tr("FJ_COURRIER") end

local function hide(region) if region then CUI:SkinHide(region) end end

local function color(fs, c)
    if not fs then return end
    fs:SetTextColor(c[1], c[2], c[3])
    fs:SetShadowOffset(0, 0)
end

-- Couleur gardée : le jeu peut la changer, elle est remise.
local function keepColor(fs, c)
    if not fs then return end
    local busy = false
    _G.hooksecurefunc(fs, "SetTextColor", function(self)
        if busy then return end
        busy = true
        self:SetTextColor(c[1], c[2], c[3])
        busy = false
    end)
    color(fs, c)
end

-- Bouton du jeu : bouton de CœurUI, texte blanc (police du jeu recopiée, teinte changée ; inactif : gris du
-- jeu).
local function skinTextButton(b)
    if not b then return end
    CUI:SkinButton(b)
    local base = b.GetNormalFontObject and b:GetNormalFontObject()
    if not base then return end
    local font = _G.CoeurUIFontBoutonBlanc or _G.CreateFont("CoeurUIFontBoutonBlanc")
    font:CopyFontObject(base)
    font:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    font:SetShadowOffset(0, 0)
    b:SetNormalFontObject(font)
    b:SetHighlightFontObject(font)
end

-- Onglet du bas : petite case (petites capitales), aussi large que son texte.
local function skinTab(tab)
    if not tab then return end
    CUI:SkinTextTab(tab)
    local text = tab.Text or (tab.GetFontString and tab:GetFontString())
    if not text then return end
    -- Le jeu borne aussi la largeur du texte (il le coupe par « ... ») : bornes retirées à chaque fois.
    local busy = false
    local function fit()
        if busy then return end
        busy = true
        text:SetWidth(0)
        if text.SetMaxLines then text:SetMaxLines(1) end
        local w = text.GetUnboundedStringWidth and text:GetUnboundedStringWidth() or text:GetStringWidth()
        if type(w) == "number" and w > 0 then
            text:SetWidth(w + 2)
            tab:SetWidth(w + 30)
        end
        busy = false
    end
    _G.hooksecurefunc(text, "SetText", fit)
    _G.hooksecurefunc(text, "SetWidth", fit)
    _G.hooksecurefunc(tab, "SetWidth", fit)
    tab:HookScript("OnShow", fit)
    if type(_G.PanelTemplates_TabResize) == "function" then
        _G.hooksecurefunc("PanelTemplates_TabResize", function(t) if t == tab then fit() end end)
    end
    fit()
end

-- Case derrière une partie (liste, texte) : cadre à part, sous la partie.
local function caseBehind(region, parent, pad, fill)
    local box = _G.CreateFrame("Frame", nil, parent)
    box:SetPoint("TOPLEFT", region, "TOPLEFT", -pad, pad)
    box:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", pad, -pad)
    box:SetFrameLevel(math.max(0, parent:GetFrameLevel()))
    CUI:CreatePanel(box, { radius = 3, fill = fill or C.case, shadow = false })
    return box
end

-- Libellés d'un champ ou d'un cadre (« À : », « Frais de port ») : gris ; le texte tapé reste blanc.
local function greyLabels(frame)
    if not frame then return end
    for _, r in ipairs({ frame:GetRegions() }) do
        if r:GetObjectType() == "FontString" and r:GetDrawLayer() == "BACKGROUND" then color(r, C.texteDiscret) end
    end
end

-- Fenêtre : cadre ardoise, titre blanc, croix.
local function skinWindow(f, inset, titleName, closeName)
    CUI:SkinHideTextures(f)
    CUI:SkinWindow(f)
    if f.FrameGlow then hide(f.FrameGlow) end
    if inset then hide(inset) end
    CUI:SkinCloseButton(_G[closeName] or f.CloseButton)
    local title = _G[titleName]
    if title then
        color(title, C.texte)
        _G.hooksecurefunc(title, "SetTextColor", function(fs, r)
            if r ~= C.texte[1] then fs:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
        end)
    end
end

-- Petite case à chevron (pages) ; le libellé du jeu (« Préc. », « Suivant ») reste, en gris clair.
local function skinPageButton(b, angle)
    if not b then return end
    CUI:SkinIconButton(b, nil, "Chevron")
    if b.cuiPicto then b.cuiPicto:SetRotation(angle) end
    for _, r in ipairs({ b:GetRegions() }) do
        if r:GetObjectType() == "FontString" then color(r, C.texteSecondaire) end
    end
end

-- Réception ------------------------------------------------------------------------------------------------

local function skinInbox()
    hide(_G.InboxFrameBg)
    color(_G.InboxCurrentPage, C.texteDiscret)
    local first, last = _G.MailItem1, _G.MailItem7
    if first and last then
        local list = _G.CreateFrame("Frame", nil, _G.InboxFrame)
        list:SetPoint("TOPLEFT", first, "TOPLEFT", -6, 6)
        list:SetPoint("BOTTOMRIGHT", last, "BOTTOMRIGHT", 6, -6)
        list:SetFrameLevel(math.max(0, _G.InboxFrame:GetFrameLevel()))
        CUI:CreatePanel(list, { radius = 3, fill = PAGE_FILL, shadow = false })
    end
    for i = 1, 7 do
        local row = _G["MailItem" .. i]
        if row then
            CUI:SkinHideTextures(row)
            local band = row:CreateTexture(nil, "BACKGROUND", nil, 1)
            band:SetTexture(WHITE)
            band:SetVertexColor(0.122, 0.141, 0.188, 1) -- #1F2430
            band:SetPoint("TOPLEFT", -2, 1)
            band:SetPoint("BOTTOMRIGHT", 2, -1)
            band:Hide()
            color(_G["MailItem" .. i .. "Sender"], C.texte)
            color(_G["MailItem" .. i .. "Subject"], C.texteDiscret)
            -- Le jeu recolore l'expéditeur et le sujet (lu / non lu) : remis en blanc et en gris.
            keepColor(_G["MailItem" .. i .. "Sender"], C.texte)
            keepColor(_G["MailItem" .. i .. "Subject"], C.texteDiscret)
            local b = _G["MailItem" .. i .. "Button"]
            if b then
                CUI:SkinItemSlot(b)
                b:HookScript("OnEnter", function() band:Show() end)
                b:HookScript("OnLeave", function() band:Hide() end)
            end
        end
    end
    local inbox = _G.InboxFrame
    if inbox then
        skinPageButton(inbox.PrevPageButton or _G.InboxPrevPageButton, -math.pi / 2)
        skinPageButton(inbox.NextPageButton or _G.InboxNextPageButton, math.pi / 2)
    end
    skinTextButton(_G.OpenAllMail)
end

-- Envoi --------------------------------------------------------------------------------------------------

-- Case de pièce jointe (l'objet est l'image « normale » du bouton) : case du thème, image rognée carrée,
-- liseré de la qualité.
local function skinAttachment(b)
    if not b or b.cuiAttach then return end
    b.cuiAttach = true
    for _, r in ipairs({ b:GetRegions() }) do
        if r:GetObjectType() == "Texture" and r:GetDrawLayer() == "BACKGROUND" then hide(r) end
    end
    local panel = CUI:CreatePanel(b, { radius = 3, fill = C.case, shadow = false })
    local hl = b:GetHighlightTexture()
    if hl then
        hl:SetColorTexture(1, 1, 1, 0.08)
        hl:ClearAllPoints()
        hl:SetPoint("TOPLEFT", 2, -2)
        hl:SetPoint("BOTTOMRIGHT", -2, 2)
    end
    local qb = b.IconBorder
    local function sync()
        local n = b:GetNormalTexture()
        if n then
            n:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            n:ClearAllPoints()
            n:SetPoint("TOPLEFT", 2, -2)
            n:SetPoint("BOTTOMRIGHT", -2, 2)
        end
        local r, g, bl
        if qb and qb:IsShown() then r, g, bl = qb:GetVertexColor() end
        if r and not (issecret(r) or issecret(g) or issecret(bl))
            and not (math.abs(r - g) < 0.06 and math.abs(g - bl) < 0.06) then
            panel.border:SetColor({ r, g, bl, 1 })
        else
            panel.border:SetColor(C.lisereSombre)
        end
    end
    if qb then
        hide(qb)
        _G.hooksecurefunc(qb, "SetVertexColor", sync)
        _G.hooksecurefunc(qb, "Show", sync)
        _G.hooksecurefunc(qb, "Hide", sync)
    end
    b.cuiSync = sync
    sync()
end

-- Choix argent / contre-remboursement : rond du thème, point blanc quand il est choisi.
local function skinRadio(cb)
    if not cb or cb.cuiRadio then return end
    cb.cuiRadio = true
    CUI:SkinHideTextures(cb)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetCheckedTexture",
                              "GetDisabledCheckedTexture" }) do
        local t = cb[getter] and cb[getter](cb)
        if t then hide(t) end
    end
    local box = _G.CreateFrame("Frame", nil, cb)
    box:SetSize(12, 12)
    box:SetPoint("CENTER")
    local ring = CUI:CreatePanel(box, { radius = 6, fill = C.case, shadow = false })
    local dot = box:CreateTexture(nil, "OVERLAY")
    dot:SetTexture(CUI.MEDIA .. "Cercle")
    dot:SetSize(6, 6)
    dot:SetPoint("CENTER")
    dot:SetVertexColor(C.texte[1], C.texte[2], C.texte[3], 1)
    local label = cb.Text or (cb:GetName() and _G[cb:GetName() .. "Text"])
    local function paint()
        local on = cb:GetChecked() and true or false
        dot:SetShown(on)
        ring.border:SetColor(on and C.texteDiscret or C.bordureDiscrete)
        if label then color(label, on and C.texte or C.texteSecondaire) end
    end
    _G.hooksecurefunc(cb, "SetChecked", paint)
    cb:HookScript("OnClick", paint)
    cb:HookScript("OnShow", paint)
    paint()
end

local function skinSend()
    local f = _G.SendMailFrame
    if not f then return end
    CUI:SkinHideTextures(f, { [_G.SendMailErrorCoin or false] = true })
    hide(_G.SendStationeryBackgroundLeft)
    hide(_G.SendStationeryBackgroundRight)
    local scroll = _G.SendMailScrollFrame
    if scroll then
        caseBehind(scroll, f, 4)
        CUI:SkinScrollBar(scroll.ScrollBar)
    end
    for _, name in ipairs({ "SendMailNameEditBox", "SendMailSubjectEditBox", "SendMailMoneyGold",
                            "SendMailMoneySilver", "SendMailMoneyCopper" }) do
        local eb = _G[name]
        if eb then
            CUI:SkinEditBox(eb)
            greyLabels(eb)
        end
    end
    greyLabels(_G.SendMailCostMoneyFrame)
    color(_G.SendMailMoneyText, C.texteDiscret)
    hide(_G.SendMailMoneyInset)
    if _G.SendMailMoneyBg then CUI:SkinHideTextures(_G.SendMailMoneyBg) end
    for i = 1, 16 do skinAttachment(_G["SendMailAttachment" .. i]) end
    if type(_G.SendMailFrame_Update) == "function" then
        _G.hooksecurefunc("SendMailFrame_Update", function()
            for i = 1, 16 do
                local b = _G["SendMailAttachment" .. i]
                if b and b.cuiSync then b.cuiSync() end
            end
        end)
    end
    skinRadio(_G.SendMailSendMoneyButton)
    skinRadio(_G.SendMailCODButton)
    skinTextButton(_G.SendMailMailButton)
    skinTextButton(_G.SendMailCancelButton)
end

-- Lettre ouverte -----------------------------------------------------------------------------------------

-- Textes de la lettre (le jeu les écrit sombres, pour son parchemin) : gris clair.
local function recolorLetter()
    local body = _G.OpenMailBodyText
    if body and body.SetTextColor then
        local c = C.texteSecondaire
        if not pcall(body.SetTextColor, body, "P", c[1], c[2], c[3]) then pcall(body.SetTextColor, body, c[1], c[2], c[3]) end
    end
    local invoice = _G.OpenMailInvoiceFrame
    if invoice then
        for _, r in ipairs({ invoice:GetRegions() }) do
            if r:GetObjectType() == "FontString" then color(r, C.texteSecondaire) end
        end
        hide(_G.OpenMailArithmeticLine)
    end
    local consortium = _G.ConsortiumMailFrame
    if consortium then
        for _, r in ipairs({ consortium:GetRegions() }) do
            if r:GetObjectType() == "FontString" then color(r, C.texteSecondaire) end
        end
    end
end

local function skinOpenMail()
    local f = _G.OpenMailFrame
    if not f or f.cuiCourrier then return end
    f.cuiCourrier = true
    skinWindow(f, _G.OpenMailFrameInset, "OpenMailFrameTitleText", "OpenMailFrameCloseButton")
    color(_G.OpenMailSenderLabel, C.texteDiscret)
    color(_G.OpenMailSubjectLabel, C.texteDiscret)
    color(_G.OpenMailSubject, C.texteSecondaire)
    color(_G.OpenMailSender and _G.OpenMailSender.Name, C.texte)
    local att = _G.OpenMailAttachmentText
    if att then
        att:SetFont(CUI:GetFont(), 10, "")
        color(att, C.texteDiscret)
    end
    hide(_G.OpenStationeryBackgroundLeft)
    hide(_G.OpenStationeryBackgroundRight)
    local scroll = _G.OpenMailScrollFrame
    if scroll then
        caseBehind(scroll, f, 4)
        CUI:SkinScrollBar(scroll.ScrollBar)
    end
    for i = 1, 16 do CUI:SkinItemSlot(_G["OpenMailAttachmentButton" .. i]) end
    CUI:SkinItemSlot(_G.OpenMailLetterButton)
    CUI:SkinItemSlot(_G.OpenMailMoneyButton)
    for _, name in ipairs({ "OpenMailReplyButton", "OpenMailDeleteButton", "OpenMailCancelButton",
                            "OpenMailReportSpamButton" }) do
        skinTextButton(_G[name])
    end
    if type(_G.OpenMail_Update) == "function" then
        _G.hooksecurefunc("OpenMail_Update", function() CUI:SafeCall(tr(), recolorLetter) end)
    end
    f:HookScript("OnShow", function() CUI:SafeCall(tr(), recolorLetter) end)
    recolorLetter()
end

-- Boîte aux lettres ---------------------------------------------------------------------------------------

local function skinMail()
    local f = _G.MailFrame
    if not f or f.cuiCourrier or (f.IsForbidden and f:IsForbidden()) then return end
    f.cuiCourrier = true
    skinWindow(f, _G.MailFrameInset, "MailFrameTitleText", "MailFrameCloseButton")
    if type(M.db.positions) ~= "table" then M.db.positions = {} end
    CUI:SkinMovable(f, M.db.positions, "courrier", 24)
    for i = 1, 2 do skinTab(_G["MailFrameTab" .. i]) end
    skinInbox()
    skinSend()
    skinOpenMail()
end

local function setup()
    CUI:SafeCall(tr(), skinMail)
end

M.windows.courrier = { setup = setup }
