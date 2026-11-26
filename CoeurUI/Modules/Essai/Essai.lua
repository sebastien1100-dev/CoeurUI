-- Module « Essai » : sert seulement à tester le noyau. À retirer avant la première publication.
-- Il écrit des messages, suit un évènement, lance une minuterie et change un réglage du jeu
-- (plaques des PNJ amis), pour vérifier que tout est bien rendu quand on le coupe.
-- Ses deux sous-modules servent à tester la fenêtre principale (tiroir, pages, réglages).
local _, CUI = ...

local M = CUI:RegisterModule({
    key = "Essai",
    name = "Essai",
    description = "Module de test du noyau (développement seulement).",
    defaultEnabled = false,
    defaults = {
        compteur = 0,
        messages = { demarrage = true, cible = "court" },
        minuterie = { delai = 5 },
    },
    subs = {
        {
            key = "messages", name = "Messages",
            description = "Messages écrits par Essai dans la discussion.",
            settings = {
                { type = "toggle", key = "demarrage", label = "Message au démarrage",
                  description = "Écrit « Essai : démarré » dans la discussion quand le module démarre." },
                { type = "dropdown", key = "cible", label = "Message quand la cible change", options = {
                    { value = "court", text = "Court" },
                    { value = "long", text = "Long" },
                    { value = "aucun", text = "Aucun" },
                } },
            },
        },
        {
            key = "minuterie", name = "Minuterie",
            description = "Minuterie lancée au démarrage d'Essai.",
            settings = {
                { type = "slider", key = "delai", label = "Délai de la minuterie", min = 1, max = 10, step = 1,
                  format = "%d s" },
            },
        },
    },
})

local CIBLE = {
    court = "Essai : cible changée.",
    long = "Essai : vous avez changé de cible (message long).",
}

function M:OnEnable()
    self.db.compteur = self.db.compteur + 1
    if self.db.messages.demarrage then
        CUI:Print(("Essai : démarré (%d fois depuis la dernière remise à zéro)."):format(self.db.compteur))
    end

    self:On("PLAYER_TARGET_CHANGED", function()
        local text = CIBLE[self.db.messages.cible]
        if text then
            CUI:Print(text)
        end
    end)

    local delai = self.db.minuterie.delai
    self:After(delai, function()
        CUI:Print(("Essai : minuterie de %d s terminée."):format(delai))
    end)

    self:SetCVar("nameplateShowFriendlyNPCs", "1")
end

function M:OnDisable()
    CUI:Print("Essai : arrêté.")
end

function M:OnSettingChanged(key, value, subKey)
    CUI:Print(("Essai : réglage « %s / %s » = %s."):format(tostring(subKey), key, tostring(value)))
end
