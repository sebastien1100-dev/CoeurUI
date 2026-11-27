# CœurUI : notes de version

La plus récente en premier. Phrases courtes, du point de vue du joueur.

## 0.38.0 · 27/11/2026

- Suivi des quêtes : réglage « Trier par zone, la mienne en premier » (actif d'office). Les quêtes suivies sont
  rangées zone par zone, dans l'ordre du journal, celles de la zone où tu te trouves en haut ; l'ordre suit quand
  tu changes de zone ou de quêtes (hors combat).
- Suivi des quêtes : il défile à la molette quand il y a plus de quêtes que sa hauteur (réglage « Faire défiler à
  la molette », actif d'office ; pas en combat). Avant, les quêtes en trop étaient cachées.
  Pendant le défilement, le titre de la section (« Quêtes »...) reste fixé en haut ; clic dessus : la replier.
  Le fond garde alors toute la hauteur du suivi et ne bouge pas : seule la liste glisse dedans.
- Suivi des quêtes : changer sa hauteur l'allonge vers le bas ; il grandissait vers le haut.
- Un /reload suffit.

## 0.37.0 · 27/11/2026

- Cadres d'unité : cadres de boss (page « Boss »). Jusqu'à 5 boss en colonne à droite de l'écran, au style de la
  cible, à la place de ceux du jeu ; vie en pourcentage, marqueur de raid, liseré blanc sur le boss ciblé.
- Barre d'incantation sous chaque boss (grise avec un cadenas si on ne peut pas l'interrompre) ; mes
  affaiblissements à gauche du cadre, avec leur durée.
- Cadenas ouvert : 5 boss d'exemple pour placer et régler les cadres.
- Soins à venir aussi sur les cadres du joueur, de la cible, de la cible de la cible et du familier (réglage dans
  « Général » de Cadres d'unité, actif d'office).
- Redémarrer le jeu (nouveau fichier).

## 0.36.0 · 27/11/2026

- Cadres de groupe : option « Familiers détachés ». Les familiers quittent le dessous de leur maître pour une
  colonne à part, placée librement avec le cadenas (cadre « Familiers du groupe »).
- Familiers sous leur maître : la place n'est plus gardée sous les équipiers qui n'en ont pas (hors combat ; en
  combat, quand le groupe change, le jeu range les cadres avec une place sous chacun jusqu'à la fin du combat).
- Un /reload suffit.

## 0.35.0 · 27/11/2026

- Cadres de groupe, troisième étape : les familiers. Un petit cadre (nom, vie) sous chaque équipier qui a un
  familier, toi compris ; clic : le cibler, clic droit : son menu. Réglage « Familiers des équipiers ».
- En colonne, la place d'un familier est gardée entre deux cadres. Le groupe de test montre ceux du chasseur et du
  démoniste.
- Un /reload suffit.

## 0.34.0 · 27/11/2026

- Cadres de groupe, deuxième étape : les effets (section « Effets » de la page « Groupe »).
- Soins à venir : la vie se prolonge en vert clair pendant qu'un soin arrive sur l'équipier.
- Mes soins sur la durée (liseré vert) et affaiblissements à dissiper (liseré de leur type : magie bleu,
  malédiction violet, poison vert, maladie brun), en petites icônes en bas à droite du cadre, avec leur durée.
- « Seulement ceux que ma classe dissipe » (actif d'office) ; nombre d'effets au plus et taille des effets.
- Place des affaiblissements et des soins sur la durée, chacun la sienne : un coin du cadre ou le centre
  (d'office : affaiblissements au centre, soins en bas à droite). Le nombre au plus vaut pour chaque sorte.
- Taille des icônes réglable à part pour les affaiblissements et pour les soins sur la durée.
- Un équipier qui a un affaiblissement à dissiper : le liseré de son cadre prend la couleur de l'affaiblissement
  (réglable, actif d'office), avec un trait de 1 point de cette couleur juste sous le contour et un léger voile sur le cadre.
- Correction : les soins à venir ne s'affichaient pas (barre accrochée avant que la barre de vie ait sa texture).
- Le groupe de test (cadenas ouvert) montre des effets d'exemple.
- Correction : erreur « Font not set » en ouvrant le cadenas (texte du nombre d'effets créé sans police).
- Fenêtre de CœurUI, page « Tous les modules » : cartes plus basses, toutes visibles sans défiler ; plus de lien
  « Réglages » : un clic sur la carte ouvre ses réglages (liseré plus clair au survol).
- Sacs : le sac de composants (emplacement à part, après les quatre sacs) est rangé à part en bas, comme les
  autres sacs de composants ; il se mêlait aux sacs ordinaires.
- Sacs et banque : bouton « Trier » dans la barre de titre de chacun (le tri du jeu).
- Redémarrer le jeu (nouvelle icône).

## 0.33.0 · 27/11/2026

- Cadres d'unité : cadres de groupe, première étape (page « Groupe »). Un cadre par membre, toi compris (réglable),
  au style du cadre du joueur, à la place de ceux du jeu.
- Colonne ou ligne, dans les quatre sens ; tri par rôle (tank, soigneur, dégâts), ordre du groupe, nom ou classe.
- Rôle en icône au trait, ressource, chef, marqueur de raid ; cadre pâli hors de portée ; « Mort », « Fantôme »,
  « Déconnecté » ; liseré blanc sur la cible, rouge sur qui a la menace.
- Cadenas ouvert : un groupe de test animé pour placer et régler les cadres, même seul.
- Correction : erreur à la création des cadres de groupe (« attempt to call a nil value »).
- Redémarrer le jeu (nouveaux fichiers).

## 0.32.0 · 27/11/2026

- Nouveau module « Bulles de discussion » (coupé d'office) : les bulles au-dessus des personnages au style des
  infobulles (fond sombre, liseré gris fin), avec une pointe au même style. Réglages : taille du texte, opacité du fond, couleur
  du texte selon le canal.
- Dans les donjons et les raids, le jeu verrouille les bulles : elles y restent les siennes.
- Couper le module demande un rechargement.
- Redémarrer le jeu (nouveau fichier).

## 0.31.0 · 27/11/2026

- Sacs et banque : la banque, dans le même style et le même rangement que les sacs, s'ouvre à gauche des sacs
  chez le banquier. Les sacs s'ouvrent avec elle.
- En bas de la banque : ses emplacements de sac débloqués (glisser un sac dessus) et « Acheter un emplacement »
  avec son prix.
- Recherche commune : taper dans l'une filtre les deux fenêtres. Le rangement (catégories ou vrac) et les
  emplacements affichés se règlent à part pour chaque fenêtre ; réglage « Banque par catégories » (section Banque).
- Fermer la banque (croix ou Échap) quitte le banquier ; les sacs restent ouverts. Elle se déplace en glissant sa
  barre de titre, ou au cadenas.
- Réglage « Banque au style de CœurUI » (section Banque) : coupé, on retrouve la banque du jeu.
- Le bouton tiroir de la banque affiche ses propres emplacements (il montrait ou cachait ceux des sacs) ; les
  emplacements encore verrouillés portent un cadenas, cliquer le premier l'achète (prix dans l'infobulle).
- Redémarrer le jeu (nouvelle icône).

## 0.30.0 · 27/11/2026

- Sacs : vente de la camelote. Chez un marchand, bouton « Vendre » avec le prix sur la section Camelote (en vrac :
  au-dessus de la grille) ; le total vendu s'écrit dans la discussion.
- Réglage « Vendre la camelote » : bouton chez le marchand, toute seule en ouvrant un marchand, ou jamais.
- Un /reload suffit.

## 0.29.0 · 27/11/2026

- Nouveau module « Sacs et banque » (coupé d'office), première étape : tous les sacs dans une seule fenêtre sobre,
  à la place de ceux du jeu, placée au cadenas.
- Rangement par catégories (équipement, consommables, composants, quêtes, divers, camelote, places libres) ou en
  vrac (réglage). Sacs de composants et carquois à part, en bas, avec leurs places libres.
- Cases au liseré de la couleur de la qualité, niveau d'objet sur l'équipement, pastille rouge sur les nouveaux
  objets jusqu'au survol.
- Recherche par nom ; en bas : sacs équipés (cliquer ou glisser pour les changer), places libres, argent.
- La fenêtre se déplace en glissant sa barre de titre (ou avec le cadenas) ; sa place est gardée.
- Places libres : carrés sombres au liseré à peine visible ; le dessin de sac vide du jeu (aile brune) ne
  s'affiche plus.
- Bouton dans la barre de titre des sacs pour passer du rangement par catégories au vrac, et retour.
  Redémarrer le jeu (nouvelle icône).
- Bouton « tiroir » dans la barre de titre : affiche ou cache les emplacements de sac en bas (choix gardé).
- Clics, glisser, infobulles et utilisation des objets : comme le jeu. Couper le module demande un rechargement.
- Redémarrer le jeu (nouveaux fichiers).

## 0.28.0 · 27/11/2026

- Plaques de nom : nouvelle page « Amis ». Les plaques des PNJ et joueurs alliés montrent le nom seul, vert pour un
  PNJ, couleur de classe pour un joueur ; une barre fine apparaît quand l'allié est blessé.
- En donjon et en raid, le jeu garde les plaques amies pour lui : elles restent les siennes.
- Réglages : habiller ou non, barre quand l'allié est blessé, niveau devant le nom des joueurs (coupé d'office), taille du nom,
  largeur et hauteur de la barre.

## 0.27.0 · 27/11/2026

- Plaques de nom : l'incantation des ennemis sous leur barre de vie, avec le nom du sort et le temps restant. Bleu
  acier (vert pour une canalisation) ; grise avec un petit cadenas si on ne peut pas l'interrompre ; rouge un instant
  quand elle est interrompue.
- Réglages : afficher ou non, hauteur.
- Plaques de nom : l'avancement d'une quête se lit comme dans le journal (« 0/8 » au début, « 5/8 » ensuite) ; il
  affichait ce qu'il restait à faire, à l'envers du journal.
- Plaques de nom : en groupe, les monstres de vos quêtes sont de nouveau signalés (le « ! » disparaissait dès qu'on
  était en groupe).

## 0.26.0 · 27/11/2026

- Plaques de nom : vos affaiblissements au-dessus du nom des ennemis, en petits carrés au liseré gris fin, temps
  restant dessous. Ils avaient disparu avec la première étape (les icônes du jeu étaient cachées avec sa plaque).
- Réglages : afficher ou non, taille, nombre au plus.
- Plaques de nom : les marqueurs de raid (crâne, croix...) reviennent, à droite de la barre. Ils avaient disparu avec
  la première étape.

## 0.25.0 · 27/11/2026

- Nouveau module « Plaques de nom » (coupé d'office), première étape : les plaques ennemies au style de CœurUI.
  Barre de vie fine, liseré gris fin, nom au-dessus avec le niveau en petit gris devant (« 35+ » pour une élite),
  pourcentage de vie dans la barre.
- Couleur d'attitude (hostile rouge, neutre jaune, gris si le monstre est pris par un autre), couleur de classe pour
  un joueur adverse.
- La plaque de la cible est plus grande (125 %, réglable).
- Menace sur le liseré : orange quand ça bascule, rouge cœur quand il y a danger (selon le rôle, pris de la
  spécialisation ou réglé).
- Monstre de quête : nom en jaune, « ! » jaune à gauche, ce qu'il reste à faire dessous.
- Les plaques amies restent celles du jeu pour l'instant. Couper le module demande un rechargement.
- Redémarrer le jeu (nouveau fichier).

## 0.24.0 · 27/11/2026

- Barres d'actions : nouvelle page « Expérience et réputation ». Deux barres fines au style de CœurUI à la place de
  celles du jeu, chacune avec son propre cadre au cadenas.
- Expérience en violet, puis en jaune celle des quêtes terminées à rendre, puis le bonus de repos en bleu.
  « +1 niveau » s'affiche à droite quand les quêtes à rendre font passer un niveau.
- Réputation suivie dans la couleur de son rang. Clic dessus : la page des réputations.
- Texte au-dessus des barres au survol (ou toujours, ou jamais), infobulle avec le détail.
- Réglages : largeur et hauteur de chaque barre, taille du texte, quêtes à rendre, repos, infobulle.
- Redémarrer le jeu (nouveau fichier).

## 0.23.0 · 27/11/2026

- Nouveau module « Effets » (coupé d'office) : les améliorations et affaiblissements du joueur en carrés sobres
  (icône rognée, liseré gris fin), le temps restant dessous en petit gris clair (blanc sous 10 secondes), le nombre
  d'applications en bas à droite.
- Affaiblissements avec un liseré de la couleur de leur type (magie, malédiction, poison, maladie).
- Améliorations et affaiblissements indépendants : chacun son cadre au cadenas et sa page de réglages (taille, par
  rangée, rangées au plus, espacement, sens, textes).
- Changer la taille des effets ne déplace pas le groupe : il reste collé du côté d'où partent les icônes.
- Clic droit pour annuler une amélioration et infobulles : comme le jeu. Couper le module demande un rechargement.
- Redémarrer le jeu (nouveau fichier).

## 0.22.0 · 27/11/2026

- Nouveau module « Discussion » (coupé d'office) : la discussion du jeu au style sobre de CœurUI. Fond sombre
  léger réglable, liseré gris fin ; onglets en petites capitales grises, l'onglet ouvert en blanc souligné ; pastille
  rouge sur un onglet qui reçoit un message.
- Canaux raccourcis ([G], [Gr], [R], [1. Général] au lieu de [1. Général - zone]), heure en gris discret (aucune, 21:05 ou 21:05:42), noms en couleur de
  classe.
- Liens web soulignés : un clic ouvre une petite fenêtre avec l'adresse prête à copier (Ctrl+C).
- Boutons du jeu autour de la discussion retirés ; au survol, deux petits pictos : « Copier la discussion » (les
  derniers messages en texte, prêts à copier) et « Descendre en bas ».
- Vieux messages effacés au bout d'un temps réglable ; ils reviennent au survol.
- Placée avec le cadenas ; largeur, hauteur, taille du texte réglables. Couper le module demande un rechargement.
- La fenêtre « Lien Wowhead » du suivi des quêtes est maintenant celle du noyau (même aspect).
- Redémarrer le jeu (nouveaux fichiers).

## 0.21.0 · 27/11/2026

- Barres d'actions : le temps de recharge des sorts s'affiche en secondes sur les boutons (police de CœurUI). Option
  « Temps de recharge (en secondes) » dans les textes de chaque barre, du familier et des postures (activée d'office).
- Les chiffres sont ceux du jeu (son option « nombres de recharge », mise en marche par CœurUI tant qu'une barre les
  demande, rendue quand plus aucune n'en veut ou quand le module est coupé). Ils peuvent aussi apparaître sur
  d'autres recharges du jeu (objets des sacs...).
- Barres d'actions : plus d'animation d'incantation sur les boutons (remplissage pendant le sort, éclair rouge
  d'interruption, cible au sol) ; l'incantation se lit sur la barre d'incantation.
- Un /reload suffit.

## 0.20.0 · 27/11/2026

- Cadres d'unité : nouvelle barre d'incantation de la cible, sous son cadre et à sa largeur, comme celle du joueur.
  Bleue quand on peut interrompre le sort, grise avec un petit cadenas quand on ne peut pas ; verte pour une
  canalisation ; rouge « Interrompu » quand le sort est coupé. Pas de zone de latence.
- Elle suit la cible : changer de cible montre tout de suite le sort que la nouvelle cible incante.
- Option « Détacher du cadre » : placée seule avec le cadenas (au centre de l'écran par défaut), à sa propre largeur.
- Réglages dans la page « Cible », section « Barre d'incantation », sans aperçu.
- Si le jeu cache le temps du sort de la cible en combat : la barre avance sans chiffres (ou reste pleine).
- Le cadre de la cible de la cible suit maintenant le cadre de la cible : juste dessous, ou sous sa barre
  d'incantation quand elle y est attachée. Sa place est remise à zéro une fois : le replacer avec le cadenas si besoin.
- Un /reload suffit.

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
