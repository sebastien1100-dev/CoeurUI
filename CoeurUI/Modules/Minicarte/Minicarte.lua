-- Module « Minicarte » (maquette validée) : minicarte sobre, rectangle ou carré à la taille voulue.
-- Autour : nom de la zone, coordonnées (centrées en bas de la carte), boutons du jeu (courrier,
-- suivi, file d'attente) et tiroir qui range les boutons des addons. Pas d'heure ni de calendrier.
-- La carte, le nom de la zone, le tiroir et chaque bouton du jeu se placent avec le cadenas ;
-- ces éléments sont rattachés à la carte et la suivent quand on la déplace.
--
-- La carte du jeu (Minimap) doit rester carrée : on la pose, carrée, au centre d'un cadre de la
-- taille voulue (qui coupe les points de la carte qui dépassent) et un masque (Media/Minicarte,
-- généré par tools/generer_masques.py) cache les bandes du terrain en trop.
-- Couper le module demande un /reload (la minicarte du jeu revient alors telle quelle).
local _, CUI = ...
local L = CUI.L
local C = CUI.Colors

local issecret = _G.issecretvalue or function() return false end
local function known(v)
    return v ~= nil and not issecret(v)
end

local M

local function replacerElements()
    for _, key in ipairs({ "minicarte_zone", "minicarte_courrier", "minicarte_suivi", "minicarte_file",
                           "minicarte_tiroir" }) do
        CUI:ResetMover(key)
    end
end

M = CUI:RegisterModule({
    key = "Minicarte",
    name = "MC_NOM",
    description = "MC_DESC",
    defaultEnabled = false,
    needsReload = true, -- la minicarte du jeu ne reprend sa forme qu'après un /reload
    defaults = {
        carre = true, largeur = 220, hauteur = 220, zoom = true,
        zone = true, coordonnees = true, boutonsJeu = true, tiroir = true,
    },
    settings = {
        { type = "section", text = "MC_CARTE" },
        { type = "toggle", key = "carre", label = "MC_CARRE" },
        { type = "slider", key = "largeur", label = "MC_LARGEUR", min = 120, max = 400, step = 10, format = "%d" },
        { type = "slider", key = "hauteur", label = "MC_HAUTEUR", min = 120, max = 400, step = 10, format = "%d",
          description = "MC_HAUTEUR_NOTE", enabledIf = function(read) return not read("carre") end },
        { type = "toggle", key = "zoom", label = "MC_ZOOM" },
        { type = "column" },
        { type = "section", text = "MC_AUTOUR" },
        { type = "toggle", key = "zone", label = "MC_ZONE" },
        { type = "toggle", key = "coordonnees", label = "MC_COORD" },
        { type = "toggle", key = "boutonsJeu", label = "MC_BOUTONS_JEU", description = "MC_BOUTONS_JEU_DESC" },
        { type = "toggle", key = "tiroir", label = "MC_TIROIR" },
        { type = "button", label = "MC_REPLACER", description = "MC_REPLACER_NOTE", onClick = replacerElements },
    },
})

local WHITE = "Interface\\Buttons\\WHITE8x8"
local K_MAX = 22 -- masques Masque_H_1..22 et Masque_V_1..22

local built = false
local holder        -- cadre de la taille visible ; parent de la carte du jeu (déplacé au cadenas)
local zoneFrame, zoneText
local coordFrame, coordText
local gameHolders = {} -- clé -> petit cadre qui porte un bouton du jeu
local drawerButton, drawer
local hiddenParent

local function solid(parent, layer, color, sublevel)
    local t = parent:CreateTexture(nil, layer, nil, sublevel or 0)
    t:SetTexture(WHITE)
    t:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    return t
end

-- Contour de 1 px autour d'un cadre, à l'extérieur (offset = écart au bord).
local function outline(frame, color, offset, layer)
    local o = offset
    local sides = {
        { "TOPLEFT", -o - 1, o + 1, "TOPRIGHT", o + 1, o },
        { "BOTTOMLEFT", -o - 1, -o, "BOTTOMRIGHT", o + 1, -o - 1 },
        { "TOPLEFT", -o - 1, o, "BOTTOMLEFT", -o, -o },
        { "TOPRIGHT", o, o, "BOTTOMRIGHT", o + 1, -o },
    }
    for _, s in ipairs(sides) do
        local t = solid(frame, layer or "BACKGROUND", color)
        t:SetPoint(s[1], frame, s[1], s[2], s[3])
        t:SetPoint(s[4], frame, s[4], s[5], s[6])
    end
end

-- Range un objet du jeu hors de vue (cadre) ou le rend invisible (texture).
local function hide(obj)
    if not obj then return end
    if obj.GetObjectType and obj:GetObjectType() == "Texture" then
        obj:SetAlpha(0)
        return
    end
    hiddenParent = hiddenParent or _G.CreateFrame("Frame")
    hiddenParent:Hide()
    obj:SetParent(hiddenParent)
    _G.hooksecurefunc(obj, "SetParent", function(self, parent)
        if parent ~= hiddenParent and M.enabled then self:SetParent(hiddenParent) end
    end)
end

-- Garde un cadre du jeu accroché à un de nos cadres, même si le jeu le replace (crochets seulement).
local function pin(frame, target, place)
    if not frame then return end
    local busy = false
    local function apply()
        if busy then return end
        busy = true
        if frame:GetParent() ~= target then frame:SetParent(target) end
        frame:ClearAllPoints()
        place(frame, target)
        frame:SetFrameLevel(target:GetFrameLevel() + 2)
        busy = false
    end
    _G.hooksecurefunc(frame, "SetPoint", function() if M.enabled and not busy then apply() end end)
    _G.hooksecurefunc(frame, "SetParent", function() if M.enabled and not busy then apply() end end)
    apply()
    return apply
end

-- Icônes de CœurUI (direction « trait + pastille », Media/Icones, tools/generer_pictos.py) ------------

local ICON_REPOS = { 0.77, 0.78, 0.8 }   -- #C4C6CC
local ICON_SURVOL = { 0.95, 0.95, 0.95 } -- #F2F2F2

local function newIcon(parent, name, size)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture(CUI.MEDIA .. "Icones\\" .. name)
    t:SetSize(size, size)
    t:SetPoint("CENTER")
    t:SetVertexColor(unpack(ICON_REPOS))
    return t
end

local function setHover(icon, on)
    icon:SetVertexColor(unpack(on and ICON_SURVOL or ICON_REPOS))
end

-- Pastille d'alerte (rouge cœur, cerclée de sombre), en haut à droite d'une icône.
local function newDot(parent, icon)
    local ring = parent:CreateTexture(nil, "OVERLAY", nil, 1)
    ring:SetTexture(CUI.MEDIA .. "Cercle")
    ring:SetVertexColor(0.08, 0.09, 0.1, 1)
    ring:SetSize(9, 9)
    ring:SetPoint("CENTER", icon, "TOPRIGHT", -1, -1)
    local dot = parent:CreateTexture(nil, "OVERLAY", nil, 2)
    dot:SetTexture(CUI.MEDIA .. "Cercle")
    dot:SetVertexColor(C.coeur[1], C.coeur[2], C.coeur[3], 1)
    dot:SetSize(6, 6)
    dot:SetPoint("CENTER", ring)
    return ring, dot
end

-- Rend un cadre du jeu invisible (il garde ses clics et ses infobulles) : notre icône le remplace.
local function ghost(frame, icon)
    if not frame then return end
    frame:SetAlpha(0)
    _G.hooksecurefunc(frame, "SetAlpha", function(self, a)
        if a ~= 0 and M.enabled then self:SetAlpha(0) end
    end)
    if icon and frame.HookScript then
        frame:HookScript("OnEnter", function() setHover(icon, true) end)
        frame:HookScript("OnLeave", function() setHover(icon, false) end)
    end
end

-- Taille ---------------------------------------------------------------------------------------

-- Taille visible, côté du carré de la carte, bande cachée (k/64 du côté) et sens du masque.
local function geometry()
    local w = M.db.largeur
    local h = M.db.carre and w or M.db.hauteur
    local side = math.max(w, h)
    local k = math.floor((side - math.min(w, h)) / 2 / side * 64 + 0.5)
    k = math.min(k, K_MAX)
    local crop = side * k / 64
    if k == 0 then
        return side, side, side, 0, 0, nil
    elseif w >= h then
        return side, side - 2 * crop, side, k, crop, "H"
    end
    return side - 2 * crop, side, side, k, crop, "V"
end

local function maskPath(k, dir)
    if k == 0 then return WHITE end
    return CUI.MEDIA .. "Minicarte\\Masque_" .. dir .. "_" .. k
end

local function applySize()
    local minimap = _G.Minimap
    local w, h, side, k, crop, dir = geometry()
    holder:SetSize(w, h)
    minimap:SetSize(side, side)
    local mask = maskPath(k, dir)
    minimap:SetMaskTexture(mask)
    local hybrid = _G.HybridMinimap
    if hybrid and hybrid.CircleMask then
        pcall(hybrid.CircleMask.SetTexture, hybrid.CircleMask, mask)
    end
    if dir == "H" then
        minimap:SetHitRectInsets(0, 0, crop, crop)
    elseif dir == "V" then
        minimap:SetHitRectInsets(crop, crop, 0, 0)
    else
        minimap:SetHitRectInsets(0, 0, 0, 0)
    end
    -- La carte du jeu se rafraîchit en changeant de zoom.
    local z = minimap:GetZoom()
    minimap:SetZoom(z > 0 and z - 1 or z + 1)
    minimap:SetZoom(z)
end

-- Nom de la zone -------------------------------------------------------------------------------

local ZONE_COLORS = {
    sanctuary = { 0.41, 0.8, 0.94 },
    arena = { 1, 0.1, 0.1 },
    combat = { 1, 0.1, 0.1 },
    hostile = { 1, 0.1, 0.1 },
    friendly = { 0.1, 1, 0.1 },
    contested = { 1, 0.7, 0 },
}
local ZONE_DEFAULT = { 1, 0.82, 0 }

local function updateZone()
    if not zoneText then return end
    local text = _G.GetMinimapZoneText and _G.GetMinimapZoneText()
    if not known(text) then text = "" end
    local pvpType = _G.C_PvP and _G.C_PvP.GetZonePVPInfo and _G.C_PvP.GetZonePVPInfo()
    local color = known(pvpType) and ZONE_COLORS[pvpType] or ZONE_DEFAULT
    zoneText:SetText(text)
    zoneText:SetTextColor(color[1], color[2], color[3])
end

-- Coordonnées ----------------------------------------------------------------------------------

local function updateCoords()
    if not coordFrame or not coordFrame:IsShown() then return end
    local text
    local mapID = _G.C_Map.GetBestMapForUnit("player")
    if known(mapID) then
        local pos = _G.C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then
            local x, y = pos:GetXY()
            if known(x) and known(y) and (x > 0 or y > 0) then
                text = ("%.1f, %.1f"):format(x * 100, y * 100)
            end
        end
    end
    coordText:SetText(text or "")
    coordFrame.veil:SetShown(text ~= nil)
end

-- Tiroir des boutons d'addons --------------------------------------------------------------------

local CELL, GAP, COLS = 28, 4, 5
local ICON = 22 -- diamètre de l'image d'un addon dans son rond
local collected = {}   -- boutons rangés, dans l'ordre où on les a trouvés
local origins = {}     -- bouton -> { parent, points, scale } (pour les rendre si le tiroir est coupé)

-- Bouton d'addon posé sur la minicarte ? (LibDBIcon, compartiment du jeu, bouton de CœurUI, ou
-- bouton nommé « ...Minimap... » qui n'est pas au jeu)
local IGNORE = {
    MinimapZoomIn = true, MinimapZoomOut = true, MiniMapTrackingButton = true, MinimapBackdrop = true,
    GameTimeFrame = true, TimeManagerClockButton = true, ExpansionLandingPageMinimapButton = true,
    QueueStatusButton = true, MinimapCluster = true,
}
local function isAddonButton(f)
    if f == drawer or f == drawerButton or f.cuiIgnore then return false end
    if f.IsForbidden and f:IsForbidden() then return false end
    local name = f.GetName and f:GetName()
    if not known(name) or not name then return false end
    if IGNORE[name] then return false end
    if name:find("^LibDBIcon10_") or name == "CoeurUIBoutonMinicarte" then return true end
    if name:find("^CoeurUI") then return false end
    return f:GetObjectType() == "Button" and name:lower():find("minimap") ~= nil
end

local compartmentOrder = {}   -- nos boutons tirés du menu des addons du jeu, dans l'ordre

-- Rond CœurUI d'un bouton d'addon (maquette « ronds sobres ») : liseré gris fin, fond graphite ;
-- le liseré s'éclaircit au survol.
local TILE_FOND = { 0.13, 0.145, 0.17, 1 } -- #22252B
local function addRound(frame, layer)
    local ring = frame:CreateTexture(nil, layer, nil, 0)
    ring:SetTexture(CUI.MEDIA .. "Cercle")
    ring:SetAllPoints()
    ring:SetVertexColor(C.bordureDiscrete[1], C.bordureDiscrete[2], C.bordureDiscrete[3], 1)
    local disc = frame:CreateTexture(nil, layer, nil, 1)
    disc:SetTexture(CUI.MEDIA .. "Cercle")
    disc:SetPoint("TOPLEFT", 1, -1)
    disc:SetPoint("BOTTOMRIGHT", -1, 1)
    disc:SetVertexColor(unpack(TILE_FOND))
    frame.cuiRing = ring
end

local function setRoundHover(frame, on)
    local c = on and C.texteSecondaire or C.bordureDiscrete
    frame.cuiRing:SetVertexColor(c[1], c[2], c[3], 1)
end

-- Image d'un rond : un peu plus grande que le rond puis découpée (les bords dessinés dans l'image
-- d'un addon, carré ou anneau, tombent hors du rond).
local ZOOM = 1.2
local function roundIcon(owner)
    local icon = owner:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON * ZOOM, ICON * ZOOM)
    icon:SetPoint("CENTER")
    local mask = owner:CreateMaskTexture()
    mask:SetTexture(CUI.MEDIA .. "Cercle", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(ICON, ICON)
    mask:SetPoint("CENTER")
    icon:AddMaskTexture(mask)
    return icon
end

-- Textures d'habillage d'un bouton de minicarte : anneau et fond standards du jeu, ou tout fichier
-- dont le nom dit « border », « background » ou « highlight », ou la couche de survol.
local DECOR_FILES = { [136430] = true, [136467] = true } -- MiniMap-TrackingBorder, UI-Minimap-Background
local function decorative(tex)
    if tex:GetDrawLayer() == "HIGHLIGHT" then return true end
    local file = tex:GetTexture()
    if file == nil then return true end
    if type(file) == "number" then
        return DECOR_FILES[file] or false
    end
    local f = tostring(file):lower()
    return f:find("border") ~= nil or f:find("background") ~= nil or f:find("highlight") ~= nil
end

-- L'image d'un bouton d'addon : son champ icon (LibDBIcon, CœurUI...), sinon sa texture normale,
-- sinon la meilleure image (voir plus bas).
local function findIcon(b)
    for _, key in ipairs({ "icon", "Icon" }) do
        local t = rawget(b, key)
        if type(t) == "table" and t.GetObjectType and t:GetObjectType() == "Texture" then return t end
    end
    local normal = b.GetNormalTexture and b:GetNormalTexture()
    if normal and not decorative(normal) then return normal end
    -- Bouton « à l'ancienne » : fond (BACKGROUND), image (ARTWORK), anneau (OVERLAY). On prend la
    -- plus grande image de la couche ARTWORK, sinon d'une autre couche, jamais un anneau, un fond
    -- ou un reflet.
    local best, bestScore = nil, 0
    for _, region in ipairs({ b:GetRegions() }) do
        if region:GetObjectType() == "Texture" and not decorative(region) then
            local w, h = region:GetSize()
            local score = w * h * (region:GetDrawLayer() == "ARTWORK" and 100 or 1)
            if score > bestScore then best, bestScore = region, score end
        end
    end
    return best
end

-- Recopie l'image de l'addon (fichier ou atlas, découpe, teinte) dans notre rond.
local function copyIcon(b)
    local tile, src = b.cuiTile, b.cuiSource
    if not tile or not src then return end
    local atlas = src.GetAtlas and src:GetAtlas()
    if type(atlas) == "string" and atlas ~= "" then
        tile.icon:SetAtlas(atlas)
    else
        tile.icon:SetTexture(src:GetTexture())
        tile.icon:SetTexCoord(src:GetTexCoord())
    end
    tile.icon:SetVertexColor(src:GetVertexColor())
    tile.icon:SetDesaturated(src:IsDesaturated() and true or false)
end

-- Habille un bouton d'addon : notre rond (liseré gris fin, fond graphite) avec une copie de son
-- image ; le bouton de l'addon, invisible, reste posé dessus pour ses clics et son infobulle.
-- Tout est noté pour être rendu si le tiroir est coupé.
local function dressButton(b, orig)
    local tile = _G.CreateFrame("Frame", nil, drawer)
    tile:SetSize(CELL, CELL)
    addRound(tile, "BACKGROUND")
    tile.icon = roundIcon(tile)
    tile:Hide()
    b.cuiTile = tile
    orig.alpha = b:GetAlpha()
    orig.width, orig.height = b:GetSize()

    local src = findIcon(b)
    b.cuiSource = src
    copyIcon(b)
    if src then
        -- L'addon change son image : la copie suit (crochets seulement).
        for _, method in ipairs({ "SetTexture", "SetAtlas", "SetTexCoord", "SetVertexColor", "SetDesaturated" }) do
            _G.hooksecurefunc(src, method, function() if b.cuiTile then copyIcon(b) end end)
        end
    end

    b:SetAlpha(0)
    _G.hooksecurefunc(b, "SetAlpha", function(self, a)
        if a ~= 0 and self.cuiTile then self:SetAlpha(0) end
    end)
    b:HookScript("OnEnter", function() if b.cuiTile then setRoundHover(b.cuiTile, true) end end)
    b:HookScript("OnLeave", function() if b.cuiTile then setRoundHover(b.cuiTile, false) end end)
end

local function undressButton(b, orig)
    if b.cuiTile then
        b.cuiTile:Hide()
        b.cuiTile = nil
    end
    b.cuiSource = nil
    b:SetAlpha(orig.alpha or 1)
    if orig.width and orig.width > 0 then b:SetSize(orig.width, orig.height) end
end

local function layoutDrawer()
    local shown = {}
    for _, b in ipairs(collected) do
        local visible = b:IsShown()
        if b.cuiTile then b.cuiTile:SetShown(visible) end
        if visible then shown[#shown + 1] = b end
    end
    for _, b in ipairs(compartmentOrder) do
        b:SetShown(b.cuiWanted)
        if b.cuiWanted then shown[#shown + 1] = b end
    end
    local n = #shown
    local cols = math.max(1, math.min(COLS, n))
    local rows = math.max(1, math.ceil(n / COLS))
    drawer:SetSize(cols * CELL + (cols - 1) * GAP + 12, rows * CELL + (rows - 1) * GAP + 12)
    for i, b in ipairs(shown) do
        local col, row = (i - 1) % COLS, math.floor((i - 1) / COLS)
        b.cuiPlace = { "TOPLEFT", 6 + col * (CELL + GAP), -6 - row * (CELL + GAP) }
        b.cuiApply()
    end
    drawer.empty:SetShown(n == 0)
    if n == 0 then
        drawer.empty:SetText(L.MC_TIROIR_VIDE)
        drawer:SetSize(math.ceil(drawer.empty:GetStringWidth()) + 20, 30)
    end
end

local function collect(b)
    if origins[b] then return end
    local points = {}
    for i = 1, b:GetNumPoints() do points[i] = { b:GetPoint(i) } end
    local orig = { parent = b:GetParent(), points = points, scale = b:GetScale() }
    origins[b] = orig
    collected[#collected + 1] = b
    if b.RegisterForDrag then b:RegisterForDrag() end -- plus de glisser autour de la carte : il vit dans le tiroir
    dressButton(b, orig)
    local busy = false
    b.cuiApply = function()
        if busy or not M.db.tiroir or not b.cuiTile then return end
        busy = true
        local tile = b.cuiTile
        local p = b.cuiPlace or { "TOPLEFT", 6, -6 }
        tile:ClearAllPoints()
        tile:SetPoint(p[1], drawer, p[1], p[2], p[3])
        tile:SetFrameLevel(drawer:GetFrameLevel() + 1)
        if b:GetParent() ~= drawer then b:SetParent(drawer) end
        b:SetScale(1)
        b:SetSize(CELL, CELL) -- invisible, à la taille du rond : c'est lui qui reçoit la souris
        b:ClearAllPoints()
        b:SetPoint("CENTER", tile, "CENTER")
        b:SetFrameLevel(drawer:GetFrameLevel() + 3)
        busy = false
    end
    _G.hooksecurefunc(b, "SetPoint", function() if M.enabled and not busy then b.cuiApply() end end)
    _G.hooksecurefunc(b, "SetParent", function() if M.enabled and not busy then b.cuiApply() end end)
    b.cuiApply()
end

-- Nom simplifié pour comparer un bouton d'addon et une entrée du menu des addons du jeu (sans
-- codes de couleur ni petites images dans le texte).
local function simplify(text)
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):lower()
    text = text:gsub("^libdbicon10_", ""):gsub("minimapbutton", ""):gsub("minimap", "")
    return (text:gsub("button", ""):gsub("[^%w]", ""))
end

-- Fichier d'une icône (numéro), pour comparer une entrée du menu et un bouton : même image =
-- même addon.
local probe
local function iconFile(icon)
    if type(icon) == "number" then return icon end
    if type(icon) ~= "string" or icon == "" then return nil end
    probe = probe or drawer:CreateTexture(nil, "BACKGROUND")
    probe:Hide()
    probe:SetTexture(icon)
    return probe:GetTextureFileID() or icon:lower()
end

local function buttonIconFile(b)
    local tex = b.icon or (b.GetNormalTexture and b:GetNormalTexture())
    if not tex or not tex.GetTexture then return nil end
    return (tex.GetTextureFileID and tex:GetTextureFileID()) or iconFile(tex:GetTexture())
end

-- L'entrée du menu a-t-elle déjà son propre bouton dans le tiroir ?
local function hasOwnButton(text, icon)
    local key = simplify(text)
    if key == "" then return true end
    local file = iconFile(icon)
    for _, b in ipairs(collected) do
        local other = simplify(b:GetName() or "")
        if other ~= "" and (other:find(key, 1, true) or key:find(other, 1, true)) then return true end
        if file and buttonIconFile(b) == file then return true end
    end
    return false
end

-- Menu des addons du jeu (le bouton « 3 ») : caché ; ses entrées qui n'ont pas déjà un bouton
-- dans le tiroir y deviennent un bouton CœurUI (même icône, même clic). Revu à chaque passage :
-- un addon qui crée son bouton plus tard fait disparaître la copie.
local compartmentButtons = {} -- texte de l'entrée -> notre bouton
local function compartmentButton(entry, text)
    local b = compartmentButtons[text]
    if b then return b end
    b = _G.CreateFrame("Button", nil, drawer)
    b:SetSize(CELL, CELL)
    b.cuiIgnore = true
    addRound(b, "BACKGROUND")
    local icon = roundIcon(b)
    if entry.icon then icon:SetTexture(entry.icon) end
    b:RegisterForClicks("AnyUp")
    b:SetScript("OnClick", function(self, mouseButton)
        if type(entry.func) == "function" then
            CUI:SafeCall(text, entry.func, self, { buttonName = mouseButton }, nil)
        end
    end)
    b:SetScript("OnEnter", function(self)
        setRoundHover(self, true)
        CUI:ShowTooltip(self, text)
    end)
    b:SetScript("OnLeave", function(self)
        setRoundHover(self, false)
        CUI:HideTooltip(self)
    end)
    b.cuiApply = function()
        b:ClearAllPoints()
        local p = b.cuiPlace or { "TOPLEFT", 6, -6 }
        b:SetPoint(p[1], drawer, p[1], p[2], p[3])
    end
    compartmentButtons[text] = b
    compartmentOrder[#compartmentOrder + 1] = b
    return b
end

local function collectCompartment()
    local frame = _G.AddonCompartmentFrame
    if not frame then return end
    if not frame.cuiHidden then
        frame.cuiHidden = true
        hide(frame)
    end
    local entries = type(frame.registeredAddons) == "table" and frame.registeredAddons or {}
    for _, entry in ipairs(entries) do
        local text = type(entry) == "table" and entry.text
        if type(text) == "string" and known(text) then
            compartmentButton(entry, text).cuiWanted = not hasOwnButton(text, entry.icon)
        end
    end
end

local function scanButtons()
    if not M.db.tiroir then return end
    for _, parent in ipairs({ _G.Minimap, _G.MinimapBackdrop }) do
        if parent then
            for _, child in ipairs({ parent:GetChildren() }) do
                if isAddonButton(child) then collect(child) end
            end
        end
    end
    collectCompartment()
    if drawer:IsShown() then layoutDrawer() end
end

-- Tiroir coupé : chaque bouton retourne là où il était.
local function releaseButtons()
    for b, orig in pairs(origins) do
        undressButton(b, orig)
        b:SetParent(orig.parent)
        b:SetScale(orig.scale)
        b:ClearAllPoints()
        for _, p in ipairs(orig.points) do b:SetPoint(unpack(p)) end
        if b.RegisterForDrag then b:RegisterForDrag("LeftButton") end
    end
    for _, b in ipairs(compartmentOrder) do b:Hide() end
    collected, origins, compartmentButtons, compartmentOrder = {}, {}, {}, {}
end

-- La grille s'ouvre sur le côté de la carte, alignée sur son bas, du côté du centre de l'écran.
local function placeDrawer()
    drawer:ClearAllPoints()
    local x = holder:GetCenter()
    if not x or x > _G.UIParent:GetWidth() / 2 then
        drawer:SetPoint("BOTTOMRIGHT", holder, "BOTTOMLEFT", -8, 0)
    else
        drawer:SetPoint("BOTTOMLEFT", holder, "BOTTOMRIGHT", 8, 0)
    end
end

local function toggleDrawer(show)
    if show == nil then show = not drawer:IsShown() end
    if show then
        scanButtons()
        layoutDrawer()
        placeDrawer()
    end
    drawer:SetShown(show)
    drawerButton.bg:SetVertexColor(unpack(show and C.graphiteClair or { 0.06, 0.07, 0.09, 0.75 }))
end

local function buildDrawer()
    drawerButton = _G.CreateFrame("Button", "CoeurUIMinicarteTiroir", holder)
    drawerButton:SetSize(26, 22)
    -- Au-dessus de la carte : posé dessus (cadenas), il doit recevoir le clic, pas la carte.
    drawerButton:SetFrameLevel(_G.Minimap:GetFrameLevel() + 10)
    drawerButton.cuiIgnore = true
    drawerButton.bg = solid(drawerButton, "BACKGROUND", { 0.06, 0.07, 0.09, 0.75 })
    drawerButton.bg:SetAllPoints()
    drawerButton.icon = newIcon(drawerButton, "Tiroir", 16)
    drawerButton:RegisterForClicks("LeftButtonUp")
    drawerButton:SetScript("OnClick", function() toggleDrawer() end)
    drawerButton:SetScript("OnEnter", function(self) setHover(self.icon, true) end)
    drawerButton:SetScript("OnLeave", function(self) setHover(self.icon, false) end)

    drawer = _G.CreateFrame("Frame", "CoeurUIMinicarteTiroirGrille", _G.UIParent)
    drawer:SetFrameStrata("MEDIUM")
    drawer:SetClampedToScreen(true)
    drawer:EnableMouse(true)
    drawer.cuiIgnore = true
    -- Même cadre que les infobulles et les menus (direction « sobre », CLAUDE.md).
    CUI:CreateBorderedRect(drawer, 3, C.bordureDiscrete, { C.fond[1], C.fond[2], C.fond[3], 0.96 })
    drawer.empty = CUI:CreateText(drawer, "petit", "texteDiscret")
    drawer.empty:SetPoint("CENTER")
    drawer:Hide()
end

-- Boutons du jeu ---------------------------------------------------------------------------------

local function newGameHolder(key, iconName)
    local f = _G.CreateFrame("Frame", "CoeurUIMinicarte_" .. key, holder)
    f:SetSize(24, 24)
    f:SetFrameLevel(_G.Minimap:GetFrameLevel() + 10)
    f.bg = solid(f, "BACKGROUND", { 0.06, 0.07, 0.09, 0.7 })
    f.bg:SetAllPoints()
    f.icon = newIcon(f, iconName, 18)
    gameHolders[key] = f
    return f
end

-- Notre icône (et son fond) n'apparaît que quand le bouton du jeu est montré.
local function followShown(f, frame)
    local function sync()
        local shown = frame:IsShown()
        f.bg:SetShown(shown)
        f.icon:SetShown(shown)
        if f.ring then
            f.ring:SetShown(shown)
            f.dot:SetShown(shown)
        end
    end
    frame:HookScript("OnShow", sync)
    frame:HookScript("OnHide", sync)
    sync()
end

-- Pas d'infobulle sur nos icônes : celle que le bouton du jeu vient d'ouvrir est refermée
-- (crochet après son survol ; on ne remplace pas son script).
local function noTooltip(owner)
    local tip = _G.GameTooltip
    if tip and tip:IsShown() and tip:GetOwner() == owner then
        tip:Hide()
    end
end

local function centerOn(f, t)
    f:SetPoint("CENTER", t, "CENTER")
end

local function buildGameButtons()
    local cluster = _G.MinimapCluster
    local indicator = cluster and cluster.IndicatorFrame

    -- Courrier : le cadre du courrier du jeu (survol : expéditeurs), invisible sous notre icône,
    -- avec la pastille rouge. Montré seulement avec du courrier en attente.
    local mail = newGameHolder("courrier", "Courrier")
    mail.ring, mail.dot = newDot(mail, mail.icon)
    -- On déplace tout le cadre d'indicateurs (le jeu lui demande de se réarranger à chaque
    -- courrier : le cadre du courrier ne doit pas changer de parent). Les commandes d'artisanat,
    -- qui y vivent aussi, n'ont pas encore d'icône CœurUI : invisibles avec lui.
    local mailFrame = indicator and indicator.MailFrame
    if mailFrame then
        pin(indicator, mail, centerOn)
        ghost(indicator, nil)
        mailFrame:HookScript("OnEnter", function(self)
            setHover(mail.icon, true)
            noTooltip(self)
        end)
        mailFrame:HookScript("OnLeave", function() setHover(mail.icon, false) end)
        followShown(mail, mailFrame)
    end

    -- Suivi : le bouton du jeu (clic : menu de suivi), invisible sous notre icône.
    local tracking = newGameHolder("suivi", "Suivi")
    local track = cluster and cluster.Tracking
    if track then
        pin(track, tracking, centerOn)
        ghost(track, nil)
        if track.Button then
            track.Button:HookScript("OnEnter", function(self)
                setHover(tracking.icon, true)
                noTooltip(self)
            end)
            track.Button:HookScript("OnLeave", function() setHover(tracking.icon, false) end)
        end
    end

    -- File d'attente : l'œil du jeu (clic : état de la file), invisible sous notre icône, montré
    -- seulement en file.
    local queue = newGameHolder("file", "File")
    local eye = _G.QueueStatusButton
    if eye then
        pin(eye, queue, function(f, t)
            f:SetScale(24 / math.max(1, f:GetWidth()))
            f:SetPoint("CENTER", t, "CENTER")
        end)
        ghost(eye, queue.icon)
        followShown(queue, eye)
    end

    -- Difficulté de l'instance : petite bannière en haut de la carte (seulement en instance).
    pin(cluster and cluster.InstanceDifficulty, holder, function(f, t) f:SetPoint("TOP", t, "TOP", 0, -2) end)
end

-- Construction -----------------------------------------------------------------------------------

local function hideBlizzardPieces()
    local cluster = _G.MinimapCluster
    local minimap = _G.Minimap
    if cluster then
        hide(cluster.BorderTop)
        hide(cluster.ZoneTextButton)
    end
    hide(minimap.ZoomIn)
    hide(minimap.ZoomOut)
    hide(_G.MinimapZoomIn)
    hide(_G.MinimapZoomOut)
    hide(_G.MinimapCompassTexture)
    hide(_G.MinimapBorder)
    hide(_G.MinimapBorderTop)
    hide(_G.GameTimeFrame)             -- calendrier : pas voulu
    hide(_G.TimeManagerClockButton)    -- heure : pas voulue
    hide(_G.ExpansionLandingPageMinimapButton)
    if minimap.SetArchBlobRingScalar then minimap:SetArchBlobRingScalar(0) end
    if minimap.SetQuestBlobRingScalar then minimap:SetQuestBlobRingScalar(0) end
end

-- Ce qui reste dans le cadre de la minicarte du jeu (resté à son ancienne place) : textes et
-- décors rendus invisibles et sans souris. Le cadre de sélection du mode édition du jeu est gardé.
local function cleanCluster()
    local cluster = _G.MinimapCluster
    if not cluster then return end
    for _, region in ipairs({ cluster:GetRegions() }) do
        region:SetAlpha(0)
    end
    for _, child in ipairs({ cluster:GetChildren() }) do
        if child ~= cluster.Selection and not (child.IsForbidden and child:IsForbidden()) then
            child:SetAlpha(0)
            if child.EnableMouse then child:EnableMouse(false) end
        end
    end
end

local function build()
    if built then return end
    built = true
    local minimap = _G.Minimap

    holder = _G.CreateFrame("Frame", "CoeurUIMinicarte", _G.UIParent)
    holder:SetFrameStrata("LOW")
    holder:SetFrameLevel(2)
    holder:SetSize(220, 220)
    outline(holder, { 0, 0, 0, 1 }, 0)
    outline(holder, C.graphite, 1)

    -- La carte du jeu, carrée, au centre de notre cadre (qui coupe ce qui dépasse).
    pin(minimap, holder, function(f, t)
        f:SetScale(1)
        f:SetPoint("CENTER", t, "CENTER")
    end)
    minimap:SetFrameLevel(holder:GetFrameLevel() + 1)
    hideBlizzardPieces()

    -- Les addons de boutons lisent cette fonction pour la forme de la carte.
    if _G.GetMinimapShape == nil then
        _G.GetMinimapShape = function() return "SQUARE" end
    end

    -- Zoom à la molette (le script est le nôtre seulement si le jeu n'en a pas).
    if not minimap:GetScript("OnMouseWheel") then
        minimap:SetScript("OnMouseWheel", function(self, delta)
            local z = self:GetZoom() + (delta > 0 and 1 or -1)
            self:SetZoom(math.max(0, math.min(self:GetZoomLevels() - 1, z)))
        end)
    end

    -- Nom de la zone.
    zoneFrame = _G.CreateFrame("Frame", "CoeurUIMinicarteZone", holder)
    zoneFrame:SetSize(200, 18)
    zoneText = zoneFrame:CreateFontString(nil, "OVERLAY")
    zoneText:SetFontObject(CUI.Fonts.normal)
    zoneText:SetShadowColor(0, 0, 0, 1)
    zoneText:SetShadowOffset(1, -1)
    zoneText:SetWordWrap(false)
    zoneText:SetAllPoints()

    -- Coordonnées, centrées en bas de la carte, sur un léger voile.
    coordFrame = _G.CreateFrame("Frame", nil, holder)
    coordFrame:SetSize(80, 18)
    coordFrame:SetPoint("BOTTOM", holder, "BOTTOM", 0, 6)
    coordFrame:SetFrameLevel(minimap:GetFrameLevel() + 10)
    coordText = CUI:CreateText(coordFrame, "petit", "texte")
    coordText:SetJustifyH("CENTER")
    coordText:SetJustifyV("MIDDLE")
    coordText:SetPoint("CENTER")
    coordFrame.veil = solid(coordFrame, "BACKGROUND", { 0.06, 0.07, 0.09, 0.6 })
    coordFrame.veil:SetPoint("TOPLEFT", coordText, "TOPLEFT", -7, 3)
    coordFrame.veil:SetPoint("BOTTOMRIGHT", coordText, "BOTTOMRIGHT", 7, -3)

    buildGameButtons()
    buildDrawer()
    cleanCluster() -- après : les pièces gardées ont déjà quitté ce cadre

    -- Cadenas : la carte (à l'écran), puis les éléments rattachés à la carte.
    -- Étiquette de la carte en dessous, à gauche : au-dessus, il y a celle du nom de la zone.
    CUI:RegisterMover({ key = "minicarte", frame = holder, label = "MC_M_CARTE",
                        default = { "TOPRIGHT", "TOPRIGHT", -20, -24 },
                        tagPoint = { "TOPLEFT", "BOTTOMLEFT", 0, -3 } })
    local function attach(key, frame, label, default)
        CUI:RegisterMover({ key = key, frame = frame, label = label, default = default, parent = holder })
    end
    attach("minicarte_zone", zoneFrame, "MC_M_ZONE", { "BOTTOM", "TOP", 0, 4 })
    attach("minicarte_courrier", gameHolders.courrier, "MC_M_COURRIER", { "TOPLEFT", "TOPLEFT", 4, -4 })
    attach("minicarte_suivi", gameHolders.suivi, "MC_M_SUIVI", { "TOPRIGHT", "TOPRIGHT", -4, -4 })
    attach("minicarte_file", gameHolders.file, "MC_M_FILE", { "BOTTOMLEFT", "BOTTOMLEFT", 2, 2 })
    attach("minicarte_tiroir", drawerButton, "MC_M_TIROIR", { "TOPRIGHT", "BOTTOMRIGHT", 0, -4 })
end

-- Applique tous les réglages.
local function applyAll()
    if not built then return end
    applySize()
    _G.Minimap:EnableMouseWheel(M.db.zoom and true or false)
    zoneFrame:SetShown(M.db.zone)
    updateZone()
    coordFrame:SetShown(M.db.coordonnees)
    updateCoords()
    for _, f in pairs(gameHolders) do f:SetShown(M.db.boutonsJeu) end
    drawerButton:SetShown(M.db.tiroir)
    if M.db.tiroir then
        scanButtons()
    else
        toggleDrawer(false)
        releaseButtons()
    end
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    build()
    applyAll()
    for _, event in ipairs({ "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA" }) do
        self:On(event, updateZone)
    end
    self:On("PLAYER_ENTERING_WORLD", function()
        updateZone()
        self:After(2, scanButtons) -- les addons créent souvent leur bouton un peu après
    end)
    self:On("ADDON_LOADED", function(_, name)
        if name == "Blizzard_HybridMinimap" then applySize() end
        if name == "Blizzard_TimeManager" then hide(_G.TimeManagerClockButton) end
        self:After(1, scanButtons)
    end)
    -- Un clic ailleurs referme le tiroir.
    self:On("GLOBAL_MOUSE_DOWN", function()
        if drawer:IsShown() and not drawer:IsMouseOver() and not drawerButton:IsMouseOver() then
            toggleDrawer(false)
        end
    end)
    self:Every(0.2, updateCoords)
    self:After(3, scanButtons)
end

-- Coupé : tout reste en place jusqu'au /reload (needsReload).
function M:OnDisable()
    if drawer then toggleDrawer(false) end
end

function M:OnSettingChanged()
    applyAll()
end

-- Police de CœurUI changée (page « Général ») : le nom de la zone la reprend.
function M:OnFontChanged()
    if zoneText then
        zoneText:SetFontObject(CUI.Fonts.normal)
        zoneText:SetShadowColor(0, 0, 0, 1)
        zoneText:SetShadowOffset(1, -1)
    end
end
