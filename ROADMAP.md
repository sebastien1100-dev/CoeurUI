# CœurUI : feuille de route

## En cours

- Noyau, en étapes testées une par une :
  1. ~~Socle : chargement, évènements, minuteries, réglages, registre des modules, commande `/cui` (sans fenêtre).~~
     Validé en jeu (0.1.0).
  2. ~~Thème, fenêtre, bouton, interrupteur, infobulle, écran « Modules ».~~ Validé en jeu (0.2.0).
  3. ~~Bouton /reload protégé, report des changements en combat.~~ Validé en jeu (0.3.0).
  4. ~~Curseur et menu déroulant dans un panneau de réglages.~~ Validé en jeu (0.4.0).
  5. ~~Fenêtre principale (maquette A + accueil C validés) : modules à gauche en tiroirs avec leurs sous-modules,
     accueil « Tous les modules » en cartes, réglages à droite.~~ Validé en jeu (0.6.0).
  6. ~~Page « Paramètres » et traduction anglaise possible~~ Validé en jeu (0.7.0) :
     - une entrée « Paramètres » fixe dans la colonne de gauche (réglages généraux de CœurUI, pas un module qu'on
       coupe) ;
     - choix de la langue (français / anglais, par défaut celle du jeu), appliqué après un /reload ;
     - réglage du bouton de minicarte (afficher ou non) rangé là ;
     - tous les textes, ceux des modules compris, passent par les fichiers de `Locales/` (`frFR.lua`, `enUS.lua`).
     Autres langues : un fichier de plus dans `Locales/` (voir `enUS.lua`).
  7. ~~Pièces pour les modules à cadres~~ Validé en jeu (0.8.0, avec le module « Cadres d'unité » en 0.9.0) :
     cadenas « Déverrouiller les cadres » dans la barre de titre et mode déplacement commun ; pages de réglages sur
     deux colonnes ; aperçu fourni par un module ; textures de barre et polices du jeu à disposition des modules.
     (Police, taille du texte et texture des barres se règlent dans le module « Cadres d'unité », sous-onglet
     « Général », communs à tous ses cadres.)

## Ensuite (dans l'ordre, un à la fois)

EllesmereUI (et ses modules) sera retiré quand les modules de CœurUI seront prêts : CœurUI ne doit dépendre de rien
chez lui. Pendant les tests d'un module, couper le module EllesmereUI qui fait la même chose.

1. ~~Icône et logo : script `tools/` qui génère les TGA à partir de la planche du joueur, `IconTexture` dans le `.toc`,
   couleurs du thème affinées sur la planche.~~ Validé en jeu (0.1.1).
2. ~~Premier module d'interface : bouton de minicarte.~~ Validé en jeu (0.5.0).
3. Modules d'interface, un à la fois (chacun : maquette validée, puis code, puis tests en jeu) :
   1. ~~Barres de vie : module « Cadres d'unité » (joueur, cible, cible de la cible).~~ Validé en jeu (0.9.0).
   2. ~~Minicarte~~ Validé en jeu (0.10.1). Maquette validée le 26/11/2026 :
      - interface sobre en jeu : pas de contour doré (l'or reste pour la fenêtre de CœurUI) ;
      - carte rectangulaire seulement : largeur et hauteur réglables, option « garder un carré » (ratio 1) ;
      - nom de la zone, coordonnées (centrées en bas de la carte), boutons du jeu (courrier, suivi, file
        d'attente) ; zoom à la molette ; pas d'heure ni de calendrier ;
      - boutons des addons rangés dans un tiroir (un petit bouton qui ouvre une grille) ;
      - déplaçables avec le cadenas : la carte, le nom de la zone, le tiroir et chacun des boutons du jeu.
      0.10.1 : icônes du courrier, du suivi, de la file d'attente et du tiroir dans la direction « trait + pastille »
      (tools/generer_pictos.py) ; tiroir sans doublon (menu des addons du jeu retiré) ; étiquettes du cadenas
      qui servent de poignée.
   3. Noyau : entrée « Général » en haut de la colonne de gauche, au-dessus de « Cadres d'unité » (demandée le
      26/11/2026). Codée (0.11.0), à tester en jeu. Pour commencer : la police de tout CœurUI (fenêtres,
      panneaux et textes de tous les modules). Le réglage « Police » de Cadres d'unité > Général y est déplacé (un
      seul endroit ; la police déjà choisie est reprise) ; les tailles restent dans Cadres d'unité.
   4. Module « Infobulles et menus » (demandé le 26/11/2026) : habiller au style de CœurUI toutes les infobulles
      de l'interface (celles du jeu : unités, objets, sorts... et celles de CœurUI, toutes pareilles) et les menus
      déroulants du jeu (ex. menu du suivi de la minicarte). Un module (il touche aux cadres du jeu), coupé = rendu
      au jeu. Maquette validée le 26/11/2026 (direction « sobre ») : fond sombre, liseré gris fin, pas d'or ;
      couleurs du jeu gardées sur le nom (qualité, attitude) ; barre de vie en trait fin ; menus : cases CœurUI
      (coche blanche au trait), ligne survolée plus claire, icônes du jeu à droite, chevron gris.
   5. Noyau : grille aimantée pour le déplacement des cadres (demandée le 26/11/2026) : taille de la grille,
      aimant ou pas. Maquette validée le 26/11/2026 ; code après la validation de la Minicarte en jeu :
      - réglages dans le panneau « Déplacement des cadres » (cadenas ouvert), gardés pour le compte ;
      - grille affichée seulement cadenas ouvert, à afficher ou cacher ; tailles 8, 16, 32 (défaut), 48, 64 ;
        partie du centre de l'écran, axes du centre en doré ;
      - aimant (actif par défaut) : grille (même cachée), bords des autres cadres (alignés ou collés), centre
        de l'écran ; à moins de 8 points ; trait vert sur ce qui attire ; Maj enfoncée = déplacement libre.
   6. Barres d'actions.
   7. Barre d'incantation (cast).
   8. Discussion (tchat).
   9. Effets : améliorations et affaiblissements (buffs et débuffs).
   10. Suivi des quêtes.
4. Client PC minimal : mises à jour de l'addon.

## Avant la première publication

- ~~Retirer le module « Essai » (sert seulement à tester le noyau).~~ Fait (0.8.0).

## Plus tard

Idées notées pendant le travail, pas encore commencées.

- Profils de réglages (plusieurs jeux de réglages, choisis par perso). Pas avant que les modules d'interface soient
  posés. À faire le moment venu : une migration de la sauvegarde qui range les réglages actuels dans un profil
  « Par défaut » (rien n'est perdu), le choix du profil branché dans le registre des modules (c'est lui qui donne
  `M.db`), un écran pour créer, copier, renommer et supprimer un profil.
  En attendant, chaque module garde deux habitudes pour que l'ajout reste simple :
  - toujours lire `M.db` au moment de s'en servir, jamais garder une référence à ses réglages au chargement ;
  - avoir une fonction qui réapplique tous ses réglages d'un coup (appelée au changement de profil).
  Questions à trancher avant de commencer :
  - qu'est-ce qui suit le profil : réglages des modules, positions des cadres (`ui.movers`), modules actifs ou
    coupés ?
  - qu'est-ce qui reste au compte : langue, bouton de minicarte ?
  - par défaut : un profil commun à tous les persos, ou un profil par perso ?
