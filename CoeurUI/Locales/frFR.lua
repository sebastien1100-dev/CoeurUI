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
L.MODULE_MANQUANT = "précisez le module : /cui %s <module> (liste : /cui modules)"
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


-- Déplacement des cadres (cadenas de la barre de titre)
L.DEVERROUILLER_CADRES = "Déverrouiller les cadres"
L.VERROUILLER_CADRES = "Verrouiller les cadres"
L.CADRES_DEVERROUILLES = "Cadres déverrouillés"
L.INFOBULLE_CADENAS = "Les cadres se glissent à la souris tant que le cadenas est ouvert."
L.INFOBULLE_CADENAS_COMBAT = "Indisponible en combat."
L.INFOBULLE_CADENAS_AUCUN = "Aucun cadre à déplacer : activez un module qui en a."
L.DEPLACEMENT_TITRE = "Déplacement des cadres"
L.DEPLACEMENT_AIDE = "Glissez un cadre pour le placer. Clic droit sur un cadre : remettre à sa place d'origine."
L.DEPLACEMENT_TOUT = "Tout remettre en place"
L.VERROUILLER = "Verrouiller"
L.DEPLACEMENT_COMBAT = "en combat : impossible de déplacer les cadres."
L.DEPLACEMENT_FERME_COMBAT = "combat : cadres verrouillés."

-- Polices et textures de barre (choix dans les pages des modules)
L.POLICE_JEU = "%s (jeu)"
L.TEXTURE_UNIE = "Unie"
L.TEXTURE_LISSE = "Lisse (CœurUI)"
L.TEXTURE_JEU = "Classique du jeu"
L.TEXTURE_RAID = "Raid du jeu"

-- Module « Cadres d'unité »
L.CU_NOM = "Cadres d'unité"
L.CU_DESC = "Joueur, cible et cible de la cible, à la place des cadres du jeu."
L.CU_GENERAL = "Général"
L.CU_JOUEUR = "Joueur"
L.CU_CIBLE = "Cible"
L.CU_CIBLE_CIBLE = "Cible de la cible"
L.CU_TEXTE = "TEXTE"
L.CU_TAILLE_NOM = "Taille du nom"
L.CU_TAILLE_NIVEAU = "Taille du niveau"
L.CU_TAILLE_VIE = "Taille du texte de la vie"
L.CU_BARRES = "BARRES"
L.CU_TEXTURE = "Texture des barres"
L.CU_TAILLE = "TAILLE"
L.CU_LARGEUR = "Largeur"
L.CU_HAUTEUR = "Hauteur"
L.CU_TEXTES = "TEXTES ET COULEURS"
L.CU_TEXTE_VIE = "Texte de la vie"
L.CU_VIE_VP = "Valeur et pourcentage"
L.CU_VIE_P = "Pourcentage"
L.CU_VIE_V = "Valeur"
L.CU_VIE_AUCUN = "Aucun"
L.CU_COULEUR = "Couleur de la vie"
L.CU_COULEUR_CLASSE = "Couleur de classe"
L.CU_COULEUR_ATTITUDE = "Classe ou attitude"
L.CU_VERT = "Vert"
L.CU_APERCU = "APERÇU"
L.CU_ELEMENTS = "ÉLÉMENTS"
L.CU_RESSOURCE = "Barre de ressource"
L.CU_NIVEAU = "Niveau"
L.CU_PORTRAIT = "Portrait"
L.CU_CHEF = "Couronne de chef de groupe"
L.CU_ELITE = "Élite"
L.CU_RARE = "Rare"
L.CU_RARE_ELITE = "Rare élite"
L.CU_BOSS = "Boss"
L.CU_MORT = "Mort"
L.CU_EXEMPLE = "%s (exemple)"
L.CU_EXEMPLE_NOM = "Nom du personnage"
L.CU_EXEMPLE_CIBLE = "Gardien des ruines"

-- Module « Minicarte »
L.MC_NOM = "Minicarte"
L.MC_DESC = "Carte sobre à la taille voulue, nom de la zone, coordonnées et boutons des addons rangés dans un tiroir."
L.MC_CARTE = "CARTE"
L.MC_CARRE = "Garder un carré (largeur = hauteur)"
L.MC_LARGEUR = "Largeur"
L.MC_HAUTEUR = "Hauteur"
L.MC_HAUTEUR_NOTE = "Tant que « Garder un carré » est coché, la hauteur suit la largeur."
L.MC_ZOOM = "Zoom à la molette"
L.MC_AUTOUR = "AUTOUR DE LA CARTE"
L.MC_ZONE = "Nom de la zone"
L.MC_COORD = "Coordonnées"
L.MC_BOUTONS_JEU = "Boutons du jeu"
L.MC_BOUTONS_JEU_DESC = "Courrier, suivi, file d'attente (le courrier et la file seulement quand ils servent)."
L.MC_TIROIR = "Ranger les boutons des addons dans un tiroir"
L.MC_REPLACER = "Remettre les éléments autour de la carte"
L.MC_REPLACER_NOTE = "Placer la carte, le nom de la zone, le tiroir et chaque bouton du jeu : le cadenas en haut de la fenêtre."
L.MC_M_CARTE = "Minicarte"
L.MC_M_ZONE = "Nom de la zone"
L.MC_M_COURRIER = "Courrier"
L.MC_M_SUIVI = "Suivi"
L.MC_M_FILE = "File d'attente"
L.MC_M_TIROIR = "Tiroir des addons"
L.MC_TIROIR_VIDE = "Aucun bouton d'addon."

-- Page « Général » (réglages communs à tout CœurUI)
L.GENERAL = "Général"
L.GENERAL_INTRO = "Réglages communs à tout CœurUI : fenêtres, panneaux et textes de tous les modules."
L.SECTION_POLICE = "POLICE"
L.POLICE = "Police"
L.POLICE_NOTE = "Utilisée partout dans CœurUI. Les tailles se règlent dans chaque module."

-- Module « Infobulles et menus »
L.IM_NOM = "Infobulles et menus"
L.IM_DESC = "Les infobulles et les menus du jeu au style de CœurUI : fond sombre, liseré fin, pas d'or."
