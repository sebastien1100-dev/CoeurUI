-- Bouton de minicarte (C + cœur), au bord de la minicarte. Paramètre général, page « Paramètres ».
-- Clic : ouvre ou ferme la fenêtre de CœurUI. Glisser : le déplace autour de la minicarte.
-- Rien n'est créé tant que le bouton n'est pas demandé ; décoché, il est caché tout de suite.
local _, CUI = ...
local L = CUI.L

local TAILLE = 32
local DEBORD = 8 -- le centre du bouton dépasse du bord de la minicarte d'autant

local button

-- Forme de la minicarte : certains addons la rendent carrée et le signalent par GetMinimapShape().
local function forme()
    if type(_G.GetMinimapShape) == "function" then
        local ok, shape = pcall(_G.GetMinimapShape)
        if ok and shape == "SQUARE" then
            return "SQUARE"
        end
    end
    return "ROUND"
end

local function placer()
    local minimap = _G.Minimap
    local angle = math.rad(CUI:GetGeneral("angleMinicarte") or 200)
    local x, y = math.cos(angle), math.sin(angle)
    if forme() == "SQUARE" then
        -- On pousse le point jusqu'au bord du carré.
        local k = 1 / math.max(math.abs(x), math.abs(y))
        x, y = x * k, y * k
    end
    local rx = minimap:GetWidth() / 2 + DEBORD
    local ry = minimap:GetHeight() / 2 + DEBORD
    button:ClearAllPoints()
    button:SetPoint("CENTER", minimap, "CENTER", x * rx, y * ry)
end

-- Pendant un glisser : l'angle suit le curseur.
local function suivreCurseur()
    local minimap = _G.Minimap
    local mx, my = minimap:GetCenter()
    if not mx then return end
    local scale = minimap:GetEffectiveScale()
    local cx, cy = _G.GetCursorPosition()
    cx, cy = cx / scale, cy / scale
    CUI.db.general.angleMinicarte = math.floor(math.deg(math.atan2(cy - my, cx - mx)) % 360 + 0.5)
    placer()
end

local function creer()
    local minimap = _G.Minimap
    button = _G.CreateFrame("Button", "CoeurUIBoutonMinicarte", minimap)
    button:SetSize(TAILLE, TAILLE)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(minimap:GetFrameLevel() + 8)

    -- La texture a 4 px transparents autour du rond (sur 64), pour les addons de minicarte qui
    -- rognent les bords des icônes en les rangeant. Ici, on affiche le rond sans cette marge.
    -- button.icon : nom habituel, utilisé par ces addons pour trouver l'icône d'un bouton.
    local icone = button:CreateTexture(nil, "ARTWORK")
    icone:SetTexture(CUI.MEDIA .. "IconeMinicarte")
    icone:SetTexCoord(4 / 64, 60 / 64, 4 / 64, 60 / 64)
    icone:SetAllPoints()
    button.icon = icone

    -- Survol : léger voile clair (la couche HIGHLIGHT s'affiche toute seule au survol).
    local voile = button:CreateTexture(nil, "HIGHLIGHT")
    voile:SetTexture(CUI.MEDIA .. "Cercle")
    voile:SetAllPoints()
    voile:SetVertexColor(1, 1, 1, 0.15)

    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function()
        CUI:ToggleModulesScreen()
    end)
    button:SetScript("OnMouseDown", function() icone:SetVertexColor(0.8, 0.8, 0.8) end)
    button:SetScript("OnMouseUp", function() icone:SetVertexColor(1, 1, 1) end)
    button:SetScript("OnDragStart", function(self)
        CUI:HideTooltip(self)
        self:SetScript("OnUpdate", suivreCurseur)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        icone:SetVertexColor(1, 1, 1)
    end)
    button:SetScript("OnEnter", function(self)
        CUI:ShowTooltip(self, "CœurUI", L.MINICARTE_CLIC, L.MINICARTE_GLISSER)
    end)
    button:SetScript("OnLeave", function(self) CUI:HideTooltip(self) end)

    -- La minicarte peut changer de taille après coup (autre addon, réglages du jeu) : on suit.
    -- Simple crochet (HookScript), qui ne fait rien quand le bouton est caché.
    minimap:HookScript("OnSizeChanged", function()
        if button and button:IsShown() then
            placer()
        end
    end)
end

-- Montre ou cache le bouton selon le paramètre « Bouton de minicarte ».
function CUI:UpdateMinimapButton()
    if self:GetGeneral("boutonMinicarte") then
        if not button then
            creer()
        end
        placer()
        button:Show()
    elseif button then
        button:SetScript("OnUpdate", nil)
        button:Hide()
    end
end

CUI:On("PLAYER_LOGIN", "core:minicarte", function()
    CUI:Off("PLAYER_LOGIN", "core:minicarte")
    CUI:UpdateMinimapButton()
end)
