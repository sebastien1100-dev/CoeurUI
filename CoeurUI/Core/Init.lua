-- CœurUI : point de départ. Crée la table commune, les langues et les petits outils de base.
local addonName, CUI = ...
_G.CoeurUI = CUI

CUI.name = addonName
CUI.displayName = "CœurUI"
CUI.version = _G.C_AddOns.GetAddOnMetadata(addonName, "Version") or "?"

-- Langues ---------------------------------------------------------------------------------
-- Chaque fichier de Locales/ s'inscrit avec :
--   local L = CoeurUI:NewLocale("deDE", "Deutsch")   -- code du jeu, nom de la langue dans sa langue
--   L.CLE = "texte"
-- Pour ajouter une langue : un fichier de plus dans Locales/ (et sa ligne dans le .toc), rien d'autre.
-- Un texte absent d'une langue est pris en anglais, puis en français (la langue d'origine, complète),
-- puis la clé elle-même s'affiche.
-- La langue est choisie au chargement de la sauvegarde (page « Paramètres ») ; un changement
-- s'applique après un /reload.

local locales = {}      -- code -> textes
local localeOrder = {}  -- { code = ..., name = ... } dans l'ordre du .toc
local current           -- textes de la langue utilisée (nil avant la sauvegarde : langue du jeu)
local FALLBACKS = { "enUS", "frFR" }

function CUI:NewLocale(code, nativeName)
    assert(not locales[code], "NewLocale : langue déjà déclarée : " .. tostring(code))
    local texts = {}
    locales[code] = texts
    localeOrder[#localeOrder + 1] = { code = code, name = nativeName }
    return texts
end

function CUI:GetLocales()
    return localeOrder
end

function CUI:GetLocaleName(code)
    for _, info in ipairs(localeOrder) do
        if info.code == code then
            return info.name
        end
    end
    return code
end

-- Choix enregistré (« auto » ou un code) » code de la langue réellement utilisée.
function CUI:ResolveLanguage(choice)
    if choice and choice ~= "auto" and locales[choice] then
        return choice
    end
    local game = _G.GetLocale()
    if locales[game] then
        return game
    end
    return "enUS"
end

-- Appelée une fois, au chargement de la sauvegarde.
function CUI:SetLanguage(choice)
    self.language = self:ResolveLanguage(choice)
    current = locales[self.language]
end

local function lookup(key)
    local texts = current or locales[CUI:ResolveLanguage("auto")]
    if texts and texts[key] ~= nil then
        return texts[key]
    end
    for _, code in ipairs(FALLBACKS) do
        texts = locales[code]
        if texts and texts[key] ~= nil then
            return texts[key]
        end
    end
end

-- Textes affichés : CUI.L.CLE. Toujours lus au moment de l'affichage (jamais gardés au chargement).
CUI.L = setmetatable({}, {
    __index = function(_, key)
        local value = lookup(key)
        if value == nil then
            return key
        end
        return value
    end,
    __newindex = function(_, key)
        error("CoeurUI.L : écrire " .. tostring(key) .. " dans la table de sa langue (CoeurUI:NewLocale)")
    end,
})

-- Traduit un texte donné par un module : une clé connue des fichiers de langue, sinon le texte tel quel.
function CUI:Tr(text)
    if type(text) ~= "string" then
        return text
    end
    local value = lookup(text)
    if type(value) == "string" then
        return value
    end
    return text
end

-- Outils ----------------------------------------------------------------------------------

local PREFIX = "|cffd9ae5bCœur|r|cfff2f2f2UI|r :"

-- Écrit un message dans la fenêtre de discussion, précédé du nom de l'addon.
function CUI:Print(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring((select(i, ...)))
    end
    _G.DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. " " .. table.concat(parts, " "))
end

-- Appelle fn sans laisser une erreur casser le reste de l'addon.
-- L'erreur est signalée dans la discussion et transmise au gestionnaire d'erreurs du jeu.
function CUI:SafeCall(label, fn, ...)
    if not fn then return true end
    local ok, err = pcall(fn, ...)
    if not ok then
        self:Print(self.L.ERREUR:format(tostring(label)))
        _G.geterrorhandler()(err)
    end
    return ok
end
