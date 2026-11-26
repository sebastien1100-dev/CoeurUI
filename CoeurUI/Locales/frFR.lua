-- Textes en français : la langue d'origine de CœurUI, toujours complète (les autres langues s'y
-- rabattent pour un texte manquant). Les modules ont aussi leurs textes ici, chacun dans sa section.
-- Rappel : polices du jeu en Windows-1252 seulement (pas de flèche, de « ~ », d'emoji...).
local _, CUI = ...
local L = CUI:NewLocale("frFR", "Français")

L.ERREUR = "erreur dans « %s » (détails dans le message d'erreur du jeu)."

-- Commande /cui
L.AIDE_TITRE = "commandes :"
L.AIDE = {
    "/cui · ouvre ou ferme la fenêtre de CœurUI",
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

-- Fenêtre principale
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
L.TOUS_LES_MODULES = "Tous les modules"
L.REGLAGES_LIEN = "Réglages »"
L.MODULE = "Module"
L.AUCUN_REGLAGE = "Ce module n'a pas de réglages."
L.VALEURS_DEFAUT = "Valeurs par défaut"
L.PANNEAU_INTRO = "Les réglages s'appliquent tout de suite."
L.RECHARGER = "Recharger l'interface"
L.INFOBULLE_BOUTON_RELOAD_TITRE = "Recharger l'interface"
L.INFOBULLE_BOUTON_RELOAD = "Fait un /reload pour appliquer les changements en attente."
L.INFOBULLE_BOUTON_RELOAD_COMBAT = "Indisponible en combat. Le bouton revient à la sortie du combat."
L.INFOBULLE_RELOAD_TITRE = "Coupé au prochain /reload"
L.INFOBULLE_RELOAD = "Ce module ne peut pas s'arrêter en cours de jeu. Faites /reload pour finir de le couper."
L.INFOBULLE_ERREUR_TITRE = "Erreur au démarrage"
L.INFOBULLE_ERREUR = "Le module n'a pas pu démarrer. Les détails sont dans le message d'erreur du jeu."
L.INFOBULLE_COMBAT_TITRE = "En combat"
L.INFOBULLE_COMBAT = "Le changement sera fait à la sortie du combat."

-- Page « Paramètres »
L.PARAMETRES = "Paramètres"
L.PARAMETRES_INTRO = "Réglages généraux de CœurUI, valables pour tous les modules."
L.SECTION_LANGUE = "LANGUE"
L.LANGUE = "Langue de CœurUI"
L.LANGUE_JEU = "Langue du jeu (%s)"
L.LANGUE_NOTE = "S'applique après un rechargement de l'interface."
L.SECTION_MINICARTE = "MINICARTE"
L.BOUTON_MINICARTE = "Bouton de minicarte"
L.BOUTON_MINICARTE_DESC = "Le bouton CœurUI au bord de la minicarte. Sans lui, la fenêtre s'ouvre avec /cui."

-- Bouton de minicarte
L.MINICARTE_CLIC = "Clic : ouvrir ou fermer la fenêtre de CœurUI."
L.MINICARTE_GLISSER = "Glisser : déplacer le bouton autour de la minicarte."

-- Réglages du jeu (CVars)
L.CVAR_INCONNUE = "réglage du jeu inconnu : %s."

-- Module « Essai » (tests du noyau, retiré avant la publication)
L.ESSAI_NOM = "Essai"
L.ESSAI_DESC = "Module de test du noyau (développement seulement)."
L.ESSAI_MESSAGES = "Messages"
L.ESSAI_MESSAGES_DESC = "Messages écrits par Essai dans la discussion."
L.ESSAI_DEMARRAGE = "Message au démarrage"
L.ESSAI_DEMARRAGE_DESC = "Écrit « Essai : démarré » dans la discussion quand le module démarre."
L.ESSAI_CIBLE = "Message quand la cible change"
L.ESSAI_COURT = "Court"
L.ESSAI_LONG = "Long"
L.ESSAI_AUCUN = "Aucun"
L.ESSAI_MINUTERIE = "Minuterie"
L.ESSAI_MINUTERIE_DESC = "Minuterie lancée au démarrage d'Essai."
L.ESSAI_DELAI = "Délai de la minuterie"
L.ESSAI_DEMARRE = "Essai : démarré (%d fois depuis la dernière remise à zéro)."
L.ESSAI_CIBLE_COURT = "Essai : cible changée."
L.ESSAI_CIBLE_LONG = "Essai : vous avez changé de cible (message long)."
L.ESSAI_MINUTERIE_FIN = "Essai : minuterie de %d s terminée."
L.ESSAI_ARRETE = "Essai : arrêté."
L.ESSAI_REGLAGE = "Essai : réglage « %s / %s » = %s."
