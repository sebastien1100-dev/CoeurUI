-- Thème : couleurs, polices et petits outils de texte communs à toutes les fenêtres.
-- Les couleurs viennent de l'icône (tools/source/Icônes@2x.png) et de la maquette validée.
local addonName, CUI = ...

CUI.MEDIA = "Interface\\AddOns\\" .. addonName .. "\\Media\\"

local function hex(code, alpha)
    return {
        tonumber(code:sub(1, 2), 16) / 255,
        tonumber(code:sub(3, 4), 16) / 255,
        tonumber(code:sub(5, 6), 16) / 255,
        alpha or 1,
    }
end

-- Couleurs { r, g, b, a } (de 0 à 1).
CUI.Colors = {
    or_ = hex("D9AE5B"),            -- « or » est un mot réservé de Lua
    orClair = hex("E6C27A"),
    coeur = hex("D2465A"),
    graphite = hex("2A2D34"),
    graphiteClair = hex("343842"),
    graphiteSombre = hex("1F2228"),
    fenetre = hex("1B1E24"),
    fond = hex("14161A"),
    ligne = hex("21242B"),          -- ligne active d'une liste
    bordure = hex("4A4E58"),
    bordureDiscrete = hex("3A3E47"),
    texte = hex("F2F2F2"),
    texteDiscret = hex("9A9DA5"),
    texteSecondaire = hex("C4C6CC"),  -- sous-onglets de la colonne de gauche
    colonne = hex("16181D"),          -- fond de la colonne de gauche
    texteDesactive = hex("8A8D95"),
    desactiveFond = hex("22252B"),
    desactiveBordure = hex("33363E"),
    railActif = hex("5A4A2A"),      -- fond d'un interrupteur activé
    actif = hex("7FC98A"),
    erreur = hex("E06B7C"),
    echantillon = hex("C69B6D"),     -- couleur des échantillons de texture de barre
    ombre = { 0, 0, 0, 0.55 },
}

-- Code couleur pour les textes : "|cffRRGGBB".
function CUI:ColorCode(color)
    local function byte(v) return math.floor(v * 255 + 0.5) end
    return ("|cff%02x%02x%02x"):format(byte(color[1]), byte(color[2]), byte(color[3]))
end

-- Polices : celle du jeu (Windows-1252 seulement), en trois tailles.
local function makeFont(name, size)
    local font = _G.CreateFont(name)
    font:SetFont(_G.STANDARD_TEXT_FONT, size, "")
    font:SetShadowColor(0, 0, 0, 0.6)
    font:SetShadowOffset(1, -1)
    return font
end

CUI.Fonts = {
    grand = makeFont("CoeurUIPoliceGrande", 17),
    titre = makeFont("CoeurUIPoliceTitre", 14),
    normal = makeFont("CoeurUIPoliceNormale", 12),
    petit = makeFont("CoeurUIPolicePetite", 11),
}

-- Crée un texte avec la police et la couleur du thème.
--   font : "grand", "titre", "normal" ou "petit" ; color : une clé de CUI.Colors
function CUI:CreateText(parent, font, color, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    fs:SetFontObject(self.Fonts[font or "normal"])
    fs:SetTextColor(unpack(self.Colors[color or "texte"]))
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    return fs
end
