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
      26/11/2026). Validée en jeu (0.11.0). Pour commencer : la police de tout CœurUI (fenêtres,
      panneaux et textes de tous les modules). Le réglage « Police » de Cadres d'unité > Général y est déplacé (un
      seul endroit ; la police déjà choisie est reprise) ; les tailles restent dans Cadres d'unité.
   4. ~~Module « Infobulles et menus »~~ Validé en jeu (0.12.0) : habiller au style de CœurUI toutes les infobulles
      de l'interface (celles du jeu : unités, objets, sorts... et celles de CœurUI, toutes pareilles) et les menus
      déroulants du jeu (ex. menu du suivi de la minicarte). Un module (il touche aux cadres du jeu), coupé = rendu
      au jeu. Maquette validée le 26/11/2026 (direction « sobre ») : fond sombre, liseré gris fin, pas d'or ;
      couleurs du jeu gardées sur le nom (qualité, attitude) ; barre de vie en trait fin ; menus : cases CœurUI
      (coche blanche au trait), ligne survolée plus claire, icônes du jeu à droite, chevron gris.
   4b. ~~Tooltips : option « Afficher les identifiants »~~ Validée en jeu (0.17.0) : ID des sorts et des effets (améliorations, affaiblissements), ID
      des objets, en bas de leur infobulle. Interrupteur dans une page de réglages du module (il n'en a pas encore).
   5. ~~Noyau : grille aimantée~~ Validée en jeu (0.13.0). Pour le déplacement des cadres : taille de la grille,
      aimant ou pas. Maquette validée le 26/11/2026 :
      - réglages dans le panneau « Déplacement des cadres » (cadenas ouvert), gardés pour le compte ;
      - grille affichée seulement cadenas ouvert, à afficher ou cacher ; tailles 8, 16, 32 (défaut), 48, 64 ;
        partie du centre de l'écran, axes du centre en doré ;
      - aimant (actif par défaut) : grille (même cachée), bords des autres cadres (alignés ou collés), centre
        de l'écran ; à moins de 8 points ; trait vert sur ce qui attire ; Maj enfoncée = déplacement libre.
   6. Barres d'actions. Maquette validée le 26/11/2026. En trois étapes : 1) ~~barres 1 à 8~~ validée en jeu (0.14.0) ;
      2) ~~familier, postures, boutons spéciaux~~ validée en jeu (0.15.0) ; 3) ~~micro-menu et sacs~~ validée en jeu (0.16.0). Module terminé. Choix du joueur :
      - barres 1 à 8, familier, postures, boutons spéciaux (action en plus, quitter le véhicule), micro-menu et sacs ;
      - carrés sobres : icône rognée, liseré gris fin, coins à peine arrondis, pas d'or ; raccourci en petit ;
      - par barre : disposition (nombre de boutons, par ligne, taille, espacement), visibilité (toujours, survol,
        combat, cachée), textes (raccourci, nom des macros, charges), opacité hors survol ; sens horizontal ou
        vertical et nombre de boutons (demandés à la validation) ;
      - une seule page de réglages : un menu pour choisir la barre, ses réglages dessous ;
      - placées avec le cadenas (grille aimantée) ; rien ne bouge en combat (boutons protégés).
   7. ~~Suivi des quêtes~~ Validé en jeu (0.18.0). Choix du joueur :
      - on habille le suivi des quêtes du jeu (il sait tout suivre), au style sobre de CœurUI ;
      - titres de section en petites capitales grises, titre de quête coloré selon la difficulté, objectifs gris
        clair (faits en vert), barres de progression fines ;
      - réglages : place (cadenas) et taille maximale, tailles des titres et objectifs, repli automatique (combat,
        donjon/raid), fond sombre léger et son opacité ;
      - clics comme le jeu (journal, menu, lien dans la discussion) ; en plus, « Lien Wowhead » dans le menu : une
        petite fenêtre avec l'adresse de la quête prête à copier et un bouton « Sélectionner » (un addon ne peut
        ni ouvrir de page web ni écrire dans le presse-papiers).
   8. ~~Barre d'incantation (cast) du joueur, dans le module « Cadres d'unité »~~ Validée en jeu (0.19.0). Maquette validée
      le 27/11/2026 (« CœurUI · Maquette Barre d'incantation ») :
      - collée sous le cadre du joueur, à sa largeur, même style (liseré gris fin, pas d'or) ; ou détachée et placée
        avec le cadenas, à sa propre largeur ;
      - icône du sort, nom, temps (restant / total, restant ou aucun) ; zone de latence ; repères des tics des
        canalisations ;
      - bleu acier (incantation), vert (canalisation, se vide), rouge cœur (interrompue, échec), puis s'efface ;
      - réglages en section « Barre d'incantation » de la page « Joueur », sans aperçu à part ;
      - la barre du jeu est cachée tant que la nôtre est affichée.
   8b. ~~Barre d'incantation de la cible, dans « Cadres d'unité »~~ Validée en jeu (0.20.0). Maquette validée le 27/11/2026
      (mêmes planches C et D) : sous le cadre de la cible ou détachée ; gris + cadenas pour un sort qu'on ne peut pas
      interrompre ; pas de latence ; réglages dans la page « Cible », sans aperçu. La cible de la cible suit la cible.
   9. ~~Discussion (tchat)~~ Validée en jeu (0.22.0). Maquette validée le 27/11/2026 (« CœurUI · Maquette Discussion ») :
      la discussion du jeu habillée ; onglets en petites capitales, pastille ; canaux raccourcis, heure grise,
      couleurs de classe ; liens web à copier ; canaux numérotés sans leur zone ([1. Général], le jeu impose « numéro. nom ») ; pictos copier / descendre au survol ; effacement réglable.
   10. ~~Effets : améliorations et affaiblissements (buffs et débuffs)~~ Validé en jeu (0.23.0). Maquette validée le
       27/11/2026 (« CœurUI · Maquette Effets ») : boutons du jeu habillés ; temps dessous, blanc sous 10 s ;
       liseré du type pour les affaiblissements ; améliorations et affaiblissements indépendants (cadre au
       cadenas et sous-onglet de réglages chacun).
   11. Sacs et banque (demandés le 27/11/2026). Choix du joueur : un seul sac, avec ou sans catégories (réglage) ;
       sacs de composants et carquois à part ; recherche, vente de la camelote, niveau d'objet, nouveaux objets ;
       banque à côté des sacs, même style. Maquette validée le 27/11/2026 (« CœurUI · Maquette Sacs et banque »).
       Étapes : 1) sacs ; 2) camelote ; 3) banque. Étape 1 validée (0.29.0). Étape 2 validée (0.30.0). Étape 3 validée (0.31.0).
   12. ~~Barres d'expérience et de réputation (demandées le 27/11/2026), rangées dans le module « Barres d'actions »
       (page « Expérience et réputation », cadre à elles au cadenas). Maquette validée le 27/11/2026 (« CœurUI ·
       Maquette Barres d'expérience et de réputation ») : violet, quêtes à rendre en jaune (« +1 niveau »), repos
       en bleu ; réputation couleur du rang ; un cadre au cadenas chacune.~~ Validé en jeu (0.24.0).
   13. Plaques de nom (nameplates), demandées le 27/11/2026. Module « Plaques de nom ». Choix du joueur : ennemis
       d'abord (vie et nom, monstres de quête avec ce qu'il reste à faire, incantation, mes affaiblissements, menace),
       cible plus grande. Maquette validée le 27/11/2026
       (« CœurUI · Maquette Plaques de nom ») : monstre de quête = nom jaune + « ! » au trait jaune à gauche, ce qu'il
       reste à faire dessous (planche C, choix 1). Étape 1 validée en jeu (0.25.0). Étape 2 validée en jeu (0.26.0, avec les marqueurs de raid). Étape 3 validée en jeu (0.27.0, avec l'avancement des quêtes comme le journal et les
       quêtes en groupe). Étape 4 validée en jeu (0.28.0) : plaques amies, nom seul (choix du joueur), barre si blessé,
       niveau des joueurs en option. Module terminé. Étapes : 1) vie, nom, cible plus grande, menace, monstres de quête ;
       2) mes affaiblissements (avancée, demandé le 27/11/2026) ; 3) incantation ; 4) plaques amies.
4. Client PC minimal : mises à jour de l'addon.

## Avant la première publication

- ~~Retirer le module « Essai » (sert seulement à tester le noyau).~~ Fait (0.8.0).

## Plus tard

Idées notées pendant le travail, pas encore commencées.

- Effets sur les cadres d'unité (ex. affaiblissements posés par le joueur sous le cadre de la cible), dans le
  module « Cadres d'unité » (proposé le 27/11/2026).
- Bulles de discussion au-dessus des personnages, au style de CœurUI (question posée le 27/11/2026, pas encore
  tranchée).
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
