-- Module « Essai » : sert seulement à tester le noyau. À retirer avant la première publication.
-- Il écrit des messages, suit un évènement, lance une minuterie et change un réglage du jeu
-- (plaques des PNJ amis), pour vérifier que tout est bien rendu quand on le coupe.
local _, CUI = ...

local M = CUI:RegisterModule({
    key = "Essai",
    name = "Essai",
    description = "Module de test du noyau (développement seulement).",
    defaultEnabled = false,
    defaults = { compteur = 0 },
})

function M:OnEnable()
    self.db.compteur = self.db.compteur + 1
    CUI:Print(("Essai : démarré (%d fois depuis la dernière remise à zéro)."):format(self.db.compteur))

    self:On("PLAYER_TARGET_CHANGED", function()
        CUI:Print("Essai : cible changée.")
    end)

    self:After(5, function()
        CUI:Print("Essai : minuterie de 5 s terminée.")
    end)

    self:SetCVar("nameplateShowFriendlyNPCs", "1")
end

function M:OnDisable()
    CUI:Print("Essai : arrêté.")
end
