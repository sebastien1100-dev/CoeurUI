-- Module « Sacs et banque » (maquette validée le 27/11/2026, « CœurUI · Maquette Sacs et banque »).
-- Style « Givre » (planche « Sacs et banque » de la direction artistique) : fenêtres ardoise au double
-- liseré discret et à l'ombre douce, cases du thème, sections en petites capitales avec leur nombre.
-- Deux fenêtres, au même rangement :
--   - « Sacs » : tous les sacs du joueur, à la place de ceux du jeu ;
--   - « Banque » : chez le banquier, à gauche des sacs, à la place de la banque du jeu (réglage).
-- Dans chacune :
--   - par catégories (Équipement, Consommables, Composants d'artisanat, Quêtes, Divers, Camelote,
--     Places libres) ou en vrac (une grille, dans l'ordre des sacs) ;
--   - sacs de composants et carquois à part, en bas, avec leur nom et leurs places libres ;
--   - cases comme les barres d'actions : icône rognée, liseré gris fin, liseré de la qualité à partir
--     de « Peu commun », niveau d'objet en bas à gauche, nombre en bas à droite, pastille rouge cœur sur
--     un nouvel objet (jusqu'au survol) ;
--   - recherche par nom, commune aux deux fenêtres (le reste s'assombrit) ;
--   - en bas : emplacements de sac, places libres ; argent (sacs) ou achat d'un emplacement (banque) ;
--   - déplacée en glissant sa barre de titre (ou au cadenas).
-- Les cases sont les boutons d'objet du jeu (ContainerFrameItemButtonTemplate) : clics, glisser,
-- infobulle et utilisation restent ceux du jeu. Camelote : vendue chez le marchand (bouton ou toute
-- seule).
-- La banque du jeu reste ouverte (le jeu en a besoin pour ranger un objet d'un clic droit) mais
-- invisible, posée hors de l'écran.
-- Couper le module demande un /reload.
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local WHITE = "Interface\\Buttons\\WHITE8x8"
local HEADER, SEARCH, FOOTER, PAD = 34, 26, 34, 12

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
        emplacementsBanque = true, -- même chose, dans la banque
        categoriesBanque = true,   -- banque par catégories (indépendant des sacs)
        vente = "bouton",    -- camelote : « bouton » chez le marchand, « auto » (toute seule), « jamais »
        banque = true,       -- banque au style de CœurUI (sinon : celle du jeu)
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
        { type = "section", text = "SAC_CAT_CAMELOTE" },
        { type = "dropdown", key = "vente", label = "SAC_VENTE", options = {
            { value = "bouton", text = "SAC_VENTE_BOUTON" },
            { value = "auto", text = "SAC_VENTE_AUTO" },
            { value = "jamais", text = "SAC_VENTE_JAMAIS" },
        } },
        { type = "section", text = "SAC_BANQUE_SECTION" },
        { type = "toggle", key = "banque", label = "SAC_BANQUE_STYLE", description = "SAC_BANQUE_NOTE" },
        { type = "toggle", key = "categoriesBanque", label = "SAC_BANQUE_CATEGORIES",
          enabledIf = function(read) return read("banque") end },
    },
})

-- Sacs du joueur : 0 (sac à dos) à 4, plus le sac de composants du jeu s'il existe.
local function lastPlayerBag()
    return _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS or _G.NUM_BAG_SLOTS or 4
end

local function playerBags()
    local list = {}
    for bag = 0, lastPlayerBag() do list[#list + 1] = bag end
    return list
end

-- Sacs de la banque : la page principale, puis les sacs posés dans les emplacements débloqués.
local function bankBags()
    local list = { CUI:BankMainContainer() }
    local _, bought = CUI:BankBagSlots()
    for i = 1, bought do list[#list + 1] = CUI:BankBagContainer(i) end
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

-- Fenêtres -------------------------------------------------------------------------------------

-- Une « vue » par fenêtre : ses cadres, ses cases et ses sacs.
local bags = { key = "sacs", frameName = "CoeurUISacs", title = "SAC_TITRE", list = playerBags,
               slotsKey = "emplacements", catKey = "categories" }
local bankView = { key = "banque", frameName = "CoeurUIBanque", title = "SAC_BANQUE", list = bankBags, isBank = true,
                   slotsKey = "emplacementsBanque", catKey = "categoriesBanque" }
local views = { bags, bankView }
for _, v in ipairs(views) do
    v.holders = {}     -- sac -> cadre porteur (son ID = le sac, demandé par les boutons du jeu)
    v.buttons = {}     -- sac -> case -> bouton
    v.titles = {}      -- textes de section réutilisés
    v.rightTitles = {}
    v.bagSlots = {}    -- boutons des emplacements de sac (bas de la fenêtre)
    v.placed = {}      -- boutons affichés (pour la recherche)
end

local searchText = ""                       -- recherche commune aux deux fenêtres
local merchantOpen, selling = false, false  -- marchand ouvert ; vente de la camelote en cours
local bankOpen = false                      -- banquier ouvert
local toggles = {}                          -- boutons de la barre de titre (à repeindre)

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

local GRIS_SOMBRE = { 0.353, 0.369, 0.408 } -- #5A5E68 : nombre d'une section

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
    if c > 0 or #parts == 0 then parts[#parts + 1] = CUIVRE .. L.SAC_PC:format(c) .. "|r" end
    return table.concat(parts, "  ")
end

local function holderFor(v, bag)
    local h = v.holders[bag]
    if h then return h end
    h = _G.CreateFrame("Frame", nil, v.frame)
    -- Le sac : numéro du parent (SetID), que le jeu lit lui-même. Aucune fonction ni valeur écrite par CœurUI
    -- sur ce chemin : sinon le clic droit qui utilise un objet (parchemin, potion) est bloqué par le jeu
    -- (ADDON_ACTION_FORBIDDEN, « UseContainerItem »).
    h:SetID(bag)
    h:SetAllPoints()
    v.holders[bag] = h
    v.buttons[bag] = {}
    return h
end

-- Habillage d'un bouton d'objet du jeu (une fois).
local function skinButton(b)
    local icon = b.icon or b.Icon
    CUI:SquareItemIcon(b, icon) -- coins arrondis du jeu retirés
    if icon then
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
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
    -- Case du thème (fond, double liseré ; le liseré extérieur prend la couleur de la qualité) ; liseré
    -- de survol par-dessus l'icône, de la couleur des boutons.
    b.cuiPanel = CUI:CreatePanel(b, { radius = 3, fill = C.case, shadow = false })
    b.cuiLines = lines(b, C.or_)
    for _, t in ipairs(b.cuiLines) do t:Hide() end
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
    b:HookScript("OnLeave", function(self)
        for _, t in ipairs(self.cuiLines) do t:Hide() end
    end)
    -- Survol : le nouvel objet n'est plus nouveau.
    b:HookScript("OnEnter", function(self)
        for _, t in ipairs(self.cuiLines) do t:Show() end
        if self.cuiNew:IsShown() then
            local NI = _G.C_NewItems
            if NI and NI.RemoveNewItem then pcall(NI.RemoveNewItem, self.cuiBag, self.cuiSlot) end
            self.cuiNew:Hide()
        end
    end)
end

local nextButton = 0
local function buttonFor(v, bag, slot)
    local list = v.buttons[bag]
    local b = list and list[slot]
    if b then return b end
    local h = holderFor(v, bag)
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
    b.cuiBag, b.cuiSlot = bag, slot
    skinButton(b)
    v.buttons[bag][slot] = b
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
    -- Liseré extérieur : couleur de la qualité à partir de « Peu commun », sinon celui du thème (case
    -- vide comprise : juste la case).
    local color = C.lisereSombre
    if s.qualite and info and info.quality and info.quality >= 2 then
        color = CUI:ItemQualityColor(info.quality) or C.lisereSombre
    end
    b.cuiPanel.border:SetColor(color)
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
    -- Niveau d'objet à la couleur de la qualité (blanc pour un objet commun).
    local qc = info and info.quality and info.quality >= 2 and CUI:ItemQualityColor(info.quality) or C.texte
    b.cuiIlvl:SetTextColor(qc[1], qc[2], qc[3], 1)
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

-- Recherche : ce qui ne correspond pas s'assombrit, dans les deux fenêtres.
local function applySearch(v)
    local text = searchText:lower()
    for _, b in ipairs(v.placed) do
        local match = text == "" or (b.cuiName and b.cuiName:lower():find(text, 1, true) ~= nil)
        b:SetAlpha(match and 1 or 0.25)
    end
end

local function titleFS(v, i)
    local fs = v.titles[i]
    if not fs then
        fs = v.frame:CreateFontString(nil, "OVERLAY")
        fs:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
        v.titles[i] = fs
    end
    fs:SetFont(CUI:GetFont(), 10, "")
    fs:Show()
    return fs
end

local function rightFS(v, i)
    local r = v.rightTitles[i]
    if not r then
        r = v.frame:CreateFontString(nil, "OVERLAY")
        r:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])
        v.rightTitles[i] = r
    end
    r:SetFont(CUI:GetFont(), 10, "")
    r:Show()
    return r
end

-- Camelote vendable des sacs : liste des cases et prix total (en cuivre).
local function junkList()
    local list, total = {}, 0
    for _, bag in ipairs(playerBags()) do
        for slot = 1, CUI:BagSlots(bag) do
            local info = CUI:BagItem(bag, slot)
            if info and info.quality == 0 and not info.hasNoValue and not info.isLocked then
                local price = (CUI:ItemSellPrice(info.itemID or info.hyperlink) or 0) * (info.stackCount or 1)
                list[#list + 1] = { bag = bag, slot = slot, itemID = info.itemID, price = price }
                total = total + price
            end
        end
    end
    return list, total
end

-- Bouton d'un emplacement de sac : son icône ; clic : le prendre, ou poser celui qu'on tient.
-- Banque : un emplacement verrouillé porte un cadenas ; cliquer le premier l'achète (par le bouton
-- « Acheter » du jeu : l'achat est protégé).
local function createBagSlot(parent, isBank)
    local b = _G.CreateFrame("Button", nil, parent)
    b:SetSize(20, 20)
    b:RegisterForClicks("LeftButtonUp")
    b:RegisterForDrag("LeftButton")
    CUI:CreatePanel(b, { radius = 3, fill = C.case, shadow = false })
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 2, -2)
    b.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b.lock = b:CreateTexture(nil, "OVERLAY")
    b.lock:SetPoint("CENTER")
    b.lock:SetSize(14, 14)
    b.lock:SetTexture(CUI.MEDIA .. "Icones\\Cadenas")
    b.lock:Hide()
    local function paintLock(self, over)
        local c = (over and self.cost) and C.texte or C.texteDiscret
        self.lock:SetVertexColor(c[1], c[2], c[3], 1)
    end
    b.paintLock = paintLock
    function b:SetVisualState(hover)
        if self.locked then paintLock(self, hover) end
    end
    local function put(self)
        if self.locked then return end
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
        if self.locked then
            paintLock(self, true)
            CUI:ShowTooltip(self, self.cost and L.SAC_ACHETER:format(moneyString(self.cost)) or L.SAC_VERROUILLE)
        elseif self.inv then
            CUI:ShowGameTooltip(self, function(tip)
                if not tip:SetInventoryItem("player", self.inv) then tip:SetText(L.SAC_EMPLACEMENT_VIDE) end
            end)
        end
    end)
    b:SetScript("OnLeave", function(self)
        if self.locked then paintLock(self, false) end
        CUI:HideGameTooltip(self)
        CUI:HideTooltip(self)
    end)
    if isBank then
        CUI:AttachSecureClick(b, function() return CUI:BankPurchaseButton() end, function()
            return L.SAC_ACHETER:format(moneyString(b.cost or 0)), L.SAC_ACHETER_NOTE
        end, function() return b.locked and b.cost ~= nil and CUI:BankPurchaseButton() ~= nil end)
    end
    return b
end

-- Bas de la fenêtre : emplacements de sac, places libres, argent ou achat d'un emplacement.
local function layoutFooter(v, freeCount)
    local s = M.db
    local shown = 0
    local count, bought
    if v.isBank then
        count, bought = CUI:BankBagSlots()
    else
        count = lastPlayerBag()
    end
    for i = 1, count do
        if not v.bagSlots[i] then v.bagSlots[i] = createBagSlot(v.frame, v.isBank) end
    end
    local cost = v.isBank and CUI:BankNextSlotCost() or nil
    local showSlots = s[v.slotsKey]
    for i, slotButton in ipairs(v.bagSlots) do
        local inv, locked = nil, false
        if v.isBank then
            -- Débloqués : leur sac ; les autres : cadenas (le premier s'achète d'un clic).
            locked = i > bought
            if not locked then inv = CUI:BankBagInventorySlot(i) end
        else
            inv = CUI:BagInventorySlot(i)
        end
        slotButton.inv, slotButton.locked = inv, locked
        slotButton.cost = (locked and i == bought + 1) and cost or nil
        local visible = showSlots and i <= count and (inv ~= nil or locked)
        slotButton:SetShown(visible)
        if visible then
            shown = shown + 1
            slotButton:ClearAllPoints()
            slotButton:SetPoint("BOTTOMLEFT", v.frame, "BOTTOMLEFT", PAD + (shown - 1) * 23, 7)
            local tex = inv and _G.GetInventoryItemTexture("player", inv)
            slotButton.icon:SetTexture(tex)
            slotButton.icon:SetShown(tex ~= nil)
            slotButton.lock:SetShown(locked)
            slotButton.paintLock(slotButton, false)
        end
    end
    v.freeText:SetText(L.SAC_PLACES_LIBRES:format(freeCount))
    v.freeText:ClearAllPoints()
    v.freeText:SetPoint("BOTTOMLEFT", v.frame, "BOTTOMLEFT", PAD + (shown > 0 and shown * 23 + 6 or 0), 12)
    if v.moneyText then v.moneyText:SetText(moneyString(_G.GetMoney())) end
    -- Bouton « Acheter » : quand les emplacements sont cachés (sinon on clique le premier cadenas).
    if v.buyButton then
        if showSlots then cost = nil end
        v.buyButton:SetShown(cost ~= nil)
        if cost then
            v.buyButton:SetLabel(L.SAC_ACHETER:format(moneyString(cost)))
            v.buyButton:SetEnabled(_G.GetMoney() >= cost)
        end
    end
end

-- Range toute une fenêtre (cases, sections, taille).
local function layout(v)
    local win = v.frame
    if not win then return end
    local s = M.db
    local size, gap, per = s.taille, s.espacement, s.parRangee
    local innerW = per * (size + gap) - gap
    local width = innerW + 2 * PAD
    for _, list in pairs(v.buttons) do
        for _, b in pairs(list) do b:Hide() end
    end
    for _, fs in pairs(v.titles) do fs:Hide() end
    for _, fs in pairs(v.rightTitles) do fs:Hide() end
    _G.wipe(v.placed)

    -- Sacs ordinaires et sacs à part.
    local normal, special = {}, {}
    local freeCount = 0
    for _, bag in ipairs(v.list()) do
        local slots = CUI:BagSlots(bag)
        if slots > 0 then
            local free, family = CUI:BagFree(bag)
            if s.aPart and (family ~= 0 or CUI:IsReagentBag(bag)) then
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
            local fs = titleFS(v, titleIndex)
            -- Petites capitales et, pour une catégorie, son nombre de cases en gris sombre.
            fs:SetText(right and title or (title .. "  " .. CUI:ColorCode(GRIS_SOMBRE)
                .. "· " .. #entries .. "|r"))
            fs:ClearAllPoints()
            fs:SetPoint("TOPLEFT", win, "TOPLEFT", PAD, -y)
            if right then
                local r = rightFS(v, titleIndex)
                r:SetText(right)
                r:ClearAllPoints()
                r:SetPoint("TOPRIGHT", win, "TOPRIGHT", -PAD, -y)
            end
            y = y + 16
        end
        for i, e in ipairs(entries) do
            local b = buttonFor(v, e.bag, e.slot)
            local col, row = (i - 1) % per, math.floor((i - 1) / per)
            b:SetSize(size, size)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", win, "TOPLEFT", PAD + col * (size + gap), -(y + row * (size + gap)))
            updateButton(b, e.info)
            b:Show()
            v.placed[#v.placed + 1] = b
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
    -- Bouton « Vendre » (sacs) : chez un marchand, s'il y a de la camelote à vendre.
    local sellButton = v.sellButton
    local showSell = false
    if sellButton then
        sellButton:Hide()
        if merchantOpen and not selling and s.vente ~= "jamais" then
            local list, total = junkList()
            showSell = #list > 0
            if showSell then
                sellButton:SetLabel(total > 0 and L.SAC_VENDRE_PRIX:format(moneyString(total)) or L.SAC_VENDRE)
            end
        end
    end
    local function placeSell()
        sellButton:ClearAllPoints()
        sellButton:SetPoint("TOPRIGHT", win, "TOPRIGHT", -PAD, -(y - 3))
        sellButton:Show()
    end
    if s[v.catKey] then
        local groups = {}
        for _, e in ipairs(all) do
            local cat = categoryOf(e.info)
            groups[cat] = groups[cat] or {}
            table.insert(groups[cat], e)
        end
        for _, cat in ipairs(CATEGORIES) do
            if groups[cat] and #groups[cat] > 0 then
                if cat == "camelote" and showSell then placeSell() end
                section(L[CATEGORY_TITLES[cat]], groups[cat])
            end
        end
    else
        -- En vrac : le bouton a sa propre ligne, au-dessus de la grille.
        if showSell then
            y = y + 3
            placeSell()
            y = y + 22
        end
        section(nil, all)
    end

    -- Sacs à part : leur nom et leurs places libres.
    if #special > 0 then
        v.separator:ClearAllPoints()
        v.separator:SetPoint("TOPLEFT", win, "TOPLEFT", PAD, -(y - 4))
        v.separator:SetWidth(innerW)
        v.separator:Show()
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
        v.separator:Hide()
    end

    win:SetSize(width, y + FOOTER)
    layoutFooter(v, freeCount)
    applySearch(v)
end

-- Fenêtres ouvertes : remise en page ; fermées : elles le seront à la prochaine ouverture.
local function refresh()
    for _, v in ipairs(views) do
        if v.frame and v.frame:IsShown() then CUI:SafeCall(CUI:Tr("SAC_NOM"), layout, v) end
    end
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

-- Vente de la camelote : une case toutes les 0,15 s (le serveur refuse les ventes trop rapides),
-- arrêtée si le marchand se ferme ; le total vendu est écrit dans la discussion.
local function sellJunk()
    if selling or not merchantOpen then return end
    local list = junkList()
    if #list == 0 then return end
    selling = true
    requestRefresh()
    local i, sold = 0, 0
    local function step()
        i = i + 1
        local e = list[i]
        if not e or not merchantOpen then
            selling = false
            if sold > 0 then CUI:Print(L.SAC_CAMELOTE_VENDUE:format(moneyString(sold))) end
            requestRefresh()
            return
        end
        -- La case n'a pas changé entre-temps (objet déplacé, vendu à la main...).
        local info = CUI:BagItem(e.bag, e.slot)
        if info and info.itemID == e.itemID and not info.isLocked then
            CUI:BagUse(e.bag, e.slot)
            sold = sold + e.price
        end
        M:After(0.15, step)
    end
    step()
end

local function paintToggles()
    for _, t in ipairs(toggles) do t.paint(false) end
end

-- Une fenêtre : titre, boutons, recherche, bas. onClose : fermer (Échap, croix).
local function buildView(v)
    if v.frame then return end
    local win = _G.CreateFrame("Frame", v.frameName, _G.UIParent)
    v.frame = win
    win:SetFrameStrata("MEDIUM")
    win:SetToplevel(true)
    win:SetClampedToScreen(true)
    win:EnableMouse(true)
    win:Hide()
    CUI:CreatePanel(win, { fill = C.fenetre })
    -- Échap ferme la fenêtre, comme les sacs et la banque du jeu.
    table.insert(_G.UISpecialFrames, v.frameName)

    local title = win:CreateFontString(nil, "OVERLAY")
    title:SetFont(CUI:GetFont(), 14, "")
    title:SetTextColor(C.texte[1], C.texte[2], C.texte[3])
    title:SetPoint("TOPLEFT", PAD, -10)
    title:SetText(L[v.title])
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
            paintToggles()
            paint(true)
            tip()
            refresh()
        end)
        btn:SetScript("OnEnter", function() paint(true); tip() end)
        btn:SetScript("OnLeave", function() paint(false); CUI:HideTooltip(btn) end)
        btn.paint = paint
        toggles[#toggles + 1] = btn
        return btn
    end
    -- « Tiroir » : emplacements de sac en bas ; « Catégories » : rangement par catégories ou en vrac.
    -- Chaque fenêtre a ses propres réglages.
    local slotsToggle = titleToggle(close, "Tiroir", v.slotsKey, "SAC_EMPLACEMENTS_CACHER",
        "SAC_EMPLACEMENTS_AFFICHER")
    local catToggle = titleToggle(slotsToggle, "Categories", v.catKey, "SAC_VRAC", "SAC_PAR_CATEGORIES")
    -- « Trier » : le tri du jeu, pour les sacs ou pour la banque (chaque fenêtre le sien).
    local sortButton = _G.CreateFrame("Button", nil, win)
    sortButton:SetSize(18, 18)
    sortButton:SetPoint("RIGHT", catToggle, "LEFT", -4, 0)
    sortButton.icon = sortButton:CreateTexture(nil, "ARTWORK")
    sortButton.icon:SetAllPoints()
    sortButton.icon:SetTexture(CUI.MEDIA .. "Icones\\Trier")
    local function paintSort(over)
        local c = over and C.texte or C.texteSecondaire
        sortButton.icon:SetVertexColor(c[1], c[2], c[3], 1)
    end
    paintSort(false)
    local sortTip = v.isBank and "SAC_TRIER_BANQUE" or "SAC_TRIER_SACS"
    sortButton:SetScript("OnClick", function()
        local sound = _G.SOUNDKIT and _G.SOUNDKIT.UI_BAG_SORTING_01
        if sound then _G.PlaySound(sound) end
        CUI:SafeCall(CUI:Tr("SAC_NOM"), function()
            if v.isBank then CUI:SortBank() else CUI:SortBags() end
        end)
    end)
    sortButton:SetScript("OnEnter", function(self) paintSort(true); CUI:ShowTooltip(self, L[sortTip]) end)
    sortButton:SetScript("OnLeave", function(self) paintSort(false); CUI:HideTooltip(self) end)
    -- Barre de titre : on glisse la fenêtre pour la déplacer (place gardée comme celle du cadenas).
    win:SetMovable(true)
    local drag = _G.CreateFrame("Frame", nil, win)
    drag:SetPoint("TOPLEFT", 1, -1)
    drag:SetPoint("TOPRIGHT", sortButton, "TOPLEFT", -2, 5)
    drag:SetHeight(HEADER - 1)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() win:StartMoving() end)
    drag:SetScript("OnDragStop", function()
        win:StopMovingOrSizing()
        win:SetUserPlaced(false)
        CUI:SaveMoverPosition(v.key)
    end)
    local headerLine = texture(win, "ARTWORK", 0, C.lisereSombre)
    headerLine:SetPoint("TOPLEFT", 2, -HEADER)
    headerLine:SetPoint("TOPRIGHT", -2, -HEADER)
    headerLine:SetHeight(1)

    -- Recherche (commune : taper dans l'une filtre les deux).
    local box = _G.CreateFrame("Frame", nil, win)
    box:SetPoint("TOPLEFT", PAD, -(HEADER + 8))
    box:SetPoint("TOPRIGHT", -PAD, -(HEADER + 8))
    box:SetHeight(SEARCH)
    CUI:CreatePanel(box, { radius = 3, fill = C.case, shadow = false })
    local search = _G.CreateFrame("EditBox", v.frameName .. "Recherche", box)
    v.search = search
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
        local text = self:GetText()
        self.hint:SetShown(text == "")
        if text == searchText then return end
        searchText = text
        for _, other in ipairs(views) do
            if other.search and other.search ~= self and other.search:GetText() ~= text then
                other.search:SetText(text)
            end
            applySearch(other)
        end
    end)
    search:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    v.separator = texture(win, "ARTWORK", 0, C.lisereSombre)
    v.separator:SetHeight(1)
    v.separator:Hide()

    -- Bas de la fenêtre.
    local footerLine = texture(win, "ARTWORK", 0, C.lisereSombre)
    footerLine:SetPoint("BOTTOMLEFT", 2, FOOTER)
    footerLine:SetPoint("BOTTOMRIGHT", -2, FOOTER)
    footerLine:SetHeight(1)
    v.freeText = win:CreateFontString(nil, "OVERLAY")
    v.freeText:SetFont(CUI:GetFont(), 11, "")
    v.freeText:SetTextColor(C.texteDiscret[1], C.texteDiscret[2], C.texteDiscret[3])

    -- À chaque ouverture : tout est relu (les sacs ont pu changer fenêtre fermée).
    win:SetScript("OnShow", function() CUI:SafeCall(CUI:Tr("SAC_NOM"), layout, v) end)
    win:SetSize(400, 300)
end

local function build()
    -- Sacs : argent en bas, bouton « Vendre » chez le marchand.
    buildView(bags)
    local win = bags.frame
    bags.moneyText = win:CreateFontString(nil, "OVERLAY")
    bags.moneyText:SetFont(CUI:GetFont(), 11, "")
    bags.moneyText:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -PAD, 12)
    bags.sellButton = CUI:CreateButton(win, "", false, true)
    bags.sellButton:SetHeight(18)
    bags.sellButton:Hide()
    bags.sellButton:SetScript("OnClick", function() sellJunk() end)
    bags.sellButton:HookScript("OnEnter", function(self) CUI:ShowTooltip(self, L.SAC_VENDRE_NOTE) end)
    bags.sellButton:HookScript("OnLeave", function(self) CUI:HideTooltip(self) end)
    win:SetScript("OnHide", function()
        -- La recherche est remise à zéro quand plus aucune fenêtre n'est ouverte.
        if not (bankView.frame and bankView.frame:IsShown()) then bags.search:SetText("") end
        bags.search:ClearFocus()
    end)
    CUI:RegisterMover({ key = "sacs", frame = win, label = "SAC_TITRE", point = "BOTTOMRIGHT",
                        default = { "BOTTOMRIGHT", "BOTTOMRIGHT", -60, 110 } })

    -- Banque : achat de l'emplacement suivant en bas ; la fermer quitte le banquier.
    buildView(bankView)
    local bw = bankView.frame
    bankView.buyButton = CUI:CreateButton(bw, "", false, true)
    bankView.buyButton:SetHeight(20)
    bankView.buyButton:SetPoint("BOTTOMRIGHT", bw, "BOTTOMRIGHT", -PAD, 7)
    bankView.buyButton:Hide()
    -- L'achat est protégé : un bouton protégé posé dessus clique le bouton « Acheter » du jeu.
    CUI:AttachSecureClick(bankView.buyButton, function() return CUI:BankPurchaseButton() end, function()
        return bankView.buyButton.label:GetText(), L.SAC_ACHETER_NOTE
    end, function() return CUI:BankPurchaseButton() ~= nil end)
    bw:SetScript("OnHide", function()
        if not (bags.frame and bags.frame:IsShown()) then bankView.search:SetText("") end
        bankView.search:ClearFocus()
        if bankOpen then CUI:BankClose() end
    end)
    CUI:RegisterMover({ key = "banque", frame = bw, label = "SAC_BANQUE", point = "BOTTOMRIGHT",
                        default = { "BOTTOMRIGHT", "BOTTOMRIGHT", -476, 110 } })
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
        local win = bags.frame
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

-- Cadres de sacs du jeu : cachés dès qu'ils s'ouvrent (ceux du joueur seulement).
local function isPlayerBagFrame(frame)
    local id = frame.GetID and frame:GetID()
    return type(id) == "number" and id >= 0 and id <= lastPlayerBag()
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
    local function forPlayerBag(state)
        return function(id) return (type(id) == "number" and id >= 0 and id <= lastPlayerBag()) and state or nil end
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

-- Banque du jeu : gardée ouverte (le jeu s'en sert pour ranger d'un clic droit) mais invisible,
-- posée hors de l'écran à chaque fois que le jeu la place.
local function useOurBank()
    return M.enabled and M.db.banque
end

local bankHooked = false
local function stashGameBank()
    local f = _G.BankFrame
    if bankHooked or not f then return end
    bankHooked = true
    local moving = false
    local function stash(self)
        if moving then return end
        moving = true
        if useOurBank() then
            self:SetAlpha(0)
            self:SetClampedToScreen(false)
            self:ClearAllPoints()
            self:SetPoint("TOPRIGHT", _G.UIParent, "TOPLEFT", -5000, 5000)
        else
            self:SetAlpha(1)
        end
        moving = false
    end
    f:HookScript("OnShow", stash)
    _G.hooksecurefunc(f, "SetPoint", stash)
end

local function onBankOpened()
    if bankOpen then return end
    bankOpen = true
    stashGameBank()
    if useOurBank() and bankView.frame then
        bankView.frame:Show()
        bags.frame:Show()
    end
end

local function onBankClosed()
    if not bankOpen then return end
    bankOpen = false
    if bankView.frame then bankView.frame:Hide() end
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    build()
    hideGameBags()
    hookToggles()
    for _, event in ipairs({ "BAG_UPDATE_DELAYED", "ITEM_LOCK_CHANGED", "BAG_UPDATE_COOLDOWN",
                             "BAG_NEW_ITEMS_UPDATED", "PLAYER_MONEY", "PLAYER_EQUIPMENT_CHANGED",
                             "INVENTORY_SEARCH_UPDATE", "PLAYERBANKSLOTS_CHANGED", "PLAYERBANKBAGSLOTS_CHANGED",
                             "BANK_TABS_CHANGED", "BANK_TAB_SETTINGS_UPDATED" }) do
        pcall(self.On, self, event, requestRefresh)
    end
    self:On("MERCHANT_SHOW", function()
        merchantOpen = true
        if M.db.vente == "auto" then sellJunk() end
        requestRefresh()
    end)
    self:On("MERCHANT_CLOSED", function()
        merchantOpen = false
        requestRefresh()
    end)
    -- Banquier : selon la version du jeu, l'un ou l'autre de ces évènements (ou les deux).
    pcall(self.On, self, "BANKFRAME_OPENED", onBankOpened)
    pcall(self.On, self, "BANKFRAME_CLOSED", onBankClosed)
    local banker = _G.Enum and _G.Enum.PlayerInteractionType and _G.Enum.PlayerInteractionType.Banker
    if banker then
        pcall(self.On, self, "PLAYER_INTERACTION_MANAGER_FRAME_SHOW", function(_, kind)
            if kind == banker then onBankOpened() end
        end)
        pcall(self.On, self, "PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function(_, kind)
            if kind == banker then onBankClosed() end
        end)
    end
    stashGameBank()
end

-- Coupé : tout reste en place jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged()
    paintToggles()
    refresh()
end

function M:OnFontChanged()
    refresh()
end
