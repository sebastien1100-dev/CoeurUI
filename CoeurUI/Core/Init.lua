-- CœurUI : point de départ. Crée la table commune et les petits outils de base.
local addonName, CUI = ...
_G.CoeurUI = CUI

CUI.name = addonName
CUI.displayName = "CœurUI"
CUI.version = _G.C_AddOns.GetAddOnMetadata(addonName, "Version") or "?"

-- Textes affichés (remplis par Locales/frFR.lua). Une clé absente s'affiche telle quelle
-- au lieu de provoquer une erreur.
CUI.L = setmetatable({}, { __index = function(_, key) return key end })

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
