-- Module « Bulles de discussion » (choix du joueur le 27/11/2026) : les bulles au-dessus des personnages
-- au style des infobulles de CœurUI (style « Givre », planche « Bulles de discussion ») : fond ardoise,
-- double liseré très discret, coins arrondis, pas d'or ; la pointe du jeu (dessin sombre au bord doré)
-- est remplacée par la nôtre, au même liseré sombre (Media/Pointe.tga, tools/generer_pointe.py). Réglages : taille du texte,
-- opacité du fond, couleur du texte selon le canal (sinon gris clair).
-- Dans les donjons et les raids, le jeu verrouille les bulles (cadres interdits) : elles restent les
-- siennes. Le jeu ne prévient pas quand une bulle apparaît : on les regarde juste après chaque message
-- qui peut en faire une (dire, crier, PNJ, groupe).
-- Couper le module demande un /reload.
local _, CUI = ...
local C = CUI.Colors

local M = CUI:RegisterModule({
    key = "Bulles",
    name = "BUL_NOM",
    description = "BUL_DESC",
    defaultEnabled = false,
    needsReload = true,
    defaults = { taille = 12, opacite = 95, couleurs = true },
    settings = {
        { type = "section", text = "BUL_AFFICHAGE" },
        { type = "slider", key = "taille", label = "BUL_TAILLE", min = 8, max = 20, step = 1, format = "%d pt" },
        { type = "slider", key = "opacite", label = "BUL_OPACITE", min = 30, max = 100, step = 5, format = "%d %%" },
        { type = "toggle", key = "couleurs", label = "BUL_COULEURS", description = "BUL_COULEURS_NOTE" },
    },
})

-- Messages qui peuvent faire apparaître une bulle.
local EVENTS = { "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL",
                 "CHAT_MSG_MONSTER_PARTY", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER" }

local RETRAIT = 4 -- notre cadre, en retrait de 4 points en haut et en bas de celui du jeu

local function textOf(frame)
    if frame.String then return frame.String end
    for _, region in ipairs({ frame:GetRegions() }) do
        if region:GetObjectType() == "FontString" then return region end
    end
end

-- Habillage d'une bulle (une fois : le jeu réutilise ses bulles).
local function skin(frame)
    if frame.cuiSkinned then return end
    -- Tout ce que le jeu dessine (fond, bords, coins, pointe), sauf le texte.
    for _, region in ipairs({ frame:GetRegions() }) do
        if region:GetObjectType() == "Texture" then region:SetAlpha(0) end
    end
    for _, child in ipairs({ frame:GetChildren() }) do
        child:SetAlpha(0)
    end
    -- Un peu moins haute que la bulle du jeu (son cadre laisse beaucoup de marge au-dessus et en dessous).
    frame.cuiPanel = CUI:CreatePanel(frame, { shadow = false, inset = { 0, RETRAIT } })
    -- Pointe : un triangle sombre (le liseré) et, par-dessus, un triangle à la couleur du fond, un point
    -- plus haut pour couvrir le liseré du bas de la bulle à cet endroit.
    local edge = frame:CreateTexture(nil, "BACKGROUND", nil, -4)
    edge:SetTexture(CUI.MEDIA .. "Pointe")
    edge:SetSize(16, 8)
    edge:SetPoint("TOP", frame, "BOTTOM", 0, RETRAIT)
    local c = C.lisereSombre
    edge:SetVertexColor(c[1], c[2], c[3], 1)
    local fill = frame:CreateTexture(nil, "BACKGROUND", nil, -3)
    fill:SetTexture(CUI.MEDIA .. "Pointe")
    fill:SetSize(14, 7)
    fill:SetPoint("TOP", frame, "BOTTOM", 0, RETRAIT + 1)
    frame.cuiTail = fill
    frame.cuiSkinned = true
end

-- Réglages appliqués à chaque passage (le jeu remet sa police et sa couleur à chaque message).
local function apply(frame)
    local s = M.db
    local a = s.opacite / 100
    frame.cuiPanel:SetOpacity(a) -- le fond suit le réglage, le liseré reste net
    local f = C.panneau
    frame.cuiTail:SetVertexColor(f[1], f[2], f[3], a)
    local text = textOf(frame)
    if text then
        text:SetFont(CUI:GetFont(), s.taille, "")
        if not s.couleurs then
            local c = C.texteSecondaire
            text:SetTextColor(c[1], c[2], c[3])
        end
    end
end

local function scan()
    local CB = _G.C_ChatBubbles
    if not (CB and CB.GetAllChatBubbles) then return end
    for _, bubble in pairs(CB.GetAllChatBubbles(false)) do
        if not bubble:IsForbidden() then
            local frame = bubble:GetChildren()
            if frame and not frame:IsForbidden() then
                skin(frame)
                apply(frame)
            end
        end
    end
end

local function safeScan()
    CUI:SafeCall(CUI:Tr("BUL_NOM"), scan)
end

-- Une bulle apparaît l'image suivant son message ; un deuxième regard un peu plus tard pour les lentes.
local function onMessage()
    M:After(0, safeScan)
    M:After(0.2, safeScan)
end

function M:OnEnable()
    for _, event in ipairs(EVENTS) do
        pcall(self.On, self, event, onMessage)
    end
    safeScan()
end

-- Coupé : l'habillage reste jusqu'au /reload (needsReload).
function M:OnDisable()
end

function M:OnSettingChanged()
    safeScan()
end

function M:OnFontChanged()
    safeScan()
end
