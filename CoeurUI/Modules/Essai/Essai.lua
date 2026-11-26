-- Module « Essai » : sert seulement à tester le noyau. À retirer avant la première publication.
-- Il écrit des messages, suit un évènement, lance une minuterie et change un réglage du jeu
-- (plaques des PNJ amis), pour vérifier que tout est bien rendu quand on le coupe.
-- Ses réglages servent à tester le panneau (curseur, menu déroulant, interrupteur).
local _, CUI = ...

local M = CUI:RegisterModule({
    key = "Essai",
    name = "Essai",
    description = "Module de test du noyau (développement seulement).",
    defaultEnabled = false,
    defaults = { compteur = 0, messageDemarrage = true, cible = "court", delai = 5 },
    settings = {
        { type = "section", text = "MESSAGES" },
        { type = "toggle", key = "messageDemarrage", label = "Message au démarrage",
          description = "Écrit « Essai : démarré » dans la discussion quand le module démarre." },
        { type = "dropdown", key = "cible", label = "Message quand la cible change", options = {
            { value = "court", text = "Court" },
            { value = "long", text = "Long" },
            { value = "aucun", text = "Aucun" },
        } },
        { type = "section", text = "MINUTERIE" },
        { type = "slider", key = "delai", label = "Délai de la minuterie", min = 1, max = 10, step = 1, format = "%d s" },
    },
})

local CIBLE = {
    court = "Essai : cible changée.",
    long = "Essai : vous avez changé de cible (message long).",
}

function M:OnEnable()
    self.db.compteur = self.db.compteur + 1
    if self.db.messageDemarrage then
        CUI:Print(("Essai : démarré (%d fois depuis la dernière remise à zéro)."):format(self.db.compteur))
    end

    self:On("PLAYER_TARGET_CHANGED", function()
        local text = CIBLE[self.db.cible]
        if text then
            CUI:Print(text)
        end
    end)

    local delai = self.db.delai
    self:After(delai, function()
        CUI:Print(("Essai : minuterie de %d s terminée."):format(delai))
    end)

    self:SetCVar("nameplateShowFriendlyNPCs", "1")
end

function M:OnDisable()
    CUI:Print("Essai : arrêté.")
end

function M:OnSettingChanged(key, value)
    CUI:Print(("Essai : réglage « %s » = %s."):format(key, tostring(value)))
end
