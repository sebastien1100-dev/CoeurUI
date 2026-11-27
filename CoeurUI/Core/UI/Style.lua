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
--                                                -- shadow = false, inset)
--   p.border:SetColor(couleur)                   -- liseré extérieur (cible, menace, affaiblissement...)
--   p:SetShown(bool), p:SetFillColor(couleur)
--   CUI:SetBarTexture(barre, clé)                -- texture de barre ; « striee » : couleur unie + stries
--                                                -- répétées (leur taille ne dépend pas de la barre)
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
end
copyColors(CUI.Themes[DEFAULT_THEME])

-- Cadres ---------------------------------------------------------------------------------------

local function lighten(c, k)
    return { c[1] + (1 - c[1]) * k, c[2] + (1 - c[2]) * k, c[3] + (1 - c[3]) * k, c[4] or 1 }
end

local SHADOW = CUI.MEDIA .. "Ombre"
local SHADOW_OUT = 10   -- l'ombre déborde de 10 points autour du cadre
local SHADOW_SLICE = 24 -- marges des neuf morceaux de la texture d'ombre

local panels = setmetatable({}, { __mode = "k" }) -- cadres dessinés (repeints par ApplyTheme)
local bars = setmetatable({}, { __mode = "k" })   -- barres striées

local Panel = {}
Panel.__index = Panel

function Panel:SetShown(shown)
    self.border:SetShown(shown)
    self.ring:SetShown(shown)
    self.fill:SetShown(shown)
    if self.shadow then self.shadow:SetShown(shown and CUI:GetTheme().ombre > 0) end
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
        self.shadow:SetShown(theme.ombre > 0 and self.fill.parts[1]:IsShown())
    end
end

function CUI:CreatePanel(parent, opts)
    opts = opts or {}
    local theme = self:GetTheme()
    local radius = opts.radius or theme.rayon
    local inset = opts.inset or 0
    local p = setmetatable({ customFill = opts.fill }, Panel)
    if opts.shadow ~= false then
        local t = parent:CreateTexture(nil, "BACKGROUND", nil, -8)
        t:SetTexture(SHADOW)
        t:SetPoint("TOPLEFT", -SHADOW_OUT + inset, SHADOW_OUT - inset)
        t:SetPoint("BOTTOMRIGHT", SHADOW_OUT - inset, -SHADOW_OUT + inset)
        -- Neuf morceaux : coins gardés, bords et centre étirés (sinon l'ombre se déforme).
        if t.SetTextureSliceMargins then
            pcall(t.SetTextureSliceMargins, t, SHADOW_SLICE, SHADOW_SLICE, SHADOW_SLICE, SHADOW_SLICE)
            if t.SetTextureSliceMode and _G.Enum and _G.Enum.UITextureSliceMode then
                pcall(t.SetTextureSliceMode, t, _G.Enum.UITextureSliceMode.Stretched)
            end
        end
        p.shadow = t
    end
    p.border = self:CreateRoundRect(parent, radius, theme.lisereSombre, inset, "BACKGROUND", -7)
    p.ring = self:CreateRoundRect(parent, math.max(1, radius - 1), theme.panneau, inset + 1, "BACKGROUND", -6)
    p.fill = self:CreateRoundRect(parent, math.max(1, radius - 2), theme.panneau, inset + 2, "BACKGROUND", -5)
    p:Paint()
    panels[p] = true
    return p
end

-- Barres ---------------------------------------------------------------------------------------

local STRIPES = CUI.MEDIA .. "Stries"
local WHITE = "Interface\\Buttons\\WHITE8x8"

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

-- Thème changé : tout ce qui a été dessiné se repeint (les modules redessinent le reste).
function CUI:ApplyTheme()
    local theme = self:GetTheme()
    copyColors(theme)
    for p in pairs(panels) do p:Paint() end
    for bar in pairs(bars) do
        if bar.cuiStripes then bar.cuiStripes:SetVertexColor(1, 1, 1, theme.stries) end
    end
end
