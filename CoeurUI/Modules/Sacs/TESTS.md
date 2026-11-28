# Sacs et banque : tests en jeu

## 0.65.1 · utiliser un objet

1. Clic droit sur un parchemin, une potion, de la nourriture : l'objet est utilisé, aucune erreur
   (BugSack vide). Banque ouverte : clic droit range l'objet dans la banque.

## 0.56.0 · icônes carrées

1. Sacs et banque ouverts : chaque icône d'objet est carrée (plus de coins arrondis) ; clic, glisser,
   infobulle : comme avant.

## 0.29.0 · étape 1 : les sacs

**Avant de commencer** : couper ce qui, dans EllesmereUI (ou un autre addon), remplace les sacs.

1. **Redémarrer le jeu** (nouveaux fichiers). Aucune erreur Lua. `/cui version` : « 0.29.0 ».
2. `/cui` : carte « Sacs et banque » (coupée) ; l'activer (puis /reload si demandé).
3. Touche des sacs (B) : la fenêtre CœurUI s'ouvre, plus aucun sac du jeu ; B de nouveau : elle se ferme.
   Échap la ferme aussi. Clic sur le sac à dos ou un sac de la barre : même chose.
4. Par catégories : sections Équipement, Consommables, Composants d'artisanat, Quêtes, Divers, Camelote, Places
   libres ; seules celles qui ont des objets sont là.
5. Sac de composants (herbes...) ou carquois : à part en bas, avec son nom et « x libres sur y ».
6. Cases : liseré vert, bleu, violet selon la qualité (gris fin sinon) ; niveau d'objet en bas à gauche de
   l'équipement ; nombre en bas à droite ; camelote un peu éteinte.
7. Ramasser un objet : pastille rouge sur sa case ; la survoler : la pastille disparaît.
8. Clic droit : utiliser ou équiper ; glisser une case sur une autre ; Maj-clic : lien dans la discussion ;
   survol : infobulle de l'objet.
9. Potion ou pierre de foyer utilisée : le temps de recharge tourne sur la case.
10. Recherche : taper « potion » : le reste s'assombrit ; Échap dans le champ : tout revient.
11. Bas : sacs équipés (survol : infobulle ; cliquer pour le prendre, poser un sac dessus pour le mettre), places
    libres, argent (po, pa, pc colorés) qui suit les gains et dépenses.
12. Chez un marchand : la fenêtre s'ouvre toute seule ; vendre un objet (clic droit) marche.
13. Réglages : par catégories (coupé : une seule grille), sacs à part, cases par rangée, taille, espacement, niveau
    d'objet, liseré de qualité, pastille. Chacun s'applique tout de suite.
14. Cadenas : un cadre « Sacs » à placer ; la fenêtre grandit vers le haut et la gauche depuis son coin bas droit ;
    `/reload` : elle est restée.
14b. Glisser la barre de titre (« Sacs ») : la fenêtre suit la souris ; la lâcher : elle reste là, même après
    `/reload` ; la croix ne déclenche pas de déplacement.
14c. Bouton « tiroir » (à gauche de la croix) : les emplacements de sac en bas disparaissent, les places libres
    se décalent à gauche ; de nouveau : ils reviennent ; `/reload` : le choix est gardé. Survol : infobulle.
14d. Bouton « liste » (à gauche du tiroir) : clic : tout en vrac, une seule grille ; clic : retour aux catégories ;
    l'infobulle dit ce que fera le clic ; le réglage du panneau suit.
15. En combat : ouvrir les sacs et utiliser une potion marchent ; aucune erreur.
16. La banque (chez le banquier) : encore celle du jeu à cette étape, ses sacs s'ouvrent normalement.
17. Langue anglaise : « Bags », « EQUIPMENT », « 12g 34s 5c ».

## 0.30.0 · étape 2 : la camelote

1. /reload. `/cui version` : « 0.30.0 ». Réglages du module : section Camelote, menu « Vendre la camelote »
   (Bouton chez le marchand par défaut).
2. Avec des objets gris dans les sacs, ouvrir un marchand : bouton « Vendre · x pa y pc » à droite du titre
   CAMELOTE ; survol : infobulle. Sans marchand : pas de bouton.
3. Clic : les objets gris partent un par un ; dans la discussion « Camelote vendue : ... » ; l'argent monte
   d'autant ; le bouton disparaît. On peut les racheter dans l'onglet Rachat du marchand.
4. Fermer le marchand pendant la vente : elle s'arrête, aucune erreur.
5. En vrac (bouton liste) : le bouton est sur sa propre ligne au-dessus de la grille.
6. Réglage « Toute seule en ouvrant un marchand » : la camelote se vend dès l'ouverture, total dans la discussion.
7. Réglage « Jamais » : aucun bouton, rien n'est vendu.
8. Un objet gris sans valeur : il n'est pas vendu et ne compte pas.

## 0.31.0 · étape 3 : la banque

1. /reload. `/cui version` : « 0.31.0 ». Réglages du module : section Banque, « Banque au style de CœurUI » (actif).
2. Parler au banquier : la fenêtre « Banque » s'ouvre à gauche des sacs (les sacs s'ouvrent aussi) ; plus rien de
   la banque du jeu à l'écran, aucune zone invisible qui capte la souris.
3. Mêmes sections que les sacs (ou en vrac) ; cases au même style ; 48 cases de la page principale.
4. Clic droit sur un objet des sacs : il va dans la banque ; clic droit dans la banque : il revient dans les sacs.
   Glisser entre les deux fenêtres marche aussi. Survol : infobulle.
5. Recherche : taper « potion » dans l'une : les deux fenêtres filtrent ; Échap dans le champ : tout revient.
6. En bas : 8 emplacements à cadenas ; le tiroir de la banque les cache ou les montre sans toucher à ceux des
   sacs. Survol du premier cadenas : « Acheter un emplacement · 10 pa » ; clic : il se débloque ; poser un sac
   dessus : ses cases s'ajoutent à la banque ; « x places libres » suit. Tiroir coupé : bouton « Acheter un
   emplacement · 10 pa » à droite (grisé sans assez d'argent).
7. Croix de la banque, ou Échap : la banque se ferme, on quitte le banquier ; les sacs restent ouverts.
   S'éloigner du banquier : la fenêtre se ferme toute seule.
8. Glisser la barre de titre de la banque : elle bouge ; /reload : elle est restée. Cadenas : cadre « Banque ».
9. Les boutons liste et tiroir de chaque fenêtre ne changent qu'elle : banque en vrac, sacs par catégories, et
   l'inverse. Le réglage « Banque par catégories » du panneau suit le bouton liste de la banque.
10. Couper « Banque au style de CœurUI » puis reparler au banquier : la banque du jeu revient, normale.

## 0.47.0 · style « Givre »

1. `/reload`. Aucune erreur Lua. `/cui version` : « 0.47.0 ».
2. Ouvrir les sacs : fenêtre ardoise (teinte de la fenêtre de CœurUI), double liseré très discret, ombre douce ; titre
   « Sacs » un peu plus grand ; traits sombres sous le titre et au-dessus du bas ; recherche dans une case sombre.
3. Cases : fond sombre et double liseré ; objets verts, bleus, violets : liseré de leur couleur ; case vide : juste
   la case. Survol : liseré doré (ou couleur de la classe) par-dessus, qui part avec la souris.
4. Par catégories : « ÉQUIPEMENT · 5 », « PLACES LIBRES · 18 »... (nombre en gris sombre). Sacs à part : leur nom
   et « places libres » à droite, sans nombre ajouté.
5. Niveau d'objet en bas à gauche, à la couleur de la qualité (blanc pour un objet commun).
6. Emplacements de sac en bas (tiroir) : petites cases du même style ; banque : cadenas sur les emplacements à acheter.
7. Chez le banquier : la banque au même style, à gauche des sacs. Recherche commune, tri, vente de la camelote :
   comme avant.
