# CœurUI : notes de version

La plus récente en premier. Phrases courtes, du point de vue du joueur.

## 0.19.1 · 27/11/2026

- Suivi des quêtes : la fenêtre « Lien Wowhead » n'a plus de bouton « Sélectionner » (l'adresse est déjà
  sélectionnée) ; un clic dans l'adresse la garde sélectionnée.
- Un /reload suffit.

## 0.19.0 · 27/11/2026

- Cadres d'unité : nouvelle barre d'incantation du joueur, collée sous son cadre et à sa largeur, au style sobre de
  CœurUI. Icône du sort, nom, temps restant et total ; zone de latence au bout de la barre ; repères des tics sur
  les canalisations les plus courantes.
- Bleu pendant une incantation, vert pendant une canalisation (la barre se vide), rouge « Interrompu » ou « Échec »
  quand le sort ne part pas ; elle s'efface ensuite.
- Option « Détacher du cadre » : la barre se place alors seule avec le cadenas, avec sa propre largeur.
- Réglages dans la page « Joueur », section « Barre d'incantation » : afficher, détacher, hauteur, largeur, temps
  affiché, icône, nom, latence, tics.
- La barre d'incantation du jeu est cachée tant que celle de CœurUI est affichée ; elle revient quand on la coupe.
- Le cadre du familier suit maintenant le cadre du joueur : juste dessous, ou sous la barre d'incantation quand elle
  y est attachée (il remonte quand on la détache ou la coupe). Sa place est remise à zéro une fois : le replacer
  avec le cadenas si besoin.
- La fenêtre de CœurUI se cache pendant un combat et revient à la fin, sur la même page. Ouverte en combat (/cui,
  bouton de minicarte) : elle s'ouvre à la fin du combat.
- Correction (Cadres d'unité) : changer un réglage de la barre d'incantation en combat provoquait une erreur
  « action bloquée ».
- Un /reload suffit.

## 0.18.0 · 26/11/2026

- Nouveau module « Suivi des quêtes » (coupé d'office) : le suivi des quêtes du jeu au style sobre de CœurUI. Titres
  de section gris, titre de quête dans la couleur de sa difficulté, objectifs gris clair (faits : en vert), barres
  de progression sobres, fond sombre léger réglable.
- Placé avec le cadenas ; largeur et hauteur maximale réglables ; tailles des titres et des objectifs.
- Repli automatique en combat et en donjon ou raid (il se déplie tout seul après ; jamais un suivi replié à la main).
- Objectifs colorés selon leur avancée : rouge (pas commencé), jaune (à moitié), vert (fait), en dégradé ; « À rendre »
  en vert quand la quête est terminée.
- La ligne « Tous les objectifs » du jeu est retirée ; chaque section garde son bouton de repli. Le fond est centré
  sur les quêtes, icônes comprises.
- Clic droit sur une quête : « Lien Wowhead », une petite fenêtre avec l'adresse de la quête prête à copier (Ctrl+C).
- Couper le module demande un rechargement de l'interface.
- Tooltips : les infobulles de survol (unités dans le monde, cadres, boutons du jeu...) se placent avec le cadenas
  (cadre « Infobulles », en bas à droite par défaut) ; elles grandissent depuis le coin le plus proche du bord.
- Correction (Minicarte) : le contour de la carte était irrégulier (côtés plus épais, coins flous) ; il est maintenant
  d'un pixel d'écran exactement, à toute échelle d'interface.
- Minicarte : le menu du suivi s'ouvre contre la carte, aligné sur son haut (du côté du centre de l'écran).
- Grille du cadenas : nouvelle taille 4 (en plus de 8, 16, 32, 48 et 64), pour placer au plus près.
- Cadenas : la fenêtre de CœurUI se cache quand on déverrouille les cadres, et revient sur la même page au
  verrouillage.
- Redémarrer le jeu.

## 0.17.1 · 26/11/2026

- Correction (Cadres d'unité) : aucune infobulle ne s'affichait au survol des cadres du joueur, de la cible et de la
  cible de la cible ; le survol montre maintenant l'infobulle de l'unité, comme sur les cadres du jeu.
- Correction (Cadres d'unité) : le cadre du familier avait disparu avec celui du joueur. Nouveau cadre « Familier »,
  petit comme celui de la cible de la cible (nom et barre de vie), avec son sous-onglet de réglages et sa place au
  cadenas ; il n'apparaît qu'avec un familier.
- Tooltips : plus de barre de vie sous l'infobulle d'une unité.
- Tooltips : dans l'infobulle d'un joueur, la classe est écrite dans sa couleur et la faction dans la sienne (Alliance
  en bleu, Horde en rouge).
- Cadres d'unité : l'infobulle n'a plus la consigne verte « Clic droit pour les paramètres de bordure ».
- Un /reload suffit.

## 0.17.0 · 26/11/2026

- Tooltips : nouvelle page de réglages avec l'option « Afficher les identifiants » (activée d'office) : en bas des
  infobulles, l'ID des sorts (barres, grimoire, talents), des effets (améliorations, affaiblissements) et des objets
  (sacs, équipement, liens, marchands), en gris discret.
- Un /reload suffit.

## 0.16.0 · 26/11/2026

- Barres d'actions, étape 3 : le micro-menu (personnage, métiers, sorts et talents, hauts faits, quêtes, guilde,
  recherche de groupe, collections, journal, boutique, menu...) en carrés sobres avec des icônes CœurUI au trait ;
  une pastille rouge quand le jeu signale quelque chose, gris sombre quand un bouton est désactivé.
- Les sacs (sac de composants, quatre sacs, sac à dos) en carrés sobres ; places libres gardées.
- Tous deux se placent avec le cadenas ; rangées, sens, taille, espacement, visibilité, opacité (le nombre de
  boutons est celui du jeu).
- « Barres d'actions » devient un tiroir dans la fenêtre : « Barres » (les barres 1 à 8 réunies, un menu choisit la
  barre), puis une page chacun pour Familier, Postures et formes (seulement si le personnage en a), Bouton d'action
  en plus, Quitter le véhicule, Micro-menu et Sacs, avec seulement leurs réglages.
- Familier : toujours ses 10 boutons sur une rangée ; « Nombre de boutons » et « Boutons par rangée » retirés de sa
  page (le sens, la taille et l'espacement restent).
- Micro-menu et sacs : toujours sur une rangée (ou une colonne en sens vertical) ; « Boutons par rangée » retiré de
  leurs pages. L'aperçu est retiré de toutes les pages (la vraie barre change tout de suite).
- Le module « Infobulles et menus » s'appelle maintenant « Tooltips » (rien ne change dans ses réglages).
- Correction : des erreurs Lua ("SetCooldown ... Secret values") apparaissaient en combat sur les barres 1 à 8. Les
  barres utilisent maintenant les boutons d'action du jeu (rangés et habillés par CœurUI) : le jeu met lui-même à jour
  recharges, sorts et raccourcis.
- Correction : une erreur Lua (Blizzard_MicroMenu, GetEdgeButton) apparaissait quand le micro-menu était rangé ; ses
  boutons restent maintenant dans le micro-menu du jeu, seulement placés sur la barre CœurUI.
- Correction : les boutons du micro-menu étaient mal alignés et de tailles différentes (échelle du micro-menu du jeu,
  réarrangements du jeu) ; ils sont remis en place tout seuls.
- Micro-menu adapté à WoW Forever : plus de Logis, de Guide de l'aventurier ni de hauts faits (ils n'y existent pas),
  ni du bouton « sorts et talents » récent qui y faisait doublon (étoile en trop, mauvais raccourcis) ; le bouton
  Héritage de Forever (couronne) a sa place après les talents (il restait seul à l'ancienne place du micro-menu) ;
  le grimoire (livre) a son bouton, les talents (étoile) le leur ; l'assistance a son icône (point d'interrogation).
- Correction : sur les sacs (et parfois ailleurs), les images touchaient les bords et le liseré gris ne se voyait pas ;
  le liseré est maintenant toujours visible, par-dessus l'image.
- Correction : les icônes restaient teintées de rouge quelle que soit la distance de la cible ; le rouge est
  maintenant un voile posé seulement quand le jeu indique « hors de portée », la couleur de l'icône reste celle du jeu.
- Redémarrer le jeu (nouvelles textures).

## 0.15.0 · 26/11/2026

- Barres d'actions, étape 2 : la barre du familier et celle des postures (ou formes) en carrés sobres, au-dessus des
  barres ; mêmes réglages que les barres (jusqu'à 10 boutons). La barre du familier n'apparaît qu'avec un familier.
- Un personnage sans posture ni forme ne voit pas « Postures et formes » (ni dans la page, ni au cadenas) ; elle
  apparaît dès qu'il en apprend une.
- Bouton d'action en plus (combats de boss, quêtes) et capacité de zone : sans leur décor du jeu, à la taille et à la
  place voulues.
- Quitter le véhicule : un carré sobre avec une icône CœurUI au trait, seulement en véhicule.
- Chacun se place avec le cadenas ; ils se choisissent dans le menu « Barre » de la page (pour les deux boutons
  spéciaux, seule la taille se règle).
- Redémarrer le jeu (nouvelle texture).

## 0.14.0 · 26/11/2026

- Nouveau module « Barres d'actions » (coupé d'office), première étape : les barres 1 à 8 en carrés sobres (icône
  rognée, liseré gris fin, pas d'or), à la place des barres du jeu. Raccourcis du jeu gardés.
- Pour chaque barre, sur une seule page (un menu choisit la barre) : l'afficher ou non, nombre de boutons (1 à
  12), boutons par rangée, sens horizontal ou vertical, taille, espacement ; quand l'afficher (toujours, au survol
  seulement, en combat seulement, jamais) et opacité hors survol ; raccourci, nom des macros, charges.
- Hors de portée : icône teintée en rouge. Sort mis en avant par le jeu : halo blanc au lieu de doré.
- Les barres se placent avec le cadenas (grille aimantée). Un réglage changé en combat s'applique à la sortie.
- Familier, postures, boutons spéciaux, micro-menu et sacs : prochaines étapes du module.
- Couper le module demande un rechargement de l'interface.
- Redémarrer le jeu.

## 0.13.0 · 26/11/2026

- Cadenas ouvert : une grille fine s'affiche sous l'interface, partie du centre de l'écran (axes du centre en
  doré). Dans le panneau « Déplacement des cadres » : l'afficher ou non, et sa taille (8, 16, 32, 48 ou 64).
- Aimant (activé d'office, se coupe dans le même panneau) : un cadre glissé se colle à la grille, aux bords des
  autres cadres (alignés ou collés) et au centre de l'écran ; un trait vert montre ce qui l'attire. Maj enfoncée :
  déplacement libre.
- Un /reload suffit.

## 0.12.0 · 26/11/2026

- Nouveau module « Infobulles et menus » (coupé d'office) : les infobulles du jeu (unités, objets, sorts...) et ses
  menus déroulants (ex. menu du suivi de la minicarte) prennent le style sobre de CœurUI : fond sombre, liseré gris
  fin, pas d'or. La barre de vie sous une infobulle devient un trait fin ; les textes prennent la police de CœurUI.
- Les infobulles et les menus de CœurUI passent aussi au style sobre (plus de contour ni de titre dorés).
- Correction (Minicarte) : certains addons apparaissaient encore deux fois dans le tiroir (leur bouton, plus une
  copie tirée du menu des addons du jeu).
- Correction (Minicarte) : posé sur la carte avec le cadenas, le bouton du tiroir ne répondait pas au clic.
- Minicarte : le tiroir s'ouvre sur le côté de la carte (vers le centre de l'écran) et a le cadre sobre de CœurUI
  (fond sombre, liseré gris fin) au lieu d'un rectangle noir.
- Minicarte : dans le tiroir, chaque bouton d'addon a le même habit, un rond sobre CœurUI (image en rond, fond
  graphite, liseré gris fin qui s'éclaircit au survol) ; les addons ajoutés plus tard le prennent aussi.
- Couper le module demande un rechargement de l'interface.
- Redémarrer le jeu.

## 0.11.0 · 26/11/2026

- Nouvelle entrée « Général » dans la fenêtre, juste sous « Tous les modules » : les réglages communs à tout
  CœurUI.
- Pour commencer, la police : elle change d'un coup les fenêtres de CœurUI et les textes de tous les modules
  (cadres d'unité, minicarte...).
- La police n'est plus réglée dans Cadres d'unité > Général (les tailles y restent) ; celle que vous aviez choisie
  y est reprise.
- Minicarte : plus d'infobulle au survol des icônes du courrier, du suivi et du tiroir.
- Nouvelle icône dans la barre de titre de la fenêtre, à gauche du cadenas : recharger l'interface d'un clic
  (grisée en combat).
- Redémarrer le jeu (nouvelle texture).

## 0.10.1 · 26/11/2026

- Minicarte : courrier, suivi, file d'attente et tiroir ont leurs icônes CœurUI (trait fin, gris clair, blanc au
  survol) ; une pastille rouge signale le courrier arrivé.
- Correction : le tiroir montrait deux fois certains addons (leur bouton, plus le menu des addons du jeu « 3 »). Le
  menu du jeu n'y est plus ; seuls les addons qui n'ont pas de bouton y gardent une place.
- Correction : des restes de la minicarte du jeu (textes, décors) restaient visibles à son ancienne place.
- Correction : une erreur Lua (Blizzard_Minimap) apparaissait à chaque arrivée de courrier.
- Cadenas ouvert : on peut aussi déplacer un élément en glissant son étiquette (son nom), plus simple pour les petits
  éléments de la minicarte ; un élément posé sur la carte s'attrape sans entraîner la carte. L'étiquette de la carte
  passe en dessous, pour ne plus cacher celle du nom de la zone.
- Redémarrer le jeu (nouvelles textures).

## 0.10.0 · 26/11/2026

- Nouveau module « Minicarte » (coupé d'office) : minicarte sobre, carrée ou rectangulaire (largeur et hauteur
  réglables), avec le nom de la zone, les coordonnées en bas de la carte et le zoom à la molette.
- Boutons du jeu gardés : courrier, suivi, file d'attente. Plus d'heure ni de calendrier sur la carte.
- Les boutons des addons sont rangés dans un tiroir qui s'ouvre d'un clic.
- Avec le cadenas, on place la carte, le nom de la zone, le tiroir et chaque bouton du jeu ; les éléments suivent la
  carte quand on la déplace.
- Couper le module demande un rechargement de l'interface.
- Redémarrer le jeu.

## 0.9.0 · 26/11/2026

- Nouveau module « Cadres d'unité » (coupé d'office) : cadres du joueur, de la cible et de la cible de la cible, à
  la place de ceux du jeu. Couper le module demande un rechargement de l'interface.
- Page « Général » : police, taille de chaque libellé (nom, niveau, vie) et texture des barres, pour tous les cadres.
- Pages Joueur, Cible, Cible de la cible : taille, texte et couleur de la vie, éléments, avec un aperçu.
- Le cadenas de la fenêtre déverrouille les cadres pour les placer à la souris.
- Redémarrer le jeu.

## 0.8.0 · 26/11/2026

- Le module « Essai », qui servait aux tests, est retiré. S'il était actif, la plaque des PNJ amis revient à son
  réglage d'origine.
- Un cadenas dans la barre de titre servira à déverrouiller les cadres pour les déplacer (avec les prochains
  modules qui ont des cadres).
- La version de CœurUI s'affiche dans la barre de titre de la fenêtre.
- Correction : « Paramètres » avait un trait doré à gauche alors qu'il n'était pas choisi.
- Redémarrer le jeu.

## 0.7.0 · 26/11/2026

- Nouvelle page « Paramètres », en bas à gauche de la fenêtre : réglages généraux de CœurUI.
- CœurUI parle anglais : choix de la langue dans « Paramètres » (par défaut celle du jeu), après un
  rechargement de l'interface. Les commandes marchent en français et en anglais (`/cui help`, `enable`, `disable`).
- Le bouton de minicarte n'est plus un module : on l'affiche ou le cache dans « Paramètres ». Sa place est gardée.
- Correction : « Paramètres » avait une pastille blanche, comme un module, alors que ce n'en est pas un.
- Redémarrer le jeu.

## 0.6.0 · 26/11/2026

- Nouvelle fenêtre principale (`/cui` ou le bouton de minicarte) : les modules sont rangés à gauche, en tiroirs
  qui s'ouvrent sur leurs sous-modules.
- Accueil « Tous les modules » : une carte par module, avec son interrupteur et un lien vers ses réglages.
- Les réglages d'un module ou d'un sous-module s'ouvrent à droite ; la molette fait défiler les longues pages.

## 0.5.0 · 26/11/2026

- Nouveau module « Bouton de minicarte », actif d'office : un clic ouvre la fenêtre des modules, on le glisse
  autour de la minicarte pour le déplacer.
- Correction : rangé par un addon de minicarte (EllesmereUIMinimap), le contour doré du bouton était coupé.
- Redémarrer le jeu.

## 0.4.0 · 26/11/2026

- Fenêtre « Modules » : bouton « Réglages » sur la ligne d'un module qui a des réglages ; son panneau s'ouvre dans
  la même fenêtre, retour par « « Modules ».
- Les réglages s'appliquent tout de suite ; « Valeurs par défaut » remet tout à zéro.
- Nouveaux curseur et menu déroulant.
- Correction : le bouton rond du curseur était caché sous son liseré (on ne voyait qu'un trou).
- Redémarrer le jeu.

## 0.3.0 · 26/11/2026

- Fenêtre « Modules » : bouton « Recharger l'interface » quand un module attend un /reload pour être coupé.
- En combat, ce bouton est grisé et revient à la sortie du combat.
- Redémarrer le jeu.

## 0.2.0 · 26/11/2026

- Nouvelle fenêtre « Modules » : `/cui` l'ouvre, un interrupteur par module pour l'activer ou le couper.
- La fenêtre se déplace par sa barre de titre et garde sa place ; Échap la ferme.
- L'aide des commandes passe par `/cui aide`.
- Redémarrer le jeu.

## 0.1.1 · 26/11/2026

- CœurUI a maintenant son icône dans la liste des addons.
- Couleurs du thème accordées à celles de l'icône (or, rouge du cœur).
- Redémarrer le jeu.

## 0.1.0 · 26/11/2026

- Première version : CœurUI se charge et garde ses réglages d'une session à l'autre.
- Commande `/cui` : version, liste des modules, activer ou couper un module, remise à zéro.
- Un module coupé rend au jeu les réglages qu'il avait changés, même après une déconnexion.
- Un module activé ou coupé en combat l'est à la sortie du combat.
- Module « Essai » pour tester le noyau (sera retiré avant la publication).
- Redémarrer le jeu.
