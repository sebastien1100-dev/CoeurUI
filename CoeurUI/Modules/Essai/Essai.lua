-- Module « Essai » : sert seulement à tester le noyau. À retirer avant la première publication.
-- Il écrit des messages, suit un évènement, lance une minuterie et change un réglage du jeu
-- (plaques des PNJ amis), pour vérifier que tout est bien rendu quand on le coupe.
-- Ses deux sous-modules servent à tester la fenêtre principale (tiroir, pages, réglages).
-- Ses textes sont des clés des fichiers de Locales/ (section « Essai »), traduites à l'affichage.
local _, CUI = ...
local L = CUI.L

local M = CUI:RegisterModule({
    key = "Essai",
    name = "ESSAI_NOM",
    description = "ESSAI_DESC",
    defaultEnabled = false,
    defaults = {
        compteur = 0,
        messages = { demarrage = true, cible = "court" },
        minuterie = { delai = 5 },
    },
    subs = {
        {
            key = "messages", name = "ESSAI_MESSAGES", description = "ESSAI_MESSAGES_DESC",
            settings = {
                { type = "toggle", key = "demarrage", label = "ESSAI_DEMARRAGE", description = "ESSAI_DEMARRAGE_DESC" },
                { type = "dropdown", key = "cible", label = "ESSAI_CIBLE", options = {
                    { value = "court", text = "ESSAI_COURT" },
                    { value = "long", text = "ESSAI_LONG" },
                    { value = "aucun", text = "ESSAI_AUCUN" },
                } },
            },
        },
        {
            key = "minuterie", name = "ESSAI_MINUTERIE", description = "ESSAI_MINUTERIE_DESC",
            settings = {
                { type = "slider", key = "delai", label = "ESSAI_DELAI", min = 1, max = 10, step = 1, format = "%d s" },
            },
        },
    },
})

local CIBLE = {
    court = "ESSAI_CIBLE_COURT",
    long = "ESSAI_CIBLE_LONG",
}

function M:OnEnable()
    self.db.compteur = self.db.compteur + 1
    if self.db.messages.demarrage then
        CUI:Print(L.ESSAI_DEMARRE:format(self.db.compteur))
    end

    self:On("PLAYER_TARGET_CHANGED", function()
        local key = CIBLE[self.db.messages.cible]
        if key then
            CUI:Print(L[key])
        end
    end)

    local delai = self.db.minuterie.delai
    self:After(delai, function()
        CUI:Print(L.ESSAI_MINUTERIE_FIN:format(delai))
    end)

    self:SetCVar("nameplateShowFriendlyNPCs", "1")
end

function M:OnDisable()
    CUI:Print(L.ESSAI_ARRETE)
end

function M:OnSettingChanged(key, value, subKey)
    CUI:Print(L.ESSAI_REGLAGE:format(tostring(subKey), key, tostring(value)))
end
