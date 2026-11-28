-- Fenêtres du jeu · Talents (maquette « 3 · Talents » validée le 28/11/2026, fond « illustré estompé ») :
-- l'onglet des talents de la fenêtre du grimoire (PlayerSpellsFrame.TalentsFrame), même disposition :
--   - haut : onglets Principale / Secondaire en petites capitales (le verrouillé grisé, notre cadenas),
--     « Talents restants » et son nombre dans une case (vert quand il en reste), recherche et réglages ;
--   - arbres : case ardoise ; l'illustration de classe du jeu gardée, estompée (35 %) ; plus de cadre doré
--     ni de séparations ; en-tête de chaque arbre : icône en case, points en petite case, nom en gras, trait ;
--   - talents : icône carrée en case ; indisponible gris et sombre, disponible liseré gris clair, en partie
--     liseré vert et rang vert, au maximum liseré blanc ; survol liseré doré ; liens en traits fins, plus
--     clairs quand ils sont ouverts ;
--   - bas : « Appliquer changements » et les autres boutons de CœurUI.
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local issecret = _G.issecretvalue or function() return false end
local ART_ALPHA = 0.35
local PAGE_FILL = { 0.082, 0.094, 0.122, 1 } -- #15181F
local GREEN = { 0.498, 0.788, 0.541 }       -- #7FC98A : couleur « actif » du thème

local function tr() return CUI:Tr("FJ_TALENTS") end

local function atlasOf(t)
    local a = t and t.GetAtlas and t:GetAtlas()
    if type(a) == "string" and not issecret(a) then return a end
end

-- Illustration de classe gardée, estompée : la transparence voulue par le jeu (animations) est multipliée.
local function fade(t)
    if not t or t.cuiFaded then return end
    t.cuiFaded = true
    local busy = false
    local function apply(_, a)
        if busy then return end
        busy = true
        local wanted = (type(a) == "number" and not issecret(a)) and a or 1
        t:SetAlpha(wanted * ART_ALPHA)
        busy = false
    end
    _G.hooksecurefunc(t, "SetAlpha", apply)
    apply(nil, t:GetAlpha() > 0 and 1 or 0)
end

-- Talents -------------------------------------------------------------------------------------------------

-- État d'un talent d'après le liseré du jeu (« talents-node-square-<état> »).
local function stateOf(b)
    local a = atlasOf(b.StateBorder) or ""
    if a:find("yellow", 1, true) or a:find("gold", 1, true) then return "max" end
    if a:find("green", 1, true) then return "part" end
    if a:find("gray", 1, true) or a:find("grey", 1, true) then return "dispo" end
    return "off"
end

local function skinNode(b)
    if b.cuiNode then
        if b.cuiPaint then b.cuiPaint() end
        return
    end
    b.cuiNode = true
    local icon = b.Icon
    for _, key in ipairs({ "Shadow", "StateBorder", "StateBorderHover", "Glow", "Ghost", "BorderSheen",
                           "SelectableGlow", "DisabledOverlay" }) do
        if b[key] then CUI:SkinHide(b[key]) end
    end
    for i = 1, 4 do
        if b["SpendTextShadow" .. i] then b["SpendTextShadow" .. i]:SetAlpha(0) end
    end
    if icon then
        if b.IconMask and icon.RemoveMaskTexture then pcall(icon.RemoveMaskTexture, icon, b.IconMask) end
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    local holder = _G.CreateFrame("Frame", nil, b)
    holder:SetPoint("TOPLEFT", -1, 1)
    holder:SetPoint("BOTTOMRIGHT", 1, -1)
    holder:SetFrameLevel(math.max(0, b:GetFrameLevel() - 1))
    local panel = CUI:CreatePanel(holder, { radius = 3, fill = C.case, shadow = false })
    -- Rang pris (maquette « 3 bis », façon B) : pastille centrée sous l'icône, à cheval sur le bord ;
    -- « 1/5 » en vert tant que le talent n'est pas complet, « 5 » en blanc quand il l'est. Le chiffre du
    -- jeu est caché ; le nôtre est écrit d'après le rang et le maximum que le jeu attache au talent.
    local spend = b.SpendText
    if spend then spend:SetAlpha(0) end
    local badge = _G.CreateFrame("Frame", nil, b)
    badge:SetHeight(16)
    badge:SetPoint("CENTER", b, "BOTTOM", 0, 0)
    badge:SetFrameLevel(b:GetFrameLevel() + 2)
    CUI:CreatePanel(badge, { radius = 4, fill = C.case, shadow = true })
    local rankText = badge:CreateFontString(nil, "OVERLAY")
    rankText:SetFont(CUI:GetFont(), 11, "")
    rankText:SetPoint("CENTER", 0, 0)
    badge:Hide()
    -- Rang et maximum : informations du talent, sinon le chiffre du jeu (sans maximum).
    local function ranks()
        local info = b.nodeInfo
        if not info and b.GetNodeInfo then
            local ok, res = pcall(b.GetNodeInfo, b)
            if ok then info = res end
        end
        local cur = info and (info.activeRank or info.currentRank)
        local max = info and info.maxRanks
        if type(cur) ~= "number" or issecret(cur) then
            cur = spend and tonumber(spend:GetText() or "")
        end
        if type(max) ~= "number" or issecret(max) then max = nil end
        return cur, max
    end
    local function paint()
        local state = stateOf(b)
        local border
        if b.cuiOver then
            border = C.or_
        elseif state == "max" then
            border = C.texte
        elseif state == "part" then
            border = GREEN
        elseif state == "dispo" then
            border = C.texteDiscret
        else
            border = C.lisereSombre
        end
        panel.border:SetColor(border)
        if icon then
            icon:SetDesaturated(state == "off")
            local k = state == "off" and 0.45 or 1
            icon:SetVertexColor(k, k, k, 1)
        end
        local cur, max = ranks()
        local shown = (state == "part" or state == "max") and cur and cur > 0
        if shown then
            local text
            if state == "max" then
                text = tostring(max or cur)
            else
                text = max and (cur .. "/" .. max) or tostring(cur)
            end
            rankText:SetText(text)
            local c = state == "max" and C.texte or GREEN
            rankText:SetTextColor(c[1], c[2], c[3])
            badge:SetWidth(math.max(22, rankText:GetStringWidth() + 12))
        end
        badge:SetShown(shown and true or false)
    end
    if b.StateBorder and b.StateBorder.SetAtlas then _G.hooksecurefunc(b.StateBorder, "SetAtlas", paint) end
    if icon then
        _G.hooksecurefunc(icon, "SetDesaturated", function(_, on)
            if (on and true or false) ~= (stateOf(b) == "off") then paint() end
        end)
    end
    if spend then
        _G.hooksecurefunc(spend, "SetText", paint)
        _G.hooksecurefunc(spend, "SetAlpha", function(fs, a) if a ~= 0 then fs:SetAlpha(0) end end)
    end
    b:HookScript("OnEnter", function() b.cuiOver = true paint() end)
    b:HookScript("OnLeave", function() b.cuiOver = false paint() end)
    b.cuiPaint = paint
    paint()
end

-- Lien entre deux talents (ligne et pointe) : trait fin, sombre tant que le lien est fermé, clair sinon.
local function skinEdge(e)
    local line, head = e.Line, e.ArrowHead
    if not line and not head then return end
    local function paint()
        local a = atlasOf(head) or ""
        local closed = a:find("locked", 1, true) or a:find("ghost", 1, true)
        local c = closed and C.bordureDiscrete or C.texteDiscret
        if line then
            if line.SetColorTexture then line:SetColorTexture(c[1], c[2], c[3], 1) end
            if line.SetThickness then line:SetThickness(2) end
        end
        if head then
            head:SetDesaturated(true)
            head:SetVertexColor(c[1], c[2], c[3], 1)
        end
    end
    if not e.cuiEdge then
        e.cuiEdge = true
        if head and head.SetAtlas then _G.hooksecurefunc(head, "SetAtlas", paint) end
    end
    paint()
end

local function skinTree(parent)
    if not parent then return end
    for _, child in ipairs({ parent:GetChildren() }) do
        if child.StateBorder then
            skinNode(child)
        elseif child.Line or child.ArrowHead then
            skinEdge(child)
        end
    end
end

-- En-tête d'arbre (icône ronde, anneau, points, nom, petite séparation) : icône carrée en case, points en
-- petite case, nom en gras, trait sombre.
local function skinHeader(h)
    if h.cuiTreeHeader then return end
    h.cuiTreeHeader = true
    for _, key in ipairs({ "MainRing", "TextBackground", "Divider" }) do
        if h[key] then CUI:SkinHide(h[key]) end
    end
    local icon
    for _, r in ipairs({ h:GetRegions() }) do
        local kind = r:GetObjectType()
        if kind == "Texture" and r ~= h.MainRing and r ~= h.TextBackground and r ~= h.Divider then icon = r end
    end
    if icon then
        for _, r in ipairs({ h:GetRegions() }) do
            if r:GetObjectType() == "MaskTexture" and icon.RemoveMaskTexture then pcall(icon.RemoveMaskTexture, icon, r) end
        end
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        local box = _G.CreateFrame("Frame", nil, h)
        box:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
        box:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
        box:SetFrameLevel(math.max(0, h:GetFrameLevel() - 1))
        CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
    end
    if h.Name then
        h.Name:SetFont(CUI:GetFont(), 16, "")
        h.Name:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
        h.Name:SetShadowOffset(0, 0)
    end
    if h.Text then
        local badge = _G.CreateFrame("Frame", nil, h)
        badge:SetSize(20, 16)
        badge:SetPoint("CENTER", h.Text, "CENTER")
        badge:SetFrameLevel(h:GetFrameLevel() + 1)
        CUI:CreatePanel(badge, { radius = 3, fill = C.fenetre, shadow = false })
        h.Text:SetParent(badge)
        h.Text:SetFont(CUI:GetFont(), 10, "")
        h.Text:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    end
end

-- Fenêtre ----------------------------------------------------------------------------------------------

local function skinTalents(tf)
    if not tf or tf.cuiTalents or (tf.IsForbidden and tf:IsForbidden()) then return end
    tf.cuiTalents = true
    -- Décor : fond de base, cadre doré, séparations, nuages et particules invisibles ; l'illustration de la
    -- classe gardée, estompée.
    local keep = { ClassBackground = true, OverlayBackgroundMid = true, OverlayBackgroundRight = true }
    for _, key in ipairs({ "Background", "BackgroundFlash", "BackgroundBorder", "DividerHorizontalLeft",
                           "DividerHorizontalRight", "DividerVerticalLeft", "DividerVerticalRight", "Clouds1",
                           "Clouds2", "AirParticlesClose", "AirParticlesFar" }) do
        if tf[key] then CUI:SkinHide(tf[key]) end
    end
    for key in pairs(keep) do fade(tf[key]) end
    -- Case ardoise sous l'illustration (zone des arbres).
    local page = _G.CreateFrame("Frame", nil, tf)
    page:SetFrameLevel(math.max(0, tf:GetFrameLevel() - 1))
    local area = tf.ButtonsParent or tf
    page:SetPoint("TOPLEFT", area, "TOPLEFT", 8, -2)
    page:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", -8, 4)
    CUI:CreatePanel(page, { radius = 3, fill = PAGE_FILL, shadow = false })

    -- Haut : onglets, talents restants, recherche, réglages.
    if tf.TabSystem then
        for _, tab in ipairs({ tf.TabSystem:GetChildren() }) do
            if tab:GetObjectType() == "Button" then CUI:SkinTextTab(tab) end
        end
    end
    local cur = tf.ClassCurrencyDisplay
    if cur then
        if cur.Border then CUI:SkinHide(cur.Border) end
        if cur.UnspentLabel then
            cur.UnspentLabel:SetFont(CUI:GetFont(), 12, "")
            local c = C.texteSecondaire
            cur.UnspentLabel:SetTextColor(c[1], c[2], c[3])
            cur.UnspentLabel:SetShadowOffset(0, 0)
        end
        local box = cur.CurrentAmountContainer
        local amount = box and box.CurrencyAmount
        if box then
            local back = _G.CreateFrame("Frame", nil, box)
            back:SetPoint("CENTER")
            back:SetSize(36, 28)
            back:SetFrameLevel(math.max(0, box:GetFrameLevel() - 1))
            CUI:CreatePanel(back, { radius = 3, fill = C.case, shadow = false })
        end
        if amount then
            amount:SetFont(CUI:GetFont(), 15, "")
            amount:SetShadowOffset(0, 0)
            local busy = false
            local function paint()
                if busy then return end
                busy = true
                local n = tonumber(amount:GetText() or "")
                local c = (n and n > 0) and GREEN or C.texte
                amount:SetTextColor(c[1], c[2], c[3])
                busy = false
            end
            _G.hooksecurefunc(amount, "SetText", paint)
            _G.hooksecurefunc(amount, "SetTextColor", paint)
            paint()
        end
    end
    CUI:SkinEditBox(tf.SearchBox)
    local opts = tf.SearchOptionsDropdown
    if opts then CUI:SkinIconButton(opts, opts.Arrow, "Chevron") end
    CUI:SkinSearchPreview(tf.SearchPreviewContainer, tf.SearchBox)

    -- Bas : boutons de CœurUI.
    for _, key in ipairs({ "ApplyButton", "InspectCopyButton" }) do CUI:SkinButton(tf[key]) end
    if tf.ActiveSpec and tf.ActiveSpec.ActivateButton then CUI:SkinButton(tf.ActiveSpec.ActivateButton) end
    for key, pictoName in pairs({ ResetButton = "Recharger", UndoButton = "TournerGauche" }) do
        local b = tf[key]
        if b then CUI:SkinIconButton(b, b.Icon, pictoName) end
    end
    for _, b in ipairs({ tf.ApplyButton, tf.ActiveSpec and tf.ActiveSpec.ActivateButton }) do
        if b and b.YellowGlow then CUI:SkinHide(b.YellowGlow) end
    end

    -- Arbres : talents, liens, en-têtes (créés et recréés par le jeu) : repris à chaque mise à jour.
    local function refresh()
        skinTree(tf.ButtonsParent)
        for _, child in ipairs({ tf:GetChildren() }) do
            if child.MainRing or (child.Name and child.Text and child.Divider) then skinHeader(child) end
        end
    end
    -- Une seule reprise par image, même si le jeu prévient plusieurs fois de suite.
    local pending = false
    local function later()
        if pending then return end
        pending = true
        _G.C_Timer.After(0, function()
            pending = false
            CUI:SafeCall(tr(), refresh)
        end)
    end
    tf:HookScript("OnShow", later)
    for _, fn in ipairs({ "LoadTalentTreeInternal", "LoadTalentTree", "UpdateTreeCurrencyInfo",
                          "OnTraitConfigUpdated", "MarkTreeDirty", "UpdateAllButtons" }) do
        if type(tf[fn]) == "function" then _G.hooksecurefunc(tf, fn, later) end
    end
    refresh()
    later()
end

local function setup()
    local function go()
        local f = _G.PlayerSpellsFrame
        if f and f.TalentsFrame then CUI:SafeCall(tr(), skinTalents, f.TalentsFrame) end
    end
    if _G.PlayerSpellsFrame then go() return end
    M:WhenLoaded("Blizzard_PlayerSpells", go)
end

M.windows.talents = { setup = setup }
