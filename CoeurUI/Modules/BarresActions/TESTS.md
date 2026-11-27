# Barres d'actions : tests en jeu

## 0.14.0 · étape 1 : barres 1 à 8

**Avant de commencer** : couper **EllesmereUIActionBars** dans la liste des addons (il remplace lui aussi les
barres du jeu). Le module ne dépend de rien chez EllesmereUI. Ne pas ouvrir le mode Édition du jeu pendant le test.

1. **Redémarrer le jeu** (nouveau fichier). Aucune erreur Lua. `/cui version` : « 0.14.0 ».
2. Activer « Barres d'actions ». Les barres du jeu disparaissent ; barres 1 et 2 en bas au centre, 3 et 4 en colonnes
   à droite. Carrés à liseré gris fin, icônes rognées, sans le cadre du jeu. Les sorts sont ceux des barres du jeu.
3. Raccourcis : chaque touche lance le sort de son bouton (barre 1 : 1 à =, et ceux des barres 2 à 4). La touche est
   écrite en petit en haut à droite.
4. Survol : liseré plus clair et infobulle du sort. Clic : lance le sort. Glisser un sort du grimoire sur un
   emplacement vide : il s'y pose ; glisser un sort hors de la barre : il s'enlève (hors combat).
5. Recharge : voile qui tourne avec les secondes. Hors de portée (cibler loin) : icône rouge. Sans assez de
   ressource : icône bleutée. Charges : nombre en bas à droite. Sort mis en avant (proc) : halo blanc.
6. Barre 1 qui change de page : forme du druide (ours, félin), furtivité du voleur, véhicule, Maj + molette ou
   Maj + 2 : les sorts de la page s'affichent et les raccourcis les lancent.
7. Page de réglages : menu « Barre ». Choisir Barre 3 : les réglages montrent ceux de la barre 3. Nombre 6, par
   rangée 3, sens Verticale : la vraie barre et l'aperçu changent (2 colonnes de 3). Taille, espacement : idem.
8. Visibilité : « Au survol seulement » : la barre disparaît, réapparaît quand la souris passe dessus ; l'opacité
   est grisée. « En combat seulement » : visible seulement en combat. « Jamais » : cachée, ses raccourcis
   reviennent aux boutons du jeu. Opacité 50 % : à moitié transparente hors survol.
9. Textes : couper Raccourci, Charges ; activer Nom des macros : la barre suit.
10. Réglage changé en combat : appliqué à la sortie du combat, sans message « action bloquée ».
11. Cadenas : chaque barre a son contour doré et son nom ; la glisser (grille aimantée). `/reload` : places gardées.
12. Barres 5 à 8 : cochées « Afficher cette barre » : elles apparaissent au centre, prêtes à être placées.
13. « Valeurs par défaut » : seule la barre choisie dans le menu revient à ses réglages d'origine.
14. Couper le module : « coupé au prochain /reload ». Après le rechargement : barres du jeu comme avant.
15. Langue anglaise : « Action bars », « Bar 1 (main) ».

## 0.15.0 · étape 2 : familier, postures, boutons spéciaux

1. **Redémarrer le jeu** (nouvelle texture). Aucune erreur Lua. `/cui version` : « 0.15.0 ».
2. Personnage avec postures ou formes (guerrier, druide, voleur...) : barre des postures au-dessus des barres, à
   gauche, en carrés sobres ; clic ou raccourci : change de posture ; la posture active est éclairée.
3. Personnage avec familier (chasseur, démoniste) : barre du familier au-dessus des barres, à droite ; attaque,
   suivre, sorts du familier ; auto-incantation visible. Renvoyer le familier : la barre disparaît ; le rappeler :
   elle revient. Les anciennes barres du jeu (familier, postures) ne s'affichent plus.
4. Page de réglages, menu « Barre » : Familier, Postures et formes : mêmes réglages que les barres (nombre jusqu'à
   10, sens, rangées, taille, visibilité, textes) ; la vraie barre suit.
5. Menu « Barre » : Bouton d'action en plus, Quitter le véhicule : seule la taille est active, le reste grisé (y
   compris les interrupteurs).
6. Bouton d'action en plus (quête ou combat qui en donne un) : il apparaît à sa place CœurUI, sans son décor du
   jeu, en carré sobre ; il marche (clic et raccourci).
7. Monter dans un véhicule (ou une monture à deux places en passager) : le carré « Quitter » (porte et flèche)
   apparaît ; survol : il s'éclaire ; clic : on descend. Hors véhicule : rien.
8. Cadenas : Familier, Postures et formes, Bouton d'action en plus, Quitter le véhicule ont leur contour doré et
   se placent (grille aimantée). `/reload` : places gardées.
9. Entrer en combat, appeler un familier en combat : rien ne casse ; s'il est mal placé, il se replace à la sortie
   du combat.
10. Personnage sans posture ni forme (mage, chasseur...) : le menu « Barre » ne propose pas « Postures et formes » ;
    au cadenas, pas d'étiquette « Postures et formes ». Personnage avec postures : les deux sont là.

## 0.16.0 · étape 3 : micro-menu et sacs

1. **Redémarrer le jeu** (nouvelles textures). Aucune erreur Lua. `/cui version` : « 0.16.0 ».
2. En bas à droite : le micro-menu en carrés sobres avec des icônes au trait grises (personnage, marteau, grimoire,
   bouclier, point d'exclamation, maison, étendard, deux personnes, coffre, livre ouvert, sac, trois traits...).
   Le micro-menu du jeu et ses sacs ont disparu de leur ancienne place.
3. Survol d'un bouton : icône blanche, liseré plus clair, infobulle du jeu. Clic : ouvre la fenêtre du jeu
   (personnage, grimoire, hauts faits...).
4. Sans guilde : l'étendard est gris sombre. Un nouveau talent à placer (ou autre alerte du jeu) : pastille rouge sur
   le bouton concerné.
5. Au-dessus : les sacs en carrés sobres (image du sac, sans bord de qualité) ; le sac à dos montre ses places libres.
   Clic : ouvre le sac. Glisser un sac dans un emplacement vide : il s'y équipe.
6. Menu « Barre » : Micro-menu et Sacs : rangées, sens, taille, espacement, visibilité, opacité actifs ; nombre de
   boutons et textes grisés. Ex. micro-menu « par rangée » 6 : deux rangées ; sens Verticale : une colonne.
7. Cadenas : « Micro-menu » et « Sacs » ont leur contour doré et se placent. `/reload` : places gardées.
8. Monter dans un véhicule puis en descendre : le micro-menu reste à sa place CœurUI (au pire, il y revient à la
   sortie du combat).
9. Minicarte coupée : l'œil de la file d'attente du jeu reste visible quand on est en file.
10. **Correction des erreurs de recharge** : combattre plusieurs minutes en lançant des sorts à recharge : aucune
    erreur « SetCooldown ... Secret values » ; les recharges tournent sur les boutons.
11. Barres 1 à 8 : les raccourcis lancent toujours les bons sorts ; la touche écrite sur le bouton est celle du jeu.
    Changer une touche dans les raccourcis du jeu : le bouton suit.
12. Barre 1 qui change de page (forme, furtivité, véhicule, Maj + 2) : les sorts de la page s'affichent tout de
    suite et les raccourcis les lancent.
13. Barres 5 à 8 : si l'une reste vide ou ne s'affiche pas, l'activer aussi dans les options du jeu (Interface >
    Barres d'action) et le dire à Claude.
14. Micro-menu : aucune erreur « Blizzard_MicroMenu ... GetEdgeButton » à la connexion, au /reload, en montant
    dans un véhicule ou en ouvrant le grimoire. Le fond et le bord du micro-menu du jeu ne se voient plus.
15. Micro-menu en visibilité « Jamais » : la barre disparaît et l'endroit ne réagit plus à la souris (pas d'infobulle
    ni de clic fantôme). Retour à « Toujours » : tout remarche.
16. Micro-menu : tous les carrés sur une seule rangée, même taille, même écart, sans chevauchement ni grand cadre
    derrière. Ouvrir puis fermer le grimoire, les talents, la carte : ils restent alignés (au pire, ils se
    réalignent en moins d'une seconde).
17. Micro-menu sur Forever : ni Logis ni Guide de l'aventurier (et rien d'invisible qui réagit à leur ancienne
    place). Couronne = Héritage (clic : la fenêtre d'héritage). Livre = Grimoire (clic : le grimoire). Étoile =
    Talents (grisée avant le niveau 10 ; ensuite clic : les talents). Point d'interrogation = assistance. Les
    boutons sont dans l'ordre du micro-menu du jeu.
18. Sacs (et barres, familier, postures) : chaque bouton a son fond sombre et son liseré gris fin bien visible, l'image
    du sac à l'intérieur ; survol : liseré plus clair.
19. Micro-menu : une seule étoile (Talents, à côté du livre du Grimoire) ; plus d'étoile en fin de barre. Infobulles :
    chaque bouton annonce la bonne touche (C personnage, P grimoire, N talents...) et la touche ouvre bien sa fenêtre.
20. Micro-menu : la couronne (Héritage) est juste après l'étoile (Talents), avant le point d'exclamation (Quêtes), et
    non plus en fin de barre ; clic : la fenêtre d'Héritage.
21. Plus aucun bouton seul à l'ancienne place du micro-menu (l'écusson de l'Héritage). La couronne est l'Héritage de
    Forever : juste après l'étoile des talents ; survol : infobulle « Héritage » ; clic : la fenêtre d'Héritage.
22. Portée : cible proche, aucun voile rouge ; s'éloigner : voile rouge sur les sorts hors de portée seulement ;
    revenir : le voile disparaît. Sans cible : aucun voile. Sans assez de ressource : icône bleutée (couleur du jeu),
    sans rouge.
23. Fenêtre CœurUI : « Barres d'actions » a une flèche ; clic : le tiroir s'ouvre sur Barres, Familier, Postures et
    formes (seulement avec postures), Bouton d'action en plus, Quitter le véhicule, Micro-menu, Sacs.
24. Page Barres : menu « Barre » (Barre 1 à Barre 8 seulement) et tous les réglages ; changer de barre relit la page.
    Page Familier : afficher, sens, taille, espacement (plus de nombre ni de rangées : 10 boutons sur une rangée),
    visibilité, raccourci, aperçu. Page Postures : avec nombre et rangées. Pages Bouton d'action en plus et
    Quitter le véhicule : la taille seulement. Pages Micro-menu et Sacs : sens, taille, espacement,
    visibilité, opacité (ni rangées ni aperçu : toujours une rangée). Aucun réglage grisé hors opacité en mode « au survol ».
25. « Valeurs par défaut » sur une page : seule cette page (ou la barre choisie, page Barres) revient à ses réglages.
26. Aucune page du tiroir « Barres d'actions » n'a d'aperçu ; chaque réglage change tout de suite la vraie barre.

## 0.21.0 · temps de recharge

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.21.0 ».
2. Lancer un sort avec un temps de recharge : sur son bouton, les secondes restantes en chiffres blancs (police
   CœurUI), par-dessus l'ombre tournante ; ils disparaissent à la fin de la recharge.
3. En combat : les chiffres s'affichent et descendent ; aucune erreur.
4. Page « Barres », barre 1 : couper « Temps de recharge (en secondes) » : plus de chiffres sur la barre 1, toujours
   sur les autres. Le remettre : ils reviennent.
5. Familier et Postures : même option dans leur page.
6. Couper l'option sur toutes les barres : l'option du jeu « nombres de recharge » revient comme avant. Couper le
   module et recharger : pareil.
7. Taille des boutons plus grande : les chiffres grandissent un peu.
8. Langue anglaise : « Cooldown timer (seconds) ».
9. Lancer un sort avec incantation depuis une barre : plus d'animation sur le bouton (ni remplissage, ni cercle) ;
   se faire interrompre : pas d'éclair rouge sur le bouton. Sort de zone au sol : pas d'animation de cible sur le
   bouton. La barre d'incantation, elle, s'affiche normalement.
