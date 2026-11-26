-- Textures de barre et polices à la disposition des modules (choix dans leurs pages de réglages).
--   CUI:GetBarTexture(clé) » fichier ; CUI:BarTextureOptions() » options d'un menu déroulant
--   CUI:GetFontFile(clé)   » fichier ; CUI:FontOptions()       » options d'un menu déroulant
-- Seulement des fichiers du jeu ou de CœurUI (Media/). Une police d'ailleurs demanderait une licence libre.
local _, CUI = ...
local L = CUI.L

local BAR_TEXTURES = {
    { key = "unie", name = "TEXTURE_UNIE", file = "Interface\\Buttons\\WHITE8x8" },
    { key = "lisse", name = "TEXTURE_LISSE", file = CUI.MEDIA .. "BarreLisse" },
    { key = "jeu", name = "TEXTURE_JEU", file = "Interface\\TargetingFrame\\UI-StatusBar" },
    { key = "raid", name = "TEXTURE_RAID", file = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill" },
}
local DEFAULT_TEXTURE = "lisse"

local FONTS = {
    { key = "friz", name = "Friz Quadrata", file = "Fonts\\FRIZQT__.TTF" },
    { key = "arialn", name = "Arial Narrow", file = "Fonts\\ARIALN.TTF" },
    { key = "morpheus", name = "Morpheus", file = "Fonts\\MORPHEUS.TTF" },
    { key = "skurri", name = "Skurri", file = "Fonts\\SKURRI.TTF" },
}
local DEFAULT_FONT = "friz"

local function find(list, key, default)
    for _, entry in ipairs(list) do
        if entry.key == key then
            return entry
        end
    end
    if default then
        return find(list, default)
    end
    return list[1]
end

function CUI:GetBarTexture(key)
    return find(BAR_TEXTURES, key, DEFAULT_TEXTURE).file
end

function CUI:GetFontFile(key)
    return find(FONTS, key, DEFAULT_FONT).file
end

-- Options pour un réglage « dropdown » : chaque texture montre son échantillon dans la liste.
function CUI:BarTextureOptions()
    local list = {}
    for i, entry in ipairs(BAR_TEXTURES) do
        list[i] = { value = entry.key, text = entry.name, texture = entry.file }
    end
    return list
end

function CUI:FontOptions()
    local list = {}
    for i, entry in ipairs(FONTS) do
        list[i] = { value = entry.key, text = L.POLICE_JEU:format(entry.name) }
    end
    return list
end
