-- Module « Effets » (maquette validée le 27/11/2026) : améliorations et affaiblissements du joueur.
-- Ce sont les boutons du jeu (BuffFrame, DebuffFrame) : le jeu les tient à jour, même en combat
-- quand il cache les valeurs aux addons. CœurUI les habille et les range :
--   - carrés sobres (icône rognée, liseré gris fin), temps restant dessous en petit gris clair (blanc
--     sous 10 s), nombre d'applications en bas à droite ;
--   - affaiblissements : liseré de la couleur de leur type (couleur donnée par le jeu, recopiée telle
--     quelle, même cachée) ;
--   - améliorations et affaiblissements indépendants : chacun son cadre au cadenas, chacun ses
--     réglages (sous-onglets).
-- Clic droit pour annuler, infobulle : ceux du jeu. Couper le module demande un /reload.
local _, CUI = ...
local C = CUI.Colors

local issecret = _G.issecretvalue or function() return false end
local function known(v) return v ~= nil and not issecret(v) end

local SENS = {
    { value = "gauche_bas", text = "EF_SENS_GAUCHE_BAS" },
    { value = "droite_bas", text = "EF_SENS_DROITE_BAS" },
    { value = "gauche_haut", text = "EF_SENS_GAUCHE_HAUT" },
    { value = "droite_haut", text = "EF_SENS_DROITE_HAUT" },
}

local function page(debuffs)
    local function tempsOn(read) return read("temps") end
    local items = {
        { type = "section", text = "EF_AFFICHAGE" },
        { type = "toggle", key = "afficher", label = debuffs and "EF_AFFICHER_DEBUFFS" or "EF_AFFICHER_BUFFS" },
        { type = "section", text = "EF_DISPOSITION" },
        { type = "slider", key = "taille", label = "EF_TAILLE", min = 20, max = 64, step = 2, format = "%d" },
        { type = "slider", key = "parRangee", label = "EF_PAR_RANGEE", min = 1, max = 20, step = 1, format = "%d" },
        { type = "slider", key = "rangees", label = "EF_RANGEES", min = 1, max = 6, step = 1, format = "%d" },
        { type = "slider", key = "espacement", label = "EF_ESPACEMENT", min = 0, max = 16, step = 1, format = "%d" },
        { type = "dropdown", key = "sens", label = "EF_SENS", options = SENS, description = "EF_PLACE_NOTE" },
        { type = "column" },
        { type = "section", text = "EF_TEXTES" },
        { type = "toggle", key = "temps", label = "EF_TEMPS" },
        { type = "toggle", key = "blanc", label = "EF_BLANC", enabledIf = tempsOn },
        { type = "toggle", key = "nombre", label = "EF_NOMBRE" },
        { type = "slider", key = "tailleTemps", label = "EF_TAILLE_TEMPS", min = 8, max = 16, step = 1, format = "%d pt",
          enabledIf = tempsOn },
        { type = "slider", key = "tailleNombre", label = "EF_TAILLE_NOMBRE", min = 8, max = 18, step = 1, format = "%d pt",
          enabledIf = function(read) return read("nombre") end },
    }
    if debuffs then
        items[#items + 1] = { type = "section", text = "EF_LISERE" }
        items[#items + 1] = { type = "toggle", key = "couleurType", label = "EF_COULEUR_TYPE" }
    end
    return items
end

local function groupDefaults(debuffs)
    return {
        afficher = true, taille = debuffs and 38 or 32, parRangee = 8, rangees = debuffs and 2 or 3, espacement = 6,
        sens = "gauche_bas", temps = true, blanc = true, nombre = true,
        tailleTemps = debuffs and 11 or 10, tailleNombre = debuffs and 12 or 11, couleurType = true,
    }
end

local M = CUI:RegisterModule({
    key = "Effets",
    name = "EF_NOM",
    description = "EF_DESC",
    defaultEnabled = false,
    needsReload = true,
    defaults = { buffs = groupDefaults(false), debuffs = groupDefaults(true) },
    subs = {
        { key = "buffs", name = "EF_BUFFS", intro = false, settings = page(false) },
        { key = "debuffs", name = "EF_DEBUFFS", intro = false, settings = page(true) },
    },
})

local WHITE = "Interface\\Buttons\\WHITE8x8"
local FOND = { 0.06, 0.07, 0.09, 1 }

local GROUPS = {
    { key = "buffs", frame = "BuffFrame", label = "EF_BUFFS", default = { "TOPRIGHT", "TOPRIGHT", -230, -16 } },
    { key = "debuffs", frame = "DebuffFrame", label = "EF_DEBUFFS", default = { "TOPRIGHT", "TOPRIGHT", -230, -150 } },
}

local built = false
local hiddenParent
local holders = {}   -- clé -> cadre placé au cadenas
local skinned = {}   -- bouton -> clé de son groupe

local function gameFrame(g)
    local f = _G[g.frame]
    if f and not (f.IsForbidden and f:IsForbidden()) then return f end
end

-- Un bouton protégé ne se touche pas en combat (il le sera de nouveau à la sortie).
local function canTouch(b)
    return not (_G.InCombatLockdown() and b.IsProtected and b:IsProtected())
end

-- Habillage d'un bouton ---------------------------------------------------------------------------

local function hide(region)
    if region and region.SetAlpha then region:SetAlpha(0) end
end

local function setBorderColor(b, r, g, bl)
    for _, line in ipairs(b.cuiLines) do line:SetVertexColor(r, g, bl, 1) end
end

local function paintBorder(b)
    local s = M.db[skinned[b]]
    if skinned[b] == "debuffs" and s.couleurType then
        local border = b.DebuffBorder
        if border and border.GetVertexColor and border:IsShown() then
            -- Couleur du type posée par le jeu (peut être cachée : passée telle quelle).
            setBorderColor(b, border:GetVertexColor())
            return
        end
        setBorderColor(b, C.coeur[1], C.coeur[2], C.coeur[3])
        return
    end
    setBorderColor(b, C.graphite[1], C.graphite[2], C.graphite[3])
end

-- Temps : gris clair, blanc sous 10 s (« 8 s », « 8 sec »...) ; texte caché par le jeu : gris clair.
local function paintDuration(fs)
    local b = fs.cuiButton
    local s = b and skinned[b] and M.db[skinned[b]]
    if not s then return end
    local text = fs:GetText()
    local urgent = false
    if s.blanc and known(text) and type(text) == "string" then
        local n, unit = text:match("^(%d+)%s*(%a+)")
        urgent = n and unit and unit:sub(1, 1):lower() == "s" and tonumber(n) < 10 or false
    end
    local c = urgent and C.texte or C.texteSecondaire
    fs.cuiPainting = true
    fs:SetTextColor(c[1], c[2], c[3])
    fs.cuiPainting = false
end

-- Pièces d'un bouton : sur ce client, « Icon », « Duration » ou « Count » peuvent être un cadre
-- qui porte la vraie texture ou le vrai texte. On cherche l'objet du bon type, au besoin dedans.
local function isKind(o, kind)
    return type(o) == "table" and type(o.GetObjectType) == "function" and o:GetObjectType() == kind
end

local function findPart(kind, ...)
    for i = 1, select("#", ...) do
        local o = select(i, ...)
        if isKind(o, kind) then return o end
        if type(o) == "table" then
            for _, k in ipairs({ "Icon", "icon", "Texture", "Text", "text", "Duration", "Count" }) do
                if isKind(o[k], kind) then return o[k] end
            end
            if type(o.GetRegions) == "function" then
                for _, r in ipairs({ o:GetRegions() }) do
                    if isKind(r, kind) then return r end
                end
            end
        end
    end
end

local function findIcon(b) return findPart("Texture", b.Icon, b.icon) end

local function skinButton(b, key)
    if skinned[b] then
        skinned[b] = key
        return
    end
    local icon = findIcon(b)
    if icon then
        -- Tous les masques retirés (icône ronde sinon), où qu'ils soient posés.
        if b.IconMask and icon.RemoveMaskTexture then icon:RemoveMaskTexture(b.IconMask) end
        if icon.GetNumMaskTextures and icon.GetMaskTexture and icon.RemoveMaskTexture then
            for i = icon:GetNumMaskTextures(), 1, -1 do
                local mask = icon:GetMaskTexture(i)
                if mask then icon:RemoveMaskTexture(mask) end
            end
        end
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", b, "TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", b, "TOPRIGHT", -1, -b:GetWidth() + 1)
        b.cuiIcon = icon
    end
    -- Décor du jeu invisible (contours, symbole du type, bordure d'enchantement).
    for _, k in ipairs({ "Border", "DebuffBorder", "TempEnchantBorder", "Symbol", "IconBorder" }) do hide(b[k]) end
    -- Fond sombre et liseré de 1 point (4 traits) autour de l'icône.
    b.cuiBack = b.cuiBack or b:CreateTexture(nil, "BACKGROUND", nil, -8)
    b.cuiBack:SetTexture(WHITE)
    b.cuiBack:SetVertexColor(FOND[1], FOND[2], FOND[3], FOND[4])
    b.cuiLines = b.cuiLines or {}
    for i = 1, 4 do
        local t = b.cuiLines[i] or b:CreateTexture(nil, "OVERLAY", nil, 6)
        t:SetTexture(WHITE)
        b.cuiLines[i] = t
    end
    -- Le jeu recolore la bordure d'un affaiblissement selon son type : on recopie sa couleur.
    if b.DebuffBorder and b.DebuffBorder.SetVertexColor then
        _G.hooksecurefunc(b.DebuffBorder, "SetVertexColor", function(_, r, g, bl)
            local s = skinned[b] and M.db[skinned[b]]
            if M.enabled and skinned[b] == "debuffs" and s and s.couleurType then setBorderColor(b, r, g, bl) end
        end)
    end
    local d = findPart("FontString", b.Duration, b.duration)
    if d then
        d.cuiButton = b
        _G.hooksecurefunc(d, "SetText", paintDuration)
        _G.hooksecurefunc(d, "SetTextColor", function(self) if not self.cuiPainting then paintDuration(self) end end)
        if d.SetVertexColor then
            _G.hooksecurefunc(d, "SetVertexColor", function(self) if not self.cuiPainting then paintDuration(self) end end)
        end
        b.cuiDuration = d
    end
    b.cuiCount = findPart("FontString", b.Count, b.count)
    -- Marqué seulement une fois tout posé : un habillage interrompu sera repris au passage suivant.
    skinned[b] = key
end

-- Taille, textes et liseré d'un bouton selon les réglages de son groupe.
local function styleButton(b)
    local s = M.db[skinned[b]]
    local size = s.taille
    b:SetScale(1) -- le jeu met ses boutons à l'échelle (taille d'icône du mode Édition) : la taille est la nôtre
    b:SetSize(size, size)
    if b.cuiIcon then
        b.cuiIcon:ClearAllPoints()
        b.cuiIcon:SetPoint("TOPLEFT", b, "TOPLEFT", 1, -1)
        b.cuiIcon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
    end
    b.cuiBack:ClearAllPoints()
    b.cuiBack:SetAllPoints(b)
    local l = b.cuiLines
    l[1]:ClearAllPoints(); l[1]:SetPoint("TOPLEFT"); l[1]:SetPoint("TOPRIGHT"); l[1]:SetHeight(1)
    l[2]:ClearAllPoints(); l[2]:SetPoint("BOTTOMLEFT"); l[2]:SetPoint("BOTTOMRIGHT"); l[2]:SetHeight(1)
    l[3]:ClearAllPoints(); l[3]:SetPoint("TOPLEFT"); l[3]:SetPoint("BOTTOMLEFT"); l[3]:SetWidth(1)
    l[4]:ClearAllPoints(); l[4]:SetPoint("TOPRIGHT"); l[4]:SetPoint("BOTTOMRIGHT"); l[4]:SetWidth(1)
    paintBorder(b)
    local font = CUI:GetFont()
    local d = b.cuiDuration
    if d then
        d:SetFont(font, s.tailleTemps, "OUTLINE")
        d:ClearAllPoints()
        d:SetPoint("TOP", b, "BOTTOM", 0, -2)
        d:SetAlpha(s.temps and 1 or 0)
        paintDuration(d)
    end
    local n = b.cuiCount
    if n then
        n:SetFont(font, s.tailleNombre, "OUTLINE")
        n:ClearAllPoints()
        n:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 2)
        n:SetAlpha(s.nombre and 1 or 0)
    end
end

-- Rangement -------------------------------------------------------------------------------------

-- Un vrai effet : pas une ancre d'effet privé du jeu, et une image posée (cachée par le jeu : comptée).
local function isPrivateAnchor(f, b)
    if rawget(b, "isPrivateAuraAnchor") then return true end
    local anchors = rawget(f, "privateAuraAnchors")
    if type(anchors) == "table" then
        for _, a in pairs(anchors) do if a == b then return true end end
    end
    return false
end

local function hasAura(f, b)
    if isPrivateAnchor(f, b) then return false end
    local icon = findIcon(b)
    if not icon or type(icon.GetTexture) ~= "function" then return false end
    local tex = icon:GetTexture()
    return tex ~= nil and (issecret(tex) or (tex ~= "" and tex ~= 0))
end

-- Boutons affichés par le jeu, dans son ordre.
local function shownButtons(f)
    local list = {}
    if type(f.auraFrames) == "table" then
        for _, b in ipairs(f.auraFrames) do
            if b.IsShown and b:IsShown() and hasAura(f, b) then list[#list + 1] = b end
        end
    end
    if #list == 0 then
        local container = f.AuraContainer or f
        for _, child in ipairs({ container:GetChildren() }) do
            if child:IsShown() and (child.Icon or child.icon) and hasAura(f, child) then list[#list + 1] = child end
        end
        table.sort(list, function(a, b)
            local ai, bi = rawget(a, "layoutIndex"), rawget(b, "layoutIndex")
            if type(ai) == "number" and type(bi) == "number" then return ai < bi end
            return false
        end)
    end
    return list
end

-- Coin de départ et sens d'ajout.
local CORNERS = {
    gauche_bas = { "TOPRIGHT", -1, -1 }, droite_bas = { "TOPLEFT", 1, -1 },
    gauche_haut = { "BOTTOMRIGHT", -1, 1 }, droite_haut = { "BOTTOMLEFT", 1, 1 },
}

local laying = false
local function layoutGroup(g)
    local f, holder = gameFrame(g), holders[g.key]
    if not f or not holder then return end
    local s = M.db[g.key]
    local size, gap = s.taille, s.espacement
    local rowGap = gap + (s.temps and (s.tailleTemps + 4) or 0)
    local per, rows = s.parRangee, s.rangees
    local corner = CORNERS[s.sens] or CORNERS.gauche_bas
    -- Le coin d'où partent les icônes reste en place quand la taille change.
    local w, h = per * (size + gap) - gap, rows * (size + rowGap) - rowGap
    if holder.cuiPoint ~= corner[1] or math.abs(holder:GetWidth() - w) > 0.01
        or math.abs(holder:GetHeight() - h) > 0.01 then
        CUI:SetMoverPoint("effets_" .. g.key, corner[1])
        holder.cuiPoint = corner[1]
    end
    holder:SetSize(w, h)
    laying = true
    for i, b in ipairs(shownButtons(f)) do
        if canTouch(b) then
            skinButton(b, g.key)
            styleButton(b)
            local index = i - 1
            local col, row = index % per, math.floor(index / per)
            b:ClearAllPoints()
            b:SetPoint(corner[1], holder, corner[1], corner[2] * col * (size + gap), corner[3] * row * (size + rowGap))
            local visible = s.afficher and row < rows
            b:SetAlpha(visible and 1 or 0)
            b:EnableMouse(visible)
        end
    end
    laying = false
end

local function layoutAll()
    if not built then return end
    for _, g in ipairs(GROUPS) do layoutGroup(g) end
end

-- Construction ----------------------------------------------------------------------------------

local function build()
    if built then return end
    built = true
    hiddenParent = _G.CreateFrame("Frame")
    hiddenParent:Hide()
    for _, g in ipairs(GROUPS) do
        local holder = _G.CreateFrame("Frame", "CoeurUIEffets" .. g.key, _G.UIParent)
        holder:SetSize(100, 40)
        holders[g.key] = holder
        CUI:RegisterMover({ key = "effets_" .. g.key, frame = holder, label = g.label, default = g.default })
        local f = gameFrame(g)
        if f then
            -- Le jeu range ses boutons à chaque changement : on repasse derrière lui (crochets).
            local container = f.AuraContainer
            if container and type(container.UpdateGridLayout) == "function" then
                _G.hooksecurefunc(container, "UpdateGridLayout", function()
                    if M.enabled and not laying then layoutGroup(g) end
                end)
            end
            if type(f.UpdateAuraButtons) == "function" then
                _G.hooksecurefunc(f, "UpdateAuraButtons", function()
                    if M.enabled and not laying then layoutGroup(g) end
                end)
            end
            -- Bouton du jeu pour replier les améliorations : retiré.
            local toggle = f.CollapseAndExpandButton
            if toggle and not (toggle.IsProtected and toggle:IsProtected()) then toggle:SetParent(hiddenParent) end
        end
    end
    layoutAll()
end

-- Marche / arrêt -------------------------------------------------------------------------------

function M:OnEnable()
    CUI:AfterCombat(build)
    self:On("UNIT_AURA", function(_, unit)
        if unit == "player" and built then self:After(0, layoutAll) end
    end)
    self:On("PLAYER_ENTERING_WORLD", function() self:After(1, layoutAll) end)
    -- Filet de sécurité : un changement que les crochets n'auraient pas vu.
    self:Every(1, layoutAll)
    self:On("PLAYER_REGEN_ENABLED", layoutAll)
end

-- Coupé : l'habillage reste jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged()
    layoutAll()
end

function M:OnFontChanged()
    layoutAll()
end
