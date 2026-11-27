-- Module « Sacs et banque » (maquette validée le 27/11/2026, « CœurUI · Maquette Sacs et banque »).
-- Étape 1 : les sacs. Une seule fenêtre sobre (fond sombre, liseré gris fin, pas d'or) pour tous les
-- sacs, à la place de ceux du jeu, placée au cadenas :
--   - par catégories (Équipement, Consommables, Composants d'artisanat, Quêtes, Divers, Camelote,
--     Places libres) ou en vrac (une grille, dans l'ordre des sacs) ;
--   - sacs de composants et carquois à part, en bas, avec leur nom et leurs places libres ;
--   - cases comme les barres d'actions : icône rognée, liseré gris fin, liseré de la qualité à partir
--     de « Peu commun », niveau d'objet en bas à gauche, nombre en bas à droite, pastille rouge cœur sur
--     un nouvel objet (jusqu'au survol) ;
--   - recherche par nom (le reste s'assombrit) ; en bas : sacs équipés, places libres, argent ;
--   - déplacée en glissant sa barre de titre (ou au cadenas).
-- Les cases sont les boutons d'objet du jeu (ContainerFrameItemButtonTemplate) : clics, glisser,
-- infobulle et utilisation restent ceux du jeu. Étapes suivantes : camelote, banque.
-- Couper le module demande un /reload.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local WHITE = "Interface\\Buttons\\WHITE8x8"
local HEADER, SEARCH, FOOTER, PAD = 34, 26, 34, 12
local CASE_VIDE = { 0.063, 0.071, 0.094 } -- #101218

local M = CUI:RegisterModule({
    key = "Sacs",
    name = "SAC_NOM",
    description = "SAC_DESC",
    defaultEnabled = false,
    needsReload = true,
    defaults = {
        categories = true, aPart = true, parRangee = 10, taille = 34, espacement = 4,
        ilvl = true, qualite = true, nouveaux = true,
        emplacements = true, -- emplacements de sac en bas (bouton de la barre de titre)
    },
    settings = {
        { type = "section", text = "SAC_RANGEMENT" },
        { type = "toggle", key = "categories", label = "SAC_CATEGORIES", description = "SAC_CATEGORIES_NOTE" },
        { type = "toggle", key = "aPart", label = "SAC_A_PART" },
        { type = "section", text = "SAC_DISPOSITION" },
        { type = "slider", key = "parRangee", label = "SAC_PAR_RANGEE", min = 6, max = 20, step = 1, format = "%d" },
        { type = "slider", key = "taille", label = "SAC_TAILLE", min = 24, max = 48, step = 2, format = "%d" },
        { type = "slider", key = "espacement", label = "SAC_ESPACEMENT", min = 0, max = 10, step = 1, format = "%d" },
        { type = "column" },
        { type = "section", text = "SAC_AFFICHAGE" },
        { type = "toggle", key = "ilvl", label = "SAC_ILVL" },
        { type = "toggle", key = "qualite", label = "SAC_QUALITE" },
        { type = "toggle", key = "nouveaux", label = "SAC_NOUVEAUX" },
    },
})

-- Sacs du joueur : 0 (sac à dos) à 4, plus le sac de composants du jeu s'il existe.
local function playerBags()
    local last = _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS or _G.NUM_BAG_SLOTS or 4
    local list = {}
    for bag = 0, last do list[#list + 1] = bag end
    return list
end

-- Catégories, dans l'ordre de la fenêtre.
local CATEGORIES = { "equipement", "consommables", "composants", "quetes", "divers", "camelote", "libres" }
local CATEGORY_TITLES = {
    equipement = "SAC_CAT_EQUIPEMENT", consommables = "SAC_CAT_CONSOMMABLES", composants = "SAC_CAT_COMPOSANTS",
    quetes = "SAC_CAT_QUETES", divers = "SAC_CAT_DIVERS", camelote = "SAC_CAT_CAMELOTE", libres = "SAC_CAT_LIBRES",
}
-- Classes d'objet du jeu (Enum.ItemClass) : 0 consommable, 2 arme, 3 gemme, 4 armure, 5 composant,
-- 7 artisanat, 8 amélioration, 12 quête.
local CLASS_CATEGORY = { [0] = "consommables", [2] = "equipement", [4] = "equipement", [3] = "composants",
                         [5] = "composants", [7] = "composants", [8] = "composants", [12] = "quetes" }

local function categoryOf(info)
    if not info then return "libres" end
    if info.quality == 0 then return "camelote" end
    local _, classID, _, equipLoc = CUI:ItemInstant(info.hyperlink or info.itemID)
    if classID == 4 and (equipLoc == nil or equipLoc == "" or equipLoc == "INVTYPE_NON_EQUIP_IGNORE") then
        return "divers"
    end
    return CLASS_CATEGORY[classID] or "divers"
end

-- Fenêtre -------------------------------------------------------------------------------------

local win, search, freeText, moneyText
local holders = {}   -- sac -> cadre porteur (son ID = le sac, demandé par les boutons du jeu)
local buttons = {}   -- sac -> case -> bouton
local titles = {}    -- textes de section réutilisés
local separator
local bagSlots = {}  -- boutons des sacs équipés (bas de la fenêtre)
local placed = {}    -- boutons affichés (pour la recherche)

local function texture(parent, layer, sub, color)
    local t = parent:CreateTexture(nil, layer, nil, sub)
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    return t
end

local function lines(parent, color)
    local l = {}
    for i = 1, 4 do l[i] = texture(parent, "OVERLAY", 6, color) end
    l[1]:SetPoint("TOPLEFT"); l[1]:SetPoint("TOPRIGHT"); l[1]:SetHeight(1)
    l[2]:SetPoint("BOTTOMLEFT"); l[2]:SetPoint("BOTTOMRIGHT"); l[2]:SetHeight(1)
    l[3]:SetPoint("TOPLEFT"); l[3]:SetPoint("BOTTOMLEFT"); l[3]:SetWidth(1)
    l[4]:SetPoint("TOPRIGHT"); l[4]:SetPoint("BOTTOMRIGHT"); l[4]:SetWidth(1)
    return l
end

local function setLines(l, color)
    for _, t in ipairs(l) do t:SetVertexColor(color[1], color[2], color[3], 1) end
end

local function hide(region)
    if region and region.SetAlpha then region:SetAlpha(0) end
end

-- Argent : « 12 po 34 pa 5 pc », couleurs des pièces.
local OR, ARGENT, CUIVRE = "|cffe6c84a", "|cffc9cdd4", "|cffc98a5a"
local function moneyString(copper)
    local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
    local parts = {}
    if g > 0 then parts[#parts + 1] = OR .. L.SAC_PO:format(_G.BreakUpLargeNumbers and _G.BreakUpLargeNumbers(g) or g) .. "|r" end
    if g > 0 or s > 0 then parts[#parts + 1] = ARGENT .. L.SAC_PA:format(s) .. "|r" end
    parts[#parts + 1] = CUIVRE .. L.SAC_PC:format(c) .. "|r"
    return table.concat(parts, "  ")
end

local function holderFor(bag)
    local h = holders[bag]
    if h then return h end
    h = _G.CreateFrame("Frame", nil, win)
    h:SetID(bag)
    h:SetAllPoints()
    -- Les boutons du jeu demandent leur sac à leur parent.
    h.GetBagID = function(self) return self:GetID() end
    holders[bag] = h
    buttons[bag] = {}
    return h
end

-- Habillage d'un bouton d'objet du jeu (une fois).
local function skinButton(b)
    local icon = b.icon or b.Icon
    if icon then
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", -1, 1)
    end
    local normal = b.GetNormalTexture and b:GetNormalTexture()
    if normal then normal:SetAlpha(0) end
    for _, k in ipairs({ "IconBorder", "IconOverlay", "IconOverlay2", "NewItemTexture", "BattlepayItemTexture",
                         "flash", "JunkIcon", "searchOverlay", "ItemContextOverlay", "ExtendedSlot",
                         "ItemSlotBackground", "EmptyBackground" }) do
        hide(b[k])
    end
    -- Toutes les textures du modèle (fond de case vide, cadres, marques) : retirées, quelle que soit leur
    -- couche. Restent l'icône et la surbrillance du survol ; nos fonds et liserés les remplacent.
    for _, region in ipairs({ b:GetRegions() }) do
        if region ~= icon and region.GetDrawLayer and region:GetObjectType() == "Texture"
            and region:GetDrawLayer() ~= "HIGHLIGHT" then
            region:SetAlpha(0)
        end
    end
    b.cuiBack = texture(b, "BACKGROUND", -8, C.fond)
    b.cuiBack:SetAllPoints()
    b.cuiLines = lines(b, C.graphite)
    b.cuiIlvl = b:CreateFontString(nil, "OVERLAY")
    b.cuiIlvl:SetPoint("BOTTOMLEFT", 2, 2)
    b.cuiIlvl:SetShadowColor(0, 0, 0, 1)
    b.cuiIlvl:SetShadowOffset(1, -1)
    b.cuiNew = texture(b, "OVERLAY", 7, C.coeur)
    b.cuiNew:SetTexture(CUI.MEDIA .. "Cercle")
    b.cuiNew:SetSize(8, 8)
    b.cuiNew:SetPoint("CENTER", b, "TOPRIGHT", -2, -2)
    b.cuiNew:Hide()
    if b.Count then
        b.Count:ClearAllPoints()
        b.Count:SetPoint("BOTTOMRIGHT", -2, 2)
    end
    -- Survol : le nouvel objet n'est plus nouveau.
    b:HookScript("OnEnter", function(self)
        if self.cuiNew:IsShown() then
            local NI = _G.C_NewItems
            if NI and NI.RemoveNewItem then pcall(NI.RemoveNewItem, self.cuiBag, self.cuiSlot) end
            self.cuiNew:Hide()
        end
    end)
end

local nextButton = 0
local function buttonFor(bag, slot)
    local list = buttons[bag]
    local b = list and list[slot]
    if b then return b end
    local h = holderFor(bag)
    nextButton = nextButton + 1
    local ok, created = pcall(_G.CreateFrame, "ItemButton", "CoeurUISacsCase" .. nextButton, h,
        "ContainerFrameItemButtonTemplate")
    if not ok then
        ok, created = pcall(_G.CreateFrame, "Button", "CoeurUISacsCase" .. nextButton, h,
            "ContainerFrameItemButtonTemplate")
    end
    if not ok then error(created) end
    b = created
    b:SetID(slot)
    b.bagID = bag
    b.cuiBag, b.cuiSlot = bag, slot
    skinButton(b)
    buttons[bag][slot] = b
    return b
end

-- Contenu d'une case : icône, nombre, verrou, qualité, niveau d'objet, recharge, nouvel objet.
local function updateButton(b, info)
    local s = M.db
    local font = CUI:GetFont()
    local tex = info and info.iconFileID or nil
    if _G.SetItemButtonTexture then _G.SetItemButtonTexture(b, tex) elseif b.icon then b.icon:SetTexture(tex) end
    local count = info and info.stackCount or 0
    if _G.SetItemButtonCount then _G.SetItemButtonCount(b, count) end
    if b.Count then b.Count:SetFont(font, math.max(9, math.floor(s.taille / 3)), "OUTLINE") end
    if _G.SetItemButtonDesaturated then _G.SetItemButtonDesaturated(b, info and info.isLocked or false) end
    local icon = b.icon or b.Icon
    if icon then
        icon:SetAlpha(info and info.quality == 0 and 0.7 or 1)
        -- Case vide : le jeu y met son dessin de sac vide ; on n'en garde rien.
        if info then icon:Show() else icon:SetTexture(nil); icon:Hide() end
    end
    -- Case vide : fond un peu plus sombre, liseré à peine visible. Sinon : couleur de la qualité à
    -- partir de « Peu commun ».
    local back = info and C.fond or CASE_VIDE
    b.cuiBack:SetVertexColor(back[1], back[2], back[3], 1)
    local color = info and C.graphite or C.desactiveFond
    if s.qualite and info and info.quality and info.quality >= 2 then
        color = CUI:ItemQualityColor(info.quality) or C.graphite
    end
    setLines(b.cuiLines, color)
    -- Niveau d'objet : équipement seulement.
    local ilvl
    if s.ilvl and info and info.hyperlink then
        local _, classID, _, equipLoc = CUI:ItemInstant(info.hyperlink)
        if (classID == 2 or classID == 4) and equipLoc and equipLoc ~= "" and equipLoc ~= "INVTYPE_BAG" then
            ilvl = CUI:ItemLevel(info.hyperlink)
        end
    end
    b.cuiIlvl:SetFont(font, math.max(8, math.floor(s.taille / 3.4)), "OUTLINE")
    b.cuiIlvl:SetText(ilvl and ilvl > 1 and ilvl or "")
    -- Recharge.
    if b.Cooldown and _G.CooldownFrame_Set then
        if info then
            local start, duration, enable = CUI:BagCooldown(b.cuiBag, b.cuiSlot)
            _G.CooldownFrame_Set(b.Cooldown, start, duration, enable)
        else
            b.Cooldown:Hide()
        end
    end
    -- Nouvel objet.
    local isNew = false
    if s.nouveaux and info and _G.C_NewItems and _G.C_NewItems.IsNewItem then
        isNew = _G.C_NewItems.IsNewItem(b.cuiBag, b.cuiSlot) and true or false
    end
    b.cuiNew:SetShown(isNew)
    b.cuiName = nil
    if info and info.hyperlink then b.cuiName = info.hyperlink:match("%[(.-)%]") end
    b.cuiEmpty = info == nil
end

-- Recherche : ce qui ne correspond pas s'assombrit.
local function applySearch()
    local text = search and search:GetText() or ""
    text = text:lower()
    for _, b in ipairs(placed) do
        local match = text == "" or (b.cuiName and b.cuiName:lower():find(text, 1, true) ~= nil)
        b:SetAlpha(match and 1 or 0.25)
    end
end

local function titleFS(i)
    local fs = titles[i]
    if not fs then
        fs = win:CreateFontString(nil, "OVERLAY")
        fs:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
        titles[i] = fs
    end
    fs:SetFont(CUI:GetFont(), 10, "")
    fs:Show()
    return fs
end

-- Range toute la fenêtre (cases, sections, taille).
local function layout()
    if not win then return end
    local s = M.db
    local size, gap, per = s.taille, s.espacement, s.parRangee
    local innerW = per * (size + gap) - gap
    local width = innerW + 2 * PAD
    for _, list in pairs(buttons) do
        for _, b in pairs(list) do b:Hide() end
    end
    for _, fs in pairs(titles) do fs:Hide() end
    for _, fs in pairs(win.rightTitles or {}) do fs:Hide() end
    _G.wipe(placed)

    -- Sacs ordinaires et sacs à part.
    local normal, special = {}, {}
    local freeCount = 0
    for _, bag in ipairs(playerBags()) do
        local slots = CUI:BagSlots(bag)
        if slots > 0 then
            local free, family = CUI:BagFree(bag)
            if s.aPart and family ~= 0 then
                special[#special + 1] = { bag = bag, slots = slots, free = free }
            else
                normal[#normal + 1] = { bag = bag, slots = slots }
                freeCount = freeCount + free
            end
        end
    end

    local y = HEADER + SEARCH + 2 * 8
    local titleIndex = 0
    local function section(title, entries, right)
        if title then
            titleIndex = titleIndex + 1
            local fs = titleFS(titleIndex)
            fs:SetText(title)
            fs:ClearAllPoints()
            fs:SetPoint("TOPLEFT", win, "TOPLEFT", PAD, -y)
            if right then
                win.rightTitles = win.rightTitles or {}
                local r = win.rightTitles[titleIndex]
                if not r then
                    r = win:CreateFontString(nil, "OVERLAY")
                    r:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
                    win.rightTitles[titleIndex] = r
                end
                r:SetFont(CUI:GetFont(), 10, "")
                r:SetText(right)
                r:ClearAllPoints()
                r:SetPoint("TOPRIGHT", win, "TOPRIGHT", -PAD, -y)
                r:Show()
            end
            y = y + 16
        end
        for i, e in ipairs(entries) do
            local b = buttonFor(e.bag, e.slot)
            local col, row = (i - 1) % per, math.floor((i - 1) / per)
            b:SetSize(size, size)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", win, "TOPLEFT", PAD + col * (size + gap), -(y + row * (size + gap)))
            updateButton(b, e.info)
            b:Show()
            placed[#placed + 1] = b
        end
        local rows = math.ceil(#entries / per)
        y = y + rows * (size + gap) - gap + 10
    end

    -- Cases des sacs ordinaires.
    local all = {}
    for _, nb in ipairs(normal) do
        for slot = 1, nb.slots do
            all[#all + 1] = { bag = nb.bag, slot = slot, info = CUI:BagItem(nb.bag, slot) }
        end
    end
    if s.categories then
        local groups = {}
        for _, e in ipairs(all) do
            local cat = categoryOf(e.info)
            groups[cat] = groups[cat] or {}
            table.insert(groups[cat], e)
        end
        for _, cat in ipairs(CATEGORIES) do
            if groups[cat] and #groups[cat] > 0 then section(L[CATEGORY_TITLES[cat]], groups[cat]) end
        end
    else
        section(nil, all)
    end

    -- Sacs à part : leur nom et leurs places libres.
    if #special > 0 then
        separator:ClearAllPoints()
        separator:SetPoint("TOPLEFT", win, "TOPLEFT", PAD, -(y - 4))
        separator:SetWidth(innerW)
        separator:Show()
        y = y + 4
        for _, sb in ipairs(special) do
            local entries = {}
            for slot = 1, sb.slots do
                entries[#entries + 1] = { bag = sb.bag, slot = slot, info = CUI:BagItem(sb.bag, slot) }
            end
            local name = CUI:BagName(sb.bag) or ""
            section(name:upper(), entries, L.SAC_LIBRES_SUR:format(sb.free, sb.slots))
        end
    else
        separator:Hide()
    end

    -- Bas : sacs équipés, places libres, argent.
    local height = y + FOOTER
    win:SetSize(width, height)
    freeText:SetText(L.SAC_PLACES_LIBRES:format(freeCount))
    moneyText:SetText(moneyString(_G.GetMoney()))
    -- Emplacements de sac : affichés ou cachés (bouton « tiroir » de la barre de titre).
    freeText:ClearAllPoints()
    freeText:SetPoint("BOTTOMLEFT", win, "BOTTOMLEFT", PAD + (s.emplacements and win.slotsWidth or 0), 12)
    for i, slotButton in ipairs(bagSlots) do
        slotButton:SetShown(s.emplacements)
        local inv = CUI:BagInventorySlot(i)
        slotButton.inv = inv
        local tex = inv and _G.GetInventoryItemTexture("player", inv)
        slotButton.icon:SetTexture(tex)
        slotButton.icon:SetShown(tex ~= nil)
    end
    applySearch()
end

-- Fenêtre ouverte : remise en page ; fermée : elle le sera à la prochaine ouverture.
local function refresh()
    if win and win:IsShown() then CUI:SafeCall(CUI:Tr("SAC_NOM"), layout) end
end

-- Plusieurs évènements à la suite : une seule remise en page, à l'image suivante.
local pending = false
local function requestRefresh()
    if pending then return end
    pending = true
    M:After(0, function()
        pending = false
        refresh()
    end)
end

-- Bouton d'un sac équipé : son icône ; clic : le prendre, ou poser celui qu'on tient.
local function createBagSlot(i)
    local b = _G.CreateFrame("Button", nil, win)
    b:SetSize(20, 20)
    b:RegisterForClicks("LeftButtonUp")
    b:RegisterForDrag("LeftButton")
    texture(b, "BACKGROUND", -8, C.fond):SetAllPoints()
    lines(b, C.graphite)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 1, -1)
    b.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local function put(self)
        if not self.inv then return end
        if _G.CursorHasItem() then
            _G.PutItemInBag(self.inv)
        else
            _G.PickupBagFromSlot(self.inv)
        end
    end
    b:SetScript("OnClick", put)
    b:SetScript("OnReceiveDrag", put)
    b:SetScript("OnDragStart", function(self) if self.inv then _G.PickupBagFromSlot(self.inv) end end)
    b:SetScript("OnEnter", function(self)
        if self.inv then
            CUI:ShowGameTooltip(self, function(tip)
                if not tip:SetInventoryItem("player", self.inv) then tip:SetText(L.SAC_EMPLACEMENT_VIDE) end
            end)
        end
    end)
    b:SetScript("OnLeave", function(self) CUI:HideGameTooltip(self) end)
    return b
end

local function build()
    if win then return end
    win = _G.CreateFrame("Frame", "CoeurUISacs", _G.UIParent)
    win:SetFrameStrata("MEDIUM")
    win:SetToplevel(true)
    win:SetClampedToScreen(true)
    win:EnableMouse(true)
    win:Hide()
    CUI:CreateBorderedRect(win, 3, C.bordureDiscrete, { C.fond[1], C.fond[2], C.fond[3], 0.96 })
    -- Échap ferme la fenêtre, comme les sacs du jeu.
    table.insert(_G.UISpecialFrames, "CoeurUISacs")

    local title = win:CreateFontString(nil, "OVERLAY")
    title:SetFont(CUI:GetFont(), 13, "")
    title:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    title:SetPoint("TOPLEFT", PAD, -10)
    title:SetText(L.SAC_TITRE)
    local close = _G.CreateFrame("Button", nil, win)
    close:SetSize(22, 22)
    close:SetPoint("TOPRIGHT", -6, -6)
    close.text = close:CreateFontString(nil, "OVERLAY")
    close.text:SetFont(CUI:GetFont(), 16, "")
    close.text:SetPoint("CENTER")
    close.text:SetText("×")
    close.text:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
    close:SetScript("OnClick", function() win:Hide() end)
    close:SetScript("OnEnter", function(self) self.text:SetTextColor(C.texte[1], C.texte[2], C.texte[3]) end)
    close:SetScript("OnLeave", function(self)
        self.text:SetTextColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3])
    end)
    -- Boutons de la barre de titre : chacun bascule un réglage (pâle quand il est coupé).
    -- iconName : texture de Media/Icones ; tipOn / tipOff : clés de l'infobulle selon l'état.
    local function titleToggle(anchor, iconName, key, tipOn, tipOff)
        local btn = _G.CreateFrame("Button", nil, win)
        btn:SetSize(18, 18)
        btn:SetPoint("RIGHT", anchor, "LEFT", -4, 0)
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetAllPoints()
        btn.icon:SetTexture(CUI.MEDIA .. "Icones\\" .. iconName)
        local function paint(over)
            local c = over and C.texte or (M.db[key] and C.texteSecondaire or C.texteDiscret)
            btn.icon:SetVertexColor(c[1], c[2], c[3], 1)
        end
        local function tip()
            CUI:ShowTooltip(btn, M.db[key] and L[tipOn] or L[tipOff])
        end
        paint(false)
        btn:SetScript("OnClick", function()
            M.db[key] = not M.db[key]
            paint(true)
            tip()
            CUI:SafeCall(CUI:Tr("SAC_NOM"), layout)
        end)
        btn:SetScript("OnEnter", function() paint(true); tip() end)
        btn:SetScript("OnLeave", function() paint(false); CUI:HideTooltip(btn) end)
        btn.paint = paint
        return btn
    end
    -- « Tiroir » : emplacements de sac en bas ; « Catégories » : rangement par catégories ou en vrac.
    local slotsToggle = titleToggle(close, "Tiroir", "emplacements", "SAC_EMPLACEMENTS_CACHER",
        "SAC_EMPLACEMENTS_AFFICHER")
    local catToggle = titleToggle(slotsToggle, "Categories", "categories", "SAC_VRAC", "SAC_PAR_CATEGORIES")
    win.cuiCatToggle = catToggle
    -- Barre de titre : on glisse la fenêtre pour la déplacer (place gardée comme celle du cadenas).
    win:SetMovable(true)
    local drag = _G.CreateFrame("Frame", nil, win)
    drag:SetPoint("TOPLEFT", 1, -1)
    drag:SetPoint("TOPRIGHT", catToggle, "TOPLEFT", -2, 5)
    drag:SetHeight(HEADER - 1)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() win:StartMoving() end)
    drag:SetScript("OnDragStop", function()
        win:StopMovingOrSizing()
        win:SetUserPlaced(false)
        CUI:SaveMoverPosition("sacs")
    end)
    local headerLine = texture(win, "ARTWORK", 0, C.graphite)
    headerLine:SetPoint("TOPLEFT", 1, -HEADER)
    headerLine:SetPoint("TOPRIGHT", -1, -HEADER)
    headerLine:SetHeight(1)

    -- Recherche.
    local box = _G.CreateFrame("Frame", nil, win)
    box:SetPoint("TOPLEFT", PAD, -(HEADER + 8))
    box:SetPoint("TOPRIGHT", -PAD, -(HEADER + 8))
    box:SetHeight(SEARCH)
    CUI:CreateBorderedRect(box, 3, C.bordureDiscrete, { 0.063, 0.071, 0.094, 1 })
    search = _G.CreateFrame("EditBox", "CoeurUISacsRecherche", box)
    search:SetPoint("TOPLEFT", 8, 0)
    search:SetPoint("BOTTOMRIGHT", -8, 0)
    search:SetAutoFocus(false)
    search:SetFont(CUI:GetFont(), 12, "")
    search:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    search.hint = search:CreateFontString(nil, "OVERLAY")
    search.hint:SetFont(CUI:GetFont(), 12, "")
    search.hint:SetPoint("LEFT")
    search.hint:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
    search.hint:SetText(L.SAC_RECHERCHER)
    search:SetScript("OnTextChanged", function(self)
        self.hint:SetShown(self:GetText() == "")
        applySearch()
    end)
    search:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    separator = texture(win, "ARTWORK", 0, C.graphite)
    separator:SetHeight(1)
    separator:Hide()

    -- Bas de la fenêtre.
    local footerLine = texture(win, "ARTWORK", 0, C.graphite)
    footerLine:SetPoint("BOTTOMLEFT", 1, FOOTER)
    footerLine:SetPoint("BOTTOMRIGHT", -1, FOOTER)
    footerLine:SetHeight(1)
    local last = (_G.NUM_TOTAL_EQUIPPED_BAG_SLOTS or _G.NUM_BAG_SLOTS or 4)
    for i = 1, last do
        local b = createBagSlot(i)
        b:SetPoint("BOTTOMLEFT", win, "BOTTOMLEFT", PAD + (i - 1) * 23, 7)
        bagSlots[i] = b
    end
    freeText = win:CreateFontString(nil, "OVERLAY")
    freeText:SetFont(CUI:GetFont(), 11, "")
    freeText:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
    freeText:SetPoint("BOTTOMLEFT", win, "BOTTOMLEFT", PAD + last * 23 + 6, 12)
    win.slotsWidth = last * 23 + 6
    moneyText = win:CreateFontString(nil, "OVERLAY")
    moneyText:SetFont(CUI:GetFont(), 11, "")
    moneyText:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -PAD, 12)

    -- À chaque ouverture : tout est relu (les sacs ont pu changer fenêtre fermée).
    win:SetScript("OnShow", function() CUI:SafeCall(CUI:Tr("SAC_NOM"), layout) end)
    win:SetScript("OnHide", function()
        if search then
            search:SetText("")
            search:ClearFocus()
        end
    end)
    win:SetSize(400, 300)
    CUI:RegisterMover({ key = "sacs", frame = win, label = "SAC_TITRE", point = "BOTTOMRIGHT",
                        default = { "BOTTOMRIGHT", "BOTTOMRIGHT", -60, 110 } })
end

-- Ouvrir et fermer : à la place des sacs du jeu ---------------------------------------------

-- Une touche ou un clic du jeu peut appeler plusieurs de ses fonctions à la suite (basculer, qui
-- ouvre ou ferme chaque sac...) : on note l'intention et on décide à l'image suivante.
local intent
local function want(what)
    if intent == "toggle" then return end -- un basculement l'emporte sur les ouvertures et fermetures internes
    intent = what
    M:After(0, function()
        local w = intent
        intent = nil
        if not win or not w then return end
        if w == "toggle" then
            win:SetShown(not win:IsShown())
        elseif w == "open" then
            win:Show()
        else
            win:Hide()
        end
    end)
end

-- Cadres de sacs du jeu : cachés dès qu'ils s'ouvrent (ceux du joueur seulement ; la banque reste
-- celle du jeu pour cette étape).
local function isPlayerBagFrame(frame)
    local id = frame.GetID and frame:GetID()
    local last = _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS or _G.NUM_BAG_SLOTS or 4
    return type(id) == "number" and id >= 0 and id <= last
end

local hookedFrames = {}
local function hideGameBags()
    local frames = { _G.ContainerFrameCombinedBags }
    for i = 1, (_G.NUM_CONTAINER_FRAMES or 13) do frames[#frames + 1] = _G["ContainerFrame" .. i] end
    for _, frame in ipairs(frames) do
        if frame and not hookedFrames[frame] then
            hookedFrames[frame] = true
            frame:HookScript("OnShow", function(self)
                if M.enabled and (self == _G.ContainerFrameCombinedBags or isPlayerBagFrame(self)) then
                    self:Hide()
                end
            end)
            if frame:IsShown() and (frame == _G.ContainerFrameCombinedBags or isPlayerBagFrame(frame)) then
                frame:Hide()
            end
        end
    end
end

local togglesHooked = false
local function hookToggles()
    if togglesHooked then return end
    togglesHooked = true
    local function hook(name, what)
        if type(_G[name]) == "function" then
            _G.hooksecurefunc(name, function(...)
                if M.enabled then want(type(what) == "function" and what(...) or what) end
            end)
        end
    end
    local last = _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS or _G.NUM_BAG_SLOTS or 4
    local function forPlayerBag(state)
        return function(id) return (type(id) == "number" and id >= 0 and id <= last) and state or nil end
    end
    hook("ToggleAllBags", "toggle")
    hook("ToggleBackpack", "toggle")
    hook("ToggleBag", forPlayerBag("toggle"))
    hook("OpenAllBags", "open")
    hook("OpenBackpack", "open")
    hook("OpenBag", forPlayerBag("open"))
    hook("CloseAllBags", "close")
    hook("CloseBackpack", "close")
    hook("CloseBag", forPlayerBag("close"))
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    build()
    hideGameBags()
    hookToggles()
    for _, event in ipairs({ "BAG_UPDATE_DELAYED", "ITEM_LOCK_CHANGED", "BAG_UPDATE_COOLDOWN",
                             "BAG_NEW_ITEMS_UPDATED", "PLAYER_MONEY", "PLAYER_EQUIPMENT_CHANGED",
                             "INVENTORY_SEARCH_UPDATE" }) do
        pcall(self.On, self, event, requestRefresh)
    end
end

-- Coupé : tout reste en place jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged()
    if win and win.cuiCatToggle then win.cuiCatToggle.paint(false) end
    refresh()
end

function M:OnFontChanged()
    refresh()
end
