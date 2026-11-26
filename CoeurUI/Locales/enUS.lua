-- English texts. Same keys as frFR.lua (the original, complete language): a missing key here
-- falls back to French. To add a language, copy this file as xxXX.lua, change the NewLocale line
-- and the texts, and add the file to CoeurUI.toc.
-- Reminder: game fonts are Windows-1252 only (no arrows, no "~", no emoji...).
local _, CUI = ...
local L = CUI:NewLocale("enUS", "English")

L.ERREUR = "error in \"%s\" (details in the game's error message)."

-- /cui command
L.AIDE_TITRE = "commands:"
L.AIDE = {
    "/cui · open or close the CœurUI window",
    "/cui help · this help",
    "/cui version · addon version",
    "/cui modules · list of modules and their state",
    "/cui enable <module> · enable a module",
    "/cui disable <module> · disable a module",
    "/cui reset · reset every setting",
}
L.VERSION = "version %s."
L.MODULES_TITRE = "modules:"
L.MODULES_AUCUN = "no modules."
L.MODULE_LIGNE = "• %s (%s): %s"
L.ETAT_ACTIF = "|cff7fd97fenabled|r"
L.ETAT_COUPE = "|cff9a9a9adisabled|r"
L.ETAT_RELOAD = "|cffd9ae5bdisabled after the next /reload|r"
L.ETAT_ERREUR = "|cffd2465afailed to start|r"
L.MODULE_INCONNU = "unknown module: \"%s\". Type /cui modules for the list."
L.MODULE_MANQUANT = "name the module: /cui %s <module> (list: /cui modules)"
L.MODULE_ACTIVE = "%s enabled."
L.MODULE_COUPE = "%s disabled."
L.MODULE_RELOAD = "%s will be disabled after the next /reload."
L.MODULE_DEJA_ACTIF = "%s is already enabled."
L.MODULE_DEJA_COUPE = "%s is already disabled."
L.EN_COMBAT = "in combat: this will be done when combat ends."
L.RESET_CONFIRMER = "every CœurUI setting will be erased. Type /cui reset yes to confirm."
L.RESET_FAIT = "settings erased. Type /reload to finish."
L.RESET_ATTENTE = "settings erased: type /reload before any other command."
L.COMMANDE_INCONNUE = "unknown command: \"%s\"."

-- Windows
L.FERMER = "Close"

-- Main window
L.ECRAN_MODULES_TITRE = "Modules"
L.ECRAN_MODULES_INTRO = "Enable or disable each module. A disabled module loads nothing and gives back to the game what it changed."
L.MODULES_AUCUN_ECRAN = "No modules."
L.ECRAN_ETAT_ACTIF = "enabled"
L.ECRAN_ETAT_COUPE = "disabled"
L.ECRAN_ETAT_RELOAD = "disabled after the next /reload"
L.ECRAN_ETAT_ERREUR = "failed to start"
L.ECRAN_ETAT_COMBAT = "when combat ends"
L.N_MODULES = { "%d module", "%d modules" }
L.N_ACTIFS = { "%d enabled", "%d enabled" }
L.TOUS_LES_MODULES = "All modules"
L.REGLAGES_LIEN = "Settings »"
L.MODULE = "Module"
L.AUCUN_REGLAGE = "This module has no settings."
L.VALEURS_DEFAUT = "Reset to defaults"
L.PANNEAU_INTRO = "Settings apply right away."
L.RECHARGER = "Reload UI"
L.INFOBULLE_BOUTON_RELOAD_TITRE = "Reload UI"
L.INFOBULLE_BOUTON_RELOAD = "Runs /reload to apply the pending changes."
L.INFOBULLE_BOUTON_RELOAD_COMBAT = "Not available in combat. The button comes back when combat ends."
L.INFOBULLE_RELOAD_TITRE = "Disabled after the next /reload"
L.INFOBULLE_RELOAD = "This module cannot stop while you play. Type /reload to finish disabling it."
L.INFOBULLE_ERREUR_TITRE = "Failed to start"
L.INFOBULLE_ERREUR = "The module could not start. Details are in the game's error message."
L.INFOBULLE_COMBAT_TITRE = "In combat"
L.INFOBULLE_COMBAT = "The change will be made when combat ends."

-- Settings page
L.PARAMETRES = "Settings"
L.PARAMETRES_INTRO = "General CœurUI settings, shared by every module."
L.SECTION_LANGUE = "LANGUAGE"
L.LANGUE = "CœurUI language"
L.LANGUE_JEU = "Game language (%s)"
L.LANGUE_NOTE = "Applied after reloading the interface."
L.SECTION_MINICARTE = "MINIMAP"
L.BOUTON_MINICARTE = "Minimap button"
L.BOUTON_MINICARTE_DESC = "The CœurUI button on the edge of the minimap. Without it, open the window with /cui."

-- Minimap button
L.MINICARTE_CLIC = "Click: open or close the CœurUI window."
L.MINICARTE_GLISSER = "Drag: move the button around the minimap."

-- Game settings (CVars)
L.CVAR_INCONNUE = "unknown game setting: %s."


-- Moving frames (padlock in the title bar)
L.DEVERROUILLER_CADRES = "Unlock frames"
L.VERROUILLER_CADRES = "Lock frames"
L.CADRES_DEVERROUILLES = "Frames unlocked"
L.INFOBULLE_CADENAS = "Frames can be dragged with the mouse while the padlock is open."
L.INFOBULLE_CADENAS_COMBAT = "Not available in combat."
L.INFOBULLE_CADENAS_AUCUN = "No frames to move: enable a module that has some."
L.DEPLACEMENT_TITRE = "Moving frames"
L.DEPLACEMENT_AIDE = "Drag a frame to place it. Right-click a frame: put it back in its original place."
L.DEPLACEMENT_TOUT = "Reset all positions"
L.VERROUILLER = "Lock"
L.DEPLACEMENT_COMBAT = "in combat: frames cannot be moved."
L.DEPLACEMENT_FERME_COMBAT = "combat: frames locked."

-- Fonts and bar textures (chosen in module pages)
L.POLICE_JEU = "%s (game)"
L.TEXTURE_UNIE = "Flat"
L.TEXTURE_LISSE = "Smooth (CœurUI)"
L.TEXTURE_JEU = "Classic (game)"
L.TEXTURE_RAID = "Raid (game)"

-- "Unit frames" module
L.CU_NOM = "Unit frames"
L.CU_DESC = "Player, target and target of target, replacing the game's frames."
L.CU_GENERAL = "General"
L.CU_JOUEUR = "Player"
L.CU_CIBLE = "Target"
L.CU_CIBLE_CIBLE = "Target of target"
L.CU_TEXTE = "TEXT"
L.CU_POLICE = "Font"
L.CU_TAILLE_NOM = "Name size"
L.CU_TAILLE_NIVEAU = "Level size"
L.CU_TAILLE_VIE = "Health text size"
L.CU_BARRES = "BARS"
L.CU_TEXTURE = "Bar texture"
L.CU_TAILLE = "SIZE"
L.CU_LARGEUR = "Width"
L.CU_HAUTEUR = "Height"
L.CU_TEXTES = "TEXT AND COLORS"
L.CU_TEXTE_VIE = "Health text"
L.CU_VIE_VP = "Value and percentage"
L.CU_VIE_P = "Percentage"
L.CU_VIE_V = "Value"
L.CU_VIE_AUCUN = "None"
L.CU_COULEUR = "Health color"
L.CU_COULEUR_CLASSE = "Class color"
L.CU_COULEUR_ATTITUDE = "Class or reaction"
L.CU_VERT = "Green"
L.CU_APERCU = "PREVIEW"
L.CU_ELEMENTS = "ELEMENTS"
L.CU_RESSOURCE = "Power bar"
L.CU_NIVEAU = "Level"
L.CU_PORTRAIT = "Portrait"
L.CU_CHEF = "Group leader crown"
L.CU_ELITE = "Elite"
L.CU_RARE = "Rare"
L.CU_RARE_ELITE = "Rare elite"
L.CU_BOSS = "Boss"
L.CU_MORT = "Dead"
L.CU_EXEMPLE = "%s (example)"
L.CU_EXEMPLE_NOM = "Character name"
L.CU_EXEMPLE_CIBLE = "Ruins warden"
