-- Style de CœurUI : thèmes, cadres et barres (direction artistique validée le 28/11/2026,
-- « CœurUI · Direction artistique », planche « Le choix »).
--
-- Porte ouverte vers un système de thèmes : toutes les valeurs du style sont rangées dans un thème
-- nommé (CUI.Themes). Aujourd'hui un seul, « givre » : minimal plat, fond ardoise bleutée, double
-- liseré très discret, ombre douce, coins de 4 points, barres à fines stries en diagonale. Les pièces
-- lisent le thème en cours (CUI:GetTheme) et se souviennent de ce qu'elles ont dessiné : un futur choix
-- de thème n'aura qu'à appeler CUI:ApplyTheme() pour tout repeindre.
--
--   local p = CUI:CreatePanel(cadre, options)   -- fond, double liseré, ombre (options : radius, fill,
--                                                -- shadow = false, inset : nombre ou { x, y })
--   p.border:SetColor(couleur)                   -- liseré extérieur (cible, menace, affaiblissement...)
--   p:SetShown(bool), p:SetFillColor(couleur)
--   CUI:SetBarTexture(barre, clé)                -- texture de barre ; « striee » : couleur unie + stries
--                                                -- répétées (leur taille ne dépend pas de la barre)
--   p:SetOpacity(a)                              -- fond et ombre plus légers, liseré net
--   p:SetShadowShown(bool)                       -- ombre ou non (bouton seul / sur un panneau)
--   CUI:CreateTipPanel(cadre)                    -- cadre d'une infobulle ou d'un menu
--   CUI:CreateStripes(parent, texture)           -- stries sur une texture placée à la main
--   CUI:GetTheme(), CUI:ApplyTheme()
local _, CUI = ...
local C = CUI.Colors

local function hex(code)
    return { tonumber(code:sub(1, 2), 16) / 255, tonumber(code:sub(3, 4), 16) / 255,
             tonumber(code:sub(5, 6), 16) / 255, 1 }
end

-- Thèmes -----------------------------------------------------------------------------------------

CUI.Themes = {
    givre = {
        name = "THEME_GIVRE",
        panneau = hex("1A1E26"),      -- fond des cadres et fenêtres
        lisereSombre = hex("0D0F14"), -- liseré extérieur
        lisereClair = 0.05,           -- liseré intérieur : le fond éclairci de 5 %
        case = hex("101218"),         -- fond des cases (sacs, barres d'actions)
        fenetre = hex("1A1E26"),      -- fond de la fenêtre de CœurUI
        colonne = hex("151820"),      -- sa colonne de gauche
        carte = hex("1F232C"),        -- une carte, une ligne de liste
        carteActive = hex("252A34"),  -- une carte active, la ligne choisie
        rayon = 4,                    -- coins (cases : rayon - 1)
        ombre = 0.55,                 -- opacité de l'ombre douce (0 : pas d'ombre)
        stries = 0.16,                -- opacité des stries des barres
        texture = "striee",           -- texture de barre par défaut
    },
}
local DEFAULT_THEME = "givre"

function CUI:GetTheme()
    local key = self.db and self.db.ui and self.db.ui.theme
    return self.Themes[key] or self.Themes[DEFAULT_THEME]
end

-- Couleurs du thème en cours, aussi dans CUI.Colors (lues au moment de dessiner).
local function copyColors(theme)
    C.panneau, C.lisereSombre, C.case = theme.panneau, theme.lisereSombre, theme.case
    C.fenetre, C.colonne, C.carte, C.ligne = theme.fenetre, theme.colonne, theme.carte, theme.carteActive
end
copyColors(CUI.Themes[DEFAULT_THEME])

-- Cadres ---------------------------------------------------------------------------------------

local function lighten(c, k)
    return { c[1] + (1 - c[1]) * k, c[2] + (1 - c[2]) * k, c[3] + (1 - c[3]) * k, c[4] or 1 }
end

local SHADOW = CUI.MEDIA .. "Ombre"
local WHITE = "Interface\\Buttons\\WHITE8x8"
local SHADOW_OUT = 10   -- l'ombre déborde de 10 points autour du cadre
local SHADOW_SLICE = 24 -- marges des neuf morceaux de la texture d'ombre

local panels = setmetatable({}, { __mode = "k" }) -- cadres dessinés (repeints par ApplyTheme)
local bars = setmetatable({}, { __mode = "k" })   -- barres striées

-- Liseré en vrai contour (cadre à fond transparent) : quatre coins en quart d'anneau (Contour2 à 4) et
-- quatre traits de 1 point. Les liserés pleins (rectangles arrondis posés sous le fond) se verraient à
-- travers un fond transparent.
local Outline = {}
Outline.__index = Outline

function Outline:SetColor(c)
    for _, t in ipairs(self.parts) do t:SetVertexColor(c[1], c[2], c[3], c[4] or 1) end
end

function Outline:SetShown(shown)
    for _, t in ipairs(self.parts) do t:SetShown(shown) end
end

-- Retrait d'un cadre : un nombre (le même partout) ou { x, y } (côtés, haut et bas).
local function insetXY(inset)
    if type(inset) == "table" then return inset[1] or 0, inset[2] or 0 end
    return inset or 0, inset or 0
end

local function createOutline(parent, radius, ix, iy, sublevel)
    local o = setmetatable({ parts = {} }, Outline)
    local r = math.max(2, math.min(4, radius))
    local file = CUI.MEDIA .. "Contour" .. r
    for _, c in ipairs({ { "TOPLEFT", ix, -iy, 0, 1, 0, 1 }, { "TOPRIGHT", -ix, -iy, 1, 0, 0, 1 },
                         { "BOTTOMLEFT", ix, iy, 0, 1, 1, 0 }, { "BOTTOMRIGHT", -ix, iy, 1, 0, 1, 0 } }) do
        local t = parent:CreateTexture(nil, "BACKGROUND", nil, sublevel)
        t:SetTexture(file)
        t:SetTexCoord(c[4], c[5], c[6], c[7])
        t:SetSize(r, r)
        t:SetPoint(c[1], c[2], c[3])
        o.parts[#o.parts + 1] = t
    end
    local function line(p1, x1, y1, p2, x2, y2, w, h)
        local t = parent:CreateTexture(nil, "BACKGROUND", nil, sublevel)
        t:SetTexture(WHITE)
        t:SetPoint(p1, x1, y1)
        t:SetPoint(p2, x2, y2)
        if w then t:SetWidth(w) else t:SetHeight(h) end
        o.parts[#o.parts + 1] = t
    end
    line("TOPLEFT", ix + r, -iy, "TOPRIGHT", -ix - r, -iy, nil, 1)
    line("BOTTOMLEFT", ix + r, iy, "BOTTOMRIGHT", -ix - r, iy, nil, 1)
    line("TOPLEFT", ix, -iy - r, "BOTTOMLEFT", ix, iy + r, 1, nil)
    line("TOPRIGHT", -ix, -iy - r, "BOTTOMRIGHT", -ix, iy + r, 1, nil)
    return o
end

local Panel = {}
Panel.__index = Panel

function Panel:SetShown(shown)
    local translucent = self.edge ~= nil and self.edge.on
    self.border:SetShown(shown and not translucent)
    self.ring:SetShown(shown and not translucent)
    if self.edge then
        self.edge:SetShown(shown and translucent)
        self.edgeIn:SetShown(shown and translucent)
    end
    self.fill:SetShown(shown)
    -- Fond transparent : pas d'ombre (elle se verrait à travers le fond et l'assombrirait).
    if self.shadow then
        self.shadow:SetShown(shown and not self.noShadow and not translucent and CUI:GetTheme().ombre > 0)
    end
end

-- Opacité du fond (0 à 1) : le fond s'éclaircit, le liseré reste net (le liseré intérieur garde au
-- moins 60 pour cent). Fond transparent : les liserés deviennent de vrais contours et l'ombre disparaît,
-- pour que l'opacité réglée soit celle qu'on voit.
function Panel:SetOpacity(a)
    self.opacity = a
    local theme = CUI:GetTheme()
    local f = self.customFill or theme.panneau
    local ring = lighten(f, theme.lisereClair)
    local translucent = a < 0.999
    if translucent and not self.edge then
        local parent, radius, ix, iy = self.parent, self.radius, self.ix, self.iy
        self.edge = createOutline(parent, radius, ix, iy, -7)
        self.edgeIn = createOutline(parent, math.max(2, radius - 1), ix + 1, iy + 1, -6)
    end
    local shown = self.fill.parts[1]:IsShown()
    if self.edge then
        self.edge.on = translucent
        self.edge:SetColor(theme.lisereSombre)
        ring[4] = math.max(a, 0.6)
        self.edgeIn:SetColor(ring)
    end
    self.ring:SetColor(lighten(f, theme.lisereClair))
    self.fill:SetColor({ f[1], f[2], f[3], a })
    if self.shadow then self.shadow:SetVertexColor(0, 0, 0, theme.ombre) end
    self:SetShown(shown)
end

-- Ombre montrée ou non (un bouton posé seul a la sienne, un bouton posé sur un panneau non).
function Panel:SetShadowShown(shown)
    self.noShadow = not shown
    if self.shadow then
        local translucent = self.edge ~= nil and self.edge.on
        self.shadow:SetShown(shown and not translucent and CUI:GetTheme().ombre > 0 and self.fill.parts[1]:IsShown())
    end
end

function Panel:SetFillColor(color)
    self.customFill = color
    self.fill:SetColor(color)
    self.ring:SetColor(lighten(color, CUI:GetTheme().lisereClair))
end

-- Couleurs et ombre selon le thème en cours (le liseré extérieur garde la couleur qu'un module lui a
-- donnée : cible, menace...).
function Panel:Paint()
    local theme = CUI:GetTheme()
    local fill = self.customFill or theme.panneau
    self.fill:SetColor(fill)
    self.ring:SetColor(lighten(fill, theme.lisereClair))
    if self.shadow then
        self.shadow:SetVertexColor(0, 0, 0, theme.ombre)
        self.shadow:SetShown(theme.ombre > 0 and not self.noShadow and self.fill.parts[1]:IsShown())
    end
    if self.opacity then self:SetOpacity(self.opacity) end
end

function CUI:CreatePanel(parent, opts)
    opts = opts or {}
    local theme = self:GetTheme()
    local radius = opts.radius or theme.rayon
    local ix, iy = insetXY(opts.inset)
    local p = setmetatable({ customFill = opts.fill, parent = parent, radius = radius, ix = ix, iy = iy }, Panel)
    if opts.shadow ~= false then
        local t = parent:CreateTexture(nil, "BACKGROUND", nil, -8)
        t:SetTexture(SHADOW)
        t:SetPoint("TOPLEFT", -SHADOW_OUT + ix, SHADOW_OUT - iy)
        t:SetPoint("BOTTOMRIGHT", SHADOW_OUT - ix, -SHADOW_OUT + iy)
        -- Neuf morceaux : coins gardés, bords et centre étirés (sinon l'ombre se déforme).
        if t.SetTextureSliceMargins then
            pcall(t.SetTextureSliceMargins, t, SHADOW_SLICE, SHADOW_SLICE, SHADOW_SLICE, SHADOW_SLICE)
            if t.SetTextureSliceMode and _G.Enum and _G.Enum.UITextureSliceMode then
                pcall(t.SetTextureSliceMode, t, _G.Enum.UITextureSliceMode.Stretched)
            end
        end
        p.shadow = t
    end
    p.border = self:CreateRoundRect(parent, radius, theme.lisereSombre, { ix, iy }, "BACKGROUND", -7)
    p.ring = self:CreateRoundRect(parent, math.max(1, radius - 1), theme.panneau, { ix + 1, iy + 1 }, "BACKGROUND", -6)
    p.fill = self:CreateRoundRect(parent, math.max(1, radius - 2), theme.panneau, { ix + 2, iy + 2 }, "BACKGROUND", -5)
    p:Paint()
    panels[p] = true
    return p
end

-- Cadre de toutes les infobulles et de tous les menus (CœurUI et jeu) : fond du thème presque opaque.
function CUI:CreateTipPanel(parent)
    local f = self:GetTheme().panneau
    return self:CreatePanel(parent, { fill = { f[1], f[2], f[3], 0.97 } })
end

-- Barres ---------------------------------------------------------------------------------------

local STRIPES = CUI.MEDIA .. "Stries"

-- Texture d'une barre (clé de CUI:BarTextureOptions) ; « striee » : couleur unie et stries par-dessus
-- la partie remplie. Les stries suivent la barre (vide, pleine) sans changer de taille.
function CUI:SetBarTexture(bar, key)
    local striped = key == "striee"
    bar:SetStatusBarTexture(striped and WHITE or self:GetBarTexture(key))
    local fill = bar:GetStatusBarTexture()
    if striped and not bar.cuiStripes then
        local t = bar:CreateTexture(nil, "ARTWORK", nil, 2)
        t:SetTexture(STRIPES, "REPEAT", "REPEAT")
        t:SetHorizTile(true)
        t:SetVertTile(true)
        bar.cuiStripes = t
    end
    if bar.cuiStripes then
        bar.cuiStripes:ClearAllPoints()
        if striped and fill then
            bar.cuiStripes:SetAllPoints(fill)
            bar.cuiStripes:SetVertexColor(1, 1, 1, self:GetTheme().stries)
            bar.cuiStripes:Show()
            bars[bar] = true
        else
            bar.cuiStripes:Hide()
        end
    end
end

-- Stries posées sur une texture déjà placée (segment de barre fait à la main) : à montrer et cacher
-- avec elle.
function CUI:CreateStripes(parent, anchor, sublevel)
    local t = parent:CreateTexture(nil, "ARTWORK", nil, sublevel or 7)
    t:SetTexture(STRIPES, "REPEAT", "REPEAT")
    t:SetHorizTile(true)
    t:SetVertTile(true)
    t:SetAllPoints(anchor)
    t:SetVertexColor(1, 1, 1, self:GetTheme().stries)
    bars[t] = true
    return t
end

-- Couleur des survols et boutons (« Général ») : l'or de CœurUI ou la couleur de la classe du joueur.
-- Posée au chargement (une partie des couleurs est retenue en dessinant : un /reload l'applique).
-- L'or de la marque (« Cœur » du titre) ne change pas.
C.marque = C.or_
function CUI:ApplyAccent()
    local choice = self.db and self.db.general and self.db.general.accent or "or"
    self.appliedAccent = choice
    if choice ~= "classe" then return end
    local _, classFile = _G.UnitClass("player")
    local c = classFile and _G.C_ClassColor and _G.C_ClassColor.GetClassColor and _G.C_ClassColor.GetClassColor(classFile)
    if not c and classFile and _G.RAID_CLASS_COLORS then c = _G.RAID_CLASS_COLORS[classFile] end
    if not c then return end
    local base = { c.r, c.g, c.b, 1 }
    C.or_ = base
    C.orClair = lighten(base, 0.25)
    C.railActif = { c.r * 0.4, c.g * 0.4, c.b * 0.4, 1 } -- fond d'un interrupteur activé
end

-- Thème changé : tout ce qui a été dessiné se repeint (les modules redessinent le reste).
function CUI:ApplyTheme()
    local theme = self:GetTheme()
    copyColors(theme)
    for p in pairs(panels) do p:Paint() end
    for bar in pairs(bars) do
        local t = bar.cuiStripes or (bar.GetObjectType and bar:GetObjectType() == "Texture" and bar)
        if t then t:SetVertexColor(1, 1, 1, theme.stries) end
    end
end
