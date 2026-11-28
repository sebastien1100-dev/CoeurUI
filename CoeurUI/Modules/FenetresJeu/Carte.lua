-- Fenêtres du jeu · Carte et journal des quêtes (maquette « 5 · Carte et journal des quêtes » validée le
-- 28/11/2026) : la fenêtre « Carte & journal des quêtes » du jeu (WorldMapFrame et QuestMapFrame), même
-- disposition :
--   - cadre de CœurUI sans médaillon ni métal, titre blanc, agrandir / réduire et croix au trait ; déplaçable
--     par l'en-tête quand elle n'est pas agrandie ;
--   - carte : dessin et points du jeu gardés ; fil d'Ariane plat (case sombre, chevrons) ; filtre et repère au
--     trait en cases (pastille rouge cœur quand un filtre est posé) ; bouton qui replie le journal au chevron ;
--   - journal : case ardoise, recherche, compteur et réglages de CœurUI ; zones en petites capitales avec
--     chevron ; quête : titre de la couleur de difficulté (comme le suivi), état au trait (« ? » blanc à rendre,
--     « ... » gris en cours), case de suivi à coche ; onglets de côté à nos icônes ;
--   - détail : case ardoise, textes clairs, récompenses en cases carrées, boutons plats (« Abandonner » rouge).
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local issecret = _G.issecretvalue or function() return false end
local WHITE = "Interface\\Buttons\\WHITE8x8"
local PAGE_FILL = { 0.082, 0.094, 0.122, 1 } -- #15181F

local function tr() return CUI:Tr("FJ_CARTE") end

local function atlasOf(t)
    local a = t and t.GetAtlas and t:GetAtlas()
    if type(a) == "string" and not issecret(a) then return a end
    return ""
end

-- Toutes les textures d'un bouton, y compris ses textures d'état.
local function hideButtonTextures(b)
    if not b then return end
    CUI:SkinHideTextures(b)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t then CUI:SkinHide(t) end
    end
end

-- Une de nos icônes au trait posée au centre d'un cadre.
local function picto(parent, name, size)
    local t = parent:CreateTexture(nil, "OVERLAY")
    t:SetTexture(CUI.MEDIA .. "Icones\\" .. name)
    t:SetSize(size, size)
    t:SetPoint("CENTER")
    return t
end

-- Bouton à icône sans case (agrandir, réglages...) : notre icône grise, blanche au survol.
local function skinPictoButton(b, name, size, angle)
    if not b or b.cuiPictoButton then return end
    b.cuiPictoButton = true
    hideButtonTextures(b)
    if b.Icon then CUI:SkinHide(b.Icon) end
    if b.HighlightIcon then CUI:SkinHide(b.HighlightIcon) end
    local t = picto(b, name, size or 14)
    if angle then t:SetRotation(angle) end
    local function paint(over)
        local c = over and C.texte or C.texteDiscret
        t:SetVertexColor(c[1], c[2], c[3], 1)
    end
    paint(false)
    b:HookScript("OnEnter", function() paint(true) end)
    b:HookScript("OnLeave", function() paint(false) end)
    return t
end

-- Case ardoise derrière une partie (liste des quêtes, détail).
local function page(parent, level)
    local f = _G.CreateFrame("Frame", nil, parent)
    f:SetFrameLevel(math.max(0, level or (parent:GetFrameLevel() - 1)))
    CUI:CreatePanel(f, { radius = 3, fill = PAGE_FILL, shadow = false })
    return f
end

-- Petite case du thème derrière une région (icône de récompense).
local function caseBehind(region, parent, pad)
    local box = _G.CreateFrame("Frame", nil, parent)
    box:SetPoint("TOPLEFT", region, "TOPLEFT", -pad, pad)
    box:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", pad, -pad)
    box:SetFrameLevel(math.max(0, parent:GetFrameLevel() - 1))
    return CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
end

-- Fil d'Ariane (NavBar) ---------------------------------------------------------------------------------------

-- Un bouton du fil : décor du jeu caché, texte gris clair (blanc : le dernier, ou survolé), bande au survol ;
-- son menu : notre chevron vers le bas ; un petit chevron vers la droite le sépare du précédent.
local function skinCrumb(b, first)
    if not b or b.cuiCrumb then return end
    b.cuiCrumb = true
    hideButtonTextures(b)
    local name = b.GetName and b:GetName()
    if name and _G[name .. "Left"] then CUI:SkinHide(_G[name .. "Left"]) end
    local band = b:CreateTexture(nil, "BACKGROUND", nil, 1)
    band:SetTexture(WHITE)
    band:SetVertexColor(C.panneau[1], C.panneau[2], C.panneau[3], 1)
    band:SetPoint("TOPLEFT", 2, -4)
    band:SetPoint("BOTTOMRIGHT", -2, 4)
    band:Hide()
    b.cuiBand = band
    if not first then
        local sep = picto(b, "Chevron", 10)
        sep:ClearAllPoints()
        sep:SetPoint("CENTER", b, "LEFT", 0, 0)
        sep:SetRotation(math.pi / 2)
        sep:SetVertexColor(C.bordureDiscrete[1], C.bordureDiscrete[2], C.bordureDiscrete[3], 1)
    end
    local arrow = b.MenuArrowButton
    if arrow then
        hideButtonTextures(arrow)
        if arrow.Art then CUI:SkinHide(arrow.Art) end
        b.cuiArrow = picto(arrow, "Chevron", 12)
        arrow:HookScript("OnEnter", function() b.cuiOver = true if b.cuiPaint then b.cuiPaint() end end)
        arrow:HookScript("OnLeave", function() b.cuiOver = false if b.cuiPaint then b.cuiPaint() end end)
    end
    b:HookScript("OnEnter", function() b.cuiOver = true if b.cuiPaint then b.cuiPaint() end end)
    b:HookScript("OnLeave", function() b.cuiOver = false if b.cuiPaint then b.cuiPaint() end end)
end

local function paintCrumbs(bar)
    local list = bar.navList
    if type(list) ~= "table" then return end
    for i, b in ipairs(list) do
        skinCrumb(b, i == 1)
        local last = i == #list
        b.cuiPaint = function()
            local fs = b.GetFontString and b:GetFontString() or b.text
            local on = last or b.cuiOver
            local c = on and C.texte or C.texteSecondaire
            if fs then
                fs:SetTextColor(c[1], c[2], c[3])
                fs:SetShadowOffset(0, 0)
            end
            if b.cuiBand then b.cuiBand:SetShown(last or b.cuiOver) end
            if b.cuiArrow then
                local a = b.cuiOver and C.texte or C.texteDiscret
                b.cuiArrow:SetVertexColor(a[1], a[2], a[3], 1)
            end
        end
        b.cuiPaint()
    end
end

local function skinNavBar(bar)
    if not bar or bar.cuiNav then return end
    bar.cuiNav = true
    CUI:SkinHideTextures(bar)
    if bar.overlay then CUI:SkinHideTextures(bar.overlay) end
    for _, key in ipairs({ "InsetBorderBottomLeft", "InsetBorderBottomRight", "InsetBorderBottom",
                           "InsetBorderLeft", "InsetBorderRight" }) do
        if bar[key] then CUI:SkinHide(bar[key]) end
    end
    local box = _G.CreateFrame("Frame", nil, bar)
    box:SetPoint("TOPLEFT", 0, -1)
    box:SetPoint("BOTTOMRIGHT", 0, 1)
    box:SetFrameLevel(math.max(0, bar:GetFrameLevel() - 1))
    CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
    local overflow = _G.WorldMapFrameOverflowButton or bar.overflowButton
    if overflow then skinPictoButton(overflow, "Chevron", 12, -math.pi / 2) end
    local function refresh() CUI:SafeCall(tr(), paintCrumbs, bar) end
    if type(_G.NavBar_AddButton) == "function" then
        _G.hooksecurefunc("NavBar_AddButton", function(self) if self == bar then refresh() end end)
    end
    if bar.Refresh then _G.hooksecurefunc(bar, "Refresh", refresh) end
    bar:HookScript("OnShow", refresh)
    refresh()
end

-- Boutons posés sur la carte -----------------------------------------------------------------------------------

-- Liste déroulante des étages (« common-dropdown-textholder » : Background, Arrow, Text) : case sombre, chevron.
local function skinFloorDropdown(dd)
    if not dd or dd.cuiDropdown then return end
    dd.cuiDropdown = true
    if dd.Background then CUI:SkinHide(dd.Background) end
    if dd.Arrow then CUI:SkinHide(dd.Arrow) end
    local panel = CUI:CreatePanel(dd, { radius = 3, fill = C.case, shadow = false })
    local chevron = picto(dd, "Chevron", 12)
    chevron:ClearAllPoints()
    chevron:SetPoint("RIGHT", dd, "RIGHT", -8, 0)
    if dd.Text then dd.Text:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
    local function paint(over)
        local c = over and C.texte or C.texteDiscret
        chevron:SetVertexColor(c[1], c[2], c[3], 1)
        panel.border:SetColor(over and C.texteDiscret or C.lisereSombre)
    end
    paint(false)
    dd:HookScript("OnEnter", function() paint(true) end)
    dd:HookScript("OnLeave", function() paint(false) end)
end

-- Filtres de la carte : case, entonnoir au trait ; « remettre à zéro » du jeu (croix rouge, montrée quand un
-- filtre est posé) : une pastille rouge cœur dans le coin, toujours cliquable.
local function skinFilterButton(b)
    if not b or b.cuiFilter then return end
    b.cuiFilter = true
    CUI:SkinIconButton(b, b.Icon, "Filtre")
    local reset = b.ResetButton
    if reset then
        hideButtonTextures(reset)
        reset:ClearAllPoints()
        reset:SetPoint("CENTER", b, "TOPRIGHT", -6, -6)
        reset:SetSize(12, 12)
        local dot = reset:CreateTexture(nil, "OVERLAY")
        dot:SetTexture(CUI.MEDIA .. "Cercle")
        dot:SetSize(7, 7)
        dot:SetPoint("CENTER")
        dot:SetVertexColor(C.coeur[1], C.coeur[2], C.coeur[3], 1)
    end
end

-- Repère : case, épingle au trait ; blanche quand un repère est posé (« Waypoint-MapPin-Tracked »).
local function skinPinButton(b)
    if not b or b.cuiPin then return end
    b.cuiPin = true
    local icon = b.Icon
    CUI:SkinIconButton(b, icon, "Repere")
    local function paint()
        local on = atlasOf(icon):find("Untracked", 1, true) == nil and atlasOf(icon) ~= ""
        local over = b:IsMouseOver()
        local c = (on or over) and C.texte or C.texteSecondaire
        if b.cuiPicto then b.cuiPicto:SetVertexColor(c[1], c[2], c[3], 1) end
        if b.cuiPanel then b.cuiPanel.border:SetColor((on or over) and C.texteDiscret or C.lisereSombre) end
    end
    if icon and icon.SetAtlas then _G.hooksecurefunc(icon, "SetAtlas", paint) end
    b:HookScript("OnLeave", paint)
    paint()
end

local function skinOverlays(f)
    if type(f.overlayFrames) == "table" then
        for _, o in ipairs(f.overlayFrames) do
            if o.Background and o.Arrow and o.Text then skinFloorDropdown(o) end
        end
    end
    for _, child in ipairs({ f:GetChildren() }) do
        if child.Background and child.Arrow and child.Text and atlasOf(child.Background):find("dropdown", 1, true) then
            skinFloorDropdown(child)
        end
    end
    skinFilterButton(f.WorldMapTrackingOptionsButton)
    skinPinButton(f.WorldMapTrackingPinButton)
    local toggle = f.SidePanelToggle
    if toggle then
        -- Journal ouvert : chevron vers la droite (le replier) ; replié : vers la gauche (l'ouvrir).
        for key, angle in pairs({ CloseButton = math.pi / 2, OpenButton = -math.pi / 2 }) do
            local b = toggle[key]
            if b then
                CUI:SkinIconButton(b, nil, "Chevron")
                if b.cuiPicto then b.cuiPicto:SetRotation(angle) end
            end
        end
    end
end

-- Journal : liste des quêtes ----------------------------------------------------------------------------------

-- Case de suivi (cadre Checkbox : case « ticksquare », coche CheckMark jaune) : petite case du thème, coche au
-- trait blanche, montrée quand celle du jeu l'est.
local function skinTrackBox(cb)
    if not cb or cb.cuiTrack then return end
    cb.cuiTrack = true
    local mark = cb.CheckMark
    CUI:SkinHideTextures(cb)
    local panel = CUI:CreatePanel(cb, { radius = 3, fill = C.case, shadow = false })
    local tick = {}
    for i, spec in ipairs({ { 4, 1.8, -2, -1, -45 }, { 7, 1.8, 1.2, 0.4, 50 } }) do
        local t = cb:CreateTexture(nil, "OVERLAY")
        t:SetTexture(WHITE)
        t:SetVertexColor(C.texte[1], C.texte[2], C.texte[3], 1)
        t:SetSize(spec[1], spec[2])
        t:SetPoint("CENTER", spec[3], spec[4])
        t:SetRotation(math.rad(spec[5]))
        tick[i] = t
    end
    local function paint()
        local on = mark and mark:IsShown()
        if issecret(on) then on = true end
        for _, t in ipairs(tick) do t:SetShown(on and true or false) end
        panel.border:SetColor(on and C.texteDiscret or C.bordureDiscrete)
    end
    if mark then
        _G.hooksecurefunc(mark, "Show", paint)
        _G.hooksecurefunc(mark, "Hide", paint)
        if mark.SetShown then _G.hooksecurefunc(mark, "SetShown", paint) end
    end
    paint()
end

-- Titre d'une quête (Text) : la couleur de difficulté que le jeu lui donne est gardée, comme dans le suivi
-- des quêtes (demandé le 28/11/2026, à la place du point de couleur de la maquette) ; notée pour le titre du
-- détail.
local function skinQuestTitle(row)
    skinTrackBox(row.Checkbox)
    local text = row.Text
    if not text or row.cuiTitle then return end
    row.cuiTitle = true
    local function note()
        local r, g, b = text:GetTextColor()
        if type(r) == "number" and not (issecret(r) or issecret(g) or issecret(b)) then row.cuiDiff = { r, g, b } end
    end
    _G.hooksecurefunc(text, "SetTextColor", note)
    note()
end

-- Point de quête de la liste (rond du jeu, Display.Icon : « TurnIn » à rendre, sinon en cours) : notre « ? »
-- blanc ou nos « ... » gris (blancs pour la quête suivie de près, « SuperTracked »).
local function skinQuestPOI(b)
    if not b or b.cuiPOI then return end
    b.cuiPOI = true
    hideButtonTextures(b)
    local icon = b.Display and b.Display.Icon
    if b.Display then CUI:SkinHideTextures(b.Display) end
    local t = picto(b, "QueteEnCours", 16)
    t:SetPoint("CENTER", -3, 0)
    local normal = b.GetNormalTexture and b:GetNormalTexture() or b.NormalTexture
    local function paint()
        local a = atlasOf(icon)
        local done = a:find("TurnIn", 1, true) or a:find("Complete", 1, true)
        t:SetTexture(CUI.MEDIA .. "Icones\\" .. (done and "QueteRendre" or "QueteEnCours"))
        local focus = atlasOf(normal):find("SuperTracked", 1, true) or b.cuiOver
        local c = (done or focus) and C.texte or C.texteDiscret
        t:SetVertexColor(c[1], c[2], c[3], 1)
    end
    if icon and icon.SetAtlas then _G.hooksecurefunc(icon, "SetAtlas", paint) end
    if normal and normal.SetAtlas then _G.hooksecurefunc(normal, "SetAtlas", paint) end
    b:HookScript("OnEnter", function() b.cuiOver = true paint() end)
    b:HookScript("OnLeave", function() b.cuiOver = false paint() end)
    b.cuiPaint = paint
    paint()
end

local function skinQuestRows(contents)
    if not contents then return end
    for _, child in ipairs({ contents:GetChildren() }) do
        if child.CollapseButton and child.ButtonText then
            CUI:SkinCollapseHeader(child)
        elseif child.Checkbox and child.Text then
            skinQuestTitle(child)
        elseif child.Display then
            skinQuestPOI(child)
            if child.cuiPaint then child.cuiPaint() end
        end
    end
    local story = contents.StoryHeader
    if story and not story.cuiStory then
        story.cuiStory = true
        CUI:SkinHideTextures(story)
    end
    local sep = contents.Separator
    if sep and sep.Divider then CUI:SkinHide(sep.Divider) end
end

local function skinQuestList(qs)
    if not qs or qs.cuiList then return end
    qs.cuiList = true
    for _, key in ipairs({ "Background", "Edge" }) do
        if qs[key] then CUI:SkinHide(qs[key]) end
    end
    if qs.BorderFrame then CUI:SkinHideTextures(qs.BorderFrame) end
    local bg = page(qs:GetParent() or qs, qs:GetFrameLevel() - 1)
    bg:SetPoint("LEFT", qs, "LEFT", 0, 0)
    bg:SetPoint("RIGHT", qs, "RIGHT", 0, 0)
    bg:SetPoint("BOTTOM", qs, "BOTTOM", 0, 0)
    if qs.SearchBox then
        bg:SetPoint("TOP", qs.SearchBox, "BOTTOM", 0, -6)
        CUI:SkinEditBox(qs.SearchBox)
    else
        bg:SetPoint("TOP", qs, "TOP", 0, 0)
    end
    if qs.SettingsDropdown then skinPictoButton(qs.SettingsDropdown, "Reglages", 16) end
    local count = _G.QuestLogCount
    if count then
        for _, key in ipairs({ "Left", "Right", "Middle" }) do
            if count[key] then CUI:SkinHide(count[key]) end
        end
        CUI:CreatePanel(count, { radius = 3, fill = C.case, shadow = false, inset = { -2, 0 } })
        local fs = _G.QuestLogQuestCount
        if fs then fs:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3]) end
    end
    CUI:SkinScrollBar(qs.ScrollBar)
    local function refresh() CUI:SafeCall(tr(), skinQuestRows, qs.Contents) end
    if type(_G.QuestLogQuests_Update) == "function" then _G.hooksecurefunc("QuestLogQuests_Update", refresh) end
    qs:HookScript("OnShow", refresh)
    refresh()
end

-- Journal : détail d'une quête --------------------------------------------------------------------------------

-- Récompense (Icon, NameFrame, Name) : icône carrée en case, sans le cadre du jeu.
local function skinReward(b)
    if not b or b.cuiReward or not b.Icon then return end
    b.cuiReward = true
    if b.NameFrame then CUI:SkinHide(b.NameFrame) end
    if b.IconBorder then CUI:SkinHide(b.IconBorder) end
    CUI:SquareItemIcon(b, b.Icon)
    caseBehind(b.Icon, b, 2)
end

-- Textes du détail (le jeu les écrit sombres, pour son fond parchemin) : titres blancs, le reste gris clair ;
-- noms d'objets des récompenses (couleur de qualité) gardés. Ces textes servent aussi à la fenêtre de quête
-- des PNJ (parchemin) : leur couleur d'origine est notée, et rendue quand le jeu les affiche ailleurs.
local original = setmetatable({}, { __mode = "k" })
-- Titres de section (« Description », « Objectifs ») : petites capitales grises ; titre de la quête : police
-- de CœurUI en gras. Police, texte et couleur d'origine notés pour la fenêtre des PNJ.
local fonts = {}
local function styleHeader(fs, size, color, upper)
    if not fs then return end
    if not fonts[fs] then
        local font, fsize, flags = fs:GetFont()
        fonts[fs] = { font, fsize, flags, fs:GetText() }
    end
    fs:SetFont(CUI:GetFont(), size, "")
    if upper then fs:SetText(CUI:Upper(fonts[fs][4])) end
    fs:SetTextColor(color[1], color[2], color[3])
    fs:SetShadowOffset(0, 0)
end

-- Titre sans le niveau ni les codes de couleur (« [9] Princesse doit mourir ! » » « Princesse doit mourir ! »).
local function bareTitle(t)
    if type(t) ~= "string" or issecret(t) then return nil end
    t = t:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("^%s*%[[^%]]*%]%s*", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return t
end

-- Couleur de difficulté de la quête affichée (comme le suivi des quêtes) : d'abord par le jeu (quête
-- choisie, son niveau), sinon celle du point de la même quête dans la liste ; blanc à défaut.
local function titleColor(d)
    local log = _G.C_QuestLog
    if log and log.GetInfo and log.GetLogIndexForQuestID and type(_G.GetQuestDifficultyColor) == "function" then
        local id = d and d.questID
        if (type(id) ~= "number" or issecret(id)) and type(_G.QuestMapFrame_GetDetailQuestID) == "function" then
            id = _G.QuestMapFrame_GetDetailQuestID()
        end
        if (type(id) ~= "number" or issecret(id)) and log.GetSelectedQuest then id = log.GetSelectedQuest() end
        if type(id) == "number" and not issecret(id) and id > 0 then
            local index = log.GetLogIndexForQuestID(id)
            local info = index and log.GetInfo(index)
            local level = info and info.level
            if type(level) == "number" and not issecret(level) and level > 0 then
                local c = _G.GetQuestDifficultyColor(level)
                if c then return { c.r, c.g, c.b } end
            end
        end
    end
    local header = _G.QuestInfoTitleHeader
    local wanted = header and bareTitle(header:GetText())
    local contents = _G.QuestScrollFrame and _G.QuestScrollFrame.Contents
    if wanted and wanted ~= "" and contents then
        for _, row in ipairs({ contents:GetChildren() }) do
            if row.cuiDiff and row.Text and bareTitle(row.Text:GetText()) == wanted then return row.cuiDiff end
        end
    end
    return C.texte
end

-- Couleur voulue pour le titre tant que le détail est affiché (le jeu peut le repeindre après nous).
local titleWanted
local function styleHeaders(d)
    styleHeader(_G.QuestInfoDescriptionHeader, 10, C.texteDiscret, true)
    styleHeader(_G.QuestInfoObjectivesHeader, 10, C.texteDiscret, true)
    titleWanted = titleColor(d)
    styleHeader(_G.QuestInfoTitleHeader, 15, titleWanted, false)
    local header = _G.QuestInfoTitleHeader
    if header and not header.cuiTitleHook then
        header.cuiTitleHook = true
        local busy = false
        _G.hooksecurefunc(header, "SetTextColor", function(fs)
            if busy or not titleWanted or not (d and d:IsShown()) then return end
            busy = true
            fs:SetTextColor(titleWanted[1], titleWanted[2], titleWanted[3])
            busy = false
        end)
    end
end

local function restoreHeaders()
    for fs, f in pairs(fonts) do
        if f[1] then fs:SetFont(f[1], f[2], f[3] or "") end
        if fs ~= _G.QuestInfoTitleHeader and type(f[4]) == "string" then fs:SetText(f[4]) end
    end
end

local function recolorDetails(root, depth)
    if not root or depth > 4 then return end
    for _, r in ipairs({ root:GetRegions() }) do
        if r:GetObjectType() == "FontString" then
            if not original[r] then
                local or_, og, ob = r:GetTextColor()
                local sx, sy = r:GetShadowOffset()
                if type(or_) == "number" and not issecret(or_) then original[r] = { or_, og, ob, sx or 0, sy or 0 } end
            end
            local _, size = r:GetFont()
            local big = r == _G.QuestInfoTitleHeader or (type(size) == "number" and not issecret(size) and size >= 15)
            local c = big and C.texte or C.texteSecondaire
            r:SetTextColor(c[1], c[2], c[3])
            r:SetShadowOffset(0, 0)
        end
    end
    for _, child in ipairs({ root:GetChildren() }) do
        -- Bouton de récompense (icône) : habillé ; son nom garde la couleur de qualité.
        if child.Icon and child.Name then
            skinReward(child)
        else
            recolorDetails(child, depth + 1)
        end
    end
end

local function skinRewards(frame)
    if not frame then return end
    if type(frame.RewardButtons) == "table" then
        for _, b in ipairs(frame.RewardButtons) do skinReward(b) end
    end
    for _, child in ipairs({ frame:GetChildren() }) do
        if child.Icon and child.Name then skinReward(child) end
    end
end

local function skinDetails(d)
    if not d or d.cuiDetails then return end
    d.cuiDetails = true
    for _, key in ipairs({ "Bg", "SealMaterialBG" }) do
        if d[key] then CUI:SkinHide(d[key]) end
    end
    if d.BorderFrame then CUI:SkinHideTextures(d.BorderFrame) end
    local bg = page(d, d:GetFrameLevel())
    bg:SetAllPoints(d)
    local back = d.BackFrame
    if back then
        CUI:SkinHideTextures(back)
        CUI:SkinButton(back.BackButton)
    end
    for _, key in ipairs({ "AbandonButton", "ShareButton", "TrackButton" }) do
        local b = d[key]
        if b then
            CUI:SkinHideTextures(b)
            CUI:SkinButton(b)
        end
    end
    -- Texte des boutons : blanc, « Abandonner » en rouge cœur (police du bouton recopiée, teinte changée ;
    -- bouton inactif : gris du jeu).
    local function textColor(b, fontName, color)
        local base = b and b.GetNormalFontObject and b:GetNormalFontObject()
        if not base then return end
        local font = _G[fontName] or _G.CreateFont(fontName)
        font:CopyFontObject(base)
        font:SetTextColor(color[1], color[2], color[3])
        font:SetShadowOffset(0, 0)
        b:SetNormalFontObject(font)
        b:SetHighlightFontObject(font)
    end
    textColor(d.AbandonButton, "CoeurUIFontBoutonRouge", C.coeur)
    textColor(d.ShareButton, "CoeurUIFontBoutonBlanc", C.texte)
    textColor(d.TrackButton, "CoeurUIFontBoutonBlanc", C.texte)
    textColor(back and back.BackButton, "CoeurUIFontBoutonBlanc", C.texte)
    skinPictoButton(d.DestinationMapButton, "Repere", 16)
    local rf = d.RewardsFrameContainer and d.RewardsFrameContainer.RewardsFrame
    if rf then
        for _, key in ipairs({ "Background", "Top", "Bottom" }) do
            if rf[key] then CUI:SkinHide(rf[key]) end
        end
        if rf.Label then
            rf.Label:SetFont(CUI:GetFont(), 10, "")
            rf.Label:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
            rf.Label:SetText(CUI:Upper(rf.Label:GetText()))
        end
    end
    local scroll = _G.QuestMapDetailsScrollFrame
    if scroll then CUI:SkinScrollBar(scroll.ScrollBar) end
    local function refresh()
        if scroll then recolorDetails(scroll.Contents or scroll, 0) end
        styleHeaders(d)
        if rf then recolorDetails(rf, 0) skinRewards(rf) end
        skinRewards(_G.MapQuestInfoRewardsFrame)
        if _G.MapQuestInfoRewardsFrame then recolorDetails(_G.MapQuestInfoRewardsFrame, 0) end
    end
    if type(_G.QuestInfo_Display) == "function" then
        -- Le jeu affiche le détail en deux fois : le texte (dans la liste défilante), puis les récompenses
        -- (dans RewardsFrame) ; tout cadre rangé dans le détail compte, le reste est la fenêtre d'un PNJ.
        local function inDetails(frame)
            local depth = 0
            while frame and depth < 8 do
                if frame == d then return true end
                frame = frame.GetParent and frame:GetParent()
                depth = depth + 1
            end
            return false
        end
        _G.hooksecurefunc("QuestInfo_Display", function(_, parent)
            if inDetails(parent) or (parent == nil and d:IsShown()) then
                CUI:SafeCall(tr(), refresh)
            else
                -- Fenêtre de quête d'un PNJ : couleurs d'origine rendues.
                titleWanted = nil
                for fs, c in pairs(original) do
                    fs:SetTextColor(c[1], c[2], c[3])
                    fs:SetShadowOffset(c[4], c[5])
                end
                restoreHeaders()
            end
        end)
    end
    d:HookScript("OnShow", function()
        _G.C_Timer.After(0, function() CUI:SafeCall(tr(), refresh) end)
    end)
end

-- Évènements (liste à fond parchemin) : fond caché sur la même case ardoise.
local function skinEvents(ev)
    if not ev or ev.cuiEvents then return end
    ev.cuiEvents = true
    CUI:SkinHideTextures(ev)
    if ev.BorderFrame then CUI:SkinHideTextures(ev.BorderFrame) end
    if ev.ScrollBox then
        if ev.ScrollBox.Background then CUI:SkinHide(ev.ScrollBox.Background) end
        if ev.ScrollBox.Shadows then CUI:SkinHideTextures(ev.ScrollBox.Shadows) end
    end
    local bg = page(ev, ev:GetFrameLevel())
    bg:SetAllPoints(ev.ScrollBox or ev)
    CUI:SkinScrollBar(ev.ScrollBar)
end

local function skinQuestLog(q)
    if not q or q.cuiLog then return end
    q.cuiLog = true
    if q.VerticalSeparator then CUI:SkinHide(q.VerticalSeparator) end
    CUI:SkinSideTab(q.QuestsTab, "Feuille")
    CUI:SkinSideTab(q.EventsTab, "Calendrier")
    CUI:SkinSideTab(q.MapLegendTab, "Repere")
    skinQuestList(_G.QuestScrollFrame)
    local qf = q.QuestsFrame
    skinDetails((qf and qf.DetailsFrame) or q.DetailsFrame)
    local campaign = qf and qf.CampaignOverview
    if campaign and campaign.BorderFrame then CUI:SkinHideTextures(campaign.BorderFrame) end
    skinEvents(q.EventsFrame)
    local legend = q.MapLegend or q.MapLegendFrame
    if legend then
        if legend.BorderFrame then CUI:SkinHideTextures(legend.BorderFrame) end
        if legend.ScrollFrame and legend.ScrollFrame.Background then CUI:SkinHide(legend.ScrollFrame.Background) end
    end
end

-- Fenêtre ------------------------------------------------------------------------------------------------------

local function skinFrame(f)
    if not f or f.cuiCarte or (f.IsForbidden and f:IsForbidden()) then return end
    f.cuiCarte = true
    if _G.WorldMapFrameBg then CUI:SkinHide(_G.WorldMapFrameBg) end
    local border = f.BorderFrame
    if border then
        CUI:SkinHideTextures(border)
        for _, key in ipairs({ "NineSlice", "PortraitContainer", "FrameGlow", "Tutorial", "TopTileStreaks",
                               "Underlay", "InsetBorderTop" }) do
            if border[key] then CUI:SkinHide(border[key]) end
        end
        local mm = border.MaximizeMinimizeFrame
        if mm then
            skinPictoButton(mm.MaximizeButton, "Agrandir")
            skinPictoButton(mm.MinimizeButton, "Reduire")
        end
    end
    if _G.WorldMapFramePortrait then CUI:SkinHide(_G.WorldMapFramePortrait) end
    if f.OverscrollBG then CUI:SkinHideTextures(f.OverscrollBG) end
    CUI:SkinWindow(f)
    CUI:SkinCloseButton(_G.WorldMapFrameCloseButton)
    local title = _G.WorldMapFrameTitleText
    if title then
        title:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
        _G.hooksecurefunc(title, "SetTextColor", function(fs, r)
            if r ~= C.texte[1] then fs:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
        end)
    end
    if type(M.db.positions) ~= "table" then M.db.positions = {} end
    CUI:SkinMovable(f, M.db.positions, "carte", 22, function()
        return not (f.IsMaximized and f:IsMaximized())
    end)
    skinNavBar(f.NavBar)
    skinOverlays(f)
    skinQuestLog(_G.QuestMapFrame)
end

local function setup()
    local function go() if _G.WorldMapFrame then CUI:SafeCall(tr(), skinFrame, _G.WorldMapFrame) end end
    if _G.WorldMapFrame then go() return end
    M:WhenLoaded("Blizzard_WorldMap", go)
end

M.windows.carte = { setup = setup }
