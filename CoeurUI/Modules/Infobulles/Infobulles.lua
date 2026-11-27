-- Module « Infobulles et menus » (maquettes validées : direction « sobre », puis style « Givre »,
-- planche « Infobulles et menus », fond ardoise) : les infobulles et les menus du jeu prennent le
-- cadre de CœurUI (CUI:CreatePanel) : fond ardoise presque opaque, double liseré très discret, ombre
-- douce, coins de 4 points, pas d'or. Les couleurs du jeu (qualité d'un objet, attitude d'une unité) restent sur le
-- nom ; pas de barre de vie sous l'infobulle ; les textes prennent la police de CœurUI.
--
-- Infobulles : le cadre du jeu (NineSlice) est rendu invisible et le nôtre est posé dessous. Toute
-- infobulle construite sur le modèle commun du jeu est habillée à son affichage, celles des autres
-- addons comprises.
-- Menus (système de menus du jeu) : tant qu'un menu est ouvert, son fond est remplacé et ses cases,
-- coches et flèches passent en gris et blanc. Les icônes du jeu ne sont pas touchées.
-- Option « Afficher les identifiants » : en bas des infobulles, l'ID des sorts, des effets et des
-- objets (TooltipDataProcessor, lignes ajoutées après celles du jeu ; rien n'est remplacé).
-- Couper le module demande un /reload (le jeu ne sait pas reprendre son ancien habillage seul).
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local M = CUI:RegisterModule({
    key = "Infobulles",
    name = "IM_NOM",
    description = "IM_DESC",
    defaultEnabled = false,
    needsReload = true,
    defaults = { ids = true },
    settings = {
        { type = "section", text = "IM_INFOS" },
        { type = "toggle", key = "ids", label = "IM_IDS", description = "IM_IDS_DESC" },
    },
})


local function forbidden(f)
    return f.IsForbidden and f:IsForbidden()
end

-- Cadre CœurUI (style du thème), sous tout le contenu du cadre.
local function addBox(frame)
    CUI:CreateTipPanel(frame)
end

-- Rend un cadre du jeu invisible pour de bon (le jeu ne peut plus le faire réapparaître).
local function vanish(frame)
    frame:SetAlpha(0)
    _G.hooksecurefunc(frame, "SetAlpha", function(self, a)
        if a ~= 0 and M.enabled then self:SetAlpha(0) end
    end)
end

-- Infobulles ------------------------------------------------------------------------------------

local skinnedTips = setmetatable({}, { __mode = "k" })

local function skinTooltip(tip)
    if not tip or skinnedTips[tip] or forbidden(tip) then return end
    skinnedTips[tip] = true
    if tip.NineSlice then vanish(tip.NineSlice) end
    addBox(tip)
end

-- Barre de vie sous une infobulle d'unité : retirée (choix du joueur), rendue invisible pour de bon.
local function skinStatusBar()
    local bar = _G.GameTooltipStatusBar
    if not bar or forbidden(bar) then return end
    vanish(bar)
end

-- Police de CœurUI sur les polices des infobulles du jeu (tailles gardées).
local TOOLTIP_FONTS = { "GameTooltipHeaderText", "GameTooltipText", "GameTooltipTextSmall" }
local function applyTooltipFonts()
    local file = CUI:GetFont()
    for _, name in ipairs(TOOLTIP_FONTS) do
        local font = _G[name]
        if font and font.GetFont then
            local _, size, flags = font:GetFont()
            if size then font:SetFont(file, size, flags or "") end
        end
    end
end

local KNOWN_TIPS = { "GameTooltip", "ItemRefTooltip", "ShoppingTooltip1", "ShoppingTooltip2",
                     "ItemRefShoppingTooltip1", "ItemRefShoppingTooltip2", "FriendsTooltip" }

-- Menus du jeu --------------------------------------------------------------------------------------

local skinnedMenus = setmetatable({}, { __mode = "k" }) -- menu -> notre fond

-- Une texture d'un menu : selon son atlas (les icônes du jeu n'en ont pas de ce genre). Repassé à
-- chaque instant tant que le menu est ouvert : le jeu remet ses couleurs au survol.
local function skinMenuTexture(tex)
    local atlas = tex.GetAtlas and tex:GetAtlas()
    if type(atlas) ~= "string" then return end
    local a = atlas:lower()
    if not (a:find("dropdown") or a:find("menu") or a:find("arrow") or a:find("next")
            or a:find("expand") or a:find("highlight")) then
        return
    end
    if a:find("bg") or a:find("background") or a:find("border") then
        tex:SetAlpha(0)                                  -- le fond du jeu : le nôtre est dessous
    elseif a:find("checkmark") then
        tex:SetDesaturated(true)                         -- coche : blanche
        tex:SetVertexColor(C.texte[1], C.texte[2], C.texte[3], 1)
    elseif a:find("highlight") or a:find("hover") then
        tex:SetDesaturated(true)                         -- ligne survolée : un peu plus claire
        tex:SetVertexColor(1, 1, 1, 0.06)
    else
        tex:SetDesaturated(true)                         -- cases, flèches, traits : gris
        tex:SetVertexColor(C.texteSecondaire[1], C.texteSecondaire[2], C.texteSecondaire[3], 1)
    end
end

-- Cadre en 9 morceaux du jeu (coins, bords, centre) : le menu lui-même en est un.
local PIECES = { "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
                 "TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "Center" }
local function hidePieces(frame)
    for _, key in ipairs(PIECES) do
        local piece = frame[key]
        if type(piece) == "table" and piece.SetAlpha then piece:SetAlpha(0) end
    end
end

-- Surbrillance d'une ligne survolée : gris très clair au lieu du dégradé doré.
local function skinHighlight(button)
    local hl = button.GetHighlightTexture and button:GetHighlightTexture()
    if hl then
        hl:SetDesaturated(true)
        hl:SetVertexColor(1, 1, 1, 0.06)
    end
end

local hookedButtons = setmetatable({}, { __mode = "k" })
local walk

-- Une ligne de menu survolée : le jeu remet ses couleurs à l'instant ; on repasse juste derrière
-- (crochet seulement ; refusé par le jeu sur certains cadres : pcall).
local function hookButton(button)
    if hookedButtons[button] then return end
    hookedButtons[button] = true
    local function again(b)
        if M.enabled then CUI:SafeCall(CUI:Tr("IM_NOM"), walk, b, 0) end
    end
    pcall(button.HookScript, button, "OnEnter", again)
    pcall(button.HookScript, button, "OnLeave", again)
end

walk = function(frame, depth)
    if depth > 6 or forbidden(frame) then return end
    hidePieces(frame)
    if frame.GetObjectType and frame:GetObjectType() == "Button" then
        skinHighlight(frame)
        hookButton(frame)
    end
    for _, region in ipairs({ frame:GetRegions() }) do
        if region.GetObjectType and region:GetObjectType() == "Texture" then
            skinMenuTexture(region)
        end
    end
    for _, child in ipairs({ frame:GetChildren() }) do
        walk(child, depth + 1)
    end
end

local skinMenu
local function skinLater(menu)
    if not M.enabled then return end
    CUI:SafeCall(CUI:Tr("IM_NOM"), skinMenu, menu)
    -- Et à l'image suivante : le jeu finit de remplir le menu après l'avoir montré.
    _G.C_Timer.After(0, function()
        if M.enabled and menu:IsShown() then CUI:SafeCall(CUI:Tr("IM_NOM"), skinMenu, menu) end
    end)
end

skinMenu = function(menu)
    if not menu or forbidden(menu) then return end
    local back = skinnedMenus[menu]
    if not back then
        -- Menu réutilisé par le jeu : habillé dès qu'il se montre (sans attendre notre passage).
        pcall(menu.HookScript, menu, "OnShow", skinLater)
        if menu.NineSlice then vanish(menu.NineSlice) end
        -- Le jeu surveille ses menus (CreateTexture refusé dessus et sur ce qu'on y accroche) :
        -- notre fond est un cadre à part, posé sur l'écran juste sous le menu, à sa taille.
        back = _G.CreateFrame("Frame", nil, _G.UIParent)
        back:SetAllPoints(menu)
        addBox(back)
        menu:HookScript("OnHide", function() back:Hide() end)
        skinnedMenus[menu] = back
    end
    back:SetFrameStrata(menu:GetFrameStrata())
    back:SetFrameLevel(math.max(0, menu:GetFrameLevel() - 1))
    back:Show()
    walk(menu, 0)
end

-- Tous les menus du jeu connus : chaque cadre de menu porte la marque isMenuProxy. Les cadres sont
-- parcourus une seule fois chacun (on reprend après le dernier vu : les nouveaux sont à la fin),
-- par paquets, et seulement quand un menu est ouvert. Les menus du jeu sont réutilisés : une fois
-- connus, plus de recherche.
local menus = {}
local lastSeen
local function discover()
    local enumerate = _G.EnumerateFrames
    if not enumerate then return end
    local f = enumerate(lastSeen)
    local n = 0
    while f and n < 4000 do
        lastSeen = f
        if rawget(f, "isMenuProxy") and not skinnedMenus[f] then
            menus[#menus + 1] = f
        end
        n = n + 1
        f = enumerate(f)
    end
end

-- Les menus ouverts : le menu principal (donné par le jeu) et tout menu connu à l'écran.
local function openMenus()
    local manager = _G.Menu and _G.Menu.GetManager and _G.Menu.GetManager()
    if not manager or not (manager.IsAnyMenuOpen and manager:IsAnyMenuOpen()) then return {} end
    discover()
    local list, seen = {}, {}
    local root = (manager.GetOpenMenu and manager:GetOpenMenu()) or manager.openMenu
    if root then
        list[1], seen[root] = root, true
    end
    for _, menu in ipairs(menus) do
        if not seen[menu] and not forbidden(menu) and menu:IsShown() then
            list[#list + 1], seen[menu] = menu, true
        end
    end
    return list
end

local function skinOpenMenus()
    for _, menu in ipairs(openMenus()) do
        CUI:SafeCall(CUI:Tr("IM_NOM"), skinMenu, menu)
    end
end

-- Ouverture d'un menu par le gestionnaire du jeu (menu, menu contextuel, sous-menu) : habillé tout de
-- suite, juste après le jeu (crochets seulement, sur ses fonctions « Open... »).
local managerHooked = false
local function hookManager()
    if managerHooked then return end
    local manager = _G.Menu and _G.Menu.GetManager and _G.Menu.GetManager()
    if type(manager) ~= "table" then return end
    managerHooked = true
    -- Sur ce client, le gestionnaire est un relais : ses fonctions sont dans la table de sa métatable
    -- (OpenMenu, OpenContextMenu), pas sur lui.
    local function hookIn(owner)
        local done = false
        for name, fn in pairs(owner) do
            if type(name) == "string" and type(fn) == "function" and name:find("^Open") then
                done = pcall(_G.hooksecurefunc, owner, name, function()
                    if M.enabled then skinOpenMenus() end
                end) or done
            end
        end
        return done
    end
    if hookIn(manager) then return end
    local mt = getmetatable(manager)
    if type(mt) == "table" and type(mt.__index) == "table" then hookIn(mt.__index) end
end

-- Identifiants -----------------------------------------------------------------------------------

local issecret = _G.issecretvalue or function() return false end

-- Ajoute « ID du sort : 123 » (ou de l'objet) en bas de l'infobulle, en gris discret. Rien si
-- l'option est coupée, si l'infobulle est interdite ou si le jeu cache la valeur (combat).
local function addId(tip, data, format)
    if not M.enabled or not M.db.ids or not tip or (tip.IsForbidden and tip:IsForbidden()) then return end
    local id = type(data) == "table" and data.id
    if id == nil or issecret(id) or type(id) ~= "number" then return end
    local c = C.texteDiscret
    tip:AddLine(format:format(id), c[1], c[2], c[3])
end

-- Infobulle d'un joueur : la ligne de la classe dans la couleur de la classe, celle de la faction
-- dans la sienne (Alliance bleue, Horde rouge). Valeurs cachées par le jeu : rien n'est touché.
local FACTION_COLORS = { Alliance = { 0.29, 0.56, 1.0 }, Horde = { 0.9, 0.22, 0.22 } }

local function classColorOf(classFile)
    if not classFile or issecret(classFile) then return nil end
    local c = _G.C_ClassColor and _G.C_ClassColor.GetClassColor and _G.C_ClassColor.GetClassColor(classFile)
    if not c and _G.RAID_CLASS_COLORS then c = _G.RAID_CLASS_COLORS[classFile] end
    return c
end

local function colorUnit(tip)
    if not M.enabled or not tip or forbidden(tip) or not tip.GetUnit then return end
    local _, unit = tip:GetUnit()
    if not unit or issecret(unit) then return end
    local isPlayer = _G.UnitIsPlayer(unit)
    if issecret(isPlayer) or not isPlayer then return end
    local className, classFile = _G.UnitClass(unit)
    local faction, factionName = _G.UnitFactionGroup(unit)
    local classColor = classColorOf(classFile)
    if issecret(className) then className = nil end
    if issecret(faction) or issecret(factionName) then faction, factionName = nil, nil end
    local tipName = tip:GetName()
    if not tipName then return end
    for i = 2, tip:NumLines() do
        local line = _G[tipName .. "TextLeft" .. i]
        local text = line and line:GetText()
        if text and not issecret(text) then
            if classColor and className and text == className then
                line:SetTextColor(classColor.r, classColor.g, classColor.b)
            elseif factionName and text == factionName and FACTION_COLORS[faction] then
                local c = FACTION_COLORS[faction]
                line:SetTextColor(c[1], c[2], c[3])
            end
        end
    end
end

local idsHooked = false
local function hookIds()
    if idsHooked then return end
    local processor, types = _G.TooltipDataProcessor, _G.Enum and _G.Enum.TooltipDataType
    if not processor or not processor.AddTooltipPostCall or not types then return end
    idsHooked = true
    local function on(kind, key)
        if types[kind] then
            processor.AddTooltipPostCall(types[kind], function(tip, data)
                CUI:SafeCall(CUI:Tr("IM_NOM"), addId, tip, data, L[key])
            end)
        end
    end
    on("Spell", "IM_ID_SORT")
    on("UnitAura", "IM_ID_SORT")
    on("Item", "IM_ID_OBJET")
    if types.Unit then
        processor.AddTooltipPostCall(types.Unit, function(tip)
            CUI:SafeCall(CUI:Tr("IM_NOM"), colorUnit, tip)
        end)
    end
end

-- Marche / arrêt -------------------------------------------------------------------------------

-- Place des infobulles ---------------------------------------------------------------------------

-- Les infobulles que le jeu pose à sa place habituelle (GameTooltip_SetDefaultAnchor : unités dans
-- le monde, cadres, nombreux boutons) s'ouvrent sur ce cadre, placé au cadenas. Elles grandissent
-- depuis le coin le plus proche du bord de l'écran.
local anchorFrame

local function anchorPoint()
    local x, y = anchorFrame:GetCenter()
    local w, h = _G.UIParent:GetSize()
    local vertical = (y and y > h / 2) and "TOP" or "BOTTOM"
    local horizontal = (x and x > w / 2) and "RIGHT" or "LEFT"
    return vertical .. horizontal
end

local anchorHooked = false
local function setupAnchor()
    if not anchorFrame then
        anchorFrame = _G.CreateFrame("Frame", "CoeurUIPlaceInfobulles", _G.UIParent)
        anchorFrame:SetSize(220, 90)
        CUI:RegisterMover({ key = "infobulles", frame = anchorFrame, label = "IM_PLACE",
                            default = { "BOTTOMRIGHT", "BOTTOMRIGHT", -40, 120 } })
    end
    if anchorHooked or type(_G.GameTooltip_SetDefaultAnchor) ~= "function" then return end
    anchorHooked = true
    _G.hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tip)
        if not M.enabled or not tip or forbidden(tip) then return end
        local point = anchorPoint()
        tip:ClearAllPoints()
        tip:SetPoint(point, anchorFrame, point, 0, 0)
    end)
end

local hooked = false
local menuDriver -- habille les menus ouverts à chaque image

function M:OnEnable()
    for _, name in ipairs(KNOWN_TIPS) do
        skinTooltip(_G[name])
    end
    skinStatusBar()
    applyTooltipFonts()
    hookIds()
    setupAnchor()
    if not hooked then
        hooked = true
        -- Chaque infobulle du modèle commun passe par là à son affichage (crochet seulement).
        if type(_G.SharedTooltip_SetBackdropStyle) == "function" then
            _G.hooksecurefunc("SharedTooltip_SetBackdropStyle", function(tip, _, embedded)
                if M.enabled and not embedded then skinTooltip(tip) end
            end)
        end
    end
    -- Menus : habillés à leur ouverture (crochets), puis à chaque image tant qu'un menu est ouvert
    -- (le jeu finit de les remplir après coup, ouvre ses sous-menus et repeint ses lignes au survol
    -- sans passer par le gestionnaire). Aucun menu ouvert : une seule question au jeu par image.
    hookManager()
    if not menuDriver then
        menuDriver = _G.CreateFrame("Frame")
        menuDriver:SetScript("OnUpdate", function()
            if M.enabled then CUI:SafeCall(CUI:Tr("IM_NOM"), skinOpenMenus) end
        end)
    end
end

-- Coupé : l'habillage reste jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnFontChanged()
    applyTooltipFonts()
end
