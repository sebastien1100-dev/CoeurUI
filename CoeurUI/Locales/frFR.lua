-- Tous les textes affichés par le noyau.
-- Rappel : polices du jeu en Windows-1252 seulement (pas de flèche, de « ~ », d'emoji...).
local _, CUI = ...
local L = CUI.L

L.ERREUR = "erreur dans « %s » (détails dans le message d'erreur du jeu)."

-- Commande /cui
L.AIDE_TITRE = "commandes :"
L.AIDE = {
    "/cui · ouvre ou ferme la fenêtre des modules",
    "/cui aide · cette aide",
    "/cui version · version de l'addon",
    "/cui modules · liste des modules et leur état",
    "/cui activer <module> · active un module",
    "/cui couper <module> · coupe un module",
    "/cui reset · remet tous les réglages à zéro",
}
L.VERSION = "version %s."
L.MODULES_TITRE = "modules :"
L.MODULES_AUCUN = "aucun module."
L.MODULE_LIGNE = "• %s (%s) : %s"
L.ETAT_ACTIF = "|cff7fd97factif|r"
L.ETAT_COUPE = "|cff9a9a9acoupé|r"
L.ETAT_RELOAD = "|cffd9ae5bcoupé au prochain /reload|r"
L.ETAT_ERREUR = "|cffd2465aerreur au démarrage|r"
L.MODULE_INCONNU = "module inconnu : « %s ». Tapez /cui modules pour la liste."
L.MODULE_MANQUANT = "précisez le module, par exemple : /cui %s essai"
L.MODULE_ACTIVE = "%s activé."
L.MODULE_COUPE = "%s coupé."
L.MODULE_RELOAD = "%s sera coupé au prochain /reload."
L.MODULE_DEJA_ACTIF = "%s est déjà actif."
L.MODULE_DEJA_COUPE = "%s est déjà coupé."
L.EN_COMBAT = "en combat : ce sera fait à la sortie du combat."
L.RESET_CONFIRMER = "tous les réglages de CœurUI seront effacés. Tapez /cui reset oui pour confirmer."
L.RESET_FAIT = "réglages effacés. Faites /reload pour terminer."
L.RESET_ATTENTE = "réglages effacés : faites /reload avant toute autre commande."
L.COMMANDE_INCONNUE = "commande inconnue : « %s »."

-- Fenêtres
L.FERMER = "Fermer"

-- Écran « Modules »
L.ECRAN_MODULES_TITRE = "Modules"
L.ECRAN_MODULES_INTRO = "Activez ou coupez chaque module. Un module coupé ne charge rien et rend au jeu ce qu'il avait changé."
L.MODULES_AUCUN_ECRAN = "Aucun module."
L.ECRAN_ETAT_ACTIF = "actif"
L.ECRAN_ETAT_COUPE = "coupé"
L.ECRAN_ETAT_RELOAD = "coupé au prochain /reload"
L.ECRAN_ETAT_ERREUR = "erreur au démarrage"
L.ECRAN_ETAT_COMBAT = "à la sortie du combat"
L.N_MODULES = { "%d module", "%d modules" }
L.N_ACTIFS = { "%d actif", "%d actifs" }
L.ECRAN_RELOAD_A_FAIRE = "faites /reload pour finir"
L.INFOBULLE_RELOAD_TITRE = "Coupé au prochain /reload"
L.INFOBULLE_RELOAD = "Ce module ne peut pas s'arrêter en cours de jeu. Faites /reload pour finir de le couper."
L.INFOBULLE_ERREUR_TITRE = "Erreur au démarrage"
L.INFOBULLE_ERREUR = "Le module n'a pas pu démarrer. Les détails sont dans le message d'erreur du jeu."
L.INFOBULLE_COMBAT_TITRE = "En combat"
L.INFOBULLE_COMBAT = "Le changement sera fait à la sortie du combat."

-- Réglages du jeu (CVars)
L.CVAR_INCONNUE = "réglage du jeu inconnu : %s."
