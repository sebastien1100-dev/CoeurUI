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

local function layoutDrawer()
    local shown = {}
    for _, b in ipairs(collected) do
        if b:IsShown() then shown[#shown + 1] = b end
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
    origins[b] = { parent = b:GetParent(), points = points, scale = b:GetScale() }
    collected[#collected + 1] = b
    if b.RegisterForDrag then b:RegisterForDrag() end -- plus de glisser autour de la carte : il vit dans le tiroir
    local busy = false
    b.cuiApply = function()
        if busy or not M.db.tiroir then return end
        busy = true
        if b:GetParent() ~= drawer then b:SetParent(drawer) end
        b:SetScale(CELL / math.max(1, b:GetWidth(), b:GetHeight()))
        b:ClearAllPoints()
        local p = b.cuiPlace or { "TOPLEFT", 6, -6 }
        local s = b:GetScale()
        b:SetPoint(p[1], drawer, p[1], p[2] / s, p[3] / s)
        b:SetFrameLevel(drawer:GetFrameLevel() + 2)
        busy = false
    end
    _G.hooksecurefunc(b, "SetPoint", function() if M.enabled and not busy then b.cuiApply() end end)
    _G.hooksecurefunc(b, "SetParent", function() if M.enabled and not busy then b.cuiApply() end end)
    b.cuiApply()
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
    if _G.AddonCompartmentFrame then collect(_G.AddonCompartmentFrame) end
    if drawer:IsShown() then layoutDrawer() end
end

-- Tiroir coupé : chaque bouton retourne là où il était.
local function releaseButtons()
    for b, orig in pairs(origins) do
        b:SetParent(orig.parent)
        b:SetScale(orig.scale)
        b:ClearAllPoints()
        for _, p in ipairs(orig.points) do b:SetPoint(unpack(p)) end
        if b.RegisterForDrag then b:RegisterForDrag("LeftButton") end
    end
    collected, origins = {}, {}
end

local function placeDrawer()
    drawer:ClearAllPoints()
    local x, y = drawerButton:GetCenter()
    local sw, sh = _G.UIParent:GetSize()
    local below = not y or y > sh / 2
    local right = x and x > sw / 2
    local v1, v2 = below and "TOP" or "BOTTOM", below and "BOTTOM" or "TOP"
    local h = right and "RIGHT" or "LEFT"
    drawer:SetPoint(v1 .. h, drawerButton, v2 .. h, 0, below and -4 or 4)
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
    drawerButton.cuiIgnore = true
    drawerButton.bg = solid(drawerButton, "BACKGROUND", { 0.06, 0.07, 0.09, 0.75 })
    drawerButton.bg:SetAllPoints()
    -- Petite grille de 4 carrés (icône du tiroir).
    for i = 0, 3 do
        local t = solid(drawerButton, "ARTWORK", C.texteSecondaire)
        t:SetSize(5, 5)
        t:SetPoint("CENTER", (i % 2 == 0) and -3.5 or 3.5, (i < 2) and 3.5 or -3.5)
    end
    local hl = solid(drawerButton, "HIGHLIGHT", { 1, 1, 1, 0.08 })
    hl:SetAllPoints()
    drawerButton:RegisterForClicks("LeftButtonUp")
    drawerButton:SetScript("OnClick", function() toggleDrawer() end)
    drawerButton:SetScript("OnEnter", function(self)
        CUI:ShowTooltip(self, L.MC_TIROIR_TITRE, L.MC_TIROIR_AIDE)
    end)
    drawerButton:SetScript("OnLeave", function(self) CUI:HideTooltip(self) end)

    drawer = _G.CreateFrame("Frame", "CoeurUIMinicarteTiroirGrille", _G.UIParent)
    drawer:SetFrameStrata("MEDIUM")
    drawer:SetClampedToScreen(true)
    drawer:EnableMouse(true)
    drawer.cuiIgnore = true
    local bg = solid(drawer, "BACKGROUND", { 0.06, 0.07, 0.09, 0.9 })
    bg:SetAllPoints()
    outline(drawer, { 0, 0, 0, 1 }, 0)
    drawer.empty = CUI:CreateText(drawer, "petit", "texteDiscret")
    drawer.empty:SetPoint("CENTER")
    drawer:Hide()
end

-- Boutons du jeu ---------------------------------------------------------------------------------

local function newGameHolder(key, w, h)
    local f = _G.CreateFrame("Frame", "CoeurUIMinicarte_" .. key, holder)
    f:SetSize(w, h)
    f:SetFrameLevel(_G.Minimap:GetFrameLevel() + 10)
    gameHolders[key] = f
    return f
end

local function buildGameButtons()
    local cluster = _G.MinimapCluster

    -- Courrier (et commandes d'artisanat) : le cadre d'indicateurs du jeu, qui ne se montre que
    -- quand il y a quelque chose.
    local mail = newGameHolder("courrier", 24, 24)
    pin(cluster and cluster.IndicatorFrame, mail, function(f, t) f:SetPoint("CENTER", t, "CENTER") end)

    -- Suivi : le bouton du jeu, sans son fond rond.
    local tracking = newGameHolder("suivi", 24, 24)
    local track = cluster and cluster.Tracking
    if track then
        if track.Background then track.Background:SetAlpha(0) end
        pin(track, tracking, function(f, t) f:SetPoint("CENTER", t, "CENTER") end)
    end

    -- File d'attente : l'œil du jeu (montré seulement en file), ramené à la taille des autres.
    local queue = newGameHolder("file", 28, 28)
    local eye = _G.QueueStatusButton
    if eye then
        pin(eye, queue, function(f, t)
            f:SetScale(28 / math.max(1, f:GetWidth()))
            f:SetPoint("CENTER", t, "CENTER")
        end)
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

    -- Cadenas : la carte (à l'écran), puis les éléments rattachés à la carte.
    CUI:RegisterMover({ key = "minicarte", frame = holder, label = "MC_M_CARTE",
                        default = { "TOPRIGHT", "TOPRIGHT", -20, -24 } })
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
