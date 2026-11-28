-- Fenêtres du jeu · Grimoire (maquette « 2 · Grimoire » validée le 28/11/2026) : le grimoire du jeu
-- (PlayerSpellsFrame, chargé par le jeu à sa première ouverture), même disposition :
--   - cadre des fenêtres de CœurUI, nom au centre, page rappelée à gauche, croix et « agrandir » au trait,
--     déplaçable par son bandeau ;
--   - catégories (Général, arbres de la classe) en petites cases à icône ; recherche dans une case sombre ;
--   - page : case ardoise un peu plus sombre, titre en gras sur un trait ;
--   - sorts : icône carrée dans une case du thème, nom blanc, sous-titre gris ; survol : liseré doré ;
--     sort absent des barres d'actions : pastille rouge cœur ; sort à choix : petit chevron ;
--   - bas : « Page 1/1 », flèches en petites cases ; onglets Talents et Grimoire en petites capitales.
-- La page des talents n'est pas habillée ici (fenêtre suivante).
local _, CUI = ...
local C = CUI.Colors

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local issecret = _G.issecretvalue or function() return false end
local WHITE = "Interface\\Buttons\\WHITE8x8"
local PAGE_FILL = { 0.082, 0.094, 0.122, 1 } -- #15181F : la page, un peu plus sombre que la fenêtre

local function tr() return CUI:Tr("FJ_GRIMOIRE") end

-- Sorts -----------------------------------------------------------------------------------------------

local function atlasOf(t)
    local a = t and t.GetAtlas and t:GetAtlas()
    if type(a) == "string" and not issecret(a) then return a end
end

-- Suit la visibilité d'une texture du jeu (montrée, cachée) sur l'un de nos éléments.
local function mirrorShown(source, target)
    if not source then target:Hide() return end
    local function sync() target:SetShown(source:IsShown()) end
    _G.hooksecurefunc(source, "Show", sync)
    _G.hooksecurefunc(source, "Hide", sync)
    if source.SetShown then _G.hooksecurefunc(source, "SetShown", sync) end
    sync()
end

local function skinSpellButton(b)
    if not b or b.cuiSpell then return end
    b.cuiSpell = true
    local icon = b.Icon
    -- Décor du jeu : cercles, cadres dorés, ombres, lueurs (tout sauf l'icône et le temps de recharge).
    local arrow, unassigned, border = b.Arrow, b.ActionBarHighlight, b.Border
    for _, r in ipairs({ b:GetRegions() }) do
        if r:GetObjectType() == "Texture" and r ~= icon then CUI:SkinHide(r) end
    end
    local copy = icon and CUI:SquareItemIcon(b, icon)
    if icon then
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    local holder = _G.CreateFrame("Frame", nil, b)
    holder:SetPoint("TOPLEFT", icon or b, "TOPLEFT", -2, 2)
    holder:SetPoint("BOTTOMRIGHT", icon or b, "BOTTOMRIGHT", 2, -2)
    holder:SetFrameLevel(math.max(0, b:GetFrameLevel() - 1))
    local panel = CUI:CreatePanel(holder, { radius = 3, fill = C.case, shadow = false })
    -- Passif (cercle gris du jeu) : case sans liseré clair, icône un peu terne.
    local function passive()
        local a = atlasOf(border)
        return a ~= nil and a:find("circle", 1, true) ~= nil
    end
    local function paint()
        local p = passive()
        if b.cuiOver then
            panel.border:SetColor(C.or_)
        else
            panel.border:SetColor(p and C.lisereSombre or C.bordureDiscrete)
        end
        if copy then copy:SetAlpha(p and 0.8 or 1) end
    end
    if border and border.SetAtlas then _G.hooksecurefunc(border, "SetAtlas", paint) end
    b:HookScript("OnEnter", function() b.cuiOver = true paint() end)
    b:HookScript("OnLeave", function() b.cuiOver = false paint() end)
    b.cuiPaint = paint
    -- Pas encore sur les barres d'actions (lueur du jeu) : pastille rouge cœur dans le coin.
    local over = _G.CreateFrame("Frame", nil, b)
    over:SetAllPoints(holder)
    over:SetFrameLevel(b:GetFrameLevel() + 5)
    local dot = over:CreateTexture(nil, "OVERLAY")
    dot:SetTexture(CUI.MEDIA .. "Cercle")
    dot:SetSize(9, 9)
    dot:SetPoint("CENTER", over, "TOPRIGHT", -1, -1)
    dot:SetVertexColor(C.coeur[1], C.coeur[2], C.coeur[3], 1)
    mirrorShown(unassigned, dot)
    -- Sort à choix (flèche du jeu) : petit chevron dans une case, sur le bord droit.
    local fly = _G.CreateFrame("Frame", nil, over)
    fly:SetSize(12, 16)
    fly:SetPoint("CENTER", over, "RIGHT", 0, 0)
    CUI:CreatePanel(fly, { radius = 3, fill = C.fenetre, shadow = false })
    local chev = fly:CreateTexture(nil, "OVERLAY")
    chev:SetTexture(CUI.MEDIA .. "Icones\\Chevron")
    chev:SetSize(10, 10)
    chev:SetPoint("CENTER")
    chev:SetRotation(math.pi / 2)
    chev:SetVertexColor(C.texte[1], C.texte[2], C.texte[3], 1)
    mirrorShown(arrow, fly)
    paint()
end

local function skinSpellItem(item)
    if item.cuiItem then
        if item.Button and item.Button.cuiPaint then item.Button.cuiPaint() end
        return
    end
    item.cuiItem = true
    if item.Backplate then CUI:SkinHide(item.Backplate) end
    local text = item.TextContainer
    if text then
        if text.Name then
            text.Name:SetFont(CUI:GetFont(), 13, "")
            text.Name:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
            text.Name:SetShadowOffset(0, 0)
        end
        for _, key in ipairs({ "SubName", "RequiredLevel" }) do
            local fs = text[key]
            if fs then
                fs:SetFont(CUI:GetFont(), 11, "")
                fs:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
                fs:SetShadowOffset(0, 0)
            end
        end
    end
    skinSpellButton(item.Button)
end

-- Titre de catégorie (« Général », « Vindicte ») : en gras, sur un trait sombre (plus d'enluminure).
local function skinHeader(h)
    if h.cuiHeader then return end
    h.cuiHeader = true
    if h.Border then CUI:SkinHide(h.Border) end
    if h.Backplate then CUI:SkinHide(h.Backplate) end
    if h.Text then
        h.Text:SetFont(CUI:GetFont(), 20, "")
        h.Text:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
        h.Text:SetShadowOffset(0, 0)
    end
    local line = h:CreateTexture(nil, "ARTWORK")
    line:SetTexture(WHITE)
    line:SetVertexColor(C.lisereSombre[1], C.lisereSombre[2], C.lisereSombre[3], 1)
    line:SetHeight(1)
    line:SetPoint("BOTTOMLEFT", 0, 6)
    line:SetPoint("BOTTOMRIGHT", 0, 6)
end

local function skinView(view)
    if not view then return end
    for _, child in ipairs({ view:GetChildren() }) do
        if child.TextContainer or child.Button then
            skinSpellItem(child)
        elseif child.Text and (child.Border or child.Backplate) then
            skinHeader(child)
        end
    end
end

-- Livre ------------------------------------------------------------------------------------------------

local function skinBook(sb)
    if not sb then return end
    -- Parchemin, enluminures, coins : invisibles ; une case ardoise à la place de la page (de la double page
    -- quand la fenêtre est agrandie).
    for _, r in ipairs({ sb:GetRegions() }) do
        if r:GetObjectType() == "Texture" then CUI:SkinHide(r) end
    end
    local page = _G.CreateFrame("Frame", nil, sb)
    -- Sous tout le reste du livre (recherche, catégories, sorts), sinon elle les recouvre.
    page:SetFrameLevel(math.max(0, sb:GetFrameLevel() - 1))
    CUI:CreatePanel(page, { radius = 3, fill = PAGE_FILL, shadow = false })
    local function place()
        page:ClearAllPoints()
        local left, right, half = sb.BookBGLeft, sb.BookBGRight, sb.BookBGHalved
        if left and right and left:IsShown() then
            page:SetPoint("TOPLEFT", left, "TOPLEFT", 10, -8)
            page:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -10, 8)
        elseif half then
            page:SetPoint("TOPLEFT", half, "TOPLEFT", 10, -8)
            page:SetPoint("BOTTOMRIGHT", half, "BOTTOMRIGHT", -10, 8)
        else
            page:SetAllPoints(sb)
        end
    end
    for _, key in ipairs({ "BookBGLeft", "BookBGHalved" }) do
        local t = sb[key]
        if t then
            _G.hooksecurefunc(t, "Show", place)
            _G.hooksecurefunc(t, "Hide", place)
            if t.SetShown then _G.hooksecurefunc(t, "SetShown", place) end
        end
    end
    place()

    -- Catégories.
    local cats = sb.CategoryTabSystem
    local function skinCats()
        if not cats then return end
        for _, tab in ipairs({ cats:GetChildren() }) do
            if tab:GetObjectType() == "Button" then CUI:SkinIconTab(tab) end
        end
    end
    skinCats()

    -- Recherche, réglages.
    CUI:SkinEditBox(sb.SearchBox)
    local settings = sb.SettingsDropdown
    if settings then CUI:SkinIconButton(settings, settings.Icon, "Chevron") end
    -- Suggestions de la recherche : panneau des menus de CœurUI ; lignes sans le fond ni la lueur bleue du
    -- jeu, bande ardoise au survol, texte gris clair (blanc au survol) ; leur icône gardée.
    local preview = sb.SearchPreviewContainer
    if preview then
        CUI:SkinHideTextures(preview)
        CUI:CreateTipPanel(preview)
        -- Lignes : tout bouton portant un texte, où qu'il soit rangé dans le menu (liste défilante ou non).
        local function rowsOf(frame, depth, out)
            if depth > 4 then return out end
            for _, child in ipairs({ frame:GetChildren() }) do
                local kind = child:GetObjectType()
                if kind == "Button" and (child.Name or child.Text or (child.GetFontString and child:GetFontString())) then
                    out[#out + 1] = child
                elseif kind ~= "Button" then
                    rowsOf(child, depth + 1, out)
                end
            end
            return out
        end
        local function skinRows()
            for _, row in ipairs(rowsOf(preview, 0, {})) do
                if not row.cuiRow then
                    row.cuiRow = true
                    local icon = row.Icon or row.icon
                    local hl = row.GetHighlightTexture and row:GetHighlightTexture()
                    for _, r in ipairs({ row:GetRegions() }) do
                        if r:GetObjectType() == "Texture" and r ~= icon and r ~= hl then CUI:SkinHide(r) end
                    end
                    if hl then
                        hl:SetColorTexture(0.145, 0.165, 0.204, 1) -- #252A34 : ligne survolée des menus
                        hl:SetDrawLayer("BACKGROUND", 1)
                    end
                    local text = row.Name or row.Text or (row.GetFontString and row:GetFontString())
                    if text then
                        local c = C.texteSecondaire
                        text:SetTextColor(c[1], c[2], c[3])
                        row:HookScript("OnEnter", function() text:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end)
                        row:HookScript("OnLeave", function() text:SetTextColor(c[1], c[2], c[3]) end)
                    end
                end
            end
        end
        preview:HookScript("OnShow", function()
            CUI:SafeCall(tr(), skinRows)
            _G.C_Timer.After(0, function() CUI:SafeCall(tr(), skinRows) end)
        end)
        if sb.SearchBox then
            local function soon() _G.C_Timer.After(0, function() CUI:SafeCall(tr(), skinRows) end) end
            sb.SearchBox:HookScript("OnEditFocusGained", soon)
            sb.SearchBox:HookScript("OnTextChanged", soon)
        end
        local scroll = preview.ScrollBox
        if scroll and scroll.Update then
            _G.hooksecurefunc(scroll, "Update", function() CUI:SafeCall(tr(), skinRows) end)
        end
        if scroll and scroll.Shadows then CUI:SkinHideTextures(scroll.Shadows) end
    end
    if sb.HelpPlateButton then CUI:SkinHide(sb.HelpPlateButton) end

    -- Pages et changement de page.
    local paged = sb.PagedSpellsFrame
    local function refresh()
        if not paged then return end
        skinCats()
        skinView(paged.View1)
        skinView(paged.View2)
    end
    local function later() _G.C_Timer.After(0, function() CUI:SafeCall(tr(), refresh) end) end
    if paged then
        local paging = paged.PagingControls
        if paging then
            if paging.PageText then
                local c = C.texteDiscret
                paging.PageText:SetTextColor(c[1], c[2], c[3])
            end
            for key, angle in pairs({ PrevPageButton = -math.pi / 2, NextPageButton = math.pi / 2 }) do
                local b = paging[key]
                if b then
                    CUI:SkinIconButton(b, nil, "Chevron")
                    if b.cuiPicto then b.cuiPicto:SetRotation(angle) end
                    b:HookScript("OnClick", later)
                end
            end
        end
        for _, key in ipairs({ "View1", "View2" }) do
            if paged[key] then paged[key]:HookScript("OnShow", later) end
        end
    end
    if cats then
        for _, tab in ipairs({ cats:GetChildren() }) do
            if tab:GetObjectType() == "Button" then tab:HookScript("OnClick", later) end
        end
    end
    if sb.SearchBox then sb.SearchBox:HookScript("OnTextChanged", later) end
    sb:HookScript("OnShow", later)
    refresh()
    later()
end

-- Fenêtre ----------------------------------------------------------------------------------------------

-- Agrandir / réduire : notre icône au trait, grise, blanche au survol (sans case, comme la croix).
local function skinSizeButton(b, pictoName)
    if not b or b.cuiSize then return end
    b.cuiSize = true
    CUI:SkinHideTextures(b)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t then CUI:SkinHide(t) end
    end
    local t = b:CreateTexture(nil, "OVERLAY")
    t:SetTexture(CUI.MEDIA .. "Icones\\" .. pictoName)
    t:SetSize(14, 14)
    t:SetPoint("CENTER")
    local function paint(over)
        local c = over and C.texte or C.texteDiscret
        t:SetVertexColor(c[1], c[2], c[3], 1)
    end
    paint(false)
    b:HookScript("OnEnter", function() paint(true) end)
    b:HookScript("OnLeave", function() paint(false) end)
end

local function line(parent, color)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], 1)
    return t
end

local function skinFrame(f)
    if not f or f.cuiGrimoire or (f.IsForbidden and f:IsForbidden()) then return end
    f.cuiGrimoire = true
    CUI:SkinHideTextures(f)
    CUI:SkinWindow(f)
    if f.FrameGlow then CUI:SkinHide(f.FrameGlow) end
    CUI:SkinCloseButton(_G.PlayerSpellsFrameCloseButton or f.CloseButton)
    local mm = f.MaximizeMinimizeButton
    if mm then
        skinSizeButton(mm.MaximizeButton, "Agrandir")
        skinSizeButton(mm.MinimizeButton, "Reduire")
    end
    local title = _G.PlayerSpellsFrameTitleText
    if title then
        title:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
        _G.hooksecurefunc(title, "SetTextColor", function(fs, r)
            if r ~= C.texte[1] then fs:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end
        end)
    end
    local headerLine = line(f, C.lisereSombre)
    headerLine:SetHeight(1)
    headerLine:SetPoint("TOPLEFT", 2, -24)
    headerLine:SetPoint("TOPRIGHT", -2, -24)
    if type(M.db.positions) ~= "table" then M.db.positions = {} end
    CUI:SkinMovable(f, M.db.positions, "grimoire", 24)

    -- Onglets du bas (Talents, Grimoire) et rappel de la page ouverte à gauche du titre.
    local label = f:CreateFontString(nil, "OVERLAY")
    label:SetFont(CUI:GetFont(), 10, "")
    label:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
    label:SetPoint("LEFT", f, "TOPLEFT", 14, -12)
    local tabs = {}
    local function updateLabel()
        for _, tab in ipairs(tabs) do
            if tab:IsShown() and tab.LeftActive and tab.LeftActive:IsShown() and tab.Text then
                label:SetText(CUI:Upper(tab.Text:GetText() or ""))
                return
            end
        end
        label:SetText("")
    end
    if f.TabSystem then
        for _, tab in ipairs({ f.TabSystem:GetChildren() }) do
            if tab:GetObjectType() == "Button" then
                tabs[#tabs + 1] = tab
                CUI:SkinTextTab(tab)
                if tab.LeftActive then
                    _G.hooksecurefunc(tab.LeftActive, "Show", updateLabel)
                    _G.hooksecurefunc(tab.LeftActive, "Hide", updateLabel)
                end
            end
        end
    end
    f:HookScript("OnShow", updateLabel)
    updateLabel()

    skinBook(f.SpellBookFrame)
end

local function setup()
    if _G.PlayerSpellsFrame then
        skinFrame(_G.PlayerSpellsFrame)
        return
    end
    -- Le grimoire du jeu n'est chargé qu'à sa première ouverture.
    M:On("ADDON_LOADED", function(_, name)
        if name == "Blizzard_PlayerSpells" and _G.PlayerSpellsFrame then
            CUI:SafeCall(tr(), skinFrame, _G.PlayerSpellsFrame)
        end
    end)
end

M.windows.grimoire = { setup = setup }
