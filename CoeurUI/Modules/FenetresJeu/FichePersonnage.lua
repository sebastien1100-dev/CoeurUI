-- Fenêtres du jeu · Fiche du personnage (maquette validée le 28/11/2026, planche « Fenêtres du jeu · 1 ·
-- Fiche du personnage », fiche de WoW Forever) : la fiche du jeu (CharacterFrame) habillée, même
-- disposition :
--   - cadre des fenêtres de CœurUI, nom au centre, croix grise ; portrait, décor doré et fonds de pierre
--     invisibles ;
--   - personnage sur un fond de case ; boutons zoom, rotation, retour en petites cases ;
--   - cases d'équipement du thème (liseré de la qualité, survol de la couleur des boutons ; case vide :
--     le dessin de l'emplacement, très discret) ;
--   - statistiques : titres de section en petites capitales sur un trait sombre, une ligne sur deux plus
--     claire, barre de défilement fine ; mêmes habits pour les titres et les ensembles d'équipement ;
--   - onglets de côté en cases du thème (l'ouvert au liseré de la couleur des boutons).
-- Les pièces viennent du noyau (Core/UI/Skin.lua). Rien n'est déplacé : seul l'aspect change.
local _, CUI = ...
local C = CUI.Colors
local issecret = _G.issecretvalue or function() return false end

local M = CUI:GetModule("FenetresJeu")
if not M then return end

local WHITE = "Interface\\Buttons\\WHITE8x8"

-- Lignes des statistiques ----------------------------------------------------------------------------

local function line(parent, color)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], 1)
    return t
end

-- Titre de section (« Général »...) : petites capitales grises sur un trait sombre.
local function skinCategory(row)
    if row.cuiSkinned then return end
    row.cuiSkinned = true
    if row.Background then CUI:SkinHide(row.Background) end
    local title = row.Title
    if title then
        title:SetFont(CUI:GetFont(), 10, "")
        title:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
        local busy = false
        local function upper(self, text)
            if busy or type(text) ~= "string" then return end
            busy = true
            self:SetText(CUI:Upper(text))
            self:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
            busy = false
        end
        _G.hooksecurefunc(title, "SetText", upper)
        upper(title, title:GetText())
        local l = line(row, C.lisereSombre)
        l:SetHeight(1)
        l:SetPoint("BOTTOMLEFT", 4, 6)
        l:SetPoint("BOTTOMRIGHT", -4, 6)
    end
end

-- Icône d'une ligne (résistances de Forever : atlas « UI-Character-Info-Resistance-... » avec son cadre
-- brun dessiné dedans, que le jeu redécoupe à chaque fois) : petite case du thème à la place de
-- l'icône ; l'icône y est agrandie dans un cadre qui coupe ce qui dépasse (le cadre brun).
local STAT_BOX, STAT_ZOOM = 18, 1.45
-- Atlas du jeu (« UI-Character-Info-Resistance-... ») » notre icône.
local RESISTANCES = { ["Resistance-Arcane"] = "ResArcanes", ["Resistance-Fire"] = "ResFeu",
                      ["Resistance-Frost"] = "ResGivre", ["Resistance-Nature"] = "ResNature",
                      ["Resistance-Shadow"] = "ResOmbre" }
local function skinStatIcon(row)
    local icon = row.Icon
    -- Repère à l'endroit où le jeu a posé l'icône.
    local spot = _G.CreateFrame("Frame", nil, row)
    for i = 1, icon:GetNumPoints() do
        local p, rel, rp, x, y = icon:GetPoint(i)
        if p then spot:SetPoint(p, rel, rp, x, y) end
    end
    local w, h = icon:GetSize()
    if not w or w <= 0 then w, h = STAT_BOX, STAT_BOX end
    spot:SetSize(w, h)
    local box = _G.CreateFrame("Frame", nil, row)
    box:SetSize(STAT_BOX, STAT_BOX)
    box:SetPoint("CENTER", spot, "CENTER")
    CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
    -- Notre copie de l'icône, agrandie dans un cadre qui coupe ce qui dépasse (le cadre brun) ; celle
    -- du jeu reste invisible, on recopie son dessin à chaque changement.
    local clip = _G.CreateFrame("Frame", nil, box)
    clip:SetPoint("TOPLEFT", 2, -2)
    clip:SetPoint("BOTTOMRIGHT", -2, 2)
    clip:SetClipsChildren(true)
    local inner = _G.CreateFrame("Frame", nil, clip)
    local size = (STAT_BOX - 4) * STAT_ZOOM
    inner:SetSize(size, size)
    inner:SetPoint("CENTER")
    local copy = inner:CreateTexture(nil, "ARTWORK")
    copy:SetAllPoints()
    -- Résistances : notre icône au trait (une forme par école), grise, à la place du dessin du jeu.
    local line = box:CreateTexture(nil, "OVERLAY")
    line:SetSize(STAT_BOX - 6, STAT_BOX - 6)
    line:SetPoint("CENTER")
    line:SetVertexColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3], 1)
    CUI:SkinHide(icon)
    local function sync()
        local atlas = icon.GetAtlas and icon:GetAtlas()
        if type(atlas) == "string" and issecret(atlas) then atlas = nil end
        local picto
        if type(atlas) == "string" then
            for key, name in pairs(RESISTANCES) do
                if atlas:find(key, 1, true) then picto = name end
            end
        end
        if picto then
            line:SetTexture(CUI.MEDIA .. "Icones\\" .. picto)
        elseif type(atlas) == "string" and atlas ~= "" then
            copy:SetAtlas(atlas)
        else
            copy:SetTexture(icon:GetTexture())
        end
        line:SetShown(picto ~= nil)
        clip:SetShown(picto == nil)
        box:SetShown(icon:IsShown() and (atlas or icon:GetTexture()) ~= nil)
    end
    _G.hooksecurefunc(icon, "SetAtlas", sync)
    _G.hooksecurefunc(icon, "SetTexture", sync)
    _G.hooksecurefunc(icon, "Show", sync)
    _G.hooksecurefunc(icon, "Hide", sync)
    if icon.SetShown then _G.hooksecurefunc(icon, "SetShown", sync) end
    row.cuiSyncIcon = sync
    sync()
end

-- Ligne de statistique : son fond du jeu (une ligne sur deux) devient une bande un peu plus claire.
local function skinStat(row)
    if row.cuiSkinned then return end
    row.cuiSkinned = true
    local bg = row.Background
    if bg then
        local band = row:CreateTexture(nil, "BACKGROUND", nil, 1)
        band:SetTexture(WHITE)
        band:SetVertexColor(C.carte[1], C.carte[2], C.carte[3], 1)
        band:SetPoint("TOPLEFT", 2, 0)
        band:SetPoint("BOTTOMRIGHT", -2, 0)
        local function sync() band:SetShown(bg:IsShown()) end
        CUI:SkinHide(bg)
        _G.hooksecurefunc(bg, "Show", sync)
        _G.hooksecurefunc(bg, "Hide", sync)
        if bg.SetShown then _G.hooksecurefunc(bg, "SetShown", sync) end
        sync()
    end
    if row.Label then
        local c = C.texteSecondaire
        row.Label:SetTextColor(c[1], c[2], c[3])
    end
    if row.Icon then skinStatIcon(row) end
end

local function skinRow(row)
    if row.Title then skinCategory(row) elseif row.Label then skinStat(row) end
end

-- Liste qui défile (le jeu recycle ses lignes) : chaque ligne montrée est habillée.
local function skinScrollList(pane)
    if not pane then return end
    CUI:SkinHideTextures(pane)
    local box = pane.ScrollBox
    CUI:SkinScrollBar(pane.ScrollBar)
    if not box then return end
    if box.Shadows then CUI:SkinHideTextures(box.Shadows) end
    local function each()
        local target = box.ScrollTarget
        if not target then return end
        for _, row in ipairs({ target:GetChildren() }) do
            skinRow(row)
            if row.cuiSyncIcon then row.cuiSyncIcon() end
        end
    end
    if box.Update then _G.hooksecurefunc(box, "Update", function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), each) end) end
    pane:HookScript("OnShow", function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), each) end)
    each()
end

-- Équipement -----------------------------------------------------------------------------------------

local slots = {}

local function updateSlots()
    for _, b in ipairs(slots) do
        local id = b:GetID()
        local tex = id and _G.GetInventoryItemTexture("player", id)
        CUI:SetItemSlotEmpty(b, tex == nil)
        if b.cuiSync then b.cuiSync() end
    end
end

-- Flèche du gestionnaire d'ensembles (choisir une autre pièce, « ...SlotPopoutButton ») : petite case
-- du thème et notre chevron, tourné vers l'extérieur de la case (droite, gauche ou haut).
local function skinPopout(pb, slot)
    if not pb or pb.cuiSkinned then return end
    pb.cuiSkinned = true
    CUI:SkinHideTextures(pb)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture" }) do
        local t = pb[getter] and pb[getter](pb)
        if t then CUI:SkinHide(t) end
    end
    local panel = CUI:CreatePanel(pb, { radius = 3, fill = C.case, shadow = false, inset = 2 })
    local icon = pb:CreateTexture(nil, "OVERLAY")
    icon:SetTexture(CUI.MEDIA .. "Icones\\Chevron")
    icon:SetSize(12, 12)
    icon:SetPoint("CENTER")
    local function paint()
        local over = pb.cuiOver
        local c = over and C.texte or C.texteSecondaire
        icon:SetVertexColor(c[1], c[2], c[3], 1)
        panel.border:SetColor(over and C.texteDiscret or C.lisereSombre)
        -- Le chevron dessiné pointe vers le bas ; on le tourne selon la place de la flèche.
        local px, py = pb:GetCenter()
        local sx, sy = slot:GetCenter()
        if px and sx then
            local dx, dy = px - sx, py - sy
            local angle
            if math.abs(dx) > math.abs(dy) then
                angle = dx > 0 and (math.pi / 2) or (-math.pi / 2)
            else
                angle = dy > 0 and math.pi or 0
            end
            icon:SetRotation(angle)
        end
    end
    pb:HookScript("OnShow", paint)
    pb:HookScript("OnEnter", function() pb.cuiOver = true paint() end)
    pb:HookScript("OnLeave", function() pb.cuiOver = false paint() end)
    paint()
end

local function skinSlots()
    local items = _G.PaperDollItemsFrame
    if not items then return end
    local function add(b)
        if b and not b.cuiSkinned and b.GetObjectType and b:GetObjectType() == "Button" then
            CUI:SkinItemSlot(b)
            slots[#slots + 1] = b
            local name = b:GetName()
            skinPopout(b.popoutButton or (name and _G[name .. "PopoutButton"]), b)
        end
    end
    for _, b in ipairs({ items:GetChildren() }) do
        local name = b.GetName and b:GetName()
        if type(name) == "string" and name:find("^Character.+Slot$") then add(b) end
    end
    -- Munitions et relique (propres à Forever, rangées ailleurs dans la fiche).
    for _, name in ipairs({ "CharacterAmmoSlot", "CharacterRangedSlot", "CharacterRelicSlot" }) do
        add(_G[name])
    end
    if type(_G.PaperDollItemSlotButton_Update) == "function" then
        _G.hooksecurefunc("PaperDollItemSlotButton_Update", function()
            CUI:SafeCall(CUI:Tr("FJ_FICHE"), updateSlots)
        end)
    end
    M:On("PLAYER_EQUIPMENT_CHANGED", function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), updateSlots) end)
    updateSlots()
end

-- Bouton « Nouvel ensemble » : son « + » vert (atlas « UI-Character-Info-Icon-Add ») devient un « + » au
-- trait, son texte vert passe en gris clair ; blancs au survol.
local function skinNewSet(b)
    if not b or b.cuiNewSet then return end
    b.cuiNewSet = true
    CUI:SkinButton(b)
    local plus, text = {}, nil
    for _, r in ipairs({ b:GetRegions() }) do
        if r:GetObjectType() == "FontString" then
            text = r
        elseif r:GetObjectType() == "Texture" then
            local atlas = r.GetAtlas and r:GetAtlas()
            if type(atlas) == "string" and not issecret(atlas) and atlas:find("Icon%-Add") then
                CUI:SkinHide(r)
                for i, angle in ipairs({ 0, 90 }) do
                    local t = b:CreateTexture(nil, "OVERLAY")
                    t:SetTexture(WHITE)
                    t:SetSize(11, 2)
                    t:SetPoint("CENTER", r, "CENTER")
                    t:SetRotation(math.rad(angle))
                    plus[i] = t
                end
            end
        end
    end
    local busy = false
    local function paint()
        if busy then return end
        busy = true
        local c = b.cuiOver and C.texte or C.texteSecondaire
        for _, t in ipairs(plus) do t:SetVertexColor(c[1], c[2], c[3], 1) end
        if text then text:SetTextColor(c[1], c[2], c[3]) end
        busy = false
    end
    if text then _G.hooksecurefunc(text, "SetTextColor", paint) end
    -- Mise en forme : texte sur une ligne, centré, le « + » devant ; le bouton à la largeur des boutons
    -- « Équiper » et « Sauver », juste au-dessus d'eux et de leur hauteur (s'ils ne sont pas posés par
    -- rapport à lui : sinon, boucle d'ancrage).
    if text then
        text:SetWordWrap(false)
        -- Le jeu lui donne une largeur fixe (coupé en « Nouvel ens... ») : largeur libre, celle du texte.
        text:SetWidth(0)
        text:ClearAllPoints()
        text:SetPoint("CENTER", b, "CENTER", 8, 0)
        for _, t in ipairs(plus) do
            t:ClearAllPoints()
            t:SetPoint("CENTER", text, "LEFT", -10, 0)
        end
    end
    local equip, save = _G.PaperDollFrameEquipSet, _G.PaperDollFrameSaveSet
    local function anchoredTo(frame, target)
        for i = 1, frame:GetNumPoints() do
            local _, rel = frame:GetPoint(i)
            if rel == target then return true end
        end
    end
    if equip and save and not anchoredTo(equip, b) and not anchoredTo(save, b) then
        local function layout()
            b:ClearAllPoints()
            b:SetPoint("BOTTOMLEFT", equip, "TOPLEFT", 0, 4)
            b:SetPoint("BOTTOMRIGHT", save, "TOPRIGHT", 0, 4)
            b:SetHeight(equip:GetHeight() > 0 and equip:GetHeight() or 24)
        end
        layout()
        b:HookScript("OnShow", layout)
    end
    b:HookScript("OnEnter", function() b.cuiOver = true paint() end)
    b:HookScript("OnLeave", function() b.cuiOver = false paint() end)
    paint()
end

-- Menu de choix d'une pièce (gestionnaire d'ensembles, EquipmentFlyoutFrame) : son décor (cadre doré,
-- liseré jaune autour de la case ouverte) invisible ; panneau du thème avec ombre sous les choix ; chaque
-- choix en case d'objet du thème. Les cases sont créées par le jeu au fur et à mesure : repris à chaque
-- ouverture.
local function skinFlyout()
    local fly = _G.EquipmentFlyoutFrame
    if not fly or (fly.IsForbidden and fly:IsForbidden()) then return end
    -- Boutons spéciaux (« Mettre dans les sacs », « Ignorer cet emplacement ») : notre icône au trait à la
    -- place du dessin du jeu. D'après l'emplacement que le jeu leur donne, sinon d'après leur dessin.
    local SPECIAL_TEX = { [255351] = "RangerSac", [255352] = "Ignorer", [255353] = "Ignorer" }
    local function special(b)
        local loc = b.location
        local picto
        if loc ~= nil and not issecret(loc) then
            if loc == _G.EQUIPMENTFLYOUT_PLACEINBAGS_LOCATION then
                picto = "RangerSac"
            elseif loc == _G.EQUIPMENTFLYOUT_IGNORESLOT_LOCATION or loc == _G.EQUIPMENTFLYOUT_UNIGNORESLOT_LOCATION then
                picto = "Ignorer"
            end
        end
        if not picto and b.cuiIcon then
            local tex = b.cuiIcon:GetTexture()
            if tex ~= nil and not issecret(tex) then picto = SPECIAL_TEX[tex] end
        end
        if picto and not b.cuiSpecial then
            b.cuiSpecial = b:CreateTexture(nil, "OVERLAY")
            b.cuiSpecial:SetSize(20, 20)
            b.cuiSpecial:SetPoint("CENTER")
            b:HookScript("OnEnter", function() b.cuiSpecial:SetVertexColor(C.texte[1], C.texte[2], C.texte[3], 1) end)
            b:HookScript("OnLeave", function()
                b.cuiSpecial:SetVertexColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3], 1)
            end)
        end
        if b.cuiSpecial then
            b.cuiSpecial:SetShown(picto ~= nil)
            if picto then
                b.cuiSpecial:SetTexture(CUI.MEDIA .. "Icones\\" .. picto)
                b.cuiSpecial:SetVertexColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3], 1)
            end
        end
        if b.cuiIcon then b.cuiIcon:SetAlpha(picto and 0 or 1) end
    end
    local function walk(frame)
        for _, child in ipairs({ frame:GetChildren() }) do
            local isItem = child:GetObjectType() == "Button" and (child.icon or child.Icon
                or (child:GetName() and _G[child:GetName() .. "IconTexture"]))
            if isItem then
                CUI:SkinItemSlot(child)
                special(child)
            elseif not child.cuiHidden then
                child.cuiHidden = true
                CUI:SkinHideTextures(child)
                walk(child)
            else
                walk(child)
            end
        end
    end
    -- Barre « Précédent / Suivant » (beaucoup de choix) : panneau du thème, flèches en petites cases avec
    -- notre chevron (tourné à gauche ou à droite), textes gris clair.
    local function skinNavigation(nav)
        if not nav or nav.cuiHidden then return end
        nav.cuiHidden = true
        CUI:SkinHideTextures(nav)
        CUI:CreatePanel(nav, { radius = 4 })
        for key, angle in pairs({ PrevButton = -math.pi / 2, NextButton = math.pi / 2 }) do
            local b = nav[key]
            if b then
                b.cuiHidden = true
                CUI:SkinIconButton(b, nil, "Chevron")
                if b.cuiPicto then b.cuiPicto:SetRotation(angle) end
            end
        end
        for _, key in ipairs({ "PreviousPageText", "NextPageText" }) do
            local fs = nav[key]
            if fs then fs:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3]) end
        end
    end
    local function each()
        if not fly.cuiHidden then
            fly.cuiHidden = true
            CUI:SkinHideTextures(fly)
        end
        skinNavigation(fly.NavigationFrame)
        walk(fly)
        local box = fly.buttonFrame
        if box and not box.cuiPanel then
            box.cuiHidden = true
            CUI:SkinHideTextures(box)
            -- Panneau calé sur les choix montrés (marge de 4), pas sur le conteneur du jeu, plus grand.
            local back = _G.CreateFrame("Frame", nil, box)
            back.cuiHidden = true -- notre cadre : à ne pas « nettoyer » au passage suivant
            back:SetFrameLevel(box:GetFrameLevel())
            box.cuiPanel = CUI:CreatePanel(back, { radius = 4 })
            box.cuiBack = back
        end
        if box and box.cuiBack then
            local function fit()
                local l, r, t, bt
                for _, b in ipairs({ box:GetChildren() }) do
                    if b.cuiSkinned and b.cuiIcon and b:IsShown() and b:GetLeft() then
                        l = math.min(l or b:GetLeft(), b:GetLeft())
                        r = math.max(r or b:GetRight(), b:GetRight())
                        t = math.max(t or b:GetTop(), b:GetTop())
                        bt = math.min(bt or b:GetBottom(), b:GetBottom())
                    end
                end
                local back = box.cuiBack
                if not l or not box:GetLeft() then back:Hide() return end
                back:ClearAllPoints()
                back:SetPoint("TOPLEFT", box, "TOPLEFT", l - box:GetLeft() - 4, t - box:GetTop() + 4)
                back:SetPoint("BOTTOMRIGHT", box, "TOPLEFT", r - box:GetLeft() + 4, bt - box:GetTop() - 4)
                back:Show()
            end
            fit()
            _G.C_Timer.After(0, function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), fit) end)
        end
        -- Morceaux du cadre doré que le jeu ajoute selon le nombre de choix (bg1, bg2, bg3...) : cachés à
        -- chaque ouverture.
        if box then
            for key, region in pairs(box) do
                if type(key) == "string" and key:match("^bg%d+$") and type(region) == "table" then
                    CUI:SkinHide(region)
                end
            end
        end
    end
    fly:HookScript("OnShow", function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), each) end)
    for _, fn in ipairs({ "EquipmentFlyout_Show", "EquipmentFlyout_DisplayButton" }) do
        if type(_G[fn]) == "function" then
            _G.hooksecurefunc(fn, function() CUI:SafeCall(CUI:Tr("FJ_FICHE"), each) end)
        end
    end
    each()
end

-- Bouton qui replie les statistiques : petite case, chevron vers la droite (replier) ou la gauche.
local function skinPaneToggle(b, pane)
    if not b then return end
    CUI:SkinHideTextures(b)
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
        local t = b[getter] and b[getter](b)
        if t then CUI:SkinHide(t) end
    end
    local panel = CUI:CreatePanel(b, { radius = 3, fill = C.case, shadow = false, inset = 4 })
    local icon = b:CreateTexture(nil, "OVERLAY")
    icon:SetTexture(CUI.MEDIA .. "Icones\\Chevron")
    icon:SetSize(12, 12)
    icon:SetPoint("CENTER")
    local function paint(over)
        local c = over and C.texte or C.texteSecondaire
        icon:SetVertexColor(c[1], c[2], c[3], 1)
        panel.border:SetColor(over and C.texteDiscret or C.lisereSombre)
        local open = not pane or pane:IsShown()
        icon:SetRotation(open and (math.pi / 2) or (-math.pi / 2))
    end
    b:HookScript("OnEnter", function() paint(true) end)
    b:HookScript("OnLeave", function() paint(false) end)
    b:HookScript("OnClick", function() paint(b:IsMouseOver()) end)
    if pane then
        pane:HookScript("OnShow", function() paint(false) end)
        pane:HookScript("OnHide", function() paint(false) end)
    end
    paint(false)
end

-- Petits onglets en haut des statistiques (PaperDollSidebarTab1 à 3) : petites cases et nos icônes au
-- trait (celles du jeu ont leur cadre dessiné dedans) : gris clair, blanches au survol et sur l'onglet
-- ouvert (le jeu cache alors son voile « Hider »), au liseré plus clair.
-- Ordre de Forever : statistiques, ensembles d'équipement, titres.
local TAB_ICONS = { "Statistiques", "Ensembles", "Titre" }

local function tabIcon(_, i)
    return TAB_ICONS[i]
end

-- Panneau ouvert par chaque petit onglet (ordre de Forever).
-- Statistiques (1) : pas de panneau fiable sur Forever ; ouvert quand ni les ensembles ni les titres ne
-- le sont.
local function tabPane(i)
    local doll = _G.PaperDollFrame
    if i == 2 then return doll and doll.EquipmentManagerPane end
    if i == 3 then return doll and doll.TitleManagerPane end
end

local sidebarPaints = {}
local function paintSidebar()
    for _, paint in ipairs(sidebarPaints) do paint() end
end

local function skinSidebarTabs()
    for i = 1, 5 do
        local tab = _G["PaperDollSidebarTab" .. i]
        if tab and not tab.cuiSkinned then
            tab.cuiSkinned = true
            local hider = tab.Hider
            for _, key in ipairs({ "TabBg", "Highlight", "Hider", "Icon" }) do
                if tab[key] then CUI:SkinHide(tab[key]) end
            end
            local hl = tab.GetHighlightTexture and tab:GetHighlightTexture()
            if hl then CUI:SkinHide(hl) end
            -- Tout le décor du jeu (cadres jaune, brun, gris selon l'état), sur l'onglet et ses enfants.
            CUI:SkinHideTextures(tab)
            for _, child in ipairs({ tab:GetChildren() }) do CUI:SkinHideTextures(child) end
            local name = tabIcon(tab, i)
            local icon
            if name then
                icon = tab:CreateTexture(nil, "OVERLAY")
                icon:SetTexture(CUI.MEDIA .. "Icones\\" .. name)
                icon:SetSize(18, 18)
                icon:SetPoint("CENTER")
            end
            local panel = CUI:CreatePanel(tab, { radius = 3, fill = C.case, shadow = false, inset = 1 })
            -- Ouvert : d'après le panneau montré (statistiques, ensembles, titres) ; sinon d'après le voile
            -- « Hider » du jeu. Mêmes états que les onglets de côté (pas d'or) : fermé sombre, icône grise ;
            -- survolé liseré gris, icône blanche ; ouvert case plus claire, liseré gris clair, icône blanche.
            local pane = tabPane(i)
            local function paint()
                local on
                if i == 1 then
                    local sets, titles = tabPane(2), tabPane(3)
                    on = not ((sets and sets:IsShown()) or (titles and titles:IsShown()))
                elseif pane then
                    on = pane:IsShown()
                else
                    on = not (hider and hider:IsShown())
                end
                panel.border:SetColor(on and C.texteDiscret or (tab.cuiOver and C.bordureDiscrete or C.lisereSombre))
                panel:SetFillColor(on and C.panneau or C.case)
                if icon then
                    local c = (on or tab.cuiOver) and C.texte or C.texteSecondaire
                    icon:SetVertexColor(c[1], c[2], c[3], 1)
                end
            end
            sidebarPaints[#sidebarPaints + 1] = paint
            if pane then
                pane:HookScript("OnShow", paintSidebar)
                pane:HookScript("OnHide", paintSidebar)
            elseif i == 1 then
                -- Repeint par les panneaux des deux autres onglets (accrochés à leur tour).
            elseif hider then
                _G.hooksecurefunc(hider, "Show", paint)
                _G.hooksecurefunc(hider, "Hide", paint)
                if hider.SetShown then _G.hooksecurefunc(hider, "SetShown", paint) end
            end
            tab:HookScript("OnEnter", function() tab.cuiOver = true paint() end)
            tab:HookScript("OnLeave", function() tab.cuiOver = false paint() end)
            paint()
        end
    end
end

-- Onglets de côté (ordre de Forever) : notre icône au trait et le nom de la page, rappelé en petites
-- capitales à gauche du titre quand elle est ouverte.
local SIDE_TABS = {
    { picto = "Personnage", page = "FJ_PAGE_PERSO" },
    { picto = "Reputation", page = "FJ_PAGE_REPU" },
    { picto = "Metiers", page = "FJ_PAGE_COMP" },
    { picto = "JcJ", page = "FJ_PAGE_JCJ" },
    { picto = "Monnaies", page = "FJ_PAGE_MONNAIES" },
    { picto = "Courbe", page = "FJ_PAGE_STATS" },
}

local function skinSideTabs(f)
    local label = f:CreateFontString(nil, "OVERLAY")
    label:SetFont(CUI:GetFont(), 10, "")
    label:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
    label:SetPoint("LEFT", f, "TOPLEFT", 14, -12)
    local tabs = {}
    local function update()
        local text = ""
        for i, tab in ipairs(tabs) do
            local sel = tab.SelectedTexture
            if sel and sel:IsShown() and SIDE_TABS[i] then text = CUI:Upper(CUI:Tr(SIDE_TABS[i].page)) end
        end
        label:SetText(text)
    end
    for i = 1, 10 do
        local tab = _G["CharacterFrameModeTab" .. i]
        if tab then
            tabs[#tabs + 1] = tab
            CUI:SkinSideTab(tab, SIDE_TABS[i] and SIDE_TABS[i].picto)
            local sel = tab.SelectedTexture
            if sel then
                _G.hooksecurefunc(sel, "Show", update)
                _G.hooksecurefunc(sel, "Hide", update)
                if sel.SetShown then _G.hooksecurefunc(sel, "SetShown", update) end
            end
        end
    end
    f:HookScript("OnShow", update)
    update()
end

-- Boutons du personnage (zoom, rotation, retour) : nos icônes au trait. D'après leur nom dans le jeu,
-- sinon d'après leur ordre (celui de l'écran).
local CONTROLS = {
    { keys = { "zoomInButton", "ZoomInButton" }, picto = "ZoomPlus" },
    { keys = { "zoomOutButton", "ZoomOutButton" }, picto = "ZoomMoins" },
    { keys = { "rotateLeftButton", "RotateLeftButton" }, picto = "TournerGauche" },
    { keys = { "rotateRightButton", "RotateRightButton" }, picto = "TournerDroite" },
    { keys = { "resetButton", "ResetButton" }, picto = "Recharger" },
}

local function skinControls(controls)
    local buttons = {}
    for _, b in ipairs({ controls:GetChildren() }) do
        if b:GetObjectType() == "Button" then buttons[#buttons + 1] = b end
    end
    local byKey = 0
    for _, c in ipairs(CONTROLS) do
        for _, key in ipairs(c.keys) do
            local b = controls[key]
            if b and not b.cuiSkinned then
                CUI:SkinIconButton(b, b.Icon, c.picto)
                byKey = byKey + 1
            end
        end
    end
    for i, b in ipairs(buttons) do
        if not b.cuiSkinned then
            CUI:SkinIconButton(b, b.Icon, byKey == 0 and CONTROLS[i] and CONTROLS[i].picto or nil)
        end
    end
end

-- « Guerrier de niveau 6 » : la classe en blanc, le reste en gris clair (plus de jaune ni de couleur de
-- classe du jeu).
local function skinLevelText()
    local fs = _G.CharacterLevelText
    if not fs then return end
    local white = string.format("|cff%02x%02x%02x", C.texte[1] * 255, C.texte[2] * 255, C.texte[3] * 255)
    local busy = false
    local function restyle(self)
        if busy then return end
        local text = self:GetText()
        if type(text) ~= "string" or issecret(text) then return end
        busy = true
        text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        local class = _G.UnitClass("player")
        if type(class) == "string" and not issecret(class) and class ~= "" then
            local a, b = text:find(class, 1, true)
            if a then text = text:sub(1, a - 1) .. white .. class .. "|r" .. text:sub(b + 1) end
        end
        self:SetText(text)
        self:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
        busy = false
    end
    _G.hooksecurefunc(fs, "SetText", restyle)
    if fs.SetFormattedText then _G.hooksecurefunc(fs, "SetFormattedText", restyle) end
    restyle(fs)
end

-- Fond du personnage : une case sombre entre les deux colonnes d'équipement, sous le personnage.
local function skinScene(scene)
    CUI:SkinHideTextures(scene)
    local head, last = _G.CharacterHeadSlot, _G.CharacterTrinket1Slot
    local bg = _G.CreateFrame("Frame", nil, scene:GetParent())
    if head and last then
        bg:SetPoint("TOPLEFT", head, "TOPRIGHT", 10, 0)
        bg:SetPoint("BOTTOMRIGHT", last, "BOTTOMLEFT", -10, 0)
    else
        bg:SetAllPoints(scene)
    end
    bg:SetFrameLevel(math.max(0, scene:GetFrameLevel() - 1))
    CUI:CreatePanel(bg, { radius = 3, fill = C.case, shadow = false })
    -- Le personnage tient dans la case (sinon ses pieds la dépassent) : l'aperçu prend la taille de la
    -- case. Seulement si les cases ne sont pas posées par rapport à l'aperçu (sinon : boucle d'ancrage).
    if head and last then
        local function anchoredToScene(slot)
            for i = 1, slot:GetNumPoints() do
                local _, rel = slot:GetPoint(i)
                if rel == scene then return true end
            end
        end
        if not anchoredToScene(head) and not anchoredToScene(last) then
            local function fit()
                scene:ClearAllPoints()
                scene:SetPoint("TOPLEFT", bg, "TOPLEFT", 2, -2)
                scene:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -2, 2)
            end
            fit()
            _G.CharacterFrame:HookScript("OnShow", fit)
        end
    end
end

-- Fiche ------------------------------------------------------------------------------------------------

local function skinFiche()
    local f = _G.CharacterFrame
    if not f or (f.IsForbidden and f:IsForbidden()) then return end
    CUI:SkinWindow(f)
    CUI:SkinCloseButton(_G.CharacterFrameCloseButton)
    -- Déplaçable par son bandeau ; place gardée pour le compte.
    if type(M.db.positions) ~= "table" then M.db.positions = {} end
    CUI:SkinMovable(f, M.db.positions, "fiche", 24)
    -- Titre : toujours le nom du personnage, en blanc (le jeu y met le nom de la page, en jaune ; la page
    -- est rappelée en petites capitales à gauche).
    local title = _G.CharacterFrameTitleText
    if title then
        local busy = false
        local function restyle(self)
            if busy then return end
            busy = true
            local name = _G.UnitName("player")
            if type(name) == "string" and not issecret(name) then self:SetText(name) end
            self:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
            busy = false
        end
        _G.hooksecurefunc(title, "SetText", restyle)
        _G.hooksecurefunc(title, "SetTextColor", restyle)
        if title.SetFormattedText then _G.hooksecurefunc(title, "SetFormattedText", restyle) end
        restyle(title)
    end
    -- Bandeau du titre : fondu dans le fond, un trait sombre dessous.
    local headerLine = line(f, C.lisereSombre)
    headerLine:SetHeight(1)
    headerLine:SetPoint("TOPLEFT", 2, -24)
    headerLine:SetPoint("TOPRIGHT", -2, -24)

    -- Colonnes : fonds de pierre invisibles ; un trait sombre entre les deux.
    CUI:SkinHideTextures(_G.CharacterFrameLeftPaneHost)
    local right = _G.CharacterFrameRightPaneHost
    if right then
        CUI:SkinHideTextures(right)
        for _, child in ipairs({ right:GetChildren() }) do CUI:SkinHideTextures(child) end
        local divider = line(right, C.lisereSombre)
        divider:SetWidth(1)
        divider:SetPoint("TOPLEFT", 0, 0)
        divider:SetPoint("BOTTOMLEFT", 0, 2)
    end
    local doll = _G.PaperDollFrame
    if doll and doll.TopBackgroundStripHost then CUI:SkinHideTextures(doll.TopBackgroundStripHost) end

    -- Statistiques, familier, titres, ensembles d'équipement.
    skinScrollList(_G.CharacterStatsPaneScrollBox)
    skinScrollList(_G.CharacterStatsPanePetScrollBox)
    if doll then
        skinScrollList(doll.TitleManagerPane)
        skinScrollList(doll.EquipmentManagerPane)
    end
    local statsPane = _G.CharacterStatsPane
    if statsPane then
        for _, child in ipairs({ statsPane:GetChildren() }) do skinRow(child) end
        if statsPane.ItemLevelFrame and statsPane.ItemLevelFrame.Background then
            CUI:SkinHide(statsPane.ItemLevelFrame.Background)
        end
    end
    for _, name in ipairs({ "PaperDollFrameEquipSet", "PaperDollFrameSaveSet", "PaperDollFrameNewSet" }) do
        CUI:SkinButton(_G[name])
    end
    skinNewSet(_G.PaperDollFrameNewSet)

    -- Personnage : fond de case sombre, boutons en petites cases.
    local scene = _G.CharacterModelScene
    if scene then
        skinScene(scene)
        if scene.ControlFrame then skinControls(scene.ControlFrame) end
    end
    skinPaneToggle(_G.CharacterFrameRightPaneToggleButton, right)
    skinLevelText()
    skinSideTabs(f)

    skinSidebarTabs()
    skinSlots()
    skinFlyout()
    f:HookScript("OnShow", function()
        CUI:SafeCall(CUI:Tr("FJ_FICHE"), skinSidebarTabs) -- créés parfois après coup par le jeu
        CUI:SafeCall(CUI:Tr("FJ_FICHE"), paintSidebar)
        CUI:SafeCall(CUI:Tr("FJ_FICHE"), updateSlots)
    end)
end

M.windows.fiche = { setup = skinFiche }
