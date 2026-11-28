-- Fenêtres du jeu · Métiers (maquette « 4 · Métiers » validée le 28/11/2026) : la fenêtre des métiers du jeu
-- (ProfessionsFrame, chargée par le jeu à sa première ouverture), même disposition :
--   - cadre de CœurUI, page rappelée à gauche du titre, croix au trait, déplaçable ; onglets de côté en cases
--     (vue d'ensemble : notre marteau au trait ; chaque métier : son icône du jeu) ;
--   - recettes : barre de compétence striée bleue dans une case ; recherche, « Filtrer » de CœurUI ; sections
--     repliables ; recette : pastille de la couleur de difficulté du jeu, nom gris clair, nombre faisable ;
--     choisie ou survolée : bande plus claire ;
--   - détail : case ardoise (illustration du métier très estompée), icône en case, nom en gras, textes gris,
--     composants en cases d'objet, case à cocher et boutons de CœurUI, compteur en petites cases ;
--   - vue d'ensemble : cartes sur cases ardoise (illustrations de la cuisine, de la pêche et du secourisme très
--     estompées), noms en petites capitales, sorts en cases, barre striée, « oublier » en petite croix.
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local issecret = _G.issecretvalue or function() return false end
local WHITE = "Interface\\Buttons\\WHITE8x8"
local PAGE_FILL = { 0.082, 0.094, 0.122, 1 } -- #15181F
local BLEU = { 0.29, 0.47, 0.72 }             -- #4A78B8 : barres de compétence
local ART_ALPHA = 0.15                         -- illustrations des métiers, très estompées

local function tr() return CUI:Tr("FJ_METIERS") end

local function atlasOf(t)
    local a = t and t.GetAtlas and t:GetAtlas()
    if type(a) == "string" and not issecret(a) then return a end
end

local function line(parent, color)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], 1)
    return t
end

-- Illustration gardée, très estompée (la transparence voulue par le jeu est multipliée).
local function fade(t, k)
    if not t or t.cuiFaded then return end
    t.cuiFaded = true
    local busy = false
    local function apply(_, a)
        if busy then return end
        busy = true
        local wanted = (type(a) == "number" and not issecret(a)) and a or 1
        t:SetAlpha(wanted * (k or ART_ALPHA))
        busy = false
    end
    _G.hooksecurefunc(t, "SetAlpha", apply)
    apply(nil, 1)
end

-- Petite case du thème derrière une région (icône, champ).
local function caseBehind(region, parent, pad)
    local box = _G.CreateFrame("Frame", nil, parent)
    box:SetPoint("TOPLEFT", region, "TOPLEFT", -(pad or 2), pad or 2)
    box:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", pad or 2, -(pad or 2))
    box:SetFrameLevel(math.max(0, parent:GetFrameLevel() - 1))
    return CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false }), box
end

-- Titre de section en petites capitales grises sur un trait (« Composants : »).
local function sectionLabel(fs)
    if not fs or fs.cuiSection then return end
    fs.cuiSection = true
    fs:SetFont(CUI:GetFont(), 10, "")
    local busy = false
    local function restyle(self, text)
        if busy or type(text) ~= "string" or issecret(text) then return end
        busy = true
        self:SetText(CUI:Upper((text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%s*:%s*$", ""))))
        self:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
        busy = false
    end
    _G.hooksecurefunc(fs, "SetText", restyle)
    restyle(fs, fs:GetText())
    local parent = fs:GetParent()
    local l = line(parent, C.lisereSombre)
    l:SetHeight(1)
    l:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -4)
    l:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
end

-- Liste des recettes ----------------------------------------------------------------------------------------

-- Recette (Label coloré par le jeu selon la difficulté, Count, SkillUps, SelectedOverlay, HighlightOverlay) :
-- pastille de la couleur de difficulté, nom gris clair (blanc choisi ou survolé), bande plus claire.
local function skinRecipe(row)
    if row.cuiRecipe then if row.cuiPaint then row.cuiPaint() end return end
    row.cuiRecipe = true
    local label, count = row.Label, row.Count
    if row.SelectedOverlay then
        row.SelectedOverlay:SetColorTexture(0.145, 0.165, 0.204, 1) -- #252A34
        row.SelectedOverlay:SetDrawLayer("BACKGROUND", 1)
    end
    if row.HighlightOverlay then
        row.HighlightOverlay:SetColorTexture(0.122, 0.137, 0.173, 1) -- #1F232C
        row.HighlightOverlay:SetDrawLayer("BACKGROUND", 1)
    end
    if row.SkillUps and row.SkillUps.Icon then CUI:SkinHide(row.SkillUps.Icon) end
    local dot = row:CreateTexture(nil, "OVERLAY")
    dot:SetTexture(CUI.MEDIA .. "Cercle")
    dot:SetSize(7, 7)
    dot:SetPoint("LEFT", row, "LEFT", 6, 0)
    if label then
        label:ClearAllPoints()
        label:SetPoint("LEFT", row, "LEFT", 18, 0)
        label:SetPoint("RIGHT", row, "RIGHT", -34, 0)
        label:SetJustifyH("LEFT")
    end
    if count then count:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3]) end
    local busy = false
    local function paint()
        if busy or not label then return end
        busy = true
        -- Couleur de difficulté que le jeu vient de poser sur le nom : passée à la pastille.
        local r, g, b = label:GetTextColor()
        if type(r) == "number" and not issecret(r) and not (r == C.texte[1] or r == C.texteSecondaire[1]) then
            row.cuiDiff = { r, g, b }
        end
        local d = row.cuiDiff or C.texteDiscret
        dot:SetVertexColor(d[1], d[2], d[3], 1)
        local on = row.cuiOver or (row.SelectedOverlay and row.SelectedOverlay:IsShown())
        local c = on and C.texte or C.texteSecondaire
        label:SetTextColor(c[1], c[2], c[3])
        busy = false
    end
    if label then _G.hooksecurefunc(label, "SetTextColor", paint) end
    if row.SelectedOverlay then
        _G.hooksecurefunc(row.SelectedOverlay, "Show", paint)
        _G.hooksecurefunc(row.SelectedOverlay, "Hide", paint)
        if row.SelectedOverlay.SetShown then _G.hooksecurefunc(row.SelectedOverlay, "SetShown", paint) end
    end
    row:HookScript("OnEnter", function() row.cuiOver = true paint() end)
    row:HookScript("OnLeave", function() row.cuiOver = false paint() end)
    row.cuiPaint = paint
    paint()
end

local function skinRecipeList(list)
    if not list then return end
    if list.Background then CUI:SkinHide(list.Background) end
    if list.BackgroundNineSlice then CUI:SkinHide(list.BackgroundNineSlice) end
    local page = _G.CreateFrame("Frame", nil, list)
    page:SetPoint("TOPLEFT", list, "TOPLEFT", 0, -26)
    page:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", 0, 0)
    page:SetFrameLevel(math.max(0, list:GetFrameLevel() - 1))
    CUI:CreatePanel(page, { radius = 3, fill = PAGE_FILL, shadow = false })
    CUI:SkinEditBox(list.SearchBox)
    local filter = list.FilterDropdown
    if filter then
        if filter.Background then CUI:SkinHide(filter.Background) end
        CUI:CreatePanel(filter, { radius = 3, fill = C.graphite, shadow = false })
        if filter.Text then filter.Text:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
        if filter.ResetButton then CUI:SkinCloseButton(filter.ResetButton) end
    end
    CUI:SkinScrollBar(list.ScrollBar)
    local box = list.ScrollBox
    if not box then return end
    if box.Shadows then CUI:SkinHideTextures(box.Shadows) end
    local function each()
        local target = box.ScrollTarget
        if not target then return end
        for _, row in ipairs({ target:GetChildren() }) do
            if row.CollapseButton or row.ButtonText then
                CUI:SkinCollapseHeader(row)
            elseif row.Label then
                skinRecipe(row)
            end
        end
    end
    if box.Update then _G.hooksecurefunc(box, "Update", function() CUI:SafeCall(tr(), each) end) end
    list:HookScript("OnShow", function() CUI:SafeCall(tr(), each) end)
    each()
end

-- Détail de la recette ----------------------------------------------------------------------------------------

local function skinReagentSlots(reagents)
    if not reagents then return end
    sectionLabel(reagents.Label)
    for _, slot in ipairs({ reagents:GetChildren() }) do
        local b = slot.Button
        if b and not b.cuiSkinned then
            for _, key in ipairs({ "SlotBackground", "CropFrame", "QualityOverlay" }) do
                if b[key] then CUI:SkinHide(b[key]) end
            end
            CUI:SkinItemSlot(b)
        end
    end
end

local function skinSchematic(form)
    if not form then return end
    -- Fond de la carte : l'illustration du métier très estompée sur une case ardoise ; cadre caché.
    for _, r in ipairs({ form:GetRegions() }) do
        if r:GetObjectType() == "Texture" then
            if r == form.Background then fade(r) else CUI:SkinHide(r) end
        end
    end
    if form.NineSlice then CUI:SkinHide(form.NineSlice) end
    local page = _G.CreateFrame("Frame", nil, form)
    page:SetAllPoints()
    page:SetFrameLevel(math.max(0, form:GetFrameLevel() - 1))
    CUI:CreatePanel(page, { radius = 3, fill = PAGE_FILL, shadow = false })
    -- Objet fabriqué : icône carrée en case, nom en gras.
    local out = form.OutputIcon
    if out and not out.cuiOut then
        out.cuiOut = true
        for _, key in ipairs({ "IconBorder", "CountShadow" }) do if out[key] then CUI:SkinHide(out[key]) end end
        local hl = out.GetHighlightTexture and out:GetHighlightTexture()
        if hl then CUI:SkinHide(hl) end
        if out.Icon then
            if out.CircleMask and out.Icon.RemoveMaskTexture then pcall(out.Icon.RemoveMaskTexture, out.Icon, out.CircleMask) end
            CUI:SquareItemIcon(out, out.Icon)
            caseBehind(out.Icon, out, 2)
        end
    end
    if form.OutputText then
        form.OutputText:SetFont(CUI:GetFont(), 14, "")
        form.OutputText:SetShadowOffset(0, 0)
    end
    for _, key in ipairs({ "Description", "RequiredTools", "Cooldown" }) do
        local fs = form[key]
        if fs then
            local c = C.texteSecondaire
            fs:SetTextColor(c[1], c[2], c[3])
            fs:SetShadowOffset(0, 0)
        end
    end
    -- Favori : étoile au trait, blanche si la recette est favorite.
    local fav = form.FavoriteButton
    if fav and not fav.cuiFav then
        fav.cuiFav = true
        CUI:SkinHideTextures(fav)
        for _, getter in ipairs({ "GetNormalTexture", "GetHighlightTexture", "GetCheckedTexture", "GetPushedTexture" }) do
            local t = fav[getter] and fav[getter](fav)
            if t then CUI:SkinHide(t) end
        end
        local star = fav:CreateTexture(nil, "OVERLAY")
        star:SetTexture(CUI.MEDIA .. "Icones\\Talents")
        star:SetSize(16, 16)
        star:SetPoint("CENTER")
        local function paint()
            local on = fav:GetChecked()
            local c = (on or fav.cuiOver) and C.texte or C.texteDiscret
            star:SetVertexColor(c[1], c[2], c[3], 1)
        end
        _G.hooksecurefunc(fav, "SetChecked", paint)
        fav:HookScript("OnClick", paint)
        fav:HookScript("OnEnter", function() fav.cuiOver = true paint() end)
        fav:HookScript("OnLeave", function() fav.cuiOver = false paint() end)
        paint()
    end
    CUI:SkinCheckbox(form.TrackRecipeCheckbox)
    CUI:SkinCheckbox(form.AllocateBestQualityCheckbox)
    sectionLabel(form.OptionalReagents and form.OptionalReagents.Label)
    sectionLabel(form.FinishingReagents and form.FinishingReagents.Label)
    local function refresh()
        skinReagentSlots(form.Reagents)
        skinReagentSlots(form.OptionalReagents)
    end
    if form.Init then _G.hooksecurefunc(form, "Init", function() _G.C_Timer.After(0, function() CUI:SafeCall(tr(), refresh) end) end) end
    form:HookScript("OnShow", function() CUI:SafeCall(tr(), refresh) end)
    -- Le jeu crée les cases de composant en choisissant une recette, après l'ouverture : vérifié souvent tant
    -- que la page est affichée (les cases déjà habillées ne sont pas retouchées).
    local wait = 0
    form:HookScript("OnUpdate", function(_, elapsed)
        wait = wait + elapsed
        if wait < 0.4 then return end
        wait = 0
        CUI:SafeCall(tr(), refresh)
    end)
    refresh()
end

-- Barre de compétence (fond, remplissage animé, reflet, cadre ; texte dans Rank) : barre striée bleue.
local function skinRankBar(bar)
    if not bar or bar.cuiBar then return end
    if bar.Flare then CUI:SkinHide(bar.Flare) end
    if bar.ExpansionDropdownButton then CUI:SkinIconButton(bar.ExpansionDropdownButton, nil, "Chevron") end
    CUI:SkinStatBar(bar, BLEU)
    local rank = bar.Rank
    if rank then
        for _, r in ipairs({ rank:GetRegions() }) do
            if r:GetObjectType() == "FontString" then
                r:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
                r:SetShadowOffset(1, -1)
            end
        end
    end
end

local function skinCraftingPage(page)
    if not page then return end
    -- Fond marron de la page (« Profession-Background-Template2 ») : invisible.
    CUI:SkinHideTextures(page)
    skinRankBar(page.RankBar)
    skinRecipeList(page.RecipeList)
    skinSchematic(page.SchematicForm)
    for _, key in ipairs({ "CreateButton", "CreateAllButton", "ViewGuildCraftersButton" }) do
        CUI:SkinButton(page[key])
    end
    local multi = page.CreateMultipleInputBox
    if multi then
        CUI:SkinEditBox(multi)
        for key, angle in pairs({ DecrementButton = -math.pi / 2, IncrementButton = math.pi / 2 }) do
            local b = multi[key]
            if b then
                CUI:SkinIconButton(b, nil, "Chevron")
                if b.cuiPicto then b.cuiPicto:SetRotation(angle) end
            end
        end
    end
    if page.LinkButton then CUI:SkinIconButton(page.LinkButton, page.LinkButton.Icon) end
    for _, key in ipairs({ "CookingToolSlot", "FishingToolSlot" }) do
        if page[key] then CUI:SkinItemSlot(page[key]) end
    end
    if page.TutorialButton then CUI:SkinHide(page.TutorialButton) end
end

-- Vue d'ensemble : cartes (PrimaryProfession1-2, SecondaryProfession1-3 de ProfessionsContentFrame) ---------

-- Bouton de sort d'une carte (IconTexture, IconBorder, OutlineMask, spellString, subSpellString) : icône
-- carrée en case, nom blanc, rang gris.
local function skinSpellButton(b)
    if not b or b.cuiSpell then return end
    b.cuiSpell = true
    for _, key in ipairs({ "IconBorder", "IconTextureOverlay", "BorderShadow" }) do
        if b[key] then CUI:SkinHide(b[key]) end
    end
    local icon = b.IconTexture or b.Icon
    if icon then
        if b.OutlineMask and icon.RemoveMaskTexture then pcall(icon.RemoveMaskTexture, icon, b.OutlineMask) end
        CUI:SquareItemIcon(b, icon)
        local panel = caseBehind(icon, b, 2)
        b:HookScript("OnEnter", function() panel.border:SetColor(C.or_) end)
        b:HookScript("OnLeave", function() panel.border:SetColor(C.lisereSombre) end)
    end
    if b.spellString then
        -- Le jeu le recolore (jaune) : remis en blanc à chaque fois.
        local fs, busy = b.spellString, false
        local function white()
            if busy then return end
            busy = true
            fs:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
            busy = false
        end
        _G.hooksecurefunc(fs, "SetTextColor", white)
        fs:SetShadowOffset(0, 0)
        white()
    end
    if b.subSpellString then
        b.subSpellString:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
        b.subSpellString:SetShadowOffset(0, 0)
    end
end

-- « Oublier le métier » (croix rouge) : petite case, croix au trait grise (blanche au survol).
local function skinUnlearn(b)
    if not b or b.cuiUnlearn then return end
    b.cuiUnlearn = true
    CUI:SkinHideTextures(b)
    for _, child in ipairs({ b:GetChildren() }) do CUI:SkinHideTextures(child) end
    local box = _G.CreateFrame("Frame", nil, b)
    box:SetAllPoints()
    box:SetFrameLevel(math.max(0, b:GetFrameLevel() - 1))
    CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
    CUI:SkinCloseButton(b)
end

-- Une carte : fond du jeu caché sur une case ardoise (illustration gardée très estompée pour la cuisine,
-- la pêche et le secourisme), nom en petites capitales grises, textes gris, sorts, barre, croix.
local function skinCard(card)
    if not card or card.cuiCard then return end
    card.cuiCard = true
    local bg = card.Background
    local a = atlasOf(bg) or ""
    if bg then
        if a:find("generic", 1, true) then fade(bg, 0.22) else CUI:SkinHide(bg) end
    end
    local page = _G.CreateFrame("Frame", nil, card)
    page:SetPoint("TOPLEFT", 4, -4)
    page:SetPoint("BOTTOMRIGHT", -4, 4)
    page:SetFrameLevel(math.max(0, card:GetFrameLevel() - 1))
    CUI:CreatePanel(page, { radius = 3, fill = PAGE_FILL, shadow = false })
    for _, r in ipairs({ card:GetRegions() }) do
        if r:GetObjectType() == "FontString" then
            if r == card.ProfessionName or r == card.missingHeader or (r.GetName and r:GetName() and
                (r:GetName():find("ProfessionName", 1, true) or r:GetName():find("Missing", 1, true))) then
                sectionLabel(r)
            else
                r:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
                r:SetShadowOffset(0, 0)
            end
        end
    end
    for _, child in ipairs({ card:GetChildren() }) do
        if child.IconTexture or child.spellString then skinSpellButton(child) end
    end
    local bar = card.StatusBar
    if bar then
        if bar.Flare then CUI:SkinHide(bar.Flare) end
        CUI:SkinStatBar(bar, BLEU)
        -- Notre remplissage passait sous le fond de la carte : monté au niveau de la barre, le texte au-dessus.
        local copy = bar.cuiFillCopy
        if copy then
            local level = bar:GetFrameLevel()
            local inner = copy:GetParent()
            local clip = inner and inner:GetParent()
            if clip then clip:SetFrameLevel(level) end
            if inner then inner:SetFrameLevel(level) end
            if bar.Rank then bar.Rank:SetFrameLevel(level + 2) end
        end
        local text = bar.Rank and bar.Rank.Text
        if text then
            text:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
            text:SetShadowOffset(1, -1)
        end
    end
    skinUnlearn(card.UnlearnButton)
end

local function skinOverview(book)
    local content = book and book.ProfessionsContentFrame
    if not content then return end
    for _, card in ipairs({ content:GetChildren() }) do
        skinCard(card)
        -- Valeur donnée par le jeu avant l'habillage : notre barre recalculée à chaque ouverture.
        local bar = card.StatusBar
        if bar and bar.cuiSync then bar.cuiSync() end
    end
end

-- Icônes des métiers (maquette « 4 bis ») : identifiant de compétence du jeu (skillLine) » notre icône.
local PROFESSION_ICONS = {
    [171] = "MetierAlchimie", [164] = "MetierForge", [333] = "MetierEnchantement", [202] = "MetierIngenierie",
    [182] = "MetierHerboristerie", [165] = "MetierCuir", [186] = "MetierMinage", [393] = "MetierDepecage",
    [197] = "MetierCouture", [185] = "MetierCuisine", [356] = "MetierPeche", [129] = "MetierSecourisme",
    [755] = "MetierJoaillerie", [773] = "MetierCalligraphie",
}

-- Icônes du jeu des métiers (onglets) » notre icône : quand l'icône de l'onglet n'est pas celle de la liste des
-- métiers du jeu (cuisine, 133971 relevé le 28/11/2026).
local GAME_ICONS = {
    [136240] = "MetierAlchimie", [136241] = "MetierForge", [136244] = "MetierEnchantement",
    [136243] = "MetierIngenierie", [136246] = "MetierHerboristerie", [136247] = "MetierCuir",
    [136248] = "MetierMinage", [134366] = "MetierDepecage", [136249] = "MetierCouture",
    [133971] = "MetierCuisine", [136245] = "MetierPeche", [135966] = "MetierSecourisme",
    [134071] = "MetierJoaillerie", [237171] = "MetierCalligraphie",
}

-- Icône du jeu de chaque métier du personnage » notre icône (liste des métiers que donne le jeu, puis la table
-- ci-dessus).
local function professionIcons()
    local map = {}
    for icon, name in pairs(GAME_ICONS) do map[icon] = name end
    if not _G.GetProfessions or not _G.GetProfessionInfo then return map end
    for _, index in ipairs({ _G.GetProfessions() }) do
        if index then
            local _, icon, _, _, _, _, skillLine = _G.GetProfessionInfo(index)
            if icon ~= nil and skillLine ~= nil and not issecret(icon) and not issecret(skillLine) then
                map[icon] = PROFESSION_ICONS[skillLine]
            end
        end
    end
    return map
end

-- Fenêtre ----------------------------------------------------------------------------------------------------

local function skinFrame(f)
    if not f or f.cuiMetiers or (f.IsForbidden and f:IsForbidden()) then return end
    f.cuiMetiers = true
    CUI:SkinHideTextures(f)
    CUI:SkinWindow(f)
    if f.FrameGlow then CUI:SkinHide(f.FrameGlow) end
    CUI:SkinCloseButton(_G.ProfessionsFrameCloseButton or f.CloseButton)
    local title = _G.ProfessionsFrameTitleText
    local label = f:CreateFontString(nil, "OVERLAY")
    label:SetFont(CUI:GetFont(), 10, "")
    label:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
    label:SetPoint("LEFT", f, "TOPLEFT", 14, -12)
    if title then
        local busy = false
        local function restyle(fs)
            if busy then return end
            busy = true
            fs:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
            local t = fs:GetText()
            if type(t) == "string" and not issecret(t) then
                label:SetText(CUI:Upper((t:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))))
            end
            busy = false
        end
        _G.hooksecurefunc(title, "SetText", restyle)
        _G.hooksecurefunc(title, "SetTextColor", restyle)
        restyle(title)
    end
    local headerLine = line(f, C.lisereSombre)
    headerLine:SetHeight(1)
    headerLine:SetPoint("TOPLEFT", 2, -24)
    headerLine:SetPoint("TOPRIGHT", -2, -24)
    if type(M.db.positions) ~= "table" then M.db.positions = {} end
    CUI:SkinMovable(f, M.db.positions, "metiers", 24)

    -- Onglets de côté (maquette « 4 bis ») : vue d'ensemble (notre marteau), puis un par métier avec notre
    -- icône au trait du métier, retrouvé d'après l'icône du jeu sur l'onglet.
    CUI:SkinSideTab(f.ProfessionsOverviewTab, "Metiers")
    local tabs = {}
    for i = 1, 10 do
        local tab = f["Professions" .. i .. "Tab"]
        if tab then
            CUI:SkinSideTab(tab, "Metiers")
            tabs[#tabs + 1] = tab
        end
    end
    local function paintTabs()
        local byIcon = professionIcons()
        for _, tab in ipairs(tabs) do
            local tex = tab.Icon and tab.Icon:GetTexture()
            local name = (tex ~= nil and not issecret(tex)) and byIcon[tex] or nil
            if tab.cuiPicto then tab.cuiPicto:SetTexture(CUI.MEDIA .. "Icones\\" .. (name or "Metiers")) end
        end
    end
    for _, tab in ipairs(tabs) do
        if tab.Icon then _G.hooksecurefunc(tab.Icon, "SetTexture", paintTabs) end
        tab:HookScript("OnShow", paintTabs)
    end
    f:HookScript("OnShow", paintTabs)
    paintTabs()

    skinCraftingPage(f.CraftingPage)
    local book = f.BookPage
    if book then
        skinOverview(book)
        book:HookScript("OnShow", function()
            _G.C_Timer.After(0, function() CUI:SafeCall(tr(), skinOverview, book) end)
        end)
    end
end

local function setup()
    local function go() if _G.ProfessionsFrame then CUI:SafeCall(tr(), skinFrame, _G.ProfessionsFrame) end end
    if _G.ProfessionsFrame then go() return end
    M:WhenLoaded("Blizzard_Professions", go)
end

M.windows.metiers = { setup = setup }
